from __future__ import annotations

from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.dependencies import require_admin
from app.models.category import Category
from app.models.user import User
from app.schemas.category import CategoryCreate, CategoryOut, CategoryUpdate
from app.services.crud import create_record, get_all, get_by_id, update_record

router = APIRouter(prefix="/categories", tags=["categories"])


@router.get("/", response_model=list[CategoryOut])
async def list_categories(db: AsyncSession = Depends(get_db)):
    return await get_all(db, Category, is_active=True)


@router.get("/{category_id}", response_model=CategoryOut)
async def get_category(category_id: str, db: AsyncSession = Depends(get_db)):
    return await get_by_id(db, Category, category_id)


@router.post("/", response_model=CategoryOut, status_code=201)
async def create_category(
    data: CategoryCreate,
    _: User = Depends(require_admin),
    db: AsyncSession = Depends(get_db),
):
    return await create_record(db, Category, data.model_dump())


@router.patch("/{category_id}", response_model=CategoryOut)
async def patch_category(
    category_id: str,
    data: CategoryUpdate,
    _: User = Depends(require_admin),
    db: AsyncSession = Depends(get_db),
):
    return await update_record(db, Category, category_id, data.model_dump(exclude_unset=True))
