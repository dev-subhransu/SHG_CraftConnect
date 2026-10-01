from datetime import datetime
from typing import Optional, List
from pydantic import BaseModel, ConfigDict
from app.schemas.order import OrderResponse


class PayoutResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    artisan_id: int
    amount: float
    currency: str
    status: str
    reference_id: Optional[str] = None
    notes: Optional[str] = None
    created_at: datetime
    processed_at: Optional[datetime] = None


class SellerLedgerSummary(BaseModel):
    artisan_id: int
    artisan_name: str
    shg_name: str
    
    # Financial metrics
    total_sales_gross: float
    platform_fees_deducted: float
    net_earnings: float
    total_payouts_completed: float
    pending_payout_balance: float
    
    # Operational metrics
    total_orders_count: int
    active_orders_count: int
    completed_orders_count: int
    total_products_count: int
    available_products_count: int
    sold_out_products_count: int
    
    # Recent items
    recent_orders: List[OrderResponse] = []
    recent_payouts: List[PayoutResponse] = []
