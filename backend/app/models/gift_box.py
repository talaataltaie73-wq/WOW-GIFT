from __future__ import annotations

from sqlalchemy import Boolean, Float, ForeignKey, Integer, String, Text
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.models.base import Base, TimestampMixin, UUIDMixin


class GiftBox(UUIDMixin, TimestampMixin, Base):
    __tablename__ = "gift_boxes"

    name: Mapped[str] = mapped_column(String(255))
    name_ar: Mapped[str | None] = mapped_column(String(255), nullable=True)
    description: Mapped[str | None] = mapped_column(Text, nullable=True)
    description_ar: Mapped[str | None] = mapped_column(Text, nullable=True)
    price: Mapped[float] = mapped_column(Float, default=0.0)
    currency: Mapped[str] = mapped_column(String(3), default="IQD")
    image_url: Mapped[str | None] = mapped_column(Text, nullable=True)
    occasion: Mapped[str | None] = mapped_column(String(100), nullable=True)
    occasion_ar: Mapped[str | None] = mapped_column(String(100), nullable=True)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)

    items: Mapped[list["GiftBoxItem"]] = relationship(
        back_populates="gift_box", lazy="selectin", cascade="all, delete-orphan"
    )


class GiftBoxItem(UUIDMixin, Base):
    __tablename__ = "gift_box_items"

    gift_box_id: Mapped[str] = mapped_column(
        String(36), ForeignKey("gift_boxes.id")
    )
    product_id: Mapped[str] = mapped_column(
        String(36), ForeignKey("products.id")
    )
    quantity: Mapped[int] = mapped_column(Integer, default=1)

    gift_box: Mapped["GiftBox"] = relationship(back_populates="items")
    product: Mapped["Product"] = relationship(lazy="selectin")  # type: ignore[name-defined]
