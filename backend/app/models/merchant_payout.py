from __future__ import annotations

from datetime import datetime

from sqlalchemy import DateTime, Float, ForeignKey, String, Text
from sqlalchemy.orm import Mapped, mapped_column, relationship

from .base import Base, TimestampMixin, UUIDMixin, _utcnow


class MerchantPayout(UUIDMixin, TimestampMixin, Base):
    __tablename__ = "merchant_payouts"

    merchant_id: Mapped[str] = mapped_column(
        String(36), ForeignKey("merchants.id")
    )
    period_start: Mapped[datetime] = mapped_column(DateTime(timezone=True))
    period_end: Mapped[datetime] = mapped_column(DateTime(timezone=True))
    gross_sales: Mapped[float] = mapped_column(Float, default=0.0)
    commission_rate: Mapped[float] = mapped_column(Float, default=10.0)
    commission_amount: Mapped[float] = mapped_column(Float, default=0.0)
    net_payout: Mapped[float] = mapped_column(Float, default=0.0)
    currency: Mapped[str] = mapped_column(String(3), default="IQD")
    status: Mapped[str] = mapped_column(String(20), default="pending")  # pending | paid
    paid_at: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True), nullable=True
    )
    note: Mapped[str | None] = mapped_column(Text, nullable=True)

    merchant: Mapped["Merchant"] = relationship(lazy="selectin")  # type: ignore[name-defined]
