from __future__ import annotations

from datetime import date, datetime, time
from enum import Enum

from pydantic import BaseModel, ConfigDict, Field


class OrderStatusEnum(str, Enum):
    pending_approval = "pending_approval"
    accepted = "accepted"
    preparing = "preparing"
    out_for_delivery = "out_for_delivery"
    delivered = "delivered"
    cancelled = "cancelled"


class PaymentMethodEnum(str, Enum):
    cash_on_delivery = "cash_on_delivery"
    zain_cash = "zain_cash"
    asia_hawala = "asia_hawala"
    mastercard = "mastercard"
    visa = "visa"
    e_wallet = "e_wallet"


class OrderItemIn(BaseModel):
    product_id: str | None = None
    gift_box_id: str | None = None
    quantity: int = Field(ge=1, default=1)


class OrderCreate(BaseModel):
    address_id: str | None = None
    coupon_code: str | None = None
    payment_method: PaymentMethodEnum | None = None
    reward_points_used: int = Field(ge=0, default=0)

    # Gift customization
    gift_message: str | None = None
    gift_message_ar: str | None = None
    greeting_card_id: str | None = None
    private_message: str | None = None
    is_anonymous: bool = False
    sender_display_name: str | None = None

    # Delivery
    recipient_name: str | None = None
    recipient_phone: str | None = None
    address: str | None = None
    latitude: float | None = None
    longitude: float | None = None
    delivery_date: date | None = None
    delivery_time: time | None = None
    notes: str | None = None

    items: list[OrderItemIn] = Field(min_length=1)


class OrderItemOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    product_id: str | None = None
    gift_box_id: str | None = None
    quantity: int
    unit_price: float


class OrderStatusHistoryOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    status: str
    note: str | None = None
    changed_at: datetime


class OrderOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    user_id: str
    address_id: str | None = None
    coupon_id: str | None = None
    status: str
    total: float
    currency: str
    payment_method: str | None = None
    reward_points_used: int = 0
    discount_amount: float = 0.0

    # Gift customization
    gift_message: str | None = None
    gift_message_ar: str | None = None
    greeting_card_id: str | None = None
    private_message: str | None = None
    is_anonymous: bool = False
    sender_display_name: str | None = None

    # Delivery
    recipient_name: str | None = None
    recipient_phone: str | None = None
    address: str | None = None
    latitude: float | None = None
    longitude: float | None = None
    delivery_date: date | None = None
    delivery_time: time | None = None
    notes: str | None = None

    items: list[OrderItemOut] = []
    status_history: list[OrderStatusHistoryOut] = []


class OrderStatusUpdate(BaseModel):
    status: OrderStatusEnum
    note: str | None = None
