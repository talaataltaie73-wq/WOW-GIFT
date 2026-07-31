from __future__ import annotations

from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from ..database import get_db
from ..dependencies import require_admin
from ..models.coupon import Coupon
from ..models.user import User
from ..schemas.coupon import CouponCreate, CouponOut, CouponUpdate
from ..services.crud import create_record, get_all, get_by_id, update_record

router = APIRouter(prefix="/coupons", tags=["coupons"])


@router.get("/", response_model=list[CouponOut])
async def list_coupons(
    _: User = Depends(require_admin),
    db: AsyncSession = Depends(get_db),
):
    return await get_all(db, Coupon)


@router.get("/{coupon_id}", response_model=CouponOut)
async def get_coupon(
    coupon_id: str,
    _: User = Depends(require_admin),
    db: AsyncSession = Depends(get_db),
):
    return await get_by_id(db, Coupon, coupon_id)


@router.post("/", response_model=CouponOut, status_code=201)
async def create_coupon(
    data: CouponCreate,
    _: User = Depends(require_admin),
    db: AsyncSession = Depends(get_db),
):
    return await create_record(db, Coupon, data.model_dump())


@router.patch("/{coupon_id}", response_model=CouponOut)
async def patch_coupon(
    coupon_id: str,
    data: CouponUpdate,
    _: User = Depends(require_admin),
    db: AsyncSession = Depends(get_db),
):
    return await update_record(db, Coupon, coupon_id, data.model_dump(exclude_unset=True))
