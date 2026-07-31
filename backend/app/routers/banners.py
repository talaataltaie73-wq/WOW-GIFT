from __future__ import annotations

from fastapi import APIRouter, Depends
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.dependencies import require_admin
from app.models.banner import Banner
from app.models.user import User
from app.schemas.banner import BannerCreate, BannerOut, BannerUpdate
from app.services.crud import create_record, get_by_id, update_record

router = APIRouter(prefix="/banners", tags=["banners"])


@router.get("/", response_model=list[BannerOut])
async def list_banners(db: AsyncSession = Depends(get_db)):
    """Return all active banners ordered by sort_order."""
    stmt = (
        select(Banner)
        .where(Banner.is_active == True)  # noqa: E712
        .order_by(Banner.sort_order)
    )
    result = await db.execute(stmt)
    return result.scalars().all()


@router.post("/", response_model=BannerOut, status_code=201)
async def create_banner(
    data: BannerCreate,
    _: User = Depends(require_admin),
    db: AsyncSession = Depends(get_db),
):
    return await create_record(db, Banner, data.model_dump())


@router.patch("/{banner_id}", response_model=BannerOut)
async def patch_banner(
    banner_id: str,
    data: BannerUpdate,
    _: User = Depends(require_admin),
    db: AsyncSession = Depends(get_db),
):
    return await update_record(db, Banner, banner_id, data.model_dump(exclude_unset=True))
