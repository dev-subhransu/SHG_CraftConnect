from datetime import datetime
from typing import Optional
from pydantic import BaseModel, ConfigDict, Field, EmailStr


class InstantCheckoutRequest(BaseModel):
    """
    Direct single-item instant checkout payload bypassing the cart.
    """
    post_id: int
    quantity: int = Field(default=1, ge=1)
    
    # Shipping info
    buyer_name: str = Field(..., min_length=2, max_length=120)
    buyer_phone: str = Field(..., min_length=10, max_length=15)
    buyer_email: Optional[str] = None
    shipping_address: str = Field(..., min_length=5)
    shipping_city: str = Field(..., min_length=2)
    shipping_state: str = Field(..., min_length=2)
    shipping_pincode: str = Field(..., min_length=4, max_length=10)
    
    # Payment selection (e.g. MOCK, RAZORPAY, STRIPE, UPI)
    payment_method: str = Field(default="MOCK")


class OrderResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    order_number: str
    post_id: Optional[int]
    artisan_id: int
    quantity: int
    unit_price: float
    total_amount: float
    platform_fee: float
    net_artisan_amount: float
    currency: str
    
    buyer_name: str
    buyer_phone: str
    buyer_email: Optional[str] = None
    shipping_address: str
    shipping_city: str
    shipping_state: str
    shipping_pincode: str
    
    payment_status: str
    payment_method: str
    payment_id: Optional[str] = None
    fulfillment_status: str
    
    created_at: datetime
    updated_at: datetime

    # Additional contextual fields for checkout receipt UI
    item_title: Optional[str] = None
    artisan_name: Optional[str] = None
    shg_name: Optional[str] = None
