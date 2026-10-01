from datetime import datetime
from typing import Optional
from pydantic import BaseModel, ConfigDict, Field
from app.schemas.artisan import ArtisanSummary


class PostBase(BaseModel):
    title: str = Field(..., max_length=200)
    description: str
    craft_story: Optional[str] = None
    media_url: str
    media_type: str = "image"
    thumbnail_url: Optional[str] = None
    price: float = Field(..., gt=0)
    currency: str = "INR"
    stock_quantity: int = Field(default=1, ge=0)


class PostCreate(PostBase):
    artisan_id: int


class PostUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    craft_story: Optional[str] = None
    media_url: Optional[str] = None
    media_type: Optional[str] = None
    thumbnail_url: Optional[str] = None
    price: Optional[float] = Field(default=None, gt=0)
    stock_quantity: Optional[int] = Field(default=None, ge=0)
    status: Optional[str] = None


class PostResponse(PostBase):
    model_config = ConfigDict(from_attributes=True)

    id: int
    artisan_id: int
    status: str
    likes_count: int
    views_count: int
    created_at: datetime
    updated_at: datetime


class PostFeedItem(PostResponse):
    """
    Rich discovery feed post object with embedded artisan and SHG context.
    """
    model_config = ConfigDict(from_attributes=True)

    artisan: ArtisanSummary
