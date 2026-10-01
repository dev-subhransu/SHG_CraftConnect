import 'package:flutter/material.dart';
import 'package:artisan_market/core/theme/app_theme.dart';
import 'package:artisan_market/ui/features/feed/view_models/feed_view_model.dart';
import 'package:artisan_market/ui/features/feed/views/feed_item_card.dart';
import 'package:artisan_market/ui/features/checkout/views/instant_checkout_bottom_sheet.dart';

class FeedScreen extends StatefulWidget {
  final FeedViewModel viewModel;

  const FeedScreen({super.key, required this.viewModel});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final PageController _pageController = PageController();

  final List<String> _categories = [
    'All',
    'Madhubani',
    'Handloom',
    'Dhokra',
    'Pottery',
    'Woodcraft',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.viewModel.posts.isEmpty) {
        widget.viewModel.loadFeed();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        if (widget.viewModel.isLoading && widget.viewModel.posts.isEmpty) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: AppColors.terracotta),
                  SizedBox(height: 16),
                  Text(
                    'Loading Artisan Showcase...',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
          );
        }

        if (widget.viewModel.errorMessage != null && widget.viewModel.posts.isEmpty) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off_rounded, size: 54, color: AppColors.terracotta),
                    const SizedBox(height: 14),
                    Text(
                      widget.viewModel.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, color: AppColors.textDark),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => widget.viewModel.loadFeed(),
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final posts = widget.viewModel.posts;

        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              // 1. Vertical Discovery Feed (Instagram-style full-bleed snapping cards)
              RefreshIndicator(
                color: AppColors.terracotta,
                onRefresh: () => widget.viewModel.loadFeed(),
                child: PageView.builder(
                  controller: _pageController,
                  scrollDirection: Axis.vertical,
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return FeedItemCard(
                      post: post,
                      onBuyNow: () {
                        InstantCheckoutBottomSheet.show(context, post, widget.viewModel);
                      },
                    );
                  },
                ),
              ),

              // 2. Top Header with App Logo and Category Filter Chips
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 8,
                    bottom: 10,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Branding Title
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Icon(Icons.hub_outlined, color: AppColors.ochre, size: 24),
                            SizedBox(width: 8),
                            Text(
                              'SHG CraftConnect',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Horizontal Category Filter
                      SizedBox(
                        height: 34,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _categories.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final cat = _categories[index];
                            final isSelected = widget.viewModel.selectedCategory == cat;

                            return GestureDetector(
                              onTap: () => widget.viewModel.filterCategory(cat),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.terracotta
                                      : Colors.black.withOpacity(0.45),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: isSelected ? AppColors.ochre : Colors.white24,
                                    width: 1,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    cat,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : Colors.white70,
                                      fontSize: 12,
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
