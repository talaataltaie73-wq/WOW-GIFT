from __future__ import annotations

from fastapi import APIRouter, Depends, Query
from sqlalchemy import desc, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.dependencies import require_admin
from app.models.store import Store
from app.models.user import User
from app.schemas.store import StoreCreate, StoreOut, StoreUpdate
from app.services.crud import create_record, get_all, get_by_id, update_record
from app.services.merchant_service import get_merchant_by_user

router = APIRouter(prefix="/stores", tags=["stores"])


@router.get("/", response_model=list[StoreOut])
async def list_stores(db: AsyncSession = Depends(get_db)):
    return await get_all(db, Store, is_active=True)


@router.get("/featured", response_model=list[StoreOut])
async def featured_stores(
    limit: int = Query(default=10, ge=1, le=50),
    db: AsyncSession = Depends(get_db),
):
    """Stores marked as featured, falling back to all active stores."""
    stmt = (
        select(Store)
        .where(Store.is_active == True, Store.is_featured == True)  # noqa: E712
        .order_by(desc(Store.created_at))
        .limit(limit)
    )
    result = await db.execute(stmt)
    stores = result.scalars().all()
    # Fallback: if no featured stores, return all active stores
    if not stores:
        stmt = (
            select(Store)
            .where(Store.is_active == True)  # noqa: E712
            .order_by(desc(Store.created_at))
            .limit(limit)
        )
        result = await db.execute(stmt)
        stores = result.scalars().all()
    return stores


@router.get("/{store_id}", response_model=StoreOut)
async def get_store(store_id: str, db: AsyncSession = Depends(get_db)):
    return await get_by_id(db, Store, store_id)


@router.post("/", response_model=StoreOut, status_code=201)
async def create_store(
    data: StoreCreate,
    current_user: User = Depends(require_admin),
    db: AsyncSession = Depends(get_db),
):
    merchant = await get_merchant_by_user(db, current_user.id)
    return await create_record(db, Store, {**data.model_dump(), "merchant_id": merchant.id})


@router.patch("/{store_id}", response_model=StoreOut)
async def patch_store(
    store_id: str,
    data: StoreUpdate,
    _: User = Depends(require_admin),
    db: AsyncSession = Depends(get_db),
):
    return await update_record(db, Store, store_id, data.model_dump(exclude_unset=True))
