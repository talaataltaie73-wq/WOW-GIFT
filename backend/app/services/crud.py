"""Generic CRUD helpers used by multiple routers."""
from __future__ import annotations

from typing import Any, Sequence, Type

from fastapi import HTTPException
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.base import Base


async def get_all(db: AsyncSession, model: Type[Base], **filters: Any) -> Sequence[Base]:
    stmt = select(model)
    for attr, value in filters.items():
        if value is not None:
            stmt = stmt.where(getattr(model, attr) == value)
    result = await db.execute(stmt)
    return result.scalars().all()


async def get_by_id(db: AsyncSession, model: Type[Base], record_id: str) -> Base:
    result = await db.execute(select(model).where(model.id == record_id))  # type: ignore[attr-defined]
    obj = result.scalar_one_or_none()
    if not obj:
        raise HTTPException(status_code=404, detail=f"{model.__name__} not found")
    return obj


async def create_record(db: AsyncSession, model: Type[Base], data: dict) -> Base:
    obj = model(**data)
    db.add(obj)
    await db.flush()
    return obj


async def update_record(db: AsyncSession, model: Type[Base], record_id: str, data: dict) -> Base:
    obj = await get_by_id(db, model, record_id)
    for field, value in data.items():
        setattr(obj, field, value)
    await db.flush()
    return obj


async def delete_record(db: AsyncSession, model: Type[Base], record_id: str) -> None:
    obj = await get_by_id(db, model, record_id)
    await db.delete(obj)
    await db.flush()
