from __future__ import annotations

from pydantic import BaseModel, ConfigDict, Field


class AddressCreate(BaseModel):
    label: str = Field(default="Home", max_length=100)
    city: str = Field(min_length=1, max_length=100)
    district: str | None = None
    street: str | None = None
    building: str | None = None
    postal_code: str | None = None
    country: str = "SA"
    notes: str | None = None
    is_default: bool = False


class AddressOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    user_id: str
    label: str
    city: str
    district: str | None = None
    street: str | None = None
    building: str | None = None
    postal_code: str | None = None
    country: str
    notes: str | None = None
    is_default: bool


class AddressUpdate(BaseModel):
    label: str | None = None
    city: str | None = None
    district: str | None = None
    street: str | None = None
    building: str | None = None
    postal_code: str | None = None
    country: str | None = None
    notes: str | None = None
    is_default: bool | None = None
