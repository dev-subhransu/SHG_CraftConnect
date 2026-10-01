from datetime import datetime
from enum import Enum
from sqlalchemy import Column, Integer, String, Float, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from app.core.database import Base


class PayoutStatus(str, Enum):
    PENDING = "PENDING"
    PROCESSED = "PROCESSED"
    FAILED = "FAILED"


class Payout(Base):
    __tablename__ = "payouts"

    id = Column(Integer, primary_key=True, index=True)
    artisan_id = Column(Integer, ForeignKey("artisans.id", ondelete="CASCADE"), nullable=False, index=True)
    
    amount = Column(Float, nullable=False)
    currency = Column(String(10), default="INR")
    status = Column(String(20), default=PayoutStatus.PENDING.value, index=True)
    
    reference_id = Column(String(100), nullable=True)  # Bank UTR / Razorpay Payout ID
    notes = Column(String(250), nullable=True)
    
    created_at = Column(DateTime, default=datetime.utcnow, index=True)
    processed_at = Column(DateTime, nullable=True)

    # Relationships
    artisan = relationship("Artisan", back_populates="payouts")
