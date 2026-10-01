import 'package:flutter/material.dart';
import 'package:artisan_market/core/theme/app_theme.dart';
import 'package:artisan_market/data/models/post.dart';
import 'package:artisan_market/ui/features/checkout/view_models/checkout_view_model.dart';
import 'package:artisan_market/ui/features/checkout/views/order_success_dialog.dart';
import 'package:artisan_market/ui/features/feed/view_models/feed_view_model.dart';

class InstantCheckoutBottomSheet extends StatefulWidget {
  final ProductPost post;
  final FeedViewModel feedViewModel;

  const InstantCheckoutBottomSheet({
    super.key,
    required this.post,
    required this.feedViewModel,
  });

  static void show(BuildContext context, ProductPost post, FeedViewModel feedViewModel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => InstantCheckoutBottomSheet(
        post: post,
        feedViewModel: feedViewModel,
      ),
    );
  }

  @override
  State<InstantCheckoutBottomSheet> createState() => _InstantCheckoutBottomSheetState();
}

class _InstantCheckoutBottomSheetState extends State<InstantCheckoutBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _checkoutViewModel = CheckoutViewModel();

  // Pre-filled defaults for frictionless testing
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _cityController;
  late final TextEditingController _stateController;
  late final TextEditingController _pincodeController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: 'Ananya Sharma');
    _phoneController = TextEditingController(text: '+919811223344');
    _addressController = TextEditingController(text: 'Flat 402, Lotus Greens, Sector 78');
    _cityController = TextEditingController(text: 'Noida');
    _stateController = TextEditingController(text: 'Uttar Pradesh');
    _pincodeController = TextEditingController(text: '201301');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _checkoutViewModel.dispose();
    super.dispose();
  }

  Future<void> _handleInstantPay() async {
    if (!_formKey.currentState!.validate()) return;

    final receipt = await _checkoutViewModel.processInstantCheckout(
      post: widget.post,
      buyerName: _nameController.text,
      buyerPhone: _phoneController.text,
      shippingAddress: _addressController.text,
      shippingCity: _cityController.text,
      shippingState: _stateController.text,
      shippingPincode: _pincodeController.text,
    );

    if (receipt != null && mounted) {
      // 1. Locally decrement stock & update feed instantly
      widget.feedViewModel.decrementPostStock(widget.post.id, 1);

      // 2. Dismiss slide-up checkout overlay
      Navigator.of(context).pop();

      // 3. Show celebratory confirmation dialog
      OrderSuccessDialog.show(context, receipt);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return ListenableBuilder(
      listenable: _checkoutViewModel,
      builder: (context, _) {
        return Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Drag Handle
                    Center(
                      child: Container(
                        width: 44,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    // Header: Direct Instant Checkout (Bypassing cart)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Instant Checkout',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                            Text(
                              'Cart bypassed • Direct artisan purchase',
                              style: TextStyle(fontSize: 12, color: AppColors.forestGreen, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Product Summary Card
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.parchment,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              widget.post.mediaUrl,
                              width: 64,
                              height: 64,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 64,
                                height: 64,
                                color: AppColors.ochre,
                                child: const Icon(Icons.palette, color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.post.title,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textDark,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  widget.post.artisan?.shgName ?? 'Artisan Collective',
                                  style: const TextStyle(fontSize: 12, color: AppColors.terracotta, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '₹${widget.post.price.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.textDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (_checkoutViewModel.errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, size: 18, color: Colors.red),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _checkoutViewModel.errorMessage!,
                                style: TextStyle(color: Colors.red.shade900, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 18),

                    // Section 1: Shipping Details
                    const Text(
                      'Delivery Address',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textDark),
                    ),
                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Full Name',
                              prefixIcon: Icon(Icons.person_outline, size: 20),
                            ),
                            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: 'Phone',
                              prefixIcon: Icon(Icons.phone_outlined, size: 20),
                            ),
                            validator: (v) => v == null || v.length < 10 ? 'Valid phone required' : null,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Street Address / House No.',
                        prefixIcon: Icon(Icons.home_outlined, size: 20),
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Address required' : null,
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            controller: _cityController,
                            decoration: const InputDecoration(labelText: 'City'),
                            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            controller: _stateController,
                            decoration: const InputDecoration(labelText: 'State'),
                            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _pincodeController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Pincode'),
                            validator: (v) => v == null || v.length < 4 ? 'Invalid' : null,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Section 2: Payment Gateway Selection
                    const Text(
                      'Payment Method',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textDark),
                    ),
                    const SizedBox(height: 10),

                    Row(
                      children: [
                        _PaymentMethodTile(
                          title: '⚡ 1-Tap Mock',
                          subtitle: 'Fast dev testing',
                          isSelected: _checkoutViewModel.selectedPaymentMethod == 'MOCK',
                          onTap: () => _checkoutViewModel.selectPaymentMethod('MOCK'),
                        ),
                        const SizedBox(width: 8),
                        _PaymentMethodTile(
                          title: '🇮🇳 UPI / Razorpay',
                          subtitle: 'GPay / PhonePe',
                          isSelected: _checkoutViewModel.selectedPaymentMethod == 'RAZORPAY',
                          onTap: () => _checkoutViewModel.selectPaymentMethod('RAZORPAY'),
                        ),
                        const SizedBox(width: 8),
                        _PaymentMethodTile(
                          title: '💳 Card / Stripe',
                          subtitle: 'Visa / MC',
                          isSelected: _checkoutViewModel.selectedPaymentMethod == 'STRIPE',
                          onTap: () => _checkoutViewModel.selectPaymentMethod('STRIPE'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Transparency Box
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Amount:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          Text(
                            '₹${widget.post.price.toStringAsFixed(0)}',
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.terracotta),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Confirm & Instant Pay Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _checkoutViewModel.isProcessing ? null : _handleInstantPay,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.terracotta,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: _checkoutViewModel.isProcessing
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                  ),
                                  SizedBox(width: 12),
                                  Text('Authorizing Payment...', style: TextStyle(color: Colors.white)),
                                ],
                              )
                            : Text(
                                'Slide to Pay • ₹${widget.post.price.toStringAsFixed(0)}',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                      ),
                    ),

                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentMethodTile({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.terracotta.withOpacity(0.08) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.terracotta : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? AppColors.terracotta : AppColors.textDark,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected ? AppColors.terracotta : Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
