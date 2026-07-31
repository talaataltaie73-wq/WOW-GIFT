from __future__ import annotations

from sqlalchemy import Boolean, ForeignKey, String, Text
from sqlalchemy.orm import Mapped, mapped_column, relationship

from .base import Base, TimestampMixin, UUIDMixin


class Merchant(UUIDMixin, TimestampMixin, Base):
    __tablename__ = "merchants"

    user_id: Mapped[str] = mapped_column(
        String(36), ForeignKey("users.id"), unique=True
    )
    business_name: Mapped[str] = mapped_column(String(255))
    business_name_ar: Mapped[str | None] = mapped_column(String(255), nullable=True)
    logo_url: Mapped[str | None] = mapped_column(Text, nullable=True)
    is_verified: Mapped[bool] = mapped_column(Boolean, default=False)

    user: Mapped["User"] = relationship(lazy="selectin")  # type: ignore[name-defined]
    stores: Mapped[list["Store"]] = relationship(back_populates="merchant", lazy="selectin")  # type: ignore[name-defined]
