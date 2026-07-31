from __future__ import annotations

# Expose submodule modules so main.py can import them as attributes.
from . import (
    auth,
    users,
    merchants,
    stores,
    categories,
    products,
    gift_boxes,
    orders,
    addresses,
    coupons,
    favorites,
    notifications,
    reminders,
    phone,
    banners,
)

__all__ = [
    "auth",
    "users",
    "merchants",
    "stores",
    "categories",
    "products",
    "gift_boxes",
    "orders",
    "addresses",
    "coupons",
    "favorites",
    "notifications",
    "reminders",
    "phone",
    "banners",
]
