from __future__ import annotations

from pydantic import BaseModel, ConfigDict


class FavoriteCreate(BaseModel):
    product_id: str


class FavoriteOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    user_id: str
    product_id: str
