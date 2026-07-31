from __future__ import annotations

from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from ..database import get_db
from ..dependencies import get_current_user
from ..models.occasion_reminder import OccasionReminder
from ..models.user import User
from ..schemas.reminder import ReminderCreate, ReminderOut, ReminderUpdate
from ..services.crud import create_record, delete_record, get_all, get_by_id, update_record

router = APIRouter(prefix="/reminders", tags=["reminders"])


@router.get("/", response_model=list[ReminderOut])
async def list_reminders(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    return await get_all(db, OccasionReminder, user_id=current_user.id)


@router.post("/", response_model=ReminderOut, status_code=201)
async def create_reminder(
    data: ReminderCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    return await create_record(
        db, OccasionReminder, {**data.model_dump(), "user_id": current_user.id}
    )


@router.get("/{reminder_id}", response_model=ReminderOut)
async def get_reminder(
    reminder_id: str,
    _: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    return await get_by_id(db, OccasionReminder, reminder_id)


@router.patch("/{reminder_id}", response_model=ReminderOut)
async def patch_reminder(
    reminder_id: str,
    data: ReminderUpdate,
    _: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    return await update_record(
        db, OccasionReminder, reminder_id, data.model_dump(exclude_unset=True)
    )


@router.delete("/{reminder_id}", status_code=204)
async def remove_reminder(
    reminder_id: str,
    _: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    await delete_record(db, OccasionReminder, reminder_id)
