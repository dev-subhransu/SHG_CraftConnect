import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from app.core.database import Base, get_db
from app.main import app
from seed_data import seed_database
from app.models.post import Post, PostStatus
from app.models.artisan import Artisan

# Use an in-memory SQLite database for test isolation
SQLALCHEMY_DATABASE_URL = "sqlite:///./test_artisan_commerce.db"

engine = create_engine(
    SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False}
)
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


def override_get_db():
    db = TestingSessionLocal()
    try:
        yield db
    finally:
        db.close()


app.dependency_overrides[get_db] = override_get_db


@pytest.fixture(scope="module", autouse=True)
def setup_test_db():
    Base.metadata.drop_all(bind=engine)
    Base.metadata.create_all(bind=engine)
    
    # Run seed script into test database
    db = TestingSessionLocal()
    try:
        from app.models.artisan import Artisan
        from app.models.post import Post
        
        artisan = Artisan(
            name="Rani Devi",
            shg_name="Maa Saraswati SHG",
            craft_type="Sujani Embroidery",
            location="Muzaffarpur, Bihar",
            phone="+919800000001",
            is_verified=True
        )
        db.add(artisan)
        db.commit()
        db.refresh(artisan)

        # Post with stock = 1 to test automatic SOLD_OUT transition
        post_single_stock = Post(
            artisan_id=artisan.id,
            title="Hand-stitched Sujani Quilt",
            description="Traditional storytelling quilt stitched with geometric borders.",
            craft_story="Handmade by 4 women over 10 days using recycled cotton fabric.",
            media_url="https://images.unsplash.com/photo-test-1",
            media_type="image",
            price=1500.0,
            stock_quantity=1,
            status=PostStatus.AVAILABLE.value
        )

        # Post with stock = 5
        post_multi_stock = Post(
            artisan_id=artisan.id,
            title="Sujani Silk Cushion Cover",
            description="Embroidered tussar silk cover.",
            media_url="https://images.unsplash.com/photo-test-2",
            media_type="image",
            price=800.0,
            stock_quantity=5,
            status=PostStatus.AVAILABLE.value
        )

        db.add_all([post_single_stock, post_multi_stock])
        db.commit()
    finally:
        db.close()

    yield
    Base.metadata.drop_all(bind=engine)


client = TestClient(app)


def test_health_check():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json()["status"] == "healthy"


def test_discovery_feed():
    response = client.get("/api/v1/posts")
    assert response.status_code == 200
    posts = response.json()
    assert len(posts) >= 2
    # Verify rich embedded artisan information
    first_post = posts[0]
    assert "artisan" in first_post
    assert first_post["artisan"]["shg_name"] == "Maa Saraswati SHG"
    assert "price" in first_post
    assert "status" in first_post


def test_instant_checkout_and_auto_sold_out():
    """
    Test that Instant Checkout bypasses cart, creates order, and automatically
    transitions an item with 1 remaining unit to SOLD_OUT upon purchase!
    """
    # 1. Fetch available posts
    posts_resp = client.get("/api/v1/posts")
    post_item = [p for p in posts_resp.json() if p["stock_quantity"] == 1][0]
    post_id = post_item["id"]

    checkout_payload = {
        "post_id": post_id,
        "quantity": 1,
        "buyer_name": "Priya Varma",
        "buyer_phone": "+919876500000",
        "buyer_email": "priya@example.com",
        "shipping_address": "404 Heritage Residency, MG Road",
        "shipping_city": "Pune",
        "shipping_state": "Maharashtra",
        "shipping_pincode": "411001",
        "payment_method": "MOCK"
    }

    # 2. Place Instant Order
    order_resp = client.post("/api/v1/orders/instant-checkout", json=checkout_payload)
    assert order_resp.status_code == 201
    order_data = order_resp.json()
    
    assert order_data["order_number"].startswith("ORD-")
    assert order_data["payment_status"] == "PAID"
    assert order_data["total_amount"] == 1500.0
    assert order_data["platform_fee"] == 75.0  # 5% fee
    assert order_data["net_artisan_amount"] == 1425.0
    assert order_data["item_title"] == "Hand-stitched Sujani Quilt"

    # 3. Verify that post status AUTOMATICALLY changed to SOLD_OUT
    post_check = client.get(f"/api/v1/posts/{post_id}")
    assert post_check.status_code == 200
    updated_post = post_check.json()
    assert updated_post["status"] == "SOLD_OUT"
    assert updated_post["stock_quantity"] == 0

    # 4. Verify that trying to buy an exhausted item fails with 409 Conflict
    second_order_resp = client.post("/api/v1/orders/instant-checkout", json=checkout_payload)
    assert second_order_resp.status_code == 409
    assert "SOLD OUT" in second_order_resp.json()["detail"]


def test_seller_ledger_and_dashboard():
    """
    Test that the Seller Dashboard accurately calculates gross sales,
    deductions, net earnings, active orders, and inventory status.
    """
    artisan_resp = client.get("/api/v1/artisans")
    assert artisan_resp.status_code == 200
    artisan_id = artisan_resp.json()[0]["id"]

    ledger_resp = client.get(f"/api/v1/artisans/{artisan_id}/ledger")
    assert ledger_resp.status_code == 200
    ledger = ledger_resp.json()

    assert ledger["total_sales_gross"] >= 1500.0
    assert ledger["net_earnings"] >= 1425.0
    assert ledger["pending_payout_balance"] >= 1425.0
    assert ledger["sold_out_products_count"] >= 1
    assert len(ledger["recent_orders"]) >= 1

    # Test requesting a payout disbursement
    payout_resp = client.post(
        f"/api/v1/artisans/{artisan_id}/payouts",
        params={"amount": 1000.0, "notes": "Weekly bank transfer"}
    )
    assert payout_resp.status_code == 201
    payout = payout_resp.json()
    assert payout["amount"] == 1000.0
    assert payout["status"] == "PROCESSED"
    assert "UTR_" in payout["reference_id"]

    # Check updated ledger reflects remaining pending balance
    updated_ledger = client.get(f"/api/v1/artisans/{artisan_id}/ledger").json()
    assert updated_ledger["pending_payout_balance"] == ledger["pending_payout_balance"] - 1000.0


def test_artisan_inventory_toggle():
    """
    Test that artisans can manually restock an item or toggle its availability.
    """
    posts_resp = client.get("/api/v1/posts")
    sold_out_post = [p for p in posts_resp.json() if p["status"] == "SOLD_OUT"][0]
    post_id = sold_out_post["id"]

    # Restock with 3 units
    toggle_resp = client.patch(
        f"/api/v1/posts/{post_id}/inventory",
        params={"status_value": "AVAILABLE", "stock_quantity": 3}
    )
    assert toggle_resp.status_code == 200
    assert toggle_resp.json()["status"] == "AVAILABLE"
    assert toggle_resp.json()["stock_quantity"] == 3
