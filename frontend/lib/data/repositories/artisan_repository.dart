import 'package:artisan_market/data/models/post.dart';
import 'package:artisan_market/data/models/order.dart';
import 'package:artisan_market/data/models/seller_ledger.dart';
import 'package:artisan_market/data/services/artisan_api_service.dart';

class ArtisanRepository {
  final ArtisanApiService _apiService;

  ArtisanRepository({ArtisanApiService? apiService})
      : _apiService = apiService ?? ArtisanApiService();

  Future<List<ProductPost>> getDiscoveryFeed({
    String? craftType,
    int? artisanId,
    String? statusFilter,
  }) {
    return _apiService.fetchDiscoveryFeed(
      craftType: craftType,
      artisanId: artisanId,
      statusFilter: statusFilter,
    );
  }

  Future<OrderReceipt> instantCheckout(InstantCheckoutRequest request) {
    return _apiService.executeInstantCheckout(request);
  }

  Future<SellerLedger> getSellerLedger(int artisanId) {
    return _apiService.fetchSellerLedger(artisanId);
  }

  Future<ProductPost> uploadPost(Map<String, dynamic> postData) {
    return _apiService.createProductPost(postData);
  }

  Future<ProductPost> toggleInventory(int postId, {String? statusValue, int? stockQuantity}) {
    return _apiService.toggleInventory(postId, statusValue: statusValue, stockQuantity: stockQuantity);
  }
}
