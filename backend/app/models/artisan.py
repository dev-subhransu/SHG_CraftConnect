from datetime import datetime
from sqlalchemy import Column, Integer, String, Text, Boolean, DateTime
from sqlalchemy.orm import relationship
from app.core.database import Base


class Artisan(Base):
    __tablename__ = "artisans"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(120), nullable=False)
    shg_name = Column(String(150), nullable=False)
    craft_type = Column(String(100), nullable=False)
    location = Column(String(150), nullable=False)
    avatar_url = Column(String(500), nullable=True)
    bio = Column(Text, nullable=True)
    phone = Column(String(20), nullable=True)
    bank_account_number = Column(String(30), nullable=True)
    bank_ifsc = Column(String(20), nullable=True)
    is_verified = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.utcnow)

    # Relationships
    posts = relationship("Post", back_populates="artisan", cascade="all, delete-orphan")
    orders = relationship("Order", back_populates="artisan")
    payouts = relationship("Payout", back_populates="artisan")
