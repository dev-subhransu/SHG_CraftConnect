import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:artisan_market/core/constants/api_constants.dart';
import 'package:artisan_market/data/models/artisan.dart';
import 'package:artisan_market/data/models/post.dart';
import 'package:artisan_market/data/models/order.dart';
import 'package:artisan_market/data/models/seller_ledger.dart';

class ArtisanApiService {
  final http.Client _client;

  ArtisanApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetches vertical discovery feed posts
  Future<List<ProductPost>> fetchDiscoveryFeed({
    String? craftType,
    int? artisanId,
    String? statusFilter,
  }) async {
    final queryParams = <String, String>{};
    if (craftType != null && craftType.isNotEmpty) queryParams['craft_type'] = craftType;
    if (artisanId != null) queryParams['artisan_id'] = artisanId.toString();
    if (statusFilter != null && statusFilter.isNotEmpty) queryParams['status_filter'] = statusFilter;

    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.postsEndpoint}')
        .replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

    try {
      final response = await _client.get(uri).timeout(const Duration(seconds: 6));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => ProductPost.fromJson(json as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      // Fallback to embedded seed catalog for zero-config offline demonstration
      return _getFallbackPosts();
    }
    return _getFallbackPosts();
  }

  /// Places direct instant single-item order bypassing the cart
  Future<OrderReceipt> executeInstantCheckout(InstantCheckoutRequest request) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.instantCheckoutEndpoint}');
    
    try {
      final response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return OrderReceipt.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Checkout failed. Please try again.');
      }
    } catch (e) {
      if (e.toString().contains('SOLD OUT') || e.toString().contains('Insufficient')) {
        rethrow;
      }
      // Simulate instantaneous mock order success in local offline mode
      return OrderReceipt(
        id: 991,
        orderNumber: 'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
        artisanId: 1,
        postId: request.postId,
        quantity: request.quantity,
        unitPrice: 2499.0,
        totalAmount: 2499.0,
        platformFee: 124.95,
        netArtisanAmount: 2374.05,
        currency: 'INR',
        buyerName: request.buyerName,
        buyerPhone: request.buyerPhone,
        shippingAddress: request.shippingAddress,
        shippingCity: request.shippingCity,
        shippingState: request.shippingState,
        shippingPincode: request.shippingPincode,
        paymentStatus: 'PAID',
        paymentMethod: request.paymentMethod,
        paymentId: 'pay_mock_simulated_${DateTime.now().millisecondsSinceEpoch}',
        fulfillmentStatus: 'PROCESSING',
        createdAt: DateTime.now(),
        itemTitle: 'Handcrafted Heritage Piece',
        artisanName: 'Sunita Devi',
        shgName: 'Mithila Shakti Mahila SHG',
      );
    }
  }

  /// Fetches seller ledger summary with gross sales, net payouts, active orders
  Future<SellerLedger> fetchSellerLedger(int artisanId) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.artisansEndpoint}/$artisanId/ledger');

    try {
      final response = await _client.get(uri).timeout(const Duration(seconds: 6));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return SellerLedger.fromJson(data);
      }
    } catch (_) {
      // Fallback ledger for offline demo
    }

    return _getFallbackLedger(artisanId);
  }

  /// Uploads a new product showcase post
  Future<ProductPost> createProductPost(Map<String, dynamic> postData) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.postsEndpoint}');

    try {
      final response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(postData),
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return ProductPost.fromJson(data);
      } else {
        final err = jsonDecode(response.body);
        throw Exception(err['detail'] ?? 'Could not create post');
      }
    } catch (e) {
      // Offline fallback post
      return ProductPost.fromJson(postData..['id'] = DateTime.now().millisecondsSinceEpoch);
    }
  }

  /// Toggles post inventory status or updates stock
  Future<ProductPost> toggleInventory(int postId, {String? statusValue, int? stockQuantity}) async {
    final queryParams = <String, String>{};
    if (statusValue != null) queryParams['status_value'] = statusValue;
    if (stockQuantity != null) queryParams['stock_quantity'] = stockQuantity.toString();

    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.postsEndpoint}/$postId/inventory')
        .replace(queryParameters: queryParams);

    try {
      final response = await _client.patch(uri).timeout(const Duration(seconds: 6));
      if (response.statusCode == 200) {
        return ProductPost.fromJson(jsonDecode(response.body));
      }
    } catch (_) {}

    return ProductPost(
      id: postId,
      artisanId: 1,
      title: 'Craft Product',
      description: 'Updated item',
      mediaUrl: 'https://images.unsplash.com/photo-1579783902614-a3fb3927b675?w=800',
      price: 2499.0,
      stockQuantity: stockQuantity ?? (statusValue == 'SOLD_OUT' ? 0 : 5),
      status: statusValue ?? 'AVAILABLE',
    );
  }

  /// Fallback demo posts
  List<ProductPost> _getFallbackPosts() {
    return [
      ProductPost(
        id: 1,
        artisanId: 1,
        title: "Hand-painted 'Tree of Life' Madhubani Canvas",
        description: "Intricate natural-pigment artwork depicting sacred flora, peacock pairs, and cosmic river motifs on unbleached organic handspun cotton.",
        craftStory: "Created over 14 days using natural vegetable dyes, bamboo twigs, and nib pens. The 'Tree of Life' symbolizes regeneration, harmony, and fertility.",
        mediaUrl: "https://images.unsplash.com/photo-1579783902614-a3fb3927b675?w=800&auto=format&fit=crop&q=80",
        price: 2499.00,
        currency: "INR",
        stockQuantity: 4,
        status: "AVAILABLE",
        likesCount: 184,
        viewsCount: 1420,
        artisan: const Artisan(
          id: 1,
          name: "Sunita Devi",
          shgName: "Mithila Shakti Mahila SHG",
          craftType: "Madhubani Folk Painting",
          location: "Ranti Village, Madhubani, Bihar",
          avatarUrl: "https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400&auto=format&fit=crop&q=80",
          bio: "Sunita leads a collective of 18 women artisans practicing traditional Bharni & Kachni styles.",
        ),
      ),
      ProductPost(
        id: 2,
        artisanId: 2,
        title: "Pochampally Double-Ikat Pure Mulberry Silk Saree",
        description: "Authentic GI-certified handwoven silk saree with geometric temple border and contrasting magenta pallu.",
        craftStory: "Takes two master artisans 22 days on a wooden pit loom. Sourced from sericulture farmers in Telangana, dyed with azo-free extracts.",
        mediaUrl: "https://images.unsplash.com/photo-1610030469983-98e550d6193c?w=800&auto=format&fit=crop&q=80",
        price: 7850.00,
        currency: "INR",
        stockQuantity: 2,
        status: "AVAILABLE",
        likesCount: 329,
        viewsCount: 2810,
        artisan: const Artisan(
          id: 2,
          name: "Lakshmi Narsimha",
          shgName: "Pochampally Weavers Sahakari Sangham",
          craftType: "Ikat Handloom Weaving",
          location: "Bhoodan Pochampally, Telangana",
          avatarUrl: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&auto=format&fit=crop&q=80",
        ),
      ),
      ProductPost(
        id: 3,
        artisanId: 3,
        title: "Ancient Dhokra Tribal Elephant with Howdah",
        description: "Hand-cast brass heirloom piece sculpted using ancestral wax thread technique and baked in an open earthen pit.",
        craftStory: "Each Dhokra cast is completely unique because the clay mould is broken open to release the molten brass sculpture.",
        mediaUrl: "https://images.unsplash.com/photo-1567696911980-2eed69a46042?w=800&auto=format&fit=crop&q=80",
        price: 3200.00,
        currency: "INR",
        stockQuantity: 1,
        status: "AVAILABLE",
        likesCount: 98,
        viewsCount: 870,
        artisan: const Artisan(
          id: 3,
          name: "Banamali Rana",
          shgName: "Bastar Adivasi Dhokra Shilpi Samiti",
          craftType: "Lost-Wax Brass & Bronze Casting",
          location: "Kondagaon, Bastar, Chhattisgarh",
          avatarUrl: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400&auto=format&fit=crop&q=80",
        ),
      ),
      ProductPost(
        id: 4,
        artisanId: 4,
        title: "Handcrafted Cobalt Persian Floral Ceramic Planter",
        description: "Signature Jaipur blue pottery tabletop planter adorned with mughal arabesque patterns and oxide turquoise glazing.",
        craftStory: "Zero clay used. Prepared with powdered quartz stone, glass, Katira Gond and Multani Mitti fired at 850°C.",
        mediaUrl: "https://images.unsplash.com/photo-1612196808214-b8e1d6145a8c?w=800&auto=format&fit=crop&q=80",
        price: 1150.00,
        currency: "INR",
        stockQuantity: 6,
        status: "AVAILABLE",
        likesCount: 214,
        viewsCount: 1930,
        artisan: const Artisan(
          id: 4,
          name: "Meenakshi Rathore",
          shgName: "Marwar Blue Pottery Collective",
          craftType: "Jaipur Traditional Blue Pottery",
          location: "Sanganer, Jaipur, Rajasthan",
          avatarUrl: "https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=400&auto=format&fit=crop&q=80",
        ),
      ),
      ProductPost(
        id: 5,
        artisanId: 5,
        title: "Organic Lacquer Pull-Along Royal Elephant Toy",
        description: "Safe, polished wooden elephant with rolling bead wheels. Coloured using turmeric and lac resin on high-speed manual wood-turning lathes.",
        craftStory: "Certified 100% non-toxic and eco-friendly by Karnataka Handicrafts Development Board.",
        mediaUrl: "https://images.unsplash.com/photo-1596461404969-9ae70f2830c1?w=800&auto=format&fit=crop&q=80",
        price: 650.00,
        currency: "INR",
        stockQuantity: 0,
        status: "SOLD_OUT",
        likesCount: 142,
        viewsCount: 1105,
        artisan: const Artisan(
          id: 5,
          name: "Gowramma & Mahila Mandali",
          shgName: "Channapatna Wooden Toys Federation",
          craftType: "Lacquered Wooden Craft",
          location: "Channapatna, Ramanagara, Karnataka",
          avatarUrl: "https://images.unsplash.com/photo-1580489944761-15a19d654956?w=400&auto=format&fit=crop&q=80",
        ),
      ),
    ];
  }

  SellerLedger _getFallbackLedger(int artisanId) {
    return SellerLedger(
      artisanId: artisanId,
      artisanName: "Sunita Devi",
      shgName: "Mithila Shakti Mahila SHG",
      totalSalesGross: 4998.0,
      platformFeesDeducted: 249.90,
      netEarnings: 4748.10,
      totalPayoutsCompleted: 2000.0,
      pendingPayoutBalance: 2748.10,
      totalOrdersCount: 2,
      activeOrdersCount: 1,
      completedOrdersCount: 1,
      totalProductsCount: 3,
      availableProductsCount: 2,
      soldOutProductsCount: 1,
      recentOrders: [
        OrderReceipt(
          id: 101,
          orderNumber: "ORD-20261001-A91B4C",
          artisanId: artisanId,
          quantity: 1,
          unitPrice: 2499.0,
          totalAmount: 2499.0,
          platformFee: 124.95,
          netArtisanAmount: 2374.05,
          currency: "INR",
          buyerName: "Ananya Sharma",
          buyerPhone: "+919811223344",
          shippingAddress: "Flat 402, Lotus Greens, Sector 78",
          shippingCity: "Noida",
          shippingState: "Uttar Pradesh",
          shippingPincode: "201301",
          paymentStatus: "PAID",
          paymentMethod: "UPI",
          fulfillmentStatus: "PROCESSING",
          createdAt: DateTime.now().subtract(const Duration(hours: 3)),
          itemTitle: "Hand-painted 'Tree of Life' Madhubani Canvas",
          artisanName: "Sunita Devi",
          shgName: "Mithila Shakti Mahila SHG",
        ),
      ],
      recentPayouts: [
        PayoutRecord(
          id: 501,
          artisanId: artisanId,
          amount: 2000.0,
          currency: "INR",
          status: "PROCESSED",
          referenceId: "UTR_20260929_KALYANI",
          notes: "Weekly bank NEFT disbursement to SHG account",
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          processedAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
      ],
    );
  }
}
