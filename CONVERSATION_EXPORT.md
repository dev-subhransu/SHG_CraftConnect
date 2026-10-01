# 🧵 SHG & Artisan Social Commerce Platform — Full Conversation Export

> **Exported from:** Antigravity IDE · Conversation: "Artisan Social Commerce Platform"
> **Date:** 2026-10-01
> **Project Location:** `C:\Users\Subhransu Jena\.gemini\antigravity\scratch\artisan_market`
> **Status:** ✅ Fully built, all tests passing

---

## 📋 Table of Contents

1. [Original Request](#1-original-request)
2. [Architecture & Design Decisions](#2-architecture--design-decisions)
3. [Project File Tree](#3-project-file-tree)
4. [Backend: FastAPI + PostgreSQL](#4-backend-fastapi--postgresql)
5. [Frontend: Flutter](#5-frontend-flutter)
6. [Test Results](#6-test-results)
7. [How to Run Locally](#7-how-to-run-locally)
8. [Flutter Setup (PATH Fix Applied)](#8-flutter-setup-path-fix-applied)
9. [Cloud Run Deployment](#9-cloud-run-deployment)
10. [Key Design Patterns](#10-key-design-patterns)

---

## 1. Original Request

> Build a cross-platform mobile app (iOS and Android) using Flutter for the frontend and a Python FastAPI backend (with PostgreSQL) to serve as a **social commerce platform for SHGs and Artisans**.
>
> **Core Features:**
> 1. **Discovery Feed (Instagram-style):** Vertically scrollable feed of artisan product posts. Each post must feature a prominent **"Buy Now"** button instead of a traditional "Like" button.
> 2. **Instant Checkout Overlay:** When "Buy Now" is clicked, bypass the traditional shopping cart entirely. Slide up an instant order page that displays item price, captures buyer's shipping details, and integrates a mock payment gateway (prepared for Razorpay/Stripe integration).
> 3. **Seller Dashboard:** Upload new posts, set prices, automatically toggle inventory to "Sold Out" after a purchase, and view a simple ledger of active orders and completed payouts.
>
> **Technical Requirements:**
> - Monorepo with `frontend/` (Flutter) and `backend/` (FastAPI) directories
> - `requirements.txt` and `pubspec.yaml` with all dependencies
> - Production-ready, clean, well-commented code
> - Dockerfile for Google Cloud Run deployment
> - `README.md` with step-by-step instructions

---

## 2. Architecture & Design Decisions

| Decision | Choice | Reason |
|---|---|---|
| **Backend Framework** | FastAPI | Async, Pydantic v2, auto-generates OpenAPI docs |
| **Database** | PostgreSQL (prod) / SQLite (local dev) | Zero-config local testing; postgres for production |
| **ORM** | SQLAlchemy 2.0 | Mature, type-safe, sync sessions |
| **Payment Gateway** | Pluggable (Mock → Razorpay → Stripe) | Switch via `.env` without code changes |
| **Platform Fee** | 5% | SHG-friendly economics, configurable |
| **Flutter Architecture** | MVVM + Repository Pattern | Strict separation of concerns, testable |
| **State Management** | `ChangeNotifier` + `ListenableBuilder` | Native Flutter, no extra dependencies |
| **Flutter Theme** | Warm Terracotta + Indigo | Cultural artisan aesthetic palette |
| **Auto Sold-Out** | Atomic DB decrement | When stock hits 0, post status auto-flips to `SOLD_OUT` |
| **Offline Fallback** | Embedded seed data in Flutter | UI testing without backend running |
| **Container** | `python:3.11-slim`, non-root `appuser` | Hardened for Google Cloud Run |

---

## 3. Project File Tree

```
artisan_market/
├── docker-compose.yml          ← PostgreSQL 16 + FastAPI, local multi-container
├── README.md                   ← Full setup, migration & deployment guide
├── backend/
│   ├── Dockerfile              ← Cloud Run optimized, $PORT aware
│   ├── requirements.txt        ← All Python dependencies
│   ├── .env.example            ← Environment template
│   ├── seed_data.py            ← Seeds 5 SHGs, 6 craft products, 2 orders, 1 payout
│   ├── app/
│   │   ├── main.py             ← FastAPI app, CORS, startup seeding, /health
│   │   ├── core/
│   │   │   ├── config.py       ← Pydantic-settings: DB, payment, CORS, fee %
│   │   │   └── database.py     ← SQLAlchemy engine, SessionLocal, init_db()
│   │   ├── models/
│   │   │   ├── artisan.py      ← Artisan/SHG profiles, bank details
│   │   │   ├── post.py         ← Product posts, stock, AVAILABLE/SOLD_OUT status
│   │   │   ├── order.py        ← Instant orders, buyer info, payment lifecycle
│   │   │   └── payout.py       ← Artisan earnings disbursements
│   │   ├── schemas/
│   │   │   ├── artisan.py      ← Pydantic schemas for artisan CRUD
│   │   │   ├── post.py         ← PostFeedItem (with embedded artisan)
│   │   │   ├── order.py        ← InstantCheckoutRequest, OrderResponse
│   │   │   ├── payout.py       ← SellerLedgerSummary (full financial dashboard)
│   │   │   └── payment.py      ← PaymentInitiateRequest/Response, VerificationRequest
│   │   ├── services/
│   │   │   ├── payment_gateway.py   ← Abstract PaymentGateway + Mock/Razorpay/Stripe
│   │   │   ├── inventory_service.py ← Atomic stock decrement + auto SOLD_OUT toggle
│   │   │   └── ledger_service.py    ← Gross sales, fees, net earnings, payouts calc
│   │   └── api/v1/
│   │       ├── router.py       ← Combines all API routers
│   │       ├── posts.py        ← Discovery feed endpoints + inventory toggle
│   │       ├── orders.py       ← /instant-checkout endpoint + fulfillment tracking
│   │       ├── artisans.py     ← Seller dashboard: ledger, orders, payouts
│   │       └── payments.py     ← Initiate, verify, webhook endpoints
│   └── tests/
│       └── test_api.py         ← 5 integration tests (all PASSED)
└── frontend/
    ├── pubspec.yaml            ← Flutter deps: http, intl, provider, etc.
    ├── analysis_options.yaml
    ├── lib/
    │   ├── main.dart           ← App entrypoint, AppTheme, MaterialApp
    │   ├── core/
    │   │   ├── theme/app_theme.dart       ← Terracotta + Indigo cultural palette
    │   │   └── constants/api_constants.dart ← Platform-aware host (Android 10.0.2.2 / iOS localhost)
    │   ├── data/
    │   │   ├── models/
    │   │   │   ├── artisan.dart           ← Artisan domain model
    │   │   │   ├── post.dart              ← ProductPost with isSoldOut getter
    │   │   │   ├── order.dart             ← InstantCheckoutRequest + OrderReceipt
    │   │   │   └── seller_ledger.dart     ← SellerLedger + PayoutRecord
    │   │   ├── services/
    │   │   │   └── artisan_api_service.dart ← HTTP calls + offline fallback seed data
    │   │   └── repositories/
    │   │       └── artisan_repository.dart  ← Clean domain separation
    │   └── ui/features/
    │       ├── feed/
    │       │   ├── view_models/feed_view_model.dart    ← Feed state, SOLD_OUT reaction
    │       │   └── views/
    │       │       ├── feed_screen.dart         ← Vertical PageView + category chips
    │       │       ├── feed_item_card.dart      ← Full-bleed card with ⚡ Buy Now button
    │       │       └── artisan_story_sheet.dart ← Heritage craft narrative modal
    │       ├── checkout/
    │       │   ├── view_models/checkout_view_model.dart ← Checkout state + payment routing
    │       │   └── views/
    │       │       ├── instant_checkout_bottom_sheet.dart ← Slide-up sheet (cart-free)
    │       │       └── order_success_dialog.dart          ← Celebratory receipt dialog
    │       ├── seller_dashboard/
    │       │   ├── view_models/seller_view_model.dart    ← Dashboard state management
    │       │   └── views/
    │       │       ├── seller_dashboard_screen.dart ← Inventory + Orders + Payouts tabs
    │       │       └── create_post_modal.dart       ← Upload new craft piece modal
    │       └── navigation/
    │           └── views/main_navigation_shell.dart ← Bottom nav (Discover + Artisan Hub)
    └── test/
        ├── feed_view_model_test.dart       ← Tests SOLD_OUT auto-toggle
        └── checkout_view_model_test.dart   ← Tests instant order + fee calculation
```

---

## 4. Backend: FastAPI + PostgreSQL

### Key API Endpoints

| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/health` | Container health probe (Cloud Run) |
| `GET` | `/api/v1/posts` | Instagram-style discovery feed (paginated, filterable by craft type) |
| `GET` | `/api/v1/posts/{id}` | Single post detail with artisan metadata |
| `POST` | `/api/v1/posts` | Artisan uploads new craft product post |
| `PATCH` | `/api/v1/posts/{id}/inventory` | Toggle AVAILABLE/SOLD_OUT or restock |
| `POST` | `/api/v1/orders/instant-checkout` | ⚡ Cart-free single-item instant purchase |
| `GET` | `/api/v1/orders/{id}` | Order status and delivery tracking |
| `PATCH` | `/api/v1/orders/{id}/fulfillment` | Update to DISPATCHED / DELIVERED |
| `GET` | `/api/v1/artisans` | List all SHGs and artisans |
| `POST` | `/api/v1/artisans` | Register new artisan/SHG |
| `GET` | `/api/v1/artisans/{id}/ledger` | Full seller financial dashboard |
| `GET` | `/api/v1/artisans/{id}/orders` | Artisan's incoming orders list |
| `POST` | `/api/v1/artisans/{id}/payouts` | Disburse pending balance to bank |
| `POST` | `/api/v1/payments/initiate` | Start payment (Mock/Razorpay/Stripe) |
| `POST` | `/api/v1/payments/verify` | Verify payment signature |
| `POST` | `/api/v1/payments/webhook` | Gateway async webhook handler |

### Instant Checkout Flow (Backend Logic)
```
POST /api/v1/orders/instant-checkout
  1. Validate product post exists + is not SOLD_OUT
  2. Calculate: total = price × qty, platform_fee = total × 5%, net = total - fee
  3. Atomically decrement stock_quantity
  4. If stock_quantity == 0 → auto-set status = SOLD_OUT
  5. Call payment gateway (Mock → PAID immediately, Razorpay/Stripe → async)
  6. Persist Order record
  7. Return enriched OrderReceipt (item_title, artisan_name, shg_name)
```

### Payment Gateway Configuration (`.env`)
```env
# Switch by changing just this one line:
PAYMENT_PROVIDER=mock        # or: razorpay, stripe

RAZORPAY_KEY_ID=rzp_test_...
RAZORPAY_KEY_SECRET=...
STRIPE_SECRET_KEY=sk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...
PLATFORM_FEE_PERCENTAGE=5.0
```

### Seed Data (5 Real Indian SHG Artisans)
| Artisan | SHG | Craft | Location |
|---|---|---|---|
| Sunita Devi | Mithila Shakti Mahila SHG | Madhubani Folk Painting | Ranti, Madhubani, Bihar |
| Lakshmi Narsimha | Pochampally Weavers Sahakari Sangham | Ikat Handloom Weaving | Bhoodan Pochampally, Telangana |
| Banamali Rana | Bastar Adivasi Dhokra Shilpi Samiti | Lost-Wax Brass & Bronze | Kondagaon, Bastar, CG |
| Meenakshi Rathore | Marwar Blue Pottery Collective | Jaipur Traditional Blue Pottery | Sanganer, Jaipur, Rajasthan |
| Gowramma & Mahila Mandali | Channapatna Wooden Toys Federation | Lacquered Wooden Craft | Channapatna, Karnataka |

---

## 5. Frontend: Flutter

### App Theme (AppColors)
```dart
terracotta   = Color(0xFFC85A32)   // Primary CTA
deepIndigo   = Color(0xFF1E2D3E)   // Secondary / headers
forestGreen  = Color(0xFF2A9D8F)   // Stock / success badges
goldAccent   = Color(0xFFE9C46A)   // Price labels
parchment    = Color(0xFFF9F6F0)   // Scaffold background
soldOutBadge = Color(0xFFD90429)   // Out of stock
```

### Platform-Aware API URL (`api_constants.dart`)
```dart
// Automatically resolves the correct host:
Android Emulator → http://10.0.2.2:8000/api/v1
iOS Simulator    → http://localhost:8000/api/v1
Chrome/Web       → http://localhost:8000/api/v1
```

### Key UI Components

**1. FeedItemCard (feed_item_card.dart)**
- Full-bleed media image with gradient overlay
- Top: Verified SHG badge with group name
- Right sidebar: Story, Share, Impact action buttons
- Bottom: Artisan profile, product title, craft description, price
- **Prominent `⚡ Buy Now • ₹{price}` ElevatedButton** (replaces Like button)
- Dynamic `SOLD OUT` badge and disabled button state

**2. InstantCheckoutBottomSheet (instant_checkout_bottom_sheet.dart)**
- Slides up instantly on "Buy Now" tap
- Product summary card at top
- Pre-filled shipping form (Name, Phone, Address, City, State, Pincode)
- Payment method selector: ⚡ Mock | 🇮🇳 Razorpay | 💳 Stripe
- Transparent pricing breakdown
- `Slide to Pay • ₹{price}` confirm button

**3. OrderSuccessDialog (order_success_dialog.dart)**
- Celebratory green checkmark
- Order reference number
- "Direct Artisan Impact" box: shows exact ₹ credited to artisan's SHG account
- Delivery summary

**4. SellerDashboardScreen (seller_dashboard_screen.dart)**
- Artisan selector dropdown (switch between registered artisans)
- Financial header card (Gross Sales / Net Earnings / Pending Balance + Disburse button)
- **Tab 1: Inventory** — product cards with In Stock/Sold Out toggle switch
- **Tab 2: Orders** — buyer info, shipping address, artisan net share per order
- **Tab 3: Payouts** — bank transfer history with UTR reference numbers
- FAB: "➕ New Post" → triggers CreatePostModal

---

## 6. Test Results

### Backend Tests (`pytest tests/ -v`)
```
tests/test_api.py::test_health_check                         PASSED ✅
tests/test_api.py::test_discovery_feed                       PASSED ✅
tests/test_api.py::test_instant_checkout_and_auto_sold_out   PASSED ✅
tests/test_api.py::test_seller_ledger_and_dashboard          PASSED ✅
tests/test_api.py::test_artisan_inventory_toggle             PASSED ✅

======================== 5 passed in 1.77s ========================
```

### Flutter Tests (`flutter test`)
```
+1: CheckoutViewModel Tests - processInstantCheckout submits successfully and returns receipt
+2: FeedViewModel Tests - loadFeed populates posts list successfully
+3: FeedViewModel Tests - decrementPostStock automatically switches to SOLD_OUT when stock reaches 0

All tests passed! ✅
```

### End-to-End Verification (Live Script)
```
Feed count: 6 products returned ✅
Ledger net_earnings: ₹4748.10 ✅
Instant Checkout Order: ORD-20261001-C09FCE  Status: PAID ✅
Post #3 (Dhokra elephant, 1 unit) auto-toggled status: SOLD_OUT, stock: 0 ✅
```

---

## 7. How to Run Locally

### Option A: Pure Python + SQLite (Zero Config)
```powershell
# 1. Navigate to backend
cd "C:\Users\Subhransu Jena\.gemini\antigravity\scratch\artisan_market\backend"

# 2. Create virtualenv
python -m venv venv
.\venv\Scripts\Activate.ps1

# 3. Install dependencies
pip install -r requirements.txt

# 4. Copy env file
copy .env.example .env

# 5. Start server (auto-creates SQLite DB and seeds data on first run)
python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload

# 6. Open Swagger UI
# → http://localhost:8000/docs
```

### Option B: Docker Compose (PostgreSQL + FastAPI)
```powershell
cd "C:\Users\Subhransu Jena\.gemini\antigravity\scratch\artisan_market"
docker-compose up --build
# Backend: http://localhost:8000/docs
# PostgreSQL: localhost:5432
```

### Run Flutter App
```powershell
cd "C:\Users\Subhransu Jena\.gemini\antigravity\scratch\artisan_market\frontend"
C:\src\flutter\bin\flutter.bat pub get
C:\src\flutter\bin\flutter.bat run -d chrome
# Or on device: C:\src\flutter\bin\flutter.bat run
```

### Run All Tests
```powershell
# Backend tests:
cd backend
python -m pytest tests/ -v

# Flutter tests:
cd ../frontend
C:\src\flutter\bin\flutter.bat test
```

---

## 8. Flutter Setup (PATH Fix Applied)

During this conversation, Flutter was found installed at `C:\src\flutter` but was not on the system PATH. We fixed this by adding `C:\src\flutter\bin` to the Windows User PATH via the Windows Registry:

```
Flutter Version: 3.47.5 (stable channel)
Dart Version:    3.13.4
DevTools:        2.60.0
Installation:    C:\src\flutter\bin\flutter.bat
```

**To use `flutter` directly in new terminals** (without full path), you must **open a new PowerShell/CMD window** after the PATH update takes effect.

---

## 9. Cloud Run Deployment

```bash
# 1. Set GCP project
gcloud config set project YOUR_GCP_PROJECT_ID
gcloud services enable run.googleapis.com sqladmin.googleapis.com

# 2. Create Cloud SQL PostgreSQL instance
gcloud sql instances create artisan-postgres-instance \
    --database-version=POSTGRES_16 --tier=db-f1-micro --region=asia-south1
gcloud sql databases create artisan_db --instance=artisan-postgres-instance

# 3. Build and push image
cd backend
gcloud builds submit --tag gcr.io/YOUR_PROJECT_ID/artisan-backend:v1

# 4. Deploy to Cloud Run
gcloud run deploy artisan-backend \
    --image gcr.io/YOUR_PROJECT_ID/artisan-backend:v1 \
    --platform managed --region asia-south1 --allow-unauthenticated \
    --add-cloudsql-instances YOUR_PROJECT_ID:asia-south1:artisan-postgres-instance \
    --set-env-vars "ENVIRONMENT=production,DATABASE_URL=postgresql+psycopg2://postgres:PASSWORD@/artisan_db?host=/cloudsql/YOUR_PROJECT_ID:asia-south1:artisan-postgres-instance,PAYMENT_PROVIDER=mock"

# 5. Update Flutter to point to Cloud Run URL:
# In frontend/lib/core/constants/api_constants.dart:
# ApiConstants.customBaseUrl = 'https://artisan-backend-xyz.a.run.app/api/v1';
```

---

## 10. Key Design Patterns

### Backend: Pluggable Payment Gateway (Strategy Pattern)
```python
# Switch providers with one .env change. No code changes needed.
class PaymentGateway(ABC):
    def create_order(...) -> Dict: ...
    def verify_payment(...) -> bool: ...

class MockPaymentGateway(PaymentGateway): ...    # PAYMENT_PROVIDER=mock
class RazorpayPaymentGateway(PaymentGateway): ... # PAYMENT_PROVIDER=razorpay
class StripePaymentGateway(PaymentGateway): ...   # PAYMENT_PROVIDER=stripe

def get_payment_gateway() -> PaymentGateway:
    return {mock: Mock, razorpay: Razorpay, stripe: Stripe}[settings.PAYMENT_PROVIDER]
```

### Flutter: MVVM + Repository (Layered Architecture)
```
View (Widget) → ViewModel (ChangeNotifier) → Repository → Service (HTTP)
                                              ↓
                                     Domain Models (Artisan, Post, Order)
```

### Automated Inventory Depletion
```python
# InventoryService.decrement_stock_and_toggle_sold_out()
post.stock_quantity -= quantity
if post.stock_quantity <= 0:
    post.stock_quantity = 0
    post.status = PostStatus.SOLD_OUT.value  # Automatic!
db.commit()
```

---

## 📌 Quick Reference: All File Paths

| File | Purpose |
|---|---|
| `backend/app/main.py` | FastAPI entrypoint |
| `backend/app/core/config.py` | All environment settings |
| `backend/app/services/payment_gateway.py` | Mock + Razorpay + Stripe gateways |
| `backend/app/services/inventory_service.py` | Auto Sold-Out logic |
| `backend/app/services/ledger_service.py` | Artisan financial dashboard calc |
| `backend/app/api/v1/orders.py` | Instant checkout endpoint |
| `backend/seed_data.py` | Indian SHG artisan seed data |
| `backend/Dockerfile` | Cloud Run production container |
| `frontend/lib/main.dart` | Flutter app entrypoint |
| `frontend/lib/core/theme/app_theme.dart` | Cultural color palette |
| `frontend/lib/ui/features/feed/views/feed_item_card.dart` | Buy Now CTA card |
| `frontend/lib/ui/features/checkout/views/instant_checkout_bottom_sheet.dart` | Checkout overlay |
| `frontend/lib/ui/features/seller_dashboard/views/seller_dashboard_screen.dart` | Seller portal |
| `docker-compose.yml` | Local PostgreSQL + backend |
| `README.md` | Full setup documentation |

---

*This export was generated from the Antigravity IDE conversation "Artisan Social Commerce Platform" (ID: 51a38d54-ee11-4837-9637-85ef6a2a86b7)*
