from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session
from app.api.deps import get_db
from app.models.post import Post, PostStatus
from app.models.artisan import Artisan
from app.schemas.post import PostFeedItem, PostCreate, PostResponse, PostUpdate
from app.services.inventory_service import InventoryService

router = APIRouter(prefix="/posts", tags=["Discovery Feed & Products"])


@router.get("", response_model=List[PostFeedItem])
def get_discovery_feed(
    skip: int = Query(0, ge=0),
    limit: int = Query(20, ge=1, le=100),
    craft_type: Optional[str] = Query(None, description="Filter by craft category"),
    artisan_id: Optional[int] = Query(None, description="Filter by artisan ID"),
    status_filter: Optional[str] = Query(None, description="Filter by status AVAILABLE / SOLD_OUT"),
    db: Session = Depends(get_db)
):
    """
    Instagram-style discovery feed of artisan and SHG handicraft posts.
    Returns posts with rich embedded artisan context, ready for vertical scrolling.
    """
    query = db.query(Post).join(Artisan, Post.artisan_id == Artisan.id)

    if craft_type:
        query = query.filter(Artisan.craft_type.ilike(f"%{craft_type}%"))
    if artisan_id:
        query = query.filter(Post.artisan_id == artisan_id)
    if status_filter:
        query = query.filter(Post.status == status_filter.upper())

    # Default order: newest posts first
    posts = query.order_by(Post.created_at.desc()).offset(skip).limit(limit).all()
    return posts


@router.get("/{post_id}", response_model=PostFeedItem)
def get_post_detail(post_id: int, db: Session = Depends(get_db)):
    """
    Fetch a single artisan showcase post with full story narrative.
    """
    post = db.query(Post).filter(Post.id == post_id).first()
    if not post:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Product post #{post_id} not found."
        )
    return post


@router.post("", response_model=PostFeedItem, status_code=status.HTTP_201_CREATED)
def create_artisan_post(payload: PostCreate, db: Session = Depends(get_db)):
    """
    Artisans can upload a new post showcasing handmade craft items with pricing and stock.
    """
    artisan = db.query(Artisan).filter(Artisan.id == payload.artisan_id).first()
    if not artisan:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Artisan #{payload.artisan_id} not found."
        )

    initial_status = PostStatus.AVAILABLE.value if payload.stock_quantity > 0 else PostStatus.SOLD_OUT.value

    post = Post(
        artisan_id=payload.artisan_id,
        title=payload.title,
        description=payload.description,
        craft_story=payload.craft_story,
        media_url=payload.media_url,
        media_type=payload.media_type,
        thumbnail_url=payload.thumbnail_url or payload.media_url,
        price=payload.price,
        currency=payload.currency,
        stock_quantity=payload.stock_quantity,
        status=initial_status
    )
    db.add(post)
    db.commit()
    db.refresh(post)
    return post


@router.patch("/{post_id}/inventory", response_model=PostResponse)
def toggle_inventory_status(
    post_id: int,
    status_value: Optional[str] = Query(None, pattern="^(AVAILABLE|SOLD_OUT)$"),
    stock_quantity: Optional[int] = Query(None, ge=0),
    db: Session = Depends(get_db)
):
    """
    Quickly toggle a product between AVAILABLE and SOLD_OUT, or restock inventory.
    """
    return InventoryService.manual_inventory_toggle(
        db=db,
        post_id=post_id,
        status_value=status_value,
        stock_quantity=stock_quantity
    )


@router.patch("/{post_id}", response_model=PostResponse)
def update_artisan_post(post_id: int, payload: PostUpdate, db: Session = Depends(get_db)):
    """
    Update post details (price, description, story, stock).
    """
    post = db.query(Post).filter(Post.id == post_id).first()
    if not post:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Post not found")

    update_dict = payload.model_dump(exclude_unset=True)
    for key, value in update_dict.items():
        setattr(post, key, value)

    # Re-evaluate status if stock_quantity was updated
    if "stock_quantity" in update_dict and "status" not in update_dict:
        if post.stock_quantity == 0:
            post.status = PostStatus.SOLD_OUT.value
        elif post.stock_quantity > 0 and post.status == PostStatus.SOLD_OUT.value:
            post.status = PostStatus.AVAILABLE.value

    db.commit()
    db.refresh(post)
    return post


@router.delete("/{post_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_post(post_id: int, db: Session = Depends(get_db)):
    """
    Delete a product post.
    """
    post = db.query(Post).filter(Post.id == post_id).first()
    if not post:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Post not found")
    db.delete(post)
    db.commit()
    return None
