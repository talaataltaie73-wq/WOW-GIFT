from __future__ import annotations

from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.dependencies import get_current_user, require_admin
from app.models.user import User
from app.schemas.merchant import MerchantCreate, MerchantEarningsOut, MerchantOut, MerchantUpdate
from app.services.merchant_service import (
    create_merchant,
    get_merchant_by_id,
    get_merchant_by_user,
    get_merchant_earnings,
    update_merchant,
)

router = APIRouter(prefix="/merchants", tags=["merchants"])


@router.post("/", response_model=MerchantOut, status_code=201)
async def create_merchant_profile(
    data: MerchantCreate,
    current_user: User = Depends(require_admin),
    db: AsyncSession = Depends(get_db),
):
    return await create_merchant(db, current_user.id, data)


@router.get("/me", response_model=MerchantOut)
async def get_my_merchant(
    current_user: User = Depends(require_admin),
    db: AsyncSession = Depends(get_db),
):
    return await get_merchant_by_user(db, current_user.id)


@router.get("/me/earnings", response_model=MerchantEarningsOut)
async def get_my_earnings(
    current_user: User = Depends(require_admin),
    db: AsyncSession = Depends(get_db),
):
    merchant = await get_merchant_by_user(db, current_user.id)
    return await get_merchant_earnings(db, merchant.id)


@router.get("/{merchant_id}", response_model=MerchantOut)
async def get_merchant(merchant_id: str, db: AsyncSession = Depends(get_db)):
    return await get_merchant_by_id(db, merchant_id)


@router.get("/{merchant_id}/earnings", response_model=MerchantEarningsOut)
async def get_merchant_earnings_by_id(
    merchant_id: str,
    _: User = Depends(require_admin),
    db: AsyncSession = Depends(get_db),
):
    return await get_merchant_earnings(db, merchant_id)


@router.patch("/{merchant_id}", response_model=MerchantOut)
async def patch_merchant(
    merchant_id: str,
    data: MerchantUpdate,
    _: User = Depends(require_admin),
    db: AsyncSession = Depends(get_db),
):
    return await update_merchant(db, merchant_id, data)
