from contextlib import asynccontextmanager
from fastapi import FastAPI, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from app.core.config import get_settings
from app.core.database import init_db
from app.api.v1.router import api_v1_router
from seed_data import seed_database

settings = get_settings()


@asynccontextmanager
async def lifespan(app: FastAPI):
    """
    Application startup and shutdown lifecycle management.
    Initializes database schema and bootstraps sample SHG artisan records.
    """
    # 1. Startup: initialize database tables
    try:
        init_db()
        # Seed initial data if tables are empty
        seed_database(force=False)
    except Exception as e:
        print(f"[Startup Warning] Database bootstrap note: {e}")
    
    yield
    # Shutdown actions (if any)


app = FastAPI(
    title=settings.PROJECT_NAME,
    version=settings.VERSION,
    description="Backend API powering the Social Commerce Platform for Self Help Groups (SHGs) and Artisans. Includes vertical discovery feed, cart-free instant checkout, and seller ledger operations.",
    docs_url="/docs",
    redoc_url="/redoc",
    lifespan=lifespan
)

# CORS Configuration
origins = settings.CORS_ORIGINS if isinstance(settings.CORS_ORIGINS, list) else [settings.CORS_ORIGINS]
if "*" in origins:
    origins = ["*"]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Mount API v1 router
app.include_router(api_v1_router, prefix=settings.API_V1_STR)


@app.get("/health", tags=["Health"])
def health_check():
    """
    Health check endpoint for Google Cloud Run container liveness and readiness probes.
    """
    return {
        "status": "healthy",
        "service": settings.PROJECT_NAME,
        "version": settings.VERSION,
        "environment": settings.ENVIRONMENT
    }


@app.get("/", tags=["Root"])
def root_redirect():
    """
    Root endpoint directing visitors to interactive Swagger OpenAPI documentation.
    """
    return {
        "message": "Welcome to the SHG & Artisan Social Commerce Platform API",
        "docs": "/docs",
        "health": "/health",
        "feed_api": f"{settings.API_V1_STR}/posts",
        "checkout_api": f"{settings.API_V1_STR}/orders/instant-checkout",
        "seller_api": f"{settings.API_V1_STR}/artisans"
    }


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "app.main:app",
        host=settings.HOST,
        port=settings.PORT,
        reload=settings.DEBUG
    )
