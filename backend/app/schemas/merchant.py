from __future__ import annotations

from pydantic import BaseModel, ConfigDict, Field


class MerchantCreate(BaseModel):
    business_name: str = Field(min_length=1, max_length=255)
    business_name_ar: str | None = None
    logo_url: str | None = None


class MerchantOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    user_id: str
    business_name: str
    business_name_ar: str | None = None
    logo_url: str | None = None
    is_verified: bool


class MerchantUpdate(BaseModel):
    business_name: str | None = None
    business_name_ar: str | None = None
    logo_url: str | None = None


class MerchantEarningsOut(BaseModel):
    merchant_id: str
    total_delivered_orders: int
    gross_sales: float
    commission_rate: float
    commission_amount: float
    net_earnings: float
    currency: str = "IQD"
    min_payout_threshold: float
    eligible_for_payout: bool
