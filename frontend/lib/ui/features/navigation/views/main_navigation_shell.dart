import 'package:flutter/material.dart';
import 'package:artisan_market/core/theme/app_theme.dart';
import 'package:artisan_market/ui/features/feed/view_models/feed_view_model.dart';
import 'package:artisan_market/ui/features/feed/views/feed_screen.dart';
import 'package:artisan_market/ui/features/seller_dashboard/view_models/seller_view_model.dart';
import 'package:artisan_market/ui/features/seller_dashboard/views/seller_dashboard_screen.dart';

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  late final FeedViewModel _feedViewModel;
  late final SellerViewModel _sellerViewModel;

  @override
  void initState() {
    super.initState();
    _feedViewModel = FeedViewModel();
    _sellerViewModel = SellerViewModel();
  }

  @override
  void dispose() {
    _feedViewModel.dispose();
    _sellerViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          FeedScreen(viewModel: _feedViewModel),
          SellerDashboardScreen(viewModel: _sellerViewModel),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
          // Refresh seller dashboard when navigated to
          if (index == 1) {
            _sellerViewModel.loadDashboard();
          }
        },
        backgroundColor: Colors.white,
        elevation: 8,
        indicatorColor: AppColors.terracotta.withOpacity(0.18),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore, color: AppColors.terracotta),
            label: 'Discover Feed',
          ),
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront, color: AppColors.terracotta),
            label: 'Artisan Hub',
          ),
        ],
      ),
    );
  }
}
