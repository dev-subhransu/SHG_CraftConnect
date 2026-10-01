import 'package:artisan_market/data/models/order.dart';

class PayoutRecord {
  final int id;
  final int artisanId;
  final double amount;
  final String currency;
  final String status;
  final String? referenceId;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? processedAt;

  const PayoutRecord({
    required this.id,
    required this.artisanId,
    required this.amount,
    required this.currency,
    required this.status,
    this.referenceId,
    this.notes,
    this.createdAt,
    this.processedAt,
  });

  factory PayoutRecord.fromJson(Map<String, dynamic> json) {
    return PayoutRecord(
      id: json['id'] as int? ?? 0,
      artisanId: json['artisan_id'] as int? ?? 0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'INR',
      status: json['status'] as String? ?? 'PROCESSED',
      referenceId: json['reference_id'] as String?,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      processedAt: json['processed_at'] != null ? DateTime.tryParse(json['processed_at']) : null,
    );
  }
}

class SellerLedger {
  final int artisanId;
  final String artisanName;
  final String shgName;
  
  final double totalSalesGross;
  final double platformFeesDeducted;
  final double netEarnings;
  final double totalPayoutsCompleted;
  final double pendingPayoutBalance;
  
  final int totalOrdersCount;
  final int activeOrdersCount;
  final int completedOrdersCount;
  final int totalProductsCount;
  final int availableProductsCount;
  final int soldOutProductsCount;
  
  final List<OrderReceipt> recentOrders;
  final List<PayoutRecord> recentPayouts;

  const SellerLedger({
    required this.artisanId,
    required this.artisanName,
    required this.shgName,
    required this.totalSalesGross,
    required this.platformFeesDeducted,
    required this.netEarnings,
    required this.totalPayoutsCompleted,
    required this.pendingPayoutBalance,
    required this.totalOrdersCount,
    required this.activeOrdersCount,
    required this.completedOrdersCount,
    required this.totalProductsCount,
    required this.availableProductsCount,
    required this.soldOutProductsCount,
    this.recentOrders = const [],
    this.recentPayouts = const [],
  });

  factory SellerLedger.fromJson(Map<String, dynamic> json) {
    return SellerLedger(
      artisanId: json['artisan_id'] as int? ?? 0,
      artisanName: json['artisan_name'] as String? ?? 'Artisan',
      shgName: json['shg_name'] as String? ?? 'SHG Collective',
      totalSalesGross: (json['total_sales_gross'] as num?)?.toDouble() ?? 0.0,
      platformFeesDeducted: (json['platform_fees_deducted'] as num?)?.toDouble() ?? 0.0,
      netEarnings: (json['net_earnings'] as num?)?.toDouble() ?? 0.0,
      totalPayoutsCompleted: (json['total_payouts_completed'] as num?)?.toDouble() ?? 0.0,
      pendingPayoutBalance: (json['pending_payout_balance'] as num?)?.toDouble() ?? 0.0,
      totalOrdersCount: json['total_orders_count'] as int? ?? 0,
      activeOrdersCount: json['active_orders_count'] as int? ?? 0,
      completedOrdersCount: json['completed_orders_count'] as int? ?? 0,
      totalProductsCount: json['total_products_count'] as int? ?? 0,
      availableProductsCount: json['available_products_count'] as int? ?? 0,
      soldOutProductsCount: json['sold_out_products_count'] as int? ?? 0,
      recentOrders: (json['recent_orders'] as List<dynamic>?)
              ?.map((e) => OrderReceipt.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      recentPayouts: (json['recent_payouts'] as List<dynamic>?)
              ?.map((e) => PayoutRecord.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
