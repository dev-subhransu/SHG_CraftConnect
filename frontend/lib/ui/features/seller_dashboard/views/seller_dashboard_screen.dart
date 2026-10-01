import 'package:flutter/material.dart';
import 'package:artisan_market/core/theme/app_theme.dart';
import 'package:artisan_market/data/models/order.dart';
import 'package:artisan_market/data/models/post.dart';
import 'package:artisan_market/ui/features/seller_dashboard/view_models/seller_view_model.dart';
import 'package:artisan_market/ui/features/seller_dashboard/views/create_post_modal.dart';

class SellerDashboardScreen extends StatefulWidget {
  final SellerViewModel viewModel;

  const SellerDashboardScreen({super.key, required this.viewModel});

  @override
  State<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends State<SellerDashboardScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.viewModel.loadDashboard();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final ledger = widget.viewModel.ledger;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Artisan Seller Portal'),
            actions: [
              // Artisan Selector
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: DropdownButton<int>(
                  value: widget.viewModel.artisanId,
                  underline: const SizedBox(),
                  icon: const Icon(Icons.arrow_drop_down, color: AppColors.terracotta),
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('Sunita Devi (Mithila SHG)')),
                    DropdownMenuItem(value: 2, child: Text('Lakshmi (Pochampally Weavers)')),
                    DropdownMenuItem(value: 3, child: Text('Banamali (Bastar Dhokra)')),
                  ],
                  onChanged: (val) {
                    if (val != null) widget.viewModel.switchArtisan(val);
                  },
                ),
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              labelColor: AppColors.terracotta,
              unselectedLabelColor: AppColors.textMuted,
              indicatorColor: AppColors.terracotta,
              indicatorWeight: 3,
              tabs: const [
                Tab(icon: Icon(Icons.inventory_2_outlined), text: 'Inventory'),
                Tab(icon: Icon(Icons.shopping_bag_outlined), text: 'Orders'),
                Tab(icon: Icon(Icons.account_balance_wallet_outlined), text: 'Payouts'),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => CreatePostModal.show(context, widget.viewModel),
            backgroundColor: AppColors.terracotta,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add_photo_alternate),
            label: const Text('New Post', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          body: widget.viewModel.isLoading && ledger == null
              ? const Center(child: CircularProgressIndicator(color: AppColors.terracotta))
              : Column(
                  children: [
                    // Top Financial Overview Card
                    if (ledger != null)
                      _FinancialHeaderCard(
                        ledger: ledger,
                        onRequestPayout: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: AppColors.forestGreen,
                              content: Text('Disbursed ₹${ledger.pendingPayoutBalance.toStringAsFixed(0)} directly to linked SHG account!'),
                            ),
                          );
                        },
                      ),

                    // Tab Views
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          // Tab 1: Live Inventory
                          _InventoryTab(
                            posts: widget.viewModel.myPosts,
                            onToggleStatus: (post, markSoldOut) {
                              widget.viewModel.togglePostStatus(post.id, markSoldOut);
                            },
                          ),

                          // Tab 2: Orders Ledger
                          _OrdersTab(orders: ledger?.recentOrders ?? []),

                          // Tab 3: Payouts Ledger
                          _PayoutsTab(ledger: ledger),
                        ],
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _FinancialHeaderCard extends StatelessWidget {
  final dynamic ledger;
  final VoidCallback onRequestPayout;

  const _FinancialHeaderCard({required this.ledger, required this.onRequestPayout});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.deepIndigo,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Pending Payout Balance', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 2),
                  Text(
                    '₹${ledger.pendingPayoutBalance.toStringAsFixed(0)}',
                    style: const TextStyle(color: AppColors.goldAccent, fontSize: 26, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: ledger.pendingPayoutBalance > 0 ? onRequestPayout : null,
                icon: const Icon(Icons.send_rounded, size: 16),
                label: const Text('Disburse'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.forestGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _MetricItem(label: 'Gross Sales', value: '₹${ledger.totalSalesGross.toStringAsFixed(0)}'),
              _MetricItem(label: 'Net Earnings', value: '₹${ledger.netEarnings.toStringAsFixed(0)}'),
              _MetricItem(label: 'Completed Payouts', value: '₹${ledger.totalPayoutsCompleted.toStringAsFixed(0)}'),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricItem extends StatelessWidget {
  final String label;
  final String value;

  const _MetricItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
      ],
    );
  }
}

class _InventoryTab extends StatelessWidget {
  final List<ProductPost> posts;
  final Function(ProductPost post, bool markSoldOut) onToggleStatus;

  const _InventoryTab({required this.posts, required this.onToggleStatus});

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return const Center(child: Text('No products uploaded yet. Tap "+ New Post" to publish!'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: posts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final post = posts[index];
        final isSoldOut = post.isSoldOut;

        return Card(
          elevation: 1.5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    post.mediaUrl,
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 72,
                      height: 72,
                      color: AppColors.ochre,
                      child: const Icon(Icons.handyman, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textDark),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '₹${post.price.toStringAsFixed(0)} • Stock: ${post.stockQuantity}',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.grey.shade800),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isSoldOut ? AppColors.soldOutBadge.withOpacity(0.12) : AppColors.forestGreen.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isSoldOut ? '🔴 SOLD OUT' : '🟢 IN STOCK',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isSoldOut ? AppColors.soldOutBadge : AppColors.forestGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Inventory Toggle Switch
                Column(
                  children: [
                    Switch(
                      value: !isSoldOut,
                      activeColor: AppColors.forestGreen,
                      onChanged: (isInStock) {
                        onToggleStatus(post, !isInStock);
                      },
                    ),
                    Text(
                      isSoldOut ? 'Mark In Stock' : 'Mark Sold Out',
                      style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _OrdersTab extends StatelessWidget {
  final List<OrderReceipt> orders;

  const _OrdersTab({required this.orders});

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return const Center(child: Text('No orders yet. They will appear here immediately on Instant Checkout!'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final order = orders[index];

        return Card(
          elevation: 1.5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      order.orderNumber,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.deepIndigo),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.forestGreen.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        order.paymentStatus,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.forestGreen),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  order.itemTitle ?? 'Handcrafted Item',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textDark),
                ),
                const SizedBox(height: 4),
                Text(
                  'Buyer: ${order.buyerName} (${order.buyerPhone})',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
                ),
                Text(
                  'Ship to: ${order.shippingAddress}, ${order.shippingCity} - ${order.shippingPincode}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
                const SizedBox(height: 8),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Net Artisan Share: ₹${order.netArtisanAmount.toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.terracotta),
                    ),
                    Text(
                      'Total: ₹${order.totalAmount.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PayoutsTab extends StatelessWidget {
  final dynamic ledger;

  const _PayoutsTab({required this.ledger});

  @override
  Widget build(BuildContext context) {
    if (ledger == null || ledger.recentPayouts.isEmpty) {
      return const Center(child: Text('No payout disbursements recorded yet.'));
    }

    final payouts = ledger.recentPayouts;

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: payouts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final p = payouts[index];

        return Card(
          elevation: 1.5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: AppColors.parchment,
              child: Icon(Icons.account_balance, color: AppColors.forestGreen),
            ),
            title: Text(
              'Bank Transfer: ₹${p.amount.toStringAsFixed(0)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            subtitle: Text(
              '${p.referenceId ?? "NEFT"} • ${p.notes ?? "Direct SHG Payout"}',
              style: const TextStyle(fontSize: 12),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.forestGreen.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'PROCESSED',
                style: TextStyle(color: AppColors.forestGreen, fontWeight: FontWeight.bold, fontSize: 11),
              ),
            ),
          ),
        );
      },
    );
  }
}
