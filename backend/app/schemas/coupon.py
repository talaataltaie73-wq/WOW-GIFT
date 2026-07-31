from __future__ import annotations

from datetime import datetime

from pydantic import BaseModel, ConfigDict, Field


class CouponCreate(BaseModel):
    code: str = Field(min_length=1, max_length=50)
    discount_type: str = Field(default="percentage", pattern="^(percentage|fixed)$")
    discount_value: float = Field(ge=0)
    min_order: float = Field(ge=0, default=0)
    max_uses: int = Field(ge=1, default=1)
    expires_at: datetime | None = None


class CouponOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    code: str
    discount_type: str
    discount_value: float
    min_order: float
    max_uses: int
    used_count: int
    expires_at: datetime | None = None
    is_active: bool


class CouponUpdate(BaseModel):
    discount_type: str | None = None
    discount_value: float | None = Field(default=None, ge=0)
    min_order: float | None = Field(default=None, ge=0)
    max_uses: int | None = Field(default=None, ge=1)
    expires_at: datetime | None = None
    is_active: bool | None = None
