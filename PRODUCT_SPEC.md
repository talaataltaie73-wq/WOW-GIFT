# Wow Gift - Product Spec (Arabic RTL Mobile Gift App)

## Brand
- Name: Wow Gift
- Tagline: "أهدي بطريقة تُبهر."
- Primary: Emerald #0F766E
- Accent: Gold #D4AF37
- Background: White #FFFFFF
- Text: Dark Charcoal #111827
- Buttons: Emerald background, white text

## Product Surfaces

Wow Gift has exactly **two surfaces**:

1. **Customer Mobile App** (Flutter) -- the end-customer experience for browsing, building, purchasing, and tracking gifts.
2. **Admin Dashboard** (React web) -- comprehensive platform management including user management, store approvals, product catalog, order management, merchant oversight, earnings/commission reports, and payouts.

There is no merchant-facing self-service dashboard. All merchant and store management is performed exclusively by administrators through the admin dashboard.

## User Flows (Customer Mobile App)
1. Splash -> animated ribbons forming "Wow Gift" + gift box + tagline.
2. Home: search, promo banner, occasions, categories, best offers, featured stores, latest products, best sellers.
3. Occasion reminder: user adds event date, gets notification before.
4. AI Gift Assistant: occasion, recipient, gender, age, budget, hobbies -> suggestions.
5. Gift Boxes: choose physical box (image, name, price, color, size, description).
6. Products: list by category; tap product -> product detail (images, name, description, price, rating, store, quantity, discount, add to gift box, favorite, share).
7. Product detail -> store page for that product.
8. Gift customization: greeting card, private message, anonymous/sender name, preview.
9. Delivery: recipient name, phone, address, map pin, date/time, notes; live order status.
10. Payment: cash on delivery, Zain Cash, AsiaHawala, Master/Visa, e-wallets, coupons, reward points.
11. Orders: statuses pending/accepted/preparing/out-for-delivery/delivered/cancelled.
12. Profile: personal info, addresses, payment methods, previous orders, favorites, points, settings, dark mode, support.

## Admin Dashboard (web)
- Users, stores, store approval, products, orders, categories, ads, coupons, reports, notifications.
- Merchant management: create/edit merchant profiles, assign stores, view earnings, process payouts.
- All merchant-level operations (product CRUD, store management, order status changes) are admin-only.

## Merchant Terms (administered via Admin Dashboard)
- 10% commission per successful sale after delivery.
- Payout weekly on Sundays, min 50,000 IQD.
- Quality, 24h response, privacy, accurate stock, on-time fulfillment.

## Tech Stack
- Flutter mobile app (RTL Arabic primary, i18n ready).
- FastAPI backend.
- SQLite dev / PostgreSQL prod.
- SQLAlchemy.
- JWT auth.
- FCM notifications.
- Google Maps.
- Clean Architecture.

## First Build Phase
Implement splash + home screen in Flutter according to chosen bold-modern comp.
