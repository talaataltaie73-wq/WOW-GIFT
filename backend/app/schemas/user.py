from __future__ import annotations

from datetime import datetime

from pydantic import BaseModel, ConfigDict, EmailStr, Field


# ── Auth ─────────────────────────────────────────────────────────────────
class RegisterRequest(BaseModel):
    email: EmailStr
    password: str = Field(min_length=6, max_length=128)
    full_name: str = Field(min_length=1, max_length=255)
    phone: str | None = None
    role: str = Field(default="customer", pattern="^(customer)$")


class LoginRequest(BaseModel):
    email: EmailStr
    password: str


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"


# ── User ─────────────────────────────────────────────────────────────────
class UserOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    email: str
    full_name: str
    phone: str | None = None
    phone_verified: bool = False
    phone_verified_at: datetime | None = None
    avatar_url: str | None = None
    role: str
    is_active: bool
    locale: str


class UserUpdate(BaseModel):
    full_name: str | None = None
    phone: str | None = None
    avatar_url: str | None = None
    locale: str | None = None


# ── OTP ──────────────────────────────────────────────────────────────────
class OtpRequestBody(BaseModel):
    phone: str
    channel: str = Field(default="sms", pattern="^(sms|whatsapp)$")


class OtpVerifyBody(BaseModel):
    request_id: str
    code: str = Field(min_length=6, max_length=6)


# ── Account Deletion ─────────────────────────────────────────────────────
class DeleteAccountRequest(BaseModel):
    password: str


class DeleteAccountResponse(BaseModel):
    detail: str
    deleted_at: datetime


# ── Admin User Listing ───────────────────────────────────────────────────
class AdminUserOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    email: str
    full_name: str
    phone: str | None = None
    phone_verified: bool = False
    role: str
    is_active: bool
    is_deleted: bool = False
    deleted_at: datetime | None = None
    created_at: datetime | None = None
