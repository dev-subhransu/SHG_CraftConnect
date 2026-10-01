# SHG CraftConnect: Social Commerce Platform for Artisans & Self Help Groups

A cross-platform mobile application and backend service built for **Self Help Groups (SHGs)**, tribal collectives, and rural artisans. The platform connects heritage craft makers directly with buyers through an **Instagram-style vertical discovery feed**, single-click **Instant Checkout** that completely bypasses shopping carts, and a dedicated **Artisan Seller Dashboard** featuring automated "Sold Out" inventory toggling and a real-time payout ledger.

---

## 🏛️ Monorepo Architecture

```
artisan_market/
├── docker-compose.yml          # Local multi-container orchestration (PostgreSQL + FastAPI)
├── README.md                   # Setup, testing, and deployment manual
├── backend/                    # Python FastAPI Backend Service
│   ├── Dockerfile              # Production container optimized for Google Cloud Run
│   ├── requirements.txt        # Backend dependencies
│   ├── .env.example            # Environment variable template
│   ├── seed_data.py            # CLI script to bootstrap realistic SHG artisan catalogs
│   ├── app/
│   │   ├── main.py             # FastAPI app factory, CORS, and startup lifespan
│   │   ├── core/               # App configuration and SQLAlchemy database engine
│   │   ├── models/             # Artisan, Post, Order, and Payout SQLAlchemy models
│   │   ├── schemas/            # Pydantic v2 schemas for requests & responses
│   │   ├── services/           # Payment gateways (Mock/Razorpay/Stripe), inventory, ledger
│   │   └── api/v1/             # Discovery feed, instant checkout, seller dashboard routes
│   └── tests/                  # Pytest test suite for end-to-end API workflows
└── frontend/                   # Cross-Platform Flutter Mobile Application
    ├── pubspec.yaml            # Flutter dependencies
    ├── analysis_options.yaml   # Linter configuration
    ├── lib/
    │   ├── main.dart           # App entrypoint & theme initialization
    │   ├── core/               # Warm cultural theme, constants, and API client
    │   ├── data/               # Models, API services, and domain repositories
    │   └── ui/
    │       ├── features/feed/  # Instagram-style vertical feed with prominent Buy Now CTA
    │       ├── features/checkout/ # Slide-up instant checkout overlay bypassing carts
    │       ├── features/seller_dashboard/ # Artisan portal: inventory & payout ledger
    │       └── features/navigation/ # Bottom navigation shell
    └── test/                   # Flutter unit & widget tests
```

---

## ✨ Core Features & Application Flows

### 1. Instagram-Style Discovery Feed
- **Full-Bleed Vertical Snapping**: Users swipe vertically through handcrafted pieces (Madhubani folk art, Pochampally Ikat silk, Bastar Dhokra brass, Jaipur Blue Pottery, Channapatna wooden toys).
- **Cultural Narrative & Verified SHG Badge**: Each piece displays the artisan's name, verified Self Help Group badge, craft technique, and village/region origin.
- **Prominent "⚡ Buy Now - ₹{Price}" CTA**: Deliberately replaces the traditional "Like" button with a high-conversion purchase trigger. When an item is sold out, the button dynamically updates to a disabled **"Sold Out"** state.

### 2. Instant Checkout Overlay (Cart-Free)
- **Zero-Friction Purchase**: Tapping "Buy Now" triggers an animated bottom sheet, bypassing carts and multiple confirmation screens.
- **Buyer Delivery Capture**: Collects full name, phone number, street address, city, state, and pincode (pre-filled with mock defaults for instant testing).
- **Pluggable Payment Gateway**:
  - `⚡ 1-Tap Mock`: Instant simulated authorization for local development.
  - `🇮🇳 Razorpay`: Native UPI (GPay, PhonePe), Cards, and NetBanking with HMAC-SHA256 signature verification.
  - `🌐 Stripe`: Global credit/debit card processing via PaymentIntents.
- **Fair Trade Transparency**: Transparent breakdown showing the exact rupee amount disbursed directly to the artisan's collective bank account.

### 3. Artisan Seller Dashboard
- **Live Inventory Management**: Real-time listing of all artisan posts with stock counters. Features an instant one-tap switch to mark items as "In Stock" or "Sold Out".
- **Automated "Sold Out" Trigger**: When a buyer completes an instant purchase for the last available unit, the backend **atomically decrements inventory to 0 and toggles the post status to `SOLD_OUT`**.
- **Active Orders Ledger**: Track incoming orders with customer contact info, shipping destination, and dispatch fulfillment status.
- **Payouts & Earnings Ledger**: Displays Gross Sales, Platform Commission (5%), Net Artisan Earnings, Completed Disbursements, and Pending Payout Balance with a one-click **"Disburse Payout"** trigger.

---

## 🚀 Quickstart: Running Backend Locally

### Option A: Local Python Environment (Zero-Config SQLite)

1. **Navigate to the backend directory**:
   ```bash
   cd backend
   ```

2. **Create and activate a virtual environment**:
   ```bash
   # Windows (PowerShell)
   python -m venv venv
   .\venv\Scripts\Activate.ps1

   # macOS / Linux
   python3 -m venv venv
   source venv/bin/activate
   ```

3. **Install dependencies**:
   ```bash
   pip install -r requirements.txt
   ```

4. **Initialize configuration**:
   ```bash
   cp .env.example .env
   ```
   *(By default, `DATABASE_URL=sqlite:///./artisan_dev.db` is used, so no external database is needed!)*

5. **Start the FastAPI application**:
   ```bash
   uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
   ```

6. **Seed sample Indian SHG artisan products**:
   ```bash
   python seed_data.py
   ```

7. **Explore Interactive Swagger API Docs**:
   Open [http://localhost:8000/docs](http://localhost:8000/docs) in your browser.

---

### Option B: Running with Docker Compose (PostgreSQL + FastAPI)

1. **From the project root directory**:
   ```bash
   docker-compose up --build
   ```

2. This will launch:
   - `artisan_postgres` (PostgreSQL 16 on port `5432`)
   - `artisan_backend` (FastAPI with hot-reload on port `8000`)
3. The database schema and demo seed data are automatically initialized on startup!

---

## 🧪 Running Automated Tests

Run the complete backend integration and unit test suite:
```bash
cd backend
python -m pytest tests/ -v
```

**Tested Scenarios**:
- ✅ Container health check (`GET /health`)
- ✅ Instagram-style discovery feed retrieval with embedded artisan data (`GET /api/v1/posts`)
- ✅ Single-item instant checkout order placement (`POST /api/v1/orders/instant-checkout`)
- ✅ **Automated inventory depletion**: Purchasing the last stock item automatically transitions the post to `SOLD_OUT` and subsequent purchase attempts fail with HTTP 409 Conflict
- ✅ Seller dashboard ledger calculations: gross sales, net earnings, pending balance, and payout disbursements
- ✅ Artisan manual inventory stock toggling

---

## 📱 Running the Flutter Mobile App

The Flutter frontend is configured with platform-aware networking. It automatically connects to `http://10.0.2.2:8000/api/v1` on Android Emulators and `http://localhost:8000/api/v1` on iOS Simulators, Web, and Desktop. Additionally, if the backend server is not running, it falls back seamlessly to realistic embedded seed data so UI testing is always uninterrupted.

1. **Navigate to the frontend directory**:
   ```bash
   cd frontend
   ```

2. **Install Flutter packages**:
   ```bash
   flutter pub get
   ```

3. **Run on an Android Emulator or iOS Simulator**:
   ```bash
   # List available devices
   flutter devices

   # Run on connected device / simulator
   flutter run
   ```

4. **Run on Chrome Web**:
   ```bash
   flutter run -d chrome
   ```

5. **Run Flutter Unit Tests**:
   ```bash
   flutter test
   ```

---

## ☁️ Deploying the Backend to Google Cloud Run

The backend includes a production-hardened `Dockerfile` optimized for Google Cloud Run:
- Uses `python:3.11-slim` for minimal image size and fast cold-start boot.
- Dynamically respects Cloud Run's `$PORT` environment variable.
- Runs as an unprivileged non-root user (`appuser`).
- Ready for Google Cloud SQL (PostgreSQL).

### Step-by-Step Google Cloud Deployment

1. **Set your Google Cloud Project**:
   ```bash
   gcloud config set project YOUR_GCP_PROJECT_ID
   gcloud services enable run.googleapis.com artifactregistry.googleapis.com sqladmin.googleapis.com
   ```

2. **Create a Cloud SQL for PostgreSQL instance (or use existing)**:
   ```bash
   gcloud sql instances create artisan-postgres-instance \
       --database-version=POSTGRES_16 \
       --tier=db-f1-micro \
       --region=asia-south1

   # Create database and user
   gcloud sql databases create artisan_db --instance=artisan-postgres-instance
   gcloud sql users set-password postgres --instance=artisan-postgres-instance --password="YOUR_SECURE_PASSWORD"
   ```

3. **Build and push the container using Google Cloud Build**:
   ```bash
   cd backend
   gcloud builds submit --tag gcr.io/YOUR_GCP_PROJECT_ID/artisan-backend:v1
   ```

4. **Deploy to Google Cloud Run**:
   ```bash
   gcloud run deploy artisan-backend \
       --image gcr.io/YOUR_GCP_PROJECT_ID/artisan-backend:v1 \
       --platform managed \
       --region asia-south1 \
       --allow-unauthenticated \
       --add-cloudsql-instances YOUR_GCP_PROJECT_ID:asia-south1:artisan-postgres-instance \
       --set-env-vars "ENVIRONMENT=production,DEBUG=False,DATABASE_URL=postgresql+psycopg2://postgres:YOUR_SECURE_PASSWORD@/artisan_db?host=/cloudsql/YOUR_GCP_PROJECT_ID:asia-south1:artisan-postgres-instance,PAYMENT_PROVIDER=mock,CORS_ORIGINS=*"
   ```

5. **Verify deployment**:
   Cloud Run will output your live HTTPS service URL (e.g. `https://artisan-backend-xyz-uc.a.run.app`).
   - Check health: `https://artisan-backend-xyz-uc.a.run.app/health`
   - Access Swagger API documentation: `https://artisan-backend-xyz-uc.a.run.app/docs`

6. **Point Flutter App to Cloud Backend**:
   Update `ApiConstants.customBaseUrl` in `frontend/lib/core/constants/api_constants.dart` with your Cloud Run URL:
   ```dart
   ApiConstants.customBaseUrl = 'https://artisan-backend-xyz-uc.a.run.app/api/v1';
   ```

---

## 💳 Payment Gateway Configuration

Switch payment providers simply by updating `PAYMENT_PROVIDER` in `backend/.env`:

| Provider | Setting | Configuration Required | Description |
| :--- | :--- | :--- | :--- |
| **Mock Gateway** | `PAYMENT_PROVIDER=mock` | None | Instant simulated success for fast local testing |
| **Razorpay** | `PAYMENT_PROVIDER=razorpay` | `RAZORPAY_KEY_ID`, `RAZORPAY_KEY_SECRET` | Indian UPI, QR, Wallets, and Cards |
| **Stripe** | `PAYMENT_PROVIDER=stripe` | `STRIPE_SECRET_KEY`, `STRIPE_WEBHOOK_SECRET` | International Credit / Debit Cards |

---

## 👥 Impact & Cultural Context
This platform is engineered to dismantle the barriers rural and tribal Self Help Groups face in digital commerce:
1. **Direct Earnings**: Removes predatory middlemen with a capped 5% platform fee to sustain hosting and operations.
2. **Storytelling First**: Preserves traditional artisan heritage through rich craft narrative modals.
3. **Cartless Conversions**: Instant Checkout maximizes mobile impulse conversions for single-origin handicrafts.
