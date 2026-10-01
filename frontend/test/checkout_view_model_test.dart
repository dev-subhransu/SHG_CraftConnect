import 'package:flutter_test/flutter_test.dart';
import 'package:artisan_market/data/models/order.dart';
import 'package:artisan_market/data/models/post.dart';
import 'package:artisan_market/ui/features/checkout/view_models/checkout_view_model.dart';
import 'package:artisan_market/data/repositories/artisan_repository.dart';

class MockCheckoutRepository implements ArtisanRepository {
  @override
  Future<OrderReceipt> instantCheckout(InstantCheckoutRequest request) async {
    return OrderReceipt(
      id: 101,
      orderNumber: "ORD-20261001-TEST",
      postId: request.postId,
      artisanId: 1,
      quantity: request.quantity,
      unitPrice: 2499.0,
      totalAmount: 2499.0,
      platformFee: 124.95,
      netArtisanAmount: 2374.05,
      currency: "INR",
      buyerName: request.buyerName,
      buyerPhone: request.buyerPhone,
      shippingAddress: request.shippingAddress,
      shippingCity: request.shippingCity,
      shippingState: request.shippingState,
      shippingPincode: request.shippingPincode,
      paymentStatus: "PAID",
      paymentMethod: request.paymentMethod,
      fulfillmentStatus: "PROCESSING",
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('CheckoutViewModel Tests', () {
    test('processInstantCheckout submits successfully and returns receipt', () async {
      final mockRepo = MockCheckoutRepository();
      final viewModel = CheckoutViewModel(repository: mockRepo);

      const samplePost = ProductPost(
        id: 1,
        artisanId: 1,
        title: "Test Post",
        description: "Test Desc",
        mediaUrl: "https://example.com/test.jpg",
        price: 2499.0,
        stockQuantity: 2,
        status: "AVAILABLE",
      );

      final receipt = await viewModel.processInstantCheckout(
        post: samplePost,
        buyerName: "Ananya Sharma",
        buyerPhone: "+919811223344",
        shippingAddress: "Flat 402, Lotus Greens",
        shippingCity: "Noida",
        shippingState: "UP",
        shippingPincode: "201301",
      );

      expect(receipt != null, true);
      expect(receipt!.orderNumber, "ORD-20261001-TEST");
      expect(receipt.paymentStatus, "PAID");
      expect(receipt.totalAmount, 2499.0);
      expect(receipt.netArtisanAmount, 2374.05);
      expect(receipt.platformFee, 124.95);
    });
  });
}
