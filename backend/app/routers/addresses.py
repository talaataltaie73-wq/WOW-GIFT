from __future__ import annotations

from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from ..database import get_db
from ..dependencies import get_current_user
from ..models.address import Address
from ..models.user import User
from ..schemas.address import AddressCreate, AddressOut, AddressUpdate
from ..services.crud import create_record, delete_record, get_all, get_by_id, update_record

router = APIRouter(prefix="/addresses", tags=["addresses"])


@router.get("/", response_model=list[AddressOut])
async def list_addresses(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    return await get_all(db, Address, user_id=current_user.id)


@router.post("/", response_model=AddressOut, status_code=201)
async def create_address(
    data: AddressCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    return await create_record(db, Address, {**data.model_dump(), "user_id": current_user.id})


@router.patch("/{address_id}", response_model=AddressOut)
async def patch_address(
    address_id: str,
    data: AddressUpdate,
    _: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    return await update_record(db, Address, address_id, data.model_dump(exclude_unset=True))


@router.delete("/{address_id}", status_code=204)
async def remove_address(
    address_id: str,
    _: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    await delete_record(db, Address, address_id)
