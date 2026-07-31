from __future__ import annotations

from fastapi import HTTPException
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import settings
from app.models.merchant import Merchant
from app.models.order import Order, OrderItem, OrderStatus
from app.models.product import Product
from app.models.store import Store
from app.schemas.merchant import MerchantCreate, MerchantEarningsOut, MerchantUpdate


async def create_merchant(db: AsyncSession, user_id: str, data: MerchantCreate) -> Merchant:
    existing = await db.execute(select(Merchant).where(Merchant.user_id == user_id))
    if existing.scalar_one_or_none():
        raise HTTPException(status_code=400, detail="Merchant profile already exists")
    merchant = Merchant(user_id=user_id, **data.model_dump())
    db.add(merchant)
    await db.flush()
    return merchant


async def get_merchant_by_user(db: AsyncSession, user_id: str) -> Merchant:
    result = await db.execute(select(Merchant).where(Merchant.user_id == user_id))
    merchant = result.scalar_one_or_none()
    if not merchant:
        raise HTTPException(status_code=404, detail="Merchant not found")
    return merchant


async def get_merchant_by_id(db: AsyncSession, merchant_id: str) -> Merchant:
    result = await db.execute(select(Merchant).where(Merchant.id == merchant_id))
    merchant = result.scalar_one_or_none()
    if not merchant:
        raise HTTPException(status_code=404, detail="Merchant not found")
    return merchant


async def update_merchant(db: AsyncSession, merchant_id: str, data: MerchantUpdate) -> Merchant:
    merchant = await get_merchant_by_id(db, merchant_id)
    for field, value in data.model_dump(exclude_unset=True).items():
        setattr(merchant, field, value)
    await db.flush()
    return merchant


async def get_merchant_earnings(db: AsyncSession, merchant_id: str) -> MerchantEarningsOut:
    merchant = await get_merchant_by_id(db, merchant_id)

    # Get all store IDs for this merchant
    store_result = await db.execute(
        select(Store.id).where(Store.merchant_id == merchant_id)
    )
    store_ids = [row[0] for row in store_result.all()]

    gross_sales = 0.0
    total_delivered_orders = 0

    if store_ids:
        # Get all product IDs for merchant's stores
        product_result = await db.execute(
            select(Product.id).where(Product.store_id.in_(store_ids))
        )
        product_ids = [row[0] for row in product_result.all()]

        if product_ids:
            # Get delivered orders that contain merchant's products
            delivered_order_ids_result = await db.execute(
                select(OrderItem.order_id).distinct().where(
                    OrderItem.product_id.in_(product_ids)
                ).join(Order, Order.id == OrderItem.order_id).where(
                    Order.status == OrderStatus.delivered.value
                )
            )
            delivered_order_ids = [row[0] for row in delivered_order_ids_result.all()]
            total_delivered_orders = len(delivered_order_ids)

            if delivered_order_ids:
                # Sum up the merchant's items in delivered orders
                sales_result = await db.execute(
                    select(
                        func.sum(OrderItem.unit_price * OrderItem.quantity)
                    ).where(
                        OrderItem.order_id.in_(delivered_order_ids),
                        OrderItem.product_id.in_(product_ids),
                    )
                )
                gross_sales = sales_result.scalar() or 0.0

    commission_rate = settings.MERCHANT_COMMISSION_RATE
    commission_amount = round(gross_sales * commission_rate / 100.0, 2)
    net_earnings = round(gross_sales - commission_amount, 2)
    min_threshold = settings.MERCHANT_MIN_PAYOUT_THRESHOLD

    return MerchantEarningsOut(
        merchant_id=merchant_id,
        total_delivered_orders=total_delivered_orders,
        gross_sales=gross_sales,
        commission_rate=commission_rate,
        commission_amount=commission_amount,
        net_earnings=net_earnings,
        currency=settings.DEFAULT_CURRENCY,
        min_payout_threshold=min_threshold,
        eligible_for_payout=net_earnings >= min_threshold,
    )
