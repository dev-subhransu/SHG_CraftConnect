from datetime import datetime
from typing import Optional
from pydantic import BaseModel, ConfigDict


class ArtisanBase(BaseModel):
    name: str
    shg_name: str
    craft_type: str
    location: str
    avatar_url: Optional[str] = None
    bio: Optional[str] = None
    phone: Optional[str] = None


class ArtisanCreate(ArtisanBase):
    bank_account_number: Optional[str] = None
    bank_ifsc: Optional[str] = None


class ArtisanResponse(ArtisanBase):
    model_config = ConfigDict(from_attributes=True)

    id: int
    is_verified: bool
    created_at: datetime


class ArtisanSummary(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    name: str
    shg_name: str
    craft_type: str
    location: str
    avatar_url: Optional[str] = None
    is_verified: bool
