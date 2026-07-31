from __future__ import annotations

from sqlalchemy import ForeignKey, String, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column, relationship

from .base import Base, TimestampMixin, UUIDMixin


class Favorite(UUIDMixin, TimestampMixin, Base):
    __tablename__ = "favorites"
    __table_args__ = (
        UniqueConstraint("user_id", "product_id", name="uq_user_product_fav"),
    )

    user_id: Mapped[str] = mapped_column(String(36), ForeignKey("users.id"))
    product_id: Mapped[str] = mapped_column(String(36), ForeignKey("products.id"))

    user: Mapped["User"] = relationship(back_populates="favorites", lazy="selectin")  # type: ignore[name-defined]
    product: Mapped["Product"] = relationship(lazy="selectin")  # type: ignore[name-defined]
