from __future__ import annotations

from fastapi import HTTPException
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.order import Order, OrderItem, OrderStatusHistory, OrderStatus
from app.models.product import Product
from app.models.gift_box import GiftBox
from app.models.coupon import Coupon
from app.schemas.order import OrderCreate


VALID_TRANSITIONS: dict[str, list[str]] = {
    OrderStatus.pending_approval.value: [OrderStatus.accepted.value, OrderStatus.cancelled.value],
    OrderStatus.accepted.value: [OrderStatus.preparing.value, OrderStatus.cancelled.value],
    OrderStatus.preparing.value: [OrderStatus.out_for_delivery.value, OrderStatus.cancelled.value],
    OrderStatus.out_for_delivery.value: [OrderStatus.delivered.value, OrderStatus.cancelled.value],
    OrderStatus.delivered.value: [],
    OrderStatus.cancelled.value: [],
}


async def create_order(db: AsyncSession, user_id: str, data: OrderCreate) -> Order:
    # resolve coupon
    coupon_id = None
    discount = 0.0
    if data.coupon_code:
        result = await db.execute(
            select(Coupon).where(Coupon.code == data.coupon_code, Coupon.is_active == True)
        )
        coupon = result.scalar_one_or_none()
        if not coupon:
            raise HTTPException(status_code=400, detail="Invalid coupon code")
        coupon_id = coupon.id
        discount = coupon.discount_value  # simplified

    total = 0.0
    order = Order(
        user_id=user_id,
        address_id=data.address_id,
        coupon_id=coupon_id,
        status=OrderStatus.pending_approval.value,
        payment_method=data.payment_method.value if data.payment_method else None,
        reward_points_used=data.reward_points_used,
        gift_message=data.gift_message,
        gift_message_ar=data.gift_message_ar,
        greeting_card_id=data.greeting_card_id,
        private_message=data.private_message,
        is_anonymous=data.is_anonymous,
        sender_display_name=data.sender_display_name,
        recipient_name=data.recipient_name,
        recipient_phone=data.recipient_phone,
        address=data.address,
        latitude=data.latitude,
        longitude=data.longitude,
        delivery_date=data.delivery_date,
        delivery_time=data.delivery_time,
        notes=data.notes,
    )
    db.add(order)
    await db.flush()

    for item_in in data.items:
        unit_price = 0.0
        if item_in.product_id:
            prod = await db.execute(select(Product).where(Product.id == item_in.product_id))
            product = prod.scalar_one_or_none()
            if product:
                unit_price = product.price
        elif item_in.gift_box_id:
            gb = await db.execute(select(GiftBox).where(GiftBox.id == item_in.gift_box_id))
            gift_box = gb.scalar_one_or_none()
            if gift_box:
                unit_price = gift_box.price

        oi = OrderItem(
            order_id=order.id,
            product_id=item_in.product_id,
            gift_box_id=item_in.gift_box_id,
            quantity=item_in.quantity,
            unit_price=unit_price,
        )
        db.add(oi)
        total += unit_price * item_in.quantity

    # apply discount (simplified)
    if discount > 0:
        total = max(0, total - discount)

    order.total = total
    order.discount_amount = discount

    # initial status history
    db.add(OrderStatusHistory(order_id=order.id, status=OrderStatus.pending_approval.value))
    await db.flush()
    return order


async def update_order_status(
    db: AsyncSession, order_id: str, new_status: str, note: str | None = None
) -> Order:
    result = await db.execute(select(Order).where(Order.id == order_id))
    order = result.scalar_one_or_none()
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")

    allowed = VALID_TRANSITIONS.get(order.status, [])
    if new_status not in allowed:
        raise HTTPException(
            status_code=400,
            detail=f"Cannot transition from '{order.status}' to '{new_status}'",
        )

    order.status = new_status
    db.add(OrderStatusHistory(order_id=order.id, status=new_status, note=note))
    await db.flush()
    return order
