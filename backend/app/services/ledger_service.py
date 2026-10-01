from datetime import datetime
from typing import Optional
from sqlalchemy.orm import Session
from sqlalchemy import func
from fastapi import HTTPException, status
from app.models.artisan import Artisan
from app.models.order import Order, PaymentStatus, FulfillmentStatus
from app.models.post import Post, PostStatus
from app.models.payout import Payout, PayoutStatus
from app.schemas.payout import SellerLedgerSummary, PayoutResponse
from app.schemas.order import OrderResponse


class LedgerService:
    """
    Computes real-time artisan financial ledger, sales summaries,
    disbursement tracking, and payout balances.
    """

    @staticmethod
    def get_artisan_ledger_summary(db: Session, artisan_id: int) -> SellerLedgerSummary:
        artisan = db.query(Artisan).filter(Artisan.id == artisan_id).first()
        if not artisan:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Artisan #{artisan_id} not found."
            )

        # Query paid orders
        paid_orders = db.query(Order).filter(
            Order.artisan_id == artisan_id,
            Order.payment_status == PaymentStatus.PAID.value
        ).all()

        total_sales_gross = sum(order.total_amount for order in paid_orders)
        platform_fees_deducted = sum(order.platform_fee for order in paid_orders)
        net_earnings = sum(order.net_artisan_amount for order in paid_orders)

        # Query completed payouts
        completed_payouts = db.query(Payout).filter(
            Payout.artisan_id == artisan_id,
            Payout.status == PayoutStatus.PROCESSED.value
        ).all()
        total_payouts_completed = sum(payout.amount for payout in completed_payouts)

        pending_payout_balance = max(0.0, net_earnings - total_payouts_completed)

        # Operational metrics
        all_orders = db.query(Order).filter(Order.artisan_id == artisan_id).order_by(Order.created_at.desc()).all()
        total_orders_count = len(all_orders)
        active_orders_count = len([o for o in all_orders if o.fulfillment_status in (FulfillmentStatus.PROCESSING.value, FulfillmentStatus.DISPATCHED.value)])
        completed_orders_count = len([o for o in all_orders if o.fulfillment_status == FulfillmentStatus.DELIVERED.value])

        # Inventory metrics
        all_posts = db.query(Post).filter(Post.artisan_id == artisan_id).all()
        total_products_count = len(all_posts)
        available_products_count = len([p for p in all_posts if p.status == PostStatus.AVAILABLE.value and p.stock_quantity > 0])
        sold_out_products_count = len([p for p in all_posts if p.status == PostStatus.SOLD_OUT.value or p.stock_quantity == 0])

        recent_orders_resp = []
        for o in all_orders[:15]:
            resp = OrderResponse.model_validate(o)
            resp.item_title = o.post.title if o.post else "Craft Product"
            resp.artisan_name = artisan.name
            resp.shg_name = artisan.shg_name
            recent_orders_resp.append(resp)

        recent_payouts_resp = [
            PayoutResponse.model_validate(p)
            for p in db.query(Payout).filter(Payout.artisan_id == artisan_id).order_by(Payout.created_at.desc()).limit(10).all()
        ]

        return SellerLedgerSummary(
            artisan_id=artisan.id,
            artisan_name=artisan.name,
            shg_name=artisan.shg_name,
            total_sales_gross=round(total_sales_gross, 2),
            platform_fees_deducted=round(platform_fees_deducted, 2),
            net_earnings=round(net_earnings, 2),
            total_payouts_completed=round(total_payouts_completed, 2),
            pending_payout_balance=round(pending_payout_balance, 2),
            total_orders_count=total_orders_count,
            active_orders_count=active_orders_count,
            completed_orders_count=completed_orders_count,
            total_products_count=total_products_count,
            available_products_count=available_products_count,
            sold_out_products_count=sold_out_products_count,
            recent_orders=recent_orders_resp,
            recent_payouts=recent_payouts_resp
        )

    @staticmethod
    def create_payout(db: Session, artisan_id: int, amount: float, notes: Optional[str] = None) -> Payout:
        artisan = db.query(Artisan).filter(Artisan.id == artisan_id).first()
        if not artisan:
            raise HTTPException(status_code=404, detail="Artisan not found")

        import uuid
        payout = Payout(
            artisan_id=artisan_id,
            amount=amount,
            status=PayoutStatus.PROCESSED.value,
            reference_id=f"UTR_{datetime.utcnow().strftime('%Y%m%d')}_{uuid.uuid4().hex[:8].upper()}",
            notes=notes or "Automated weekly direct SHG bank transfer",
            processed_at=datetime.utcnow()
        )
        db.add(payout)
        db.commit()
        db.refresh(payout)
        return payout
