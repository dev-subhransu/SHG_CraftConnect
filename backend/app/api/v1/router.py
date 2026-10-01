from fastapi import APIRouter
from app.api.v1.posts import router as posts_router
from app.api.v1.orders import router as orders_router
from app.api.v1.artisans import router as artisans_router
from app.api.v1.payments import router as payments_router

api_v1_router = APIRouter()
api_v1_router.include_router(posts_router)
api_v1_router.include_router(orders_router)
api_v1_router.include_router(artisans_router)
api_v1_router.include_router(payments_router)
