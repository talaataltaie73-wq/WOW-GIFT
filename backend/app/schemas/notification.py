from __future__ import annotations

from pydantic import BaseModel, ConfigDict, Field


class NotificationCreate(BaseModel):
    user_id: str
    title: str = Field(min_length=1, max_length=255)
    title_ar: str | None = None
    body: str | None = None
    body_ar: str | None = None
    notification_type: str = "general"


class NotificationOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    user_id: str
    title: str
    title_ar: str | None = None
    body: str | None = None
    body_ar: str | None = None
    notification_type: str
    is_read: bool
