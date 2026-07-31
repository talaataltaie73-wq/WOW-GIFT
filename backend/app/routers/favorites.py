from __future__ import annotations

from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from ..database import get_db
from ..dependencies import get_current_user
from ..models.favorite import Favorite
from ..models.user import User
from ..schemas.favorite import FavoriteCreate, FavoriteOut
from ..services.crud import create_record, delete_record, get_all

router = APIRouter(prefix="/favorites", tags=["favorites"])


@router.get("/", response_model=list[FavoriteOut])
async def list_favorites(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    return await get_all(db, Favorite, user_id=current_user.id)


@router.post("/", response_model=FavoriteOut, status_code=201)
async def add_favorite(
    data: FavoriteCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    return await create_record(
        db, Favorite, {**data.model_dump(), "user_id": current_user.id}
    )


@router.delete("/{favorite_id}", status_code=204)
async def remove_favorite(
    favorite_id: str,
    _: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    await delete_record(db, Favorite, favorite_id)
