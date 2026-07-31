from __future__ import annotations

import enum
from datetime import date, datetime, time

from sqlalchemy import Boolean, Date, DateTime, Enum, Float, ForeignKey, Integer, String, Text, Time
from sqlalchemy.orm import Mapped, mapped_column, relationship

from .base import Base, TimestampMixin, UUIDMixin, _utcnow


class OrderStatus(str, enum.Enum):
    pending_approval = "pending_approval"
    accepted = "accepted"
    preparing = "preparing"
    out_for_delivery = "out_for_delivery"
    delivered = "delivered"
    cancelled = "cancelled"


class PaymentMethod(str, enum.Enum):
    cash_on_delivery = "cash_on_delivery"
    zain_cash = "zain_cash"
    asia_hawala = "asia_hawala"
    mastercard = "mastercard"
    visa = "visa"
    e_wallet = "e_wallet"


class Order(UUIDMixin, TimestampMixin, Base):
    __tablename__ = "orders"

    user_id: Mapped[str] = mapped_column(String(36), ForeignKey("users.id"))
    address_id: Mapped[str | None] = mapped_column(
        String(36), ForeignKey("addresses.id"), nullable=True
    )
    coupon_id: Mapped[str | None] = mapped_column(
        String(36), ForeignKey("coupons.id"), nullable=True
    )
    status: Mapped[str] = mapped_column(
        String(30), default=OrderStatus.pending_approval.value
    )
    total: Mapped[float] = mapped_column(Float, default=0.0)
    currency: Mapped[str] = mapped_column(String(3), default="IQD")

    # ── Payment ──────────────────────────────────────────────────────────
    payment_method: Mapped[str | None] = mapped_column(String(30), nullable=True)
    reward_points_used: Mapped[int] = mapped_column(Integer, default=0)
    discount_amount: Mapped[float] = mapped_column(Float, default=0.0)

    # ── Gift customization ───────────────────────────────────────────────
    gift_message: Mapped[str | None] = mapped_column(Text, nullable=True)
    gift_message_ar: Mapped[str | None] = mapped_column(Text, nullable=True)
    greeting_card_id: Mapped[str | None] = mapped_column(String(36), nullable=True)
    private_message: Mapped[str | None] = mapped_column(Text, nullable=True)
    is_anonymous: Mapped[bool] = mapped_column(Boolean, default=False)
    sender_display_name: Mapped[str | None] = mapped_column(String(255), nullable=True)

    # ── Delivery ─────────────────────────────────────────────────────────
    recipient_name: Mapped[str | None] = mapped_column(String(255), nullable=True)
    recipient_phone: Mapped[str | None] = mapped_column(String(20), nullable=True)
    address: Mapped[str | None] = mapped_column(Text, nullable=True)
    latitude: Mapped[float | None] = mapped_column(Float, nullable=True)
    longitude: Mapped[float | None] = mapped_column(Float, nullable=True)
    delivery_date: Mapped[date | None] = mapped_column(Date, nullable=True)
    delivery_time: Mapped[time | None] = mapped_column(Time, nullable=True)
    notes: Mapped[str | None] = mapped_column(Text, nullable=True)

    user: Mapped["User"] = relationship(back_populates="orders", lazy="selectin")  # type: ignore[name-defined]
    items: Mapped[list["OrderItem"]] = relationship(
        back_populates="order", lazy="selectin", cascade="all, delete-orphan"
    )
    status_history: Mapped[list["OrderStatusHistory"]] = relationship(
        back_populates="order", lazy="selectin", cascade="all, delete-orphan"
    )


class OrderItem(UUIDMixin, Base):
    __tablename__ = "order_items"

    order_id: Mapped[str] = mapped_column(String(36), ForeignKey("orders.id"))
    product_id: Mapped[str | None] = mapped_column(
        String(36), ForeignKey("products.id"), nullable=True
    )
    gift_box_id: Mapped[str | None] = mapped_column(
        String(36), ForeignKey("gift_boxes.id"), nullable=True
    )
    quantity: Mapped[int] = mapped_column(Integer, default=1)
    unit_price: Mapped[float] = mapped_column(Float, default=0.0)

    order: Mapped["Order"] = relationship(back_populates="items")
    product: Mapped["Product"] = relationship(lazy="selectin")  # type: ignore[name-defined]
    gift_box: Mapped["GiftBox"] = relationship(lazy="selectin")  # type: ignore[name-defined]


class OrderStatusHistory(UUIDMixin, Base):
    __tablename__ = "order_status_history"

    order_id: Mapped[str] = mapped_column(String(36), ForeignKey("orders.id"))
    status: Mapped[str] = mapped_column(String(30))
    note: Mapped[str | None] = mapped_column(Text, nullable=True)
    changed_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=_utcnow
    )

    order: Mapped["Order"] = relationship(back_populates="status_history")
