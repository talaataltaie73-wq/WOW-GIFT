from __future__ import annotations

from datetime import datetime

from pydantic import BaseModel, ConfigDict, Field


class ReminderCreate(BaseModel):
    title: str = Field(min_length=1, max_length=255)
    title_ar: str | None = None
    occasion_date: datetime
    recipient_name: str | None = None
    notes: str | None = None


class ReminderOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    user_id: str
    title: str
    title_ar: str | None = None
    occasion_date: datetime
    recipient_name: str | None = None
    notes: str | None = None


class ReminderUpdate(BaseModel):
    title: str | None = None
    title_ar: str | None = None
    occasion_date: datetime | None = None
    recipient_name: str | None = None
    notes: str | None = None
