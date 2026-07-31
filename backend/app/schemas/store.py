from __future__ import annotations

from pydantic import BaseModel, ConfigDict, Field


class StoreCreate(BaseModel):
    name: str = Field(min_length=1, max_length=255)
    name_ar: str | None = None
    description: str | None = None
    description_ar: str | None = None
    logo_url: str | None = None


class StoreOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    merchant_id: str
    name: str
    name_ar: str | None = None
    description: str | None = None
    description_ar: str | None = None
    logo_url: str | None = None
    is_active: bool
    is_featured: bool = False


class StoreUpdate(BaseModel):
    name: str | None = None
    name_ar: str | None = None
    description: str | None = None
    description_ar: str | None = None
    logo_url: str | None = None
    is_active: bool | None = None
    is_featured: bool | None = None
