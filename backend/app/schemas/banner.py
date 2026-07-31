from __future__ import annotations

from pydantic import BaseModel, ConfigDict, Field


class BannerCreate(BaseModel):
    title: str = Field(min_length=1, max_length=255)
    title_ar: str | None = None
    image_url: str
    link_url: str | None = None
    sort_order: int = 0


class BannerOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    title: str
    title_ar: str | None = None
    image_url: str
    link_url: str | None = None
    sort_order: int
    is_active: bool


class BannerUpdate(BaseModel):
    title: str | None = None
    title_ar: str | None = None
    image_url: str | None = None
    link_url: str | None = None
    sort_order: int | None = None
    is_active: bool | None = None
