from __future__ import annotations

from sqlalchemy import Boolean, ForeignKey, String, Text
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.models.base import Base, TimestampMixin, UUIDMixin


class Store(UUIDMixin, TimestampMixin, Base):
    __tablename__ = "stores"

    merchant_id: Mapped[str] = mapped_column(
        String(36), ForeignKey("merchants.id")
    )
    name: Mapped[str] = mapped_column(String(255))
    name_ar: Mapped[str | None] = mapped_column(String(255), nullable=True)
    description: Mapped[str | None] = mapped_column(Text, nullable=True)
    description_ar: Mapped[str | None] = mapped_column(Text, nullable=True)
    logo_url: Mapped[str | None] = mapped_column(Text, nullable=True)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    is_featured: Mapped[bool] = mapped_column(Boolean, default=False)

    merchant: Mapped["Merchant"] = relationship(back_populates="stores", lazy="selectin")  # type: ignore[name-defined]
    products: Mapped[list["Product"]] = relationship(back_populates="store", lazy="selectin")  # type: ignore[name-defined]
