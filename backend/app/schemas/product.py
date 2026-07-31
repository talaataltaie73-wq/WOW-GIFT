from __future__ import annotations

from pydantic import BaseModel, ConfigDict, Field


class ProductCreate(BaseModel):
    store_id: str | None = None
    category_id: str | None = None
    name: str = Field(min_length=1, max_length=255)
    name_ar: str | None = None
    description: str | None = None
    description_ar: str | None = None
    price: float = Field(ge=0)
    discount_price: float | None = Field(default=None, ge=0)
    currency: str = "IQD"
    image_url: str | None = None
    stock: int = Field(ge=0, default=0)
    is_giftable: bool = True


class ProductOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    store_id: str | None = None
    category_id: str | None = None
    name: str
    name_ar: str | None = None
    description: str | None = None
    description_ar: str | None = None
    price: float
    discount_price: float | None = None
    currency: str
    image_url: str | None = None
    stock: int
    is_active: bool
    is_giftable: bool


class ProductUpdate(BaseModel):
    name: str | None = None
    name_ar: str | None = None
    description: str | None = None
    description_ar: str | None = None
    price: float | None = Field(default=None, ge=0)
    discount_price: float | None = Field(default=None, ge=0)
    image_url: str | None = None
    stock: int | None = Field(default=None, ge=0)
    is_active: bool | None = None
    is_giftable: bool | None = None
    category_id: str | None = None
