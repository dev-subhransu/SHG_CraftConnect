from typing import Optional
from sqlalchemy.orm import Session
from fastapi import HTTPException, status
from app.models.post import Post, PostStatus


class InventoryService:
    """
    Handles atomic stock validation, automated inventory decrements,
    and automatic state transitions to SOLD_OUT when inventory reaches zero.
    """

    @staticmethod
    def get_post_for_purchase(db: Session, post_id: int, quantity: int = 1) -> Post:
        post = db.query(Post).filter(Post.id == post_id).first()
        if not post:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Artisan product post #{post_id} not found."
            )

        if post.status == PostStatus.SOLD_OUT.value or post.stock_quantity <= 0:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="This artisan piece is currently SOLD OUT."
            )

        if post.stock_quantity < quantity:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Only {post.stock_quantity} units available, requested {quantity}."
            )

        return post

    @staticmethod
    def decrement_stock_and_toggle_sold_out(db: Session, post_id: int, quantity: int = 1) -> Post:
        """
        Deducts purchased stock and automatically transitions post status
        to SOLD_OUT if remaining inventory hits zero.
        """
        post = db.query(Post).filter(Post.id == post_id).with_for_update().first() if db.bind.dialect.name != "sqlite" else db.query(Post).filter(Post.id == post_id).first()
        
        if not post:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Artisan product post #{post_id} not found."
            )

        if post.stock_quantity < quantity:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail=f"Insufficient inventory. Only {post.stock_quantity} items remaining."
            )

        post.stock_quantity -= quantity
        
        # Automatic toggle to SOLD_OUT when inventory is exhausted
        if post.stock_quantity <= 0:
            post.stock_quantity = 0
            post.status = PostStatus.SOLD_OUT.value

        db.commit()
        db.refresh(post)
        return post

    @staticmethod
    def manual_inventory_toggle(db: Session, post_id: int, status_value: Optional[str] = None, stock_quantity: Optional[int] = None) -> Post:
        """
        Allows artisans to manually toggle availability or restock handmade pieces.
        """
        post = db.query(Post).filter(Post.id == post_id).first()
        if not post:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Post not found")

        if stock_quantity is not None:
            post.stock_quantity = max(0, stock_quantity)
            if post.stock_quantity == 0:
                post.status = PostStatus.SOLD_OUT.value
            elif status_value is None and post.stock_quantity > 0:
                post.status = PostStatus.AVAILABLE.value

        if status_value is not None:
            post.status = status_value
            if status_value == PostStatus.AVAILABLE.value and post.stock_quantity == 0:
                post.stock_quantity = 1  # Default to 1 unit if manually marked available

        db.commit()
        db.refresh(post)
        return post
