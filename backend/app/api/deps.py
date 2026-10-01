from typing import Generator
from fastapi import Depends
from sqlalchemy.orm import Session
from app.core.database import get_db

# Re-export database dependency for API routes
__all__ = ["get_db"]
