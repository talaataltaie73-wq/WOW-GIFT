from __future__ import annotations

from types import SimpleNamespace

from fastapi import APIRouter

_ROUTER_NAMES = [
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


def _make_router(name: str) -> SimpleNamespace:
    router = APIRouter(tags=[name])

    @router.get(f"/{name}")
    async def placeholder() -> dict[str, str]:
        return {"module": name, "status": "ready"}

    return SimpleNamespace(router=router)


for _name in _ROUTER_NAMES:
    globals()[_name] = _make_router(_name)


__all__ = _ROUTER_NAMES
