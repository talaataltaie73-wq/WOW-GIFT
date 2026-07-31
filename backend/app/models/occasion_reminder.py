from __future__ import annotations

from datetime import datetime

from sqlalchemy import DateTime, ForeignKey, String, Text
from sqlalchemy.orm import Mapped, mapped_column, relationship

from .base import Base, TimestampMixin, UUIDMixin


class OccasionReminder(UUIDMixin, TimestampMixin, Base):
    __tablename__ = "occasion_reminders"

    user_id: Mapped[str] = mapped_column(String(36), ForeignKey("users.id"))
    title: Mapped[str] = mapped_column(String(255))
    title_ar: Mapped[str | None] = mapped_column(String(255), nullable=True)
    occasion_date: Mapped[datetime] = mapped_column(DateTime(timezone=True))
    recipient_name: Mapped[str | None] = mapped_column(String(255), nullable=True)
    notes: Mapped[str | None] = mapped_column(Text, nullable=True)

    user: Mapped["User"] = relationship(back_populates="reminders", lazy="selectin")  # type: ignore[name-defined]
