import 'package:flutter/material.dart';
import 'package:artisan_market/data/models/order.dart';
import 'package:artisan_market/data/models/post.dart';
import 'package:artisan_market/data/repositories/artisan_repository.dart';

class CheckoutViewModel extends ChangeNotifier {
  final ArtisanRepository _repository;

  CheckoutViewModel({ArtisanRepository? repository})
      : _repository = repository ?? ArtisanRepository();

  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  OrderReceipt? _lastReceipt;
  OrderReceipt? get lastReceipt => _lastReceipt;

  String _selectedPaymentMethod = 'MOCK'; // 'MOCK', 'UPI', 'RAZORPAY', 'STRIPE'
  String get selectedPaymentMethod => _selectedPaymentMethod;

  void selectPaymentMethod(String method) {
    _selectedPaymentMethod = method;
    notifyListeners();
  }

  Future<OrderReceipt?> processInstantCheckout({
    required ProductPost post,
    required String buyerName,
    required String buyerPhone,
    String? buyerEmail,
    required String shippingAddress,
    required String shippingCity,
    required String shippingState,
    required String shippingPincode,
  }) async {
    _isProcessing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final request = InstantCheckoutRequest(
        postId: post.id,
        quantity: 1,
        buyerName: buyerName.trim(),
        buyerPhone: buyerPhone.trim(),
        buyerEmail: buyerEmail?.trim(),
        shippingAddress: shippingAddress.trim(),
        shippingCity: shippingCity.trim(),
        shippingState: shippingState.trim(),
        shippingPincode: shippingPincode.trim(),
        paymentMethod: _selectedPaymentMethod,
      );

      final receipt = await _repository.instantCheckout(request);
      _lastReceipt = receipt;
      return receipt;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return null;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }
}
