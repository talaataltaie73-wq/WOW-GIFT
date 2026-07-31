from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException
from fastapi.responses import JSONResponse
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from ..database import get_db
from ..dependencies import get_current_user, require_admin
from ..models.order import Order
from ..models.user import User
from ..schemas.order import OrderCreate, OrderOut, OrderStatusUpdate
from ..services.crud import get_by_id
from ..services.order_service import create_order, update_order_status

router = APIRouter(prefix="/orders", tags=["orders"])


@router.get("/", response_model=list[OrderOut])
async def list_my_orders(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(select(Order).where(Order.user_id == current_user.id))
    return result.scalars().all()


@router.get("/{order_id}", response_model=OrderOut)
async def get_order(
    order_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    return await get_by_id(db, Order, order_id)


@router.post("/", response_model=OrderOut, status_code=201)
async def place_order(
    data: OrderCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    if not current_user.phone_verified:
        return JSONResponse(
            status_code=403,
            content={"detail": "phone_not_verified", "code": "PHONE_NOT_VERIFIED"},
        )
    order = await create_order(db, current_user.id, data)
    return await get_by_id(db, Order, order.id)


@router.patch("/{order_id}/status", response_model=OrderOut)
async def change_order_status(
    order_id: str,
    data: OrderStatusUpdate,
    _: User = Depends(require_admin),
    db: AsyncSession = Depends(get_db),
):
    order = await update_order_status(db, order_id, data.status, data.note)
    return await get_by_id(db, Order, order.id)
