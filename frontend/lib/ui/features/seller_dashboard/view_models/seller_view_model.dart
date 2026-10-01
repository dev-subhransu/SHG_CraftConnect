import 'package:flutter/foundation.dart';
import 'package:artisan_market/data/models/post.dart';
import 'package:artisan_market/data/models/seller_ledger.dart';
import 'package:artisan_market/data/repositories/artisan_repository.dart';

class SellerViewModel extends ChangeNotifier {
  final ArtisanRepository _repository;

  SellerViewModel({ArtisanRepository? repository})
      : _repository = repository ?? ArtisanRepository();

  int _artisanId = 1; // Default to Sunita Devi / Mithila SHG for demo
  int get artisanId => _artisanId;

  SellerLedger? _ledger;
  SellerLedger? get ledger => _ledger;

  List<ProductPost> _myPosts = [];
  List<ProductPost> get myPosts => _myPosts;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void switchArtisan(int id) {
    _artisanId = id;
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final ledgerData = await _repository.getSellerLedger(_artisanId);
      final feedPosts = await _repository.getDiscoveryFeed(artisanId: _artisanId);
      
      _ledger = ledgerData;
      _myPosts = feedPosts;
    } catch (e) {
      _errorMessage = 'Could not load seller ledger';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createPost({
    required String title,
    required String description,
    String? craftStory,
    required String mediaUrl,
    required double price,
    required int stockQuantity,
  }) async {
    _isSaving = true;
    notifyListeners();

    try {
      final postData = {
        'artisan_id': _artisanId,
        'title': title,
        'description': description,
        'craft_story': craftStory,
        'media_url': mediaUrl,
        'media_type': 'image',
        'price': price,
        'currency': 'INR',
        'stock_quantity': stockQuantity,
      };

      final newPost = await _repository.uploadPost(postData);
      _myPosts.insert(0, newPost);
      await loadDashboard(); // Refresh ledger stats
      return true;
    } catch (e) {
      _errorMessage = 'Failed to publish post: $e';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> togglePostStatus(int postId, bool markSoldOut) async {
    final status = markSoldOut ? 'SOLD_OUT' : 'AVAILABLE';
    final stock = markSoldOut ? 0 : 3;

    try {
      final updated = await _repository.toggleInventory(
        postId,
        statusValue: status,
        stockQuantity: stock,
      );

      final index = _myPosts.indexWhere((p) => p.id == postId);
      if (index != -1) {
        _myPosts[index] = updated;
      }
      await loadDashboard();
    } catch (e) {
      _errorMessage = 'Failed to update stock status';
      notifyListeners();
    }
  }
}
