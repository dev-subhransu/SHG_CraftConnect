import os
from functools import lru_cache
from typing import List, Union
from pydantic import Field, field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """
    Application runtime configuration loaded from environment variables
    with safe defaults for local development.
    """
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore"
    )

    PROJECT_NAME: str = "SHG & Artisan Social Commerce API"
    VERSION: str = "1.0.0"
    API_V1_STR: str = "/api/v1"
    
    ENVIRONMENT: str = Field(default="development")
    DEBUG: bool = Field(default=True)
    HOST: str = Field(default="0.0.0.0")
    PORT: int = Field(default=8000)

    # Database
    DATABASE_URL: str = Field(
        default="sqlite:///./artisan_dev.db",
        description="PostgreSQL URL for production or SQLite URL for local testing"
    )

    # Payment Gateway Configuration
    # Options: mock, razorpay, stripe
    PAYMENT_PROVIDER: str = Field(default="mock")
    RAZORPAY_KEY_ID: str = Field(default="rzp_test_placeholder")
    RAZORPAY_KEY_SECRET: str = Field(default="rzp_secret_placeholder")
    STRIPE_SECRET_KEY: str = Field(default="sk_test_placeholder")
    STRIPE_WEBHOOK_SECRET: str = Field(default="whsec_placeholder")

    # Platform Economics
    PLATFORM_FEE_PERCENTAGE: float = Field(default=5.0)

    # CORS configuration
    CORS_ORIGINS: Union[str, List[str]] = Field(default="*")

    @field_validator("CORS_ORIGINS", mode="before")
    @classmethod
    def assemble_cors_origins(cls, v: Union[str, List[str]]) -> List[str]:
        if isinstance(v, str) and not v.startswith("["):
            return [i.strip() for i in v.split(",") if i.strip()]
        elif isinstance(v, list):
            return v
        return ["*"]


@lru_cache()
def get_settings() -> Settings:
    return Settings()
