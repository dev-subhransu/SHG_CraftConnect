class InstantCheckoutRequest {
  final int postId;
  final int quantity;
  final String buyerName;
  final String buyerPhone;
  final String? buyerEmail;
  final String shippingAddress;
  final String shippingCity;
  final String shippingState;
  final String shippingPincode;
  final String paymentMethod; // 'MOCK', 'RAZORPAY', 'STRIPE', 'UPI'

  const InstantCheckoutRequest({
    required this.postId,
    this.quantity = 1,
    required this.buyerName,
    required this.buyerPhone,
    this.buyerEmail,
    required this.shippingAddress,
    required this.shippingCity,
    required this.shippingState,
    required this.shippingPincode,
    this.paymentMethod = 'MOCK',
  });

  Map<String, dynamic> toJson() {
    return {
      'post_id': postId,
      'quantity': quantity,
      'buyer_name': buyerName,
      'buyer_phone': buyerPhone,
      'buyer_email': buyerEmail,
      'shipping_address': shippingAddress,
      'shipping_city': shippingCity,
      'shipping_state': shippingState,
      'shipping_pincode': shippingPincode,
      'payment_method': paymentMethod,
    };
  }
}

class OrderReceipt {
  final int id;
  final String orderNumber;
  final int? postId;
  final int artisanId;
  final int quantity;
  final double unitPrice;
  final double totalAmount;
  final double platformFee;
  final double netArtisanAmount;
  final String currency;
  final String buyerName;
  final String buyerPhone;
  final String shippingAddress;
  final String shippingCity;
  final String shippingState;
  final String shippingPincode;
  final String paymentStatus;
  final String paymentMethod;
  final String? paymentId;
  final String fulfillmentStatus;
  final DateTime? createdAt;
  final String? itemTitle;
  final String? artisanName;
  final String? shgName;

  const OrderReceipt({
    required this.id,
    required this.orderNumber,
    this.postId,
    required this.artisanId,
    required this.quantity,
    required this.unitPrice,
    required this.totalAmount,
    required this.platformFee,
    required this.netArtisanAmount,
    required this.currency,
    required this.buyerName,
    required this.buyerPhone,
    required this.shippingAddress,
    required this.shippingCity,
    required this.shippingState,
    required this.shippingPincode,
    required this.paymentStatus,
    required this.paymentMethod,
    this.paymentId,
    required this.fulfillmentStatus,
    this.createdAt,
    this.itemTitle,
    this.artisanName,
    this.shgName,
  });

  factory OrderReceipt.fromJson(Map<String, dynamic> json) {
    return OrderReceipt(
      id: json['id'] as int? ?? 0,
      orderNumber: json['order_number'] as String? ?? 'ORD-REF',
      postId: json['post_id'] as int?,
      artisanId: json['artisan_id'] as int? ?? 0,
      quantity: json['quantity'] as int? ?? 1,
      unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      platformFee: (json['platform_fee'] as num?)?.toDouble() ?? 0.0,
      netArtisanAmount: (json['net_artisan_amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'INR',
      buyerName: json['buyer_name'] as String? ?? '',
      buyerPhone: json['buyer_phone'] as String? ?? '',
      shippingAddress: json['shipping_address'] as String? ?? '',
      shippingCity: json['shipping_city'] as String? ?? '',
      shippingState: json['shipping_state'] as String? ?? '',
      shippingPincode: json['shipping_pincode'] as String? ?? '',
      paymentStatus: json['payment_status'] as String? ?? 'PAID',
      paymentMethod: json['payment_method'] as String? ?? 'MOCK',
      paymentId: json['payment_id'] as String?,
      fulfillmentStatus: json['fulfillment_status'] as String? ?? 'PROCESSING',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      itemTitle: json['item_title'] as String?,
      artisanName: json['artisan_name'] as String?,
      shgName: json['shg_name'] as String?,
    );
  }
}
