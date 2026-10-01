from datetime import datetime
from enum import Enum
from sqlalchemy import Column, Integer, String, Text, Float, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from app.core.database import Base


class PostStatus(str, Enum):
    AVAILABLE = "AVAILABLE"
    SOLD_OUT = "SOLD_OUT"


class MediaType(str, Enum):
    IMAGE = "image"
    VIDEO = "video"


class Post(Base):
    __tablename__ = "posts"

    id = Column(Integer, primary_key=True, index=True)
    artisan_id = Column(Integer, ForeignKey("artisans.id", ondelete="CASCADE"), nullable=False, index=True)
    
    title = Column(String(200), nullable=False)
    description = Column(Text, nullable=False)
    craft_story = Column(Text, nullable=True)  # Context about handloom, raw materials, heritage
    
    media_url = Column(String(500), nullable=False)
    media_type = Column(String(20), default=MediaType.IMAGE.value)
    thumbnail_url = Column(String(500), nullable=True)
    
    price = Column(Float, nullable=False)
    currency = Column(String(10), default="INR")
    stock_quantity = Column(Integer, default=1, nullable=False)
    status = Column(String(20), default=PostStatus.AVAILABLE.value, index=True)
    
    likes_count = Column(Integer, default=0)
    views_count = Column(Integer, default=0)
    
    created_at = Column(DateTime, default=datetime.utcnow, index=True)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relationships
    artisan = relationship("Artisan", back_populates="posts")
    orders = relationship("Order", back_populates="post")
