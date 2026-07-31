from __future__ import annotations

from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from ..database import get_db
from ..dependencies import require_admin
from ..models.gift_box import GiftBox, GiftBoxItem
from ..models.user import User
from ..schemas.gift_box import GiftBoxCreate, GiftBoxOut, GiftBoxUpdate
from ..services.crud import get_all, get_by_id, update_record

router = APIRouter(prefix="/gift-boxes", tags=["gift_boxes"])


@router.get("/", response_model=list[GiftBoxOut])
async def list_gift_boxes(db: AsyncSession = Depends(get_db)):
    return await get_all(db, GiftBox, is_active=True)


@router.get("/{box_id}", response_model=GiftBoxOut)
async def get_gift_box(box_id: str, db: AsyncSession = Depends(get_db)):
    return await get_by_id(db, GiftBox, box_id)


@router.post("/", response_model=GiftBoxOut, status_code=201)
async def create_gift_box(
    data: GiftBoxCreate,
    _: User = Depends(require_admin),
    db: AsyncSession = Depends(get_db),
):
    box = GiftBox(**data.model_dump(exclude={"items"}))
    db.add(box)
    await db.flush()
    for item in data.items:
        db.add(GiftBoxItem(gift_box_id=box.id, **item.model_dump()))
    await db.flush()
    return await get_by_id(db, GiftBox, box.id)


@router.patch("/{box_id}", response_model=GiftBoxOut)
async def patch_gift_box(
    box_id: str,
    data: GiftBoxUpdate,
    _: User = Depends(require_admin),
    db: AsyncSession = Depends(get_db),
):
    return await update_record(db, GiftBox, box_id, data.model_dump(exclude_unset=True))
