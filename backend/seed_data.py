"""
Database Seed Script: Populates realistic Indian Self Help Groups (SHGs),
rural artisans, authentic craft products, sample orders, and initial ledger data.
"""

from datetime import datetime, timedelta
from app.core.database import SessionLocal, init_db
from app.models.artisan import Artisan
from app.models.post import Post, PostStatus, MediaType
from app.models.order import Order, PaymentStatus, FulfillmentStatus
from app.models.payout import Payout, PayoutStatus


def seed_database(force: bool = False):
    init_db()
    db = SessionLocal()

    try:
        existing_count = db.query(Artisan).count()
        if existing_count > 0 and not force:
            print(f"[Seed] Database already contains {existing_count} artisans. Skipping seed.")
            return

        print("[Seed] Seeding SHGs, Artisans, and Handcrafted Products...")

        # 1. Artisans & SHGs
        artisan1 = Artisan(
            name="Sunita Devi",
            shg_name="Mithila Shakti Mahila SHG",
            craft_type="Madhubani Folk Painting",
            location="Ranti Village, Madhubani, Bihar",
            avatar_url="https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400&auto=format&fit=crop&q=80",
            bio="Sunita leads a collective of 18 women artisans practicing the traditional Bharni & Kachni styles of Madhubani art passed down through four generations.",
            phone="+919876543210",
            bank_account_number="XXXXXX4512",
            bank_ifsc="SBIN0001234",
            is_verified=True
        )

        artisan2 = Artisan(
            name="Lakshmi Narsimha",
            shg_name="Pochampally Weavers Sahakari Sangham",
            craft_type="Ikat Handloom Weaving",
            location="Bhoodan Pochampally, Telangana",
            avatar_url="https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&auto=format&fit=crop&q=80",
            bio="GI-certified master weaver working alongside 12 women cooperative members on traditional pit looms creating naturally dyed silk warp and weft patterns.",
            phone="+919876543211",
            bank_account_number="XXXXXX8823",
            bank_ifsc="ANDB0005678",
            is_verified=True
        )

        artisan3 = Artisan(
            name="Banamali Rana",
            shg_name="Bastar Adivasi Dhokra Shilpi Samiti",
            craft_type="Lost-Wax Brass & Bronze Casting",
            location="Kondagaon, Bastar, Chhattisgarh",
            avatar_url="https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400&auto=format&fit=crop&q=80",
            bio="Preserving the 4000-year-old non-ferrous lost-wax metal casting technique with tribal motifs representing indigenous nature spirits and forest folklore.",
            phone="+919876543212",
            bank_account_number="XXXXXX3190",
            bank_ifsc="PUNB0009988",
            is_verified=True
        )

        artisan4 = Artisan(
            name="Meenakshi Rathore",
            shg_name="Marwar Blue Pottery Self-Help Collective",
            craft_type="Jaipur Traditional Blue Pottery",
            location="Sanganer, Jaipur, Rajasthan",
            avatar_url="https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=400&auto=format&fit=crop&q=80",
            bio="A women-empowered craft unit crafting low-fire Egyptian faience pottery without clay, utilizing crushed quartz, fuller's earth, and copper oxide glaze.",
            phone="+919876543213",
            bank_account_number="XXXXXX7741",
            bank_ifsc="BARB0SANGAN",
            is_verified=True
        )

        artisan5 = Artisan(
            name="Gowramma & Mahila Mandali",
            shg_name="Channapatna Wooden Toys Federation",
            craft_type="Lacquered Wooden Craft",
            location="Channapatna, Ramanagara, Karnataka",
            avatar_url="https://images.unsplash.com/photo-1580489944761-15a19d654956?w=400&auto=format&fit=crop&q=80",
            bio="Handcrafting non-toxic, child-safe ivory wood (Wrightia tinctoria) toys coated with organic vegetable dyes (turmeric, indigo, kumkum).",
            phone="+919876543214",
            bank_account_number="XXXXXX6054",
            bank_ifsc="CNRB0002441",
            is_verified=True
        )

        db.add_all([artisan1, artisan2, artisan3, artisan4, artisan5])
        db.commit()

        # 2. Showcase Posts for Discovery Feed
        posts = [
            Post(
                artisan_id=artisan1.id,
                title="Hand-painted 'Tree of Life' Madhubani Canvas",
                description="Intricate natural-pigment artwork depicting sacred flora, peacock pairs, and cosmic river motifs on unbleached organic handspun cotton.",
                craft_story="Created over 14 days using natural vegetable dyes, bamboo twigs, and nib pens. The 'Tree of Life' symbolizes regeneration, harmony, and fertility.",
                media_url="https://images.unsplash.com/photo-1579783902614-a3fb3927b675?w=800&auto=format&fit=crop&q=80",
                media_type=MediaType.IMAGE.value,
                price=2499.00,
                currency="INR",
                stock_quantity=4,
                status=PostStatus.AVAILABLE.value,
                likes_count=184,
                views_count=1420
            ),
            Post(
                artisan_id=artisan2.id,
                title="Pochampally Double-Ikat Pure Mulberry Silk Saree",
                description="Authentic GI-certified handwoven silk saree with geometric temple border and contrasting magenta pallu.",
                craft_story="Takes two master artisans 22 days on a wooden pit loom. Sourced from sericulture farmers in Telangana, dyed with azo-free extracts.",
                media_url="https://images.unsplash.com/photo-1610030469983-98e550d6193c?w=800&auto=format&fit=crop&q=80",
                media_type=MediaType.IMAGE.value,
                price=7850.00,
                currency="INR",
                stock_quantity=2,
                status=PostStatus.AVAILABLE.value,
                likes_count=329,
                views_count=2810
            ),
            Post(
                artisan_id=artisan3.id,
                title="Ancient Dhokra Tribal Elephant with Howdah Figurine",
                description="Hand-cast brass heirloom piece sculpted using ancestral wax thread technique and baked in an open earthen pit.",
                craft_story="Each Dhokra cast is completely unique because the clay mould is broken open to release the molten brass sculpture.",
                media_url="https://images.unsplash.com/photo-1567696911980-2eed69a46042?w=800&auto=format&fit=crop&q=80",
                media_type=MediaType.IMAGE.value,
                price=3200.00,
                currency="INR",
                stock_quantity=1,
                status=PostStatus.AVAILABLE.value,
                likes_count=98,
                views_count=870
            ),
            Post(
                artisan_id=artisan4.id,
                title="Handcrafted Cobalt Persian Floral Ceramic Planter",
                description="Signature Jaipur blue pottery tabletop planter adorned with mughal arabesque patterns and oxide turquoise glazing.",
                craft_story="Zero clay used. Prepared with powdered quartz stone, glass, Katira Gond and Multani Mitti fired at 850°C.",
                media_url="https://images.unsplash.com/photo-1612196808214-b8e1d6145a8c?w=800&auto=format&fit=crop&q=80",
                media_type=MediaType.IMAGE.value,
                price=1150.00,
                currency="INR",
                stock_quantity=6,
                status=PostStatus.AVAILABLE.value,
                likes_count=214,
                views_count=1930
            ),
            Post(
                artisan_id=artisan5.id,
                title="Organic Lacquer Pull-Along Royal Elephant Toy",
                description="Safe, polished wooden elephant with rolling bead wheels. Coloured using turmeric and lac resin on high-speed manual wood-turning lathes.",
                craft_story="Certified 100% non-toxic and eco-friendly by Karnataka Handicrafts Development Board. Provides livelihoods to 6 women toy-turners.",
                media_url="https://images.unsplash.com/photo-1596461404969-9ae70f2830c1?w=800&auto=format&fit=crop&q=80",
                media_type=MediaType.IMAGE.value,
                price=650.00,
                currency="INR",
                stock_quantity=0,
                status=PostStatus.SOLD_OUT.value,  # Demonstrates Sold Out status badge in feed
                likes_count=142,
                views_count=1105
            ),
            Post(
                artisan_id=artisan1.id,
                title="Sun God Surya Mithila Wall Hanging",
                description="Auspicious Surya motif on tussar silk mount with hand-drawn geometric borders and vermilion mineral washes.",
                craft_story="Symbolizes energy and light; traditionally painted on village mud walls during harvest festivals.",
                media_url="https://images.unsplash.com/photo-1582562124811-c09040d0a901?w=800&auto=format&fit=crop&q=80",
                media_type=MediaType.IMAGE.value,
                price=1850.00,
                currency="INR",
                stock_quantity=3,
                status=PostStatus.AVAILABLE.value,
                likes_count=87,
                views_count=730
            )
        ]

        db.add_all(posts)
        db.commit()

        # 3. Sample Orders & Payout to populate Seller Dashboard Ledger
        order1 = Order(
            order_number="ORD-20261001-A91B4C",
            post_id=posts[0].id,
            artisan_id=artisan1.id,
            quantity=1,
            unit_price=2499.0,
            total_amount=2499.0,
            platform_fee=124.95,
            net_artisan_amount=2374.05,
            currency="INR",
            buyer_name="Ananya Sharma",
            buyer_phone="+919811223344",
            buyer_email="ananya.sharma@example.com",
            shipping_address="Flat 402, Lotus Greens, Sector 78",
            shipping_city="Noida",
            shipping_state="Uttar Pradesh",
            shipping_pincode="201301",
            payment_status=PaymentStatus.PAID.value,
            payment_method="UPI",
            payment_id="pay_mock_upi_001",
            fulfillment_status=FulfillmentStatus.PROCESSING.value,
            created_at=datetime.utcnow() - timedelta(hours=3)
        )

        order2 = Order(
            order_number="ORD-20260928-C38E2F",
            post_id=posts[0].id,
            artisan_id=artisan1.id,
            quantity=1,
            unit_price=2499.0,
            total_amount=2499.0,
            platform_fee=124.95,
            net_artisan_amount=2374.05,
            currency="INR",
            buyer_name="Rohan Mehra",
            buyer_phone="+919711889900",
            buyer_email="rohan.m@example.com",
            shipping_address="12B, Indiranagar 100ft Road",
            shipping_city="Bengaluru",
            shipping_state="Karnataka",
            shipping_pincode="560038",
            payment_status=PaymentStatus.PAID.value,
            payment_method="MOCK",
            payment_id="pay_mock_002",
            fulfillment_status=FulfillmentStatus.DELIVERED.value,
            created_at=datetime.utcnow() - timedelta(days=3)
        )

        # Completed historical payout for artisan 1
        payout1 = Payout(
            artisan_id=artisan1.id,
            amount=2000.0,
            currency="INR",
            status=PayoutStatus.PROCESSED.value,
            reference_id="UTR_20260929_KALYANI",
            notes="Weekly bank NEFT disbursement to SHG account",
            created_at=datetime.utcnow() - timedelta(days=2),
            processed_at=datetime.utcnow() - timedelta(days=2)
        )

        db.add_all([order1, order2, payout1])
        db.commit()

        print("[Seed] Successfully seeded 5 Artisans, 6 Products, 2 Orders, and 1 Payout!")

    except Exception as e:
        db.rollback()
        print(f"[Seed] Error during seeding: {e}")
        raise
    finally:
        db.close()


if __name__ == "__main__":
    seed_database(force=True)
