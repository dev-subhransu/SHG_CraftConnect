from fastapi import APIRouter, Depends, HTTPException, Request, status
from sqlalchemy.orm import Session
from app.api.deps import get_db
from app.core.config import get_settings
from app.models.order import Order, PaymentStatus
from app.schemas.payment import (
    PaymentInitiateRequest,
    PaymentInitiateResponse,
    PaymentVerificationRequest,
    PaymentVerificationResponse
)
from app.services.payment_gateway import get_payment_gateway

settings = get_settings()
router = APIRouter(prefix="/payments", tags=["Payment Gateway Integration"])


@router.post("/initiate", response_model=PaymentInitiateResponse)
def initiate_payment(payload: PaymentInitiateRequest, db: Session = Depends(get_db)):
    """
    Initiate payment with the selected gateway (Mock, Razorpay, Stripe).
    Returns order token, client secret, or mock verification payload.
    """
    order = db.query(Order).filter(Order.id == payload.order_id).first()
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")

    gateway = get_payment_gateway(payload.gateway)
    gateway_data = gateway.create_order(
        amount=order.total_amount,
        currency=order.currency,
        receipt=order.order_number,
        notes={"buyer_phone": order.buyer_phone}
    )

    return PaymentInitiateResponse(
        order_id=order.id,
        order_number=order.order_number,
        amount=order.total_amount,
        currency=order.currency,
        gateway=payload.gateway,
        gateway_order_id=gateway_data.get("gateway_order_id"),
        client_secret=gateway_data.get("client_secret"),
        public_key=gateway_data.get("public_key"),
        additional_data=gateway_data.get("additional_data", {})
    )


@router.post("/verify", response_model=PaymentVerificationResponse)
def verify_payment(payload: PaymentVerificationRequest, db: Session = Depends(get_db)):
    """
    Verify payment signature from client SDKs (Razorpay checkout or Stripe confirmCardPayment).
    """
    order = db.query(Order).filter(Order.id == payload.order_id).first()
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")

    gateway = get_payment_gateway(payload.gateway)
    is_valid = gateway.verify_payment(payload.model_dump())

    if is_valid:
        order.payment_status = PaymentStatus.PAID.value
        order.payment_id = payload.payment_id
        db.commit()
        return PaymentVerificationResponse(
            success=True,
            order_id=order.id,
            order_number=order.order_number,
            payment_status=order.payment_status,
            message="Payment successfully verified. Artisan notified for order fulfillment."
        )
    else:
        order.payment_status = PaymentStatus.FAILED.value
        db.commit()
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Payment verification failed: invalid signature or authorization."
        )


@router.post("/webhook")
async def payment_webhook(request: Request, db: Session = Depends(get_db)):
    """
    Asynchronous payment status webhook handler for Razorpay / Stripe.
    """
    payload = await request.json()
    # In production, verify gateway signature header here
    event_type = payload.get("event") or payload.get("type", "unknown")
    return {"status": "received", "event": event_type}
