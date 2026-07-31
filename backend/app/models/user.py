from __future__ import annotations

from datetime import datetime

from sqlalchemy import Boolean, DateTime, String, Text
from sqlalchemy.orm import Mapped, mapped_column, relationship

from .base import Base, TimestampMixin, UUIDMixin


class User(UUIDMixin, TimestampMixin, Base):
    __tablename__ = "users"

    email: Mapped[str] = mapped_column(String(255), unique=True, index=True)
    hashed_password: Mapped[str] = mapped_column(String(255))
    full_name: Mapped[str] = mapped_column(String(255))
    phone: Mapped[str | None] = mapped_column(String(20), nullable=True)
    phone_verified: Mapped[bool] = mapped_column(Boolean, default=False)
    phone_verified_at: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True), nullable=True
    )
    avatar_url: Mapped[str | None] = mapped_column(Text, nullable=True)
    role: Mapped[str] = mapped_column(String(20), default="customer")  # customer | merchant | admin
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    locale: Mapped[str] = mapped_column(String(5), default="ar")
    is_deleted: Mapped[bool] = mapped_column(Boolean, default=False)
    deleted_at: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True), nullable=True
    )

    # relationships
    addresses: Mapped[list["Address"]] = relationship(back_populates="user", lazy="selectin")  # type: ignore[name-defined]
    orders: Mapped[list["Order"]] = relationship(back_populates="user", lazy="selectin")  # type: ignore[name-defined]
    favorites: Mapped[list["Favorite"]] = relationship(back_populates="user", lazy="selectin")  # type: ignore[name-defined]
    notifications: Mapped[list["Notification"]] = relationship(back_populates="user", lazy="selectin")  # type: ignore[name-defined]
    reminders: Mapped[list["OccasionReminder"]] = relationship(back_populates="user", lazy="selectin")  # type: ignore[name-defined]
