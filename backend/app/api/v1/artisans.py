from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session
from app.api.deps import get_db
from app.models.artisan import Artisan
from app.models.post import Post
from app.models.order import Order
from app.schemas.artisan import ArtisanResponse, ArtisanCreate, ArtisanSummary
from app.schemas.post import PostResponse
from app.schemas.order import OrderResponse
from app.schemas.payout import SellerLedgerSummary, PayoutResponse
from app.services.ledger_service import LedgerService

router = APIRouter(prefix="/artisans", tags=["Artisans & Seller Dashboard"])


@router.get("", response_model=List[ArtisanSummary])
def list_artisans(db: Session = Depends(get_db)):
    """
    List registered Self Help Groups and artisans.
    """
    return db.query(Artisan).all()


@router.get("/{artisan_id}", response_model=ArtisanResponse)
def get_artisan_profile(artisan_id: int, db: Session = Depends(get_db)):
    """
    Retrieve artisan public profile and craft heritage credentials.
    """
    artisan = db.query(Artisan).filter(Artisan.id == artisan_id).first()
    if not artisan:
        raise HTTPException(status_code=404, detail="Artisan not found")
    return artisan


@router.post("", response_model=ArtisanResponse, status_code=status.HTTP_201_CREATED)
def create_artisan(payload: ArtisanCreate, db: Session = Depends(get_db)):
    """
    Register a new artisan or Self Help Group (SHG) collective.
    """
    artisan = Artisan(
        name=payload.name,
        shg_name=payload.shg_name,
        craft_type=payload.craft_type,
        location=payload.location,
        avatar_url=payload.avatar_url,
        bio=payload.bio,
        phone=payload.phone,
        bank_account_number=payload.bank_account_number,
        bank_ifsc=payload.bank_ifsc,
        is_verified=True
    )
    db.add(artisan)
    db.commit()
    db.refresh(artisan)
    return artisan


@router.get("/{artisan_id}/ledger", response_model=SellerLedgerSummary)
def get_seller_ledger(artisan_id: int, db: Session = Depends(get_db)):
    """
    Returns the real-time financial and operational ledger for the artisan dashboard:
    - Gross sales, platform fees, net earnings
    - Pending payout balance & completed payouts
    - Active vs completed orders count
    - Real-time inventory counts (available vs sold out)
    """
    return LedgerService.get_artisan_ledger_summary(db=db, artisan_id=artisan_id)


@router.get("/{artisan_id}/posts", response_model=List[PostResponse])
def get_artisan_posts(artisan_id: int, db: Session = Depends(get_db)):
    """
    List all product posts managed by this artisan with stock levels and status.
    """
    return db.query(Post).filter(Post.artisan_id == artisan_id).order_by(Post.created_at.desc()).all()


@router.get("/{artisan_id}/orders", response_model=List[OrderResponse])
def get_artisan_orders(
    artisan_id: int,
    fulfillment_status: Optional[str] = Query(None),
    db: Session = Depends(get_db)
):
    """
    Fetch all incoming orders for this artisan's items.
    """
    query = db.query(Order).filter(Order.artisan_id == artisan_id)
    if fulfillment_status:
        query = query.filter(Order.fulfillment_status == fulfillment_status.upper())
    orders = query.order_by(Order.created_at.desc()).all()

    results = []
    for o in orders:
        resp = OrderResponse.model_validate(o)
        if o.post:
            resp.item_title = o.post.title
        results.append(resp)
    return results


@router.post("/{artisan_id}/payouts", response_model=PayoutResponse, status_code=status.HTTP_201_CREATED)
def request_payout(
    artisan_id: int,
    amount: Optional[float] = Query(None, description="Disbursement amount, defaults to entire pending balance"),
    notes: Optional[str] = Query(None),
    db: Session = Depends(get_db)
):
    """
    Disburse pending earnings directly to the artisan's linked bank account.
    """
    ledger = LedgerService.get_artisan_ledger_summary(db=db, artisan_id=artisan_id)
    payout_amount = amount if amount is not None else ledger.pending_payout_balance
    
    if payout_amount <= 0:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="No pending balance available for disbursement."
        )

    if payout_amount > ledger.pending_payout_balance:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Requested amount ₹{payout_amount} exceeds available balance ₹{ledger.pending_payout_balance}."
        )

    payout = LedgerService.create_payout(db=db, artisan_id=artisan_id, amount=payout_amount, notes=notes)
    return payout
