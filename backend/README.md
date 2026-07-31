# Wow Gift API -- Backend

FastAPI backend for the **Wow Gift** gift-giving platform targeting **Iraq** (currency: **IQD**).

## Architecture

Wow Gift has exactly **two surfaces**:

1. **Customer Mobile App** (Flutter) -- end-customer gift browsing, building, checkout, and tracking.
2. **Admin Dashboard** (React web) -- full platform management including merchant/store oversight, product catalog, orders, reports, and payouts.

There is no merchant-facing self-service dashboard. All merchant and store management is performed by administrators through the admin dashboard.

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | FastAPI |
| ORM | SQLAlchemy 2.0 (async) |
| DB (dev) | SQLite + aiosqlite |
| DB (prod) | PostgreSQL + asyncpg |
| Auth | JWT (python-jose) + bcrypt (passlib) |
| Validation | Pydantic v2 |
| Migrations | Alembic |
| Testing | pytest + httpx + pytest-asyncio |

## Quick Start

```bash
# 1. Create virtual environment
python -m venv venv
venv\Scripts\activate        # Windows
# source venv/bin/activate   # macOS / Linux

# 2. Install dependencies
pip install -r requirements.txt

# 3. Copy env file
copy .env.example .env       # Windows
# cp .env.example .env       # macOS / Linux

# 4. Run the server (auto-creates tables on startup)
uvicorn main:app --reload --port 8000

# 5. Seed sample data
python seed.py

# 6. Open API docs
# http://localhost:8000/docs
```

## Alembic Migrations

```bash
# Generate a new migration after model changes
alembic revision --autogenerate -m "describe change"

# Apply migrations
alembic upgrade head
```

## Running Tests

```bash
pytest -v
```

## Project Structure

```
backend/
├── main.py                  # FastAPI app entry point
├── seed.py                  # Sample data seeder
├── alembic.ini              # Alembic config
├── alembic/                 # Migration scripts
│   ├── env.py
│   ├── script.py.mako
│   └── versions/
├── app/
│   ├── core/
│   │   ├── config.py        # Settings (env-based, IQD currency, payout config)
│   │   └── security.py      # JWT + password hashing
│   ├── database.py          # Async engine & session
│   ├── dependencies.py      # Auth dependencies (require_admin guards all management ops)
│   ├── models/              # SQLAlchemy models
│   │   ├── user.py
│   │   ├── merchant.py
│   │   ├── merchant_payout.py
│   │   ├── store.py
│   │   ├── category.py
│   │   ├── product.py
│   │   ├── gift_box.py
│   │   ├── order.py         # OrderStatus & PaymentMethod enums
│   │   ├── address.py
│   │   ├── coupon.py
│   │   ├── favorite.py
│   │   ├── notification.py
│   │   └── occasion_reminder.py
│   ├── schemas/             # Pydantic v2 schemas
│   ├── services/            # Business logic
│   │   ├── auth_service.py
│   │   ├── user_service.py
│   │   ├── merchant_service.py  # Includes earnings calculation
│   │   ├── order_service.py
│   │   └── crud.py
│   └── routers/             # API endpoints
│       ├── auth.py
│       ├── users.py
│       ├── merchants.py     # Admin-only merchant management & earnings
│       ├── stores.py
│       ├── categories.py
│       ├── products.py
│       ├── gift_boxes.py
│       ├── orders.py
│       ├── addresses.py
│       ├── coupons.py
│       ├── favorites.py
│       ├── notifications.py
│       └── reminders.py
├── tests/
│   ├── test_api.py
│   └── test_orders_and_earnings.py
├── requirements.txt
└── .env.example
```

## Currency

All prices are in **IQD** (Iraqi Dinar). The default currency is configured in `app/core/config.py`.

## Merchant Payout

| Setting | Default |
|---------|---------|
| Commission rate | 10% of each successful sale |
| Calculated on | Order delivery completion (status = `delivered`) |
| Payout schedule | Weekly, every Sunday |
| Minimum payout | 50,000 IQD |

These settings are administered via the admin dashboard.

## Order Status Flow

```
pending_approval -> accepted -> preparing -> out_for_delivery -> delivered
       |              |           |              |
   cancelled      cancelled   cancelled      cancelled
```

## Payment Methods

- `cash_on_delivery`
- `zain_cash`
- `asia_hawala`
- `mastercard`
- `visa`
- `e_wallet`

## API Endpoints

All endpoints are prefixed with `/api/v1`.

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| POST | /auth/register | - | Register customer account |
| POST | /auth/login | - | Login, returns JWT |
| POST | /auth/phone/request-otp | JWT | Request phone verification OTP (SMS or WhatsApp) |
| POST | /auth/phone/verify-otp | JWT | Verify OTP code and mark phone as verified |
| GET | /users/me | JWT | Current user profile (includes phone_verified) |
| PATCH | /users/me | JWT | Update profile |
| POST | /merchants/ | Admin | Create merchant profile |
| GET | /merchants/me | Admin | Merchant profile (admin context) |
| GET | /merchants/me/earnings | Admin | Merchant earnings (admin context) |
| GET/PATCH | /merchants/{id} | - / Admin | Get / update merchant |
| GET | /merchants/{id}/earnings | Admin | Merchant earnings by ID |
| GET/POST | /stores/ | - / Admin | List / create stores |
| GET/PATCH | /stores/{id} | - / Admin | Get / update store |
| GET/POST | /categories/ | - / Admin | List / create categories |
| GET/PATCH | /categories/{id} | - / Admin | Get / update category |
| GET/POST | /products/ | - / Admin | List / create products |
| GET/PATCH | /products/{id} | - / Admin | Get / update product |
| GET/POST | /gift-boxes/ | - / Admin | List / create gift boxes |
| GET/PATCH | /gift-boxes/{id} | - / Admin | Get / update gift box |
| GET/POST | /orders/ | JWT | List / place orders |
| GET | /orders/{id} | JWT | Get order details |
| PATCH | /orders/{id}/status | Admin | Update order status |
| GET/POST | /addresses/ | JWT | List / create addresses |
| PATCH/DELETE | /addresses/{id} | JWT | Update / delete address |
| GET/POST | /coupons/ | Admin | List / create coupons |
| GET/PATCH | /coupons/{id} | Admin | Get / update coupon |
| GET/POST | /favorites/ | JWT | List / add favorites |
| DELETE | /favorites/{id} | JWT | Remove favorite |
| GET | /notifications/ | JWT | List notifications |
| PATCH | /notifications/{id}/read | JWT | Mark as read |
| GET/POST | /reminders/ | JWT | List / create reminders |
| GET/PATCH/DELETE | /reminders/{id} | JWT | Get / update / delete |

## i18n / RTL Support

All content models include `_ar` fields (e.g., `name_ar`, `description_ar`) for Arabic translations. The user model stores a `locale` preference (`ar` by default).

## Phone Verification (OTP)

Phone verification is required before a customer can place an order (checkout gate). The verified phone belongs to the user account — the order's recipient phone is a separate, unverified field.

### Flow

1. Customer calls `POST /api/v1/auth/phone/request-otp` with `{ "phone": "+9647XXXXXXXX", "channel": "sms" }`.
2. In dev mode (`OTP_DEV_MODE=true`), the response includes `dev_code` with the OTP.
3. Customer calls `POST /api/v1/auth/phone/verify-otp` with `{ "request_id": "<uuid>", "code": "123456" }`.
4. On success, the user's phone is marked as verified. Orders can now be placed.

### Settings

| Setting | Default | Description |
|---------|---------|-------------|
| `OTP_LENGTH` | 6 | Number of digits in the OTP code |
| `OTP_TTL_SECONDS` | 300 | Code validity window (5 minutes) |
| `OTP_MAX_ATTEMPTS` | 5 | Max wrong attempts per request |
| `OTP_RESEND_COOLDOWN_SECONDS` | 60 | Minimum wait between requests |
| `OTP_MAX_REQUESTS_PER_PHONE_PER_HOUR` | 5 | Rate limit per phone per hour |
| `OTP_DEV_MODE` | true | **MUST be `false` in production** — exposes `dev_code` |
| `OTP_PROVIDER` | mock | `"mock"` (dev) or `"twilio"` (production) |
| `TWILIO_ACCOUNT_SID` | | Required when `OTP_PROVIDER=twilio` |
| `TWILIO_AUTH_TOKEN` | | Required when `OTP_PROVIDER=twilio` |
| `TWILIO_SMS_FROM` | | Twilio SMS sender number |
| `TWILIO_WHATSAPP_FROM` | | Twilio WhatsApp sender number |

> **Production checklist:** Before launch, set `OTP_DEV_MODE=false` and configure a real provider (`OTP_PROVIDER=twilio` with valid Twilio credentials).
