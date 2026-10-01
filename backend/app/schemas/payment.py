from typing import Optional, Dict, Any
from pydantic import BaseModel


class PaymentInitiateRequest(BaseModel):
    order_id: int
    gateway: str = "mock"  # mock, razorpay, stripe


class PaymentInitiateResponse(BaseModel):
    order_id: int
    order_number: str
    amount: float
    currency: str
    gateway: str
    gateway_order_id: Optional[str] = None
    client_secret: Optional[str] = None
    public_key: Optional[str] = None
    additional_data: Dict[str, Any] = {}


class PaymentVerificationRequest(BaseModel):
    order_id: int
    gateway: str
    payment_id: str
    gateway_signature: Optional[str] = None
    gateway_order_id: Optional[str] = None


class PaymentVerificationResponse(BaseModel):
    success: bool
    order_id: int
    order_number: str
    payment_status: str
    message: str
