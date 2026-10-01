import 'package:flutter/material.dart';
import 'package:artisan_market/core/theme/app_theme.dart';
import 'package:artisan_market/data/models/order.dart';

class OrderSuccessDialog extends StatelessWidget {
  final OrderReceipt receipt;

  const OrderSuccessDialog({super.key, required this.receipt});

  static void show(BuildContext context, OrderReceipt receipt) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => OrderSuccessDialog(receipt: receipt),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success icon animation container
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.forestGreen.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: AppColors.forestGreen,
                size: 46,
              ),
            ),
            const SizedBox(height: 18),

            const Text(
              'Order Placed Instantly!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),

            Text(
              'Ref: ${receipt.orderNumber}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 16),

            // SHG Impact Banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.parchment,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.goldAccent.withOpacity(0.4)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.volunteer_activism, size: 20, color: AppColors.terracotta),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Direct Artisan Impact',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.brown.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '₹${receipt.netArtisanAmount.toStringAsFixed(0)} is credited directly to ${receipt.artisanName ?? "the artisan"}\'s ${receipt.shgName ?? "Self Help Group"} account.',
                    style: const TextStyle(fontSize: 12, height: 1.4, color: AppColors.textDark),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Delivery Details Summary
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Deliver to:', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
                Text(
                  receipt.buyerName,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textDark),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Amount Paid:', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
                Text(
                  '₹${receipt.totalAmount.toStringAsFixed(0)} (${receipt.paymentMethod})',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.forestGreen),
                ),
              ],
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.deepIndigo,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Back to Artisan Discovery', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
