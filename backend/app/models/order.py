from datetime import datetime
from enum import Enum
from sqlalchemy import Column, Integer, String, Text, Float, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from app.core.database import Base


class PaymentStatus(str, Enum):
    PENDING = "PENDING"
    PAID = "PAID"
    FAILED = "FAILED"
    REFUNDED = "REFUNDED"


class FulfillmentStatus(str, Enum):
    PROCESSING = "PROCESSING"
    DISPATCHED = "DISPATCHED"
    DELIVERED = "DELIVERED"
    CANCELLED = "CANCELLED"


class Order(Base):
    __tablename__ = "orders"

    id = Column(Integer, primary_key=True, index=True)
    order_number = Column(String(50), unique=True, index=True, nullable=False)
    
    post_id = Column(Integer, ForeignKey("posts.id", ondelete="SET NULL"), nullable=True, index=True)
    artisan_id = Column(Integer, ForeignKey("artisans.id", ondelete="CASCADE"), nullable=False, index=True)
    
    quantity = Column(Integer, default=1, nullable=False)
    unit_price = Column(Float, nullable=False)
    total_amount = Column(Float, nullable=False)
    platform_fee = Column(Float, default=0.0)
    net_artisan_amount = Column(Float, nullable=False)
    currency = Column(String(10), default="INR")
    
    # Buyer shipping info
    buyer_name = Column(String(120), nullable=False)
    buyer_phone = Column(String(20), nullable=False)
    buyer_email = Column(String(120), nullable=True)
    shipping_address = Column(Text, nullable=False)
    shipping_city = Column(String(80), nullable=False)
    shipping_state = Column(String(80), nullable=False)
    shipping_pincode = Column(String(20), nullable=False)
    
    # Payment lifecycle
    payment_status = Column(String(20), default=PaymentStatus.PENDING.value, index=True)
    payment_method = Column(String(30), default="MOCK")  # MOCK, RAZORPAY, STRIPE, UPI
    payment_id = Column(String(100), nullable=True)
    
    fulfillment_status = Column(String(20), default=FulfillmentStatus.PROCESSING.value, index=True)
    
    created_at = Column(DateTime, default=datetime.utcnow, index=True)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relationships
    post = relationship("Post", back_populates="orders")
    artisan = relationship("Artisan", back_populates="orders")
