from __future__ import annotations

from pydantic import BaseModel, ConfigDict, Field


class GiftBoxItemIn(BaseModel):
    product_id: str
    quantity: int = Field(ge=1, default=1)


class GiftBoxCreate(BaseModel):
    name: str = Field(min_length=1, max_length=255)
    name_ar: str | None = None
    description: str | None = None
    description_ar: str | None = None
    price: float = Field(ge=0)
    currency: str = "IQD"
    image_url: str | None = None
    occasion: str | None = None
    occasion_ar: str | None = None
    items: list[GiftBoxItemIn] = []


class GiftBoxItemOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    product_id: str
    quantity: int


class GiftBoxOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    name: str
    name_ar: str | None = None
    description: str | None = None
    description_ar: str | None = None
    price: float
    currency: str
    image_url: str | None = None
    occasion: str | None = None
    occasion_ar: str | None = None
    is_active: bool
    items: list[GiftBoxItemOut] = []


class GiftBoxUpdate(BaseModel):
    name: str | None = None
    name_ar: str | None = None
    description: str | None = None
    description_ar: str | None = None
    price: float | None = Field(default=None, ge=0)
    image_url: str | None = None
    occasion: str | None = None
    occasion_ar: str | None = None
    is_active: bool | None = None
