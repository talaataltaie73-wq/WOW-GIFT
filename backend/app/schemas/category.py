from __future__ import annotations

from pydantic import BaseModel, ConfigDict, Field


class CategoryCreate(BaseModel):
    name: str = Field(min_length=1, max_length=255)
    name_ar: str | None = None
    slug: str = Field(min_length=1, max_length=255)
    icon_url: str | None = None


class CategoryOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    name: str
    name_ar: str | None = None
    slug: str
    icon_url: str | None = None
    is_active: bool


class CategoryUpdate(BaseModel):
    name: str | None = None
    name_ar: str | None = None
    slug: str | None = None
    icon_url: str | None = None
    is_active: bool | None = None
