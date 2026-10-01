import 'package:flutter_test/flutter_test.dart';
import 'package:artisan_market/data/models/artisan.dart';
import 'package:artisan_market/data/models/post.dart';
import 'package:artisan_market/ui/features/feed/view_models/feed_view_model.dart';
import 'package:artisan_market/data/repositories/artisan_repository.dart';

class MockArtisanRepository implements ArtisanRepository {
  @override
  Future<List<ProductPost>> getDiscoveryFeed({
    String? craftType,
    int? artisanId,
    String? statusFilter,
  }) async {
    return [
      const ProductPost(
        id: 1,
        artisanId: 1,
        title: "Hand-painted Madhubani Canvas",
        description: "Intricate natural-pigment artwork.",
        mediaUrl: "https://example.com/test.jpg",
        price: 2499.0,
        currency: "INR",
        stockQuantity: 1,
        status: "AVAILABLE",
        artisan: Artisan(
          id: 1,
          name: "Sunita Devi",
          shgName: "Mithila Shakti SHG",
          craftType: "Madhubani",
          location: "Bihar",
        ),
      ),
    ];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('FeedViewModel Tests', () {
    test('loadFeed populates posts list successfully', () async {
      final mockRepo = MockArtisanRepository();
      final viewModel = FeedViewModel(repository: mockRepo);

      expect(viewModel.posts.isEmpty, true);
      await viewModel.loadFeed();

      expect(viewModel.posts.length, 1);
      expect(viewModel.posts.first.title, "Hand-painted Madhubani Canvas");
      expect(viewModel.posts.first.price, 2499.0);
    });

    test('decrementPostStock automatically switches to SOLD_OUT when stock reaches 0', () async {
      final mockRepo = MockArtisanRepository();
      final viewModel = FeedViewModel(repository: mockRepo);

      await viewModel.loadFeed();
      expect(viewModel.posts.first.stockQuantity, 1);
      expect(viewModel.posts.first.isSoldOut, false);

      // Decrement remaining unit
      viewModel.decrementPostStock(1, 1);

      expect(viewModel.posts.first.stockQuantity, 0);
      expect(viewModel.posts.first.isSoldOut, true);
      expect(viewModel.posts.first.status, 'SOLD_OUT');
    });
  });
}
