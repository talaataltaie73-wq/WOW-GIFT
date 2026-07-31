"""Seed sample data: categories, products, gift boxes."""
from __future__ import annotations

import asyncio

from app.database import async_session_factory, init_db
from app.models.category import Category
from app.models.product import Product
from app.models.gift_box import GiftBox, GiftBoxItem


CATEGORIES = [
    {"name": "Chocolates", "name_ar": "شوكولاتة", "slug": "chocolates"},
    {"name": "Flowers", "name_ar": "زهور", "slug": "flowers"},
    {"name": "Perfumes", "name_ar": "عطور", "slug": "perfumes"},
    {"name": "Electronics", "name_ar": "إلكترونيات", "slug": "electronics"},
    {"name": "Fashion", "name_ar": "أزياء", "slug": "fashion"},
    {"name": "Home & Living", "name_ar": "المنزل والمعيشة", "slug": "home-living"},
]

PRODUCTS = [
    {
        "name": "Premium Dark Chocolate Box",
        "name_ar": "علبة شوكولاتة داكنة فاخرة",
        "price": 15000.0,
        "currency": "IQD",
        "stock": 50,
        "category_slug": "chocolates",
        "description": "Handcrafted Belgian dark chocolate assortment",
        "description_ar": "تشكيلة شوكولاتة بلجيكية داكنة مصنوعة يدوياً",
    },
    {
        "name": "Red Rose Bouquet",
        "name_ar": "باقة ورد أحمر",
        "price": 25000.0,
        "currency": "IQD",
        "stock": 30,
        "category_slug": "flowers",
        "description": "24 premium red roses with elegant wrapping",
        "description_ar": "24 وردة حمراء فاخرة بتغليف أنيق",
    },
    {
        "name": "Oud Perfume 50ml",
        "name_ar": "عطر عود 50 مل",
        "price": 45000.0,
        "currency": "IQD",
        "stock": 20,
        "category_slug": "perfumes",
        "description": "Luxury Arabian oud fragrance",
        "description_ar": "عطر عود عربي فاخر",
    },
    {
        "name": "Wireless Earbuds",
        "name_ar": "سماعات لاسلكية",
        "price": 35000.0,
        "currency": "IQD",
        "stock": 40,
        "category_slug": "electronics",
        "description": "Noise-cancelling Bluetooth earbuds",
        "description_ar": "سماعات بلوتوث بخاصية إلغاء الضوضاء",
    },
    {
        "name": "Silk Scarf",
        "name_ar": "وشاح حرير",
        "price": 22000.0,
        "currency": "IQD",
        "stock": 25,
        "category_slug": "fashion",
        "description": "Hand-painted silk scarf",
        "description_ar": "وشاح حرير مرسوم يدوياً",
    },
    {
        "name": "Scented Candle Set",
        "name_ar": "طقم شموع معطرة",
        "price": 12000.0,
        "currency": "IQD",
        "stock": 60,
        "category_slug": "home-living",
        "description": "Set of 3 luxury scented candles",
        "description_ar": "طقم من 3 شموع معطرة فاخرة",
    },
]

GIFT_BOXES = [
    {
        "name": "Birthday Surprise Box",
        "name_ar": "صندوق مفاجأة عيد الميلاد",
        "price": 55000.0,
        "currency": "IQD",
        "occasion": "Birthday",
        "occasion_ar": "عيد ميلاد",
        "description": "Curated birthday gift box with chocolates, candles, and a scarf",
        "description_ar": "صندوق هدايا عيد ميلاد منسق يحتوي على شوكولاتة وشموع ووشاح",
        "product_names": ["Premium Dark Chocolate Box", "Scented Candle Set", "Silk Scarf"],
    },
    {
        "name": "Romantic Evening Box",
        "name_ar": "صندوق السهرة الرومانسية",
        "price": 80000.0,
        "currency": "IQD",
        "occasion": "Anniversary",
        "occasion_ar": "ذكرى سنوية",
        "description": "Roses, perfume, and chocolates for a special evening",
        "description_ar": "ورود وعطر وشوكولاتة لسهرة مميزة",
        "product_names": ["Red Rose Bouquet", "Oud Perfume 50ml", "Premium Dark Chocolate Box"],
    },
]


async def seed():
    await init_db()

    async with async_session_factory() as session:
        # Categories
        cat_map: dict[str, Category] = {}
        for c in CATEGORIES:
            cat = Category(**c)
            session.add(cat)
            cat_map[c["slug"]] = cat
        await session.flush()

        # Products
        prod_map: dict[str, Product] = {}
        for p in PRODUCTS:
            slug = p.pop("category_slug")
            prod = Product(**p, category_id=cat_map[slug].id)
            session.add(prod)
            prod_map[p["name"]] = prod
        await session.flush()

        # Gift Boxes
        for gb in GIFT_BOXES:
            product_names = gb.pop("product_names")
            box = GiftBox(**gb)
            session.add(box)
            await session.flush()
            for pname in product_names:
                session.add(
                    GiftBoxItem(gift_box_id=box.id, product_id=prod_map[pname].id, quantity=1)
                )
            await session.flush()

        await session.commit()
        print("Seed data inserted successfully")


if __name__ == "__main__":
    asyncio.run(seed())
