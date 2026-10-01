import 'package:flutter/foundation.dart';
import 'package:artisan_market/data/models/post.dart';
import 'package:artisan_market/data/repositories/artisan_repository.dart';

class FeedViewModel extends ChangeNotifier {
  final ArtisanRepository _repository;

  FeedViewModel({ArtisanRepository? repository})
      : _repository = repository ?? ArtisanRepository();

  List<ProductPost> _posts = [];
  List<ProductPost> get posts => _posts;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String _selectedCategory = 'All';
  String get selectedCategory => _selectedCategory;

  Future<void> loadFeed() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final categoryFilter = _selectedCategory == 'All' ? null : _selectedCategory;
      _posts = await _repository.getDiscoveryFeed(craftType: categoryFilter);
    } catch (e) {
      _errorMessage = 'Could not load artisan showcase. Please pull to refresh.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void filterCategory(String category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    loadFeed();
  }

  /// Called when an instant purchase succeeds to immediately reflect SOLD_OUT status
  void markPostSoldOut(int postId) {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      _posts[index] = _posts[index].copyWith(
        status: 'SOLD_OUT',
        stockQuantity: 0,
      );
      notifyListeners();
    }
  }

  /// Decrement stock locally for responsive UI
  void decrementPostStock(int postId, int quantityPurchased) {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final currentStock = _posts[index].stockQuantity;
      final newStock = (currentStock - quantityPurchased).clamp(0, 99999);
      _posts[index] = _posts[index].copyWith(
        stockQuantity: newStock,
        status: newStock == 0 ? 'SOLD_OUT' : _posts[index].status,
      );
      notifyListeners();
    }
  }
}
