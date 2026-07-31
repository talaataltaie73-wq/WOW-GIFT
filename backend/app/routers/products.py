from __future__ import annotations

from fastapi import APIRouter, Depends, Query
from sqlalchemy import desc, func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.dependencies import require_admin
from app.models.order import OrderItem
from app.models.product import Product
from app.models.user import User
from app.schemas.product import ProductCreate, ProductOut, ProductUpdate
from app.services.crud import create_record, get_all, get_by_id, update_record

router = APIRouter(prefix="/products", tags=["products"])


@router.get("/", response_model=list[ProductOut])
async def list_products(
    category_id: str | None = Query(default=None),
    store_id: str | None = Query(default=None),
    db: AsyncSession = Depends(get_db),
):
    filters: dict = {"is_active": True}
    if category_id:
        filters["category_id"] = category_id
    if store_id:
        filters["store_id"] = store_id
    return await get_all(db, Product, **filters)


@router.get("/best-sellers", response_model=list[ProductOut])
async def best_sellers(
    limit: int = Query(default=10, ge=1, le=50),
    db: AsyncSession = Depends(get_db),
):
    """Products ordered by total quantity sold (via OrderItem)."""
    stmt = (
        select(Product)
        .outerjoin(OrderItem, OrderItem.product_id == Product.id)
        .where(Product.is_active == True)  # noqa: E712
        .group_by(Product.id)
        .order_by(desc(func.coalesce(func.sum(OrderItem.quantity), 0)))
        .limit(limit)
    )
    result = await db.execute(stmt)
    return result.scalars().all()


@router.get("/latest", response_model=list[ProductOut])
async def latest_products(
    limit: int = Query(default=10, ge=1, le=50),
    db: AsyncSession = Depends(get_db),
):
    """Most recently created active products."""
    stmt = (
        select(Product)
        .where(Product.is_active == True)  # noqa: E712
        .order_by(desc(Product.created_at))
        .limit(limit)
    )
    result = await db.execute(stmt)
    return result.scalars().all()


@router.get("/best-deals", response_model=list[ProductOut])
async def best_deals(
    limit: int = Query(default=10, ge=1, le=50),
    db: AsyncSession = Depends(get_db),
):
    """Products with a discount_price set (i.e. on sale)."""
    stmt = (
        select(Product)
        .where(
            Product.is_active == True,  # noqa: E712
            Product.discount_price.isnot(None),
            Product.discount_price < Product.price,
        )
        .order_by(desc(Product.price - Product.discount_price))
        .limit(limit)
    )
    result = await db.execute(stmt)
    products = result.scalars().all()
    # Fallback: if no deals exist yet, return latest products
    if not products:
        stmt = (
            select(Product)
            .where(Product.is_active == True)  # noqa: E712
            .order_by(desc(Product.created_at))
            .limit(limit)
        )
        result = await db.execute(stmt)
        products = result.scalars().all()
    return products


@router.get("/{product_id}", response_model=ProductOut)
async def get_product(product_id: str, db: AsyncSession = Depends(get_db)):
    return await get_by_id(db, Product, product_id)


@router.post("/", response_model=ProductOut, status_code=201)
async def create_product(
    data: ProductCreate,
    _: User = Depends(require_admin),
    db: AsyncSession = Depends(get_db),
):
    return await create_record(db, Product, data.model_dump())


@router.patch("/{product_id}", response_model=ProductOut)
async def patch_product(
    product_id: str,
    data: ProductUpdate,
    _: User = Depends(require_admin),
    db: AsyncSession = Depends(get_db),
):
    return await update_record(db, Product, product_id, data.model_dump(exclude_unset=True))
