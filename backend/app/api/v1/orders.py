import uuid
from datetime import datetime
from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session
from app.api.deps import get_db
from app.core.config import get_settings
from app.models.order import Order, PaymentStatus, FulfillmentStatus
from app.models.post import Post, PostStatus
from app.models.artisan import Artisan
from app.schemas.order import InstantCheckoutRequest, OrderResponse
from app.services.inventory_service import InventoryService
from app.services.payment_gateway import get_payment_gateway

settings = get_settings()
router = APIRouter(prefix="/orders", tags=["Instant Checkout & Orders"])


@router.post("/instant-checkout", response_model=OrderResponse, status_code=status.HTTP_201_CREATED)
def instant_checkout(payload: InstantCheckoutRequest, db: Session = Depends(get_db)):
    """
    Bypasses traditional cart. Executes single-click instant checkout for an artisan item:
    1. Validates and reserves stock.
    2. Atomically decrements inventory (automatically transitions post to SOLD_OUT if inventory hits 0).
    3. Calculates platform commission & artisan payout amount.
    4. Interacts with payment gateway (Mock, Razorpay, Stripe).
    5. Returns finalized order confirmation receipt.
    """
    # 1. Fetch and validate product post
    post = db.query(Post).filter(Post.id == payload.post_id).first()
    if not post:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Product post #{payload.post_id} not found."
        )

    if post.status == PostStatus.SOLD_OUT.value or post.stock_quantity <= 0:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=f"Apologies! '{post.title}' is completely SOLD OUT."
        )

    if post.stock_quantity < payload.quantity:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Only {post.stock_quantity} pieces available, requested {payload.quantity}."
        )

    # 2. Financial calculation
    unit_price = post.price
    total_amount = round(unit_price * payload.quantity, 2)
    platform_fee = round(total_amount * (settings.PLATFORM_FEE_PERCENTAGE / 100.0), 2)
    net_artisan_amount = round(total_amount - platform_fee, 2)

    order_number = f"ORD-{datetime.utcnow().strftime('%Y%m%d')}-{uuid.uuid4().hex[:6].upper()}"

    # 3. Decrement stock atomically (and auto-toggle SOLD_OUT)
    InventoryService.decrement_stock_and_toggle_sold_out(
        db=db,
        post_id=post.id,
        quantity=payload.quantity
    )

    # 4. Process payment through pluggable gateway
    gateway = get_payment_gateway()
    payment_method = payload.payment_method.upper()
    payment_status = PaymentStatus.PENDING.value
    payment_id = None

    if payment_method in ("MOCK", "UPI", "DIRECT"):
        # Instant mock payment succeeds
        payment_status = PaymentStatus.PAID.value
        payment_id = f"pay_mock_{uuid.uuid4().hex[:12]}"
    elif payment_method == "RAZORPAY":
        gateway_resp = gateway.create_order(
            amount=total_amount,
            currency=post.currency,
            receipt=order_number,
            notes={"buyer_phone": payload.buyer_phone}
        )
        payment_id = gateway_resp.get("gateway_order_id")
        payment_status = PaymentStatus.PAID.value  # Mocked as instant approval in test mode
    elif payment_method == "STRIPE":
        gateway_resp = gateway.create_order(
            amount=total_amount,
            currency=post.currency,
            receipt=order_number
        )
        payment_id = gateway_resp.get("gateway_order_id")
        payment_status = PaymentStatus.PAID.value

    # 5. Persist order
    order = Order(
        order_number=order_number,
        post_id=post.id,
        artisan_id=post.artisan_id,
        quantity=payload.quantity,
        unit_price=unit_price,
        total_amount=total_amount,
        platform_fee=platform_fee,
        net_artisan_amount=net_artisan_amount,
        currency=post.currency,
        buyer_name=payload.buyer_name,
        buyer_phone=payload.buyer_phone,
        buyer_email=payload.buyer_email,
        shipping_address=payload.shipping_address,
        shipping_city=payload.shipping_city,
        shipping_state=payload.shipping_state,
        shipping_pincode=payload.shipping_pincode,
        payment_status=payment_status,
        payment_method=payment_method,
        payment_id=payment_id,
        fulfillment_status=FulfillmentStatus.PROCESSING.value
    )
    db.add(order)
    db.commit()
    db.refresh(order)

    # Enrich response for immediate slide-up confirmation sheet
    resp = OrderResponse.model_validate(order)
    resp.item_title = post.title
    resp.artisan_name = post.artisan.name if post.artisan else None
    resp.shg_name = post.artisan.shg_name if post.artisan else None
    return resp


@router.get("/{order_id}", response_model=OrderResponse)
def get_order_by_id(order_id: int, db: Session = Depends(get_db)):
    """
    Retrieve order details and delivery status by ID.
    """
    order = db.query(Order).filter(Order.id == order_id).first()
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")
    
    resp = OrderResponse.model_validate(order)
    if order.post:
        resp.item_title = order.post.title
    if order.artisan:
        resp.artisan_name = order.artisan.name
        resp.shg_name = order.artisan.shg_name
    return resp


@router.patch("/{order_id}/fulfillment", response_model=OrderResponse)
def update_fulfillment_status(
    order_id: int,
    fulfillment_status: str = Query(..., pattern="^(PROCESSING|DISPATCHED|DELIVERED|CANCELLED)$"),
    db: Session = Depends(get_db)
):
    """
    Artisans can mark orders as DISPATCHED or DELIVERED from their seller dashboard.
    """
    order = db.query(Order).filter(Order.id == order_id).first()
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")

    order.fulfillment_status = fulfillment_status
    db.commit()
    db.refresh(order)

    resp = OrderResponse.model_validate(order)
    if order.post:
        resp.item_title = order.post.title
    return resp
