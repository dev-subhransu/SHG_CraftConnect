import 'package:flutter/material.dart';
import 'package:artisan_market/core/theme/app_theme.dart';
import 'package:artisan_market/data/models/post.dart';
import 'package:artisan_market/ui/features/feed/views/artisan_story_sheet.dart';

class FeedItemCard extends StatelessWidget {
  final ProductPost post;
  final VoidCallback onBuyNow;

  const FeedItemCard({
    super.key,
    required this.post,
    required this.onBuyNow,
  });

  @override
  Widget build(BuildContext context) {
    final artisan = post.artisan;
    final isSoldOut = post.isSoldOut;

    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. Full-bleed product media (image / video preview)
        Container(
          color: Colors.black,
          child: Image.network(
            post.mediaUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: const Color(0xFF2C2420),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.handyman, size: 64, color: AppColors.ochre),
                      const SizedBox(height: 12),
                      Text(
                        post.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              );
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: const Color(0xFF1E1E1E),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.terracotta,
                    strokeWidth: 2.5,
                  ),
                ),
              );
            },
          ),
        ),

        // 2. High-contrast gradient overlay for readable text and controls
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.35),
                Colors.transparent,
                Colors.black.withOpacity(0.4),
                Colors.black.withOpacity(0.92),
              ],
              stops: const [0.0, 0.25, 0.6, 1.0],
            ),
          ),
        ),

        // 3. Top Badges: SHG certification & craft origin
        Positioned(
          top: MediaQuery.of(context).padding.top + 55,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.55),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white24, width: 0.8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.verified_outlined, size: 14, color: AppColors.goldAccent),
                const SizedBox(width: 5),
                Text(
                  artisan?.shgName ?? 'Verified Artisan SHG',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),

        // 4. Right Action Bar (Story, Share, Save)
        Positioned(
          right: 14,
          bottom: 150,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Craft Story Button
              _ActionButton(
                icon: Icons.auto_stories,
                label: 'Story',
                onTap: () => ArtisanStorySheet.show(context, post),
              ),
              const SizedBox(height: 18),

              // Share Button
              _ActionButton(
                icon: Icons.share_rounded,
                label: 'Share',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Sharing ${post.title} with friends!'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
              const SizedBox(height: 18),

              // Fair Trade / Impact Badge
              _ActionButton(
                icon: Icons.spa_outlined,
                label: 'Direct',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('100% Direct Fair Trade: 95% proceeds go to the artisan!'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        // 5. Bottom Overlay: Artisan info, Title, Price, & PROMINENT BUY NOW Button
        Positioned(
          left: 16,
          right: 80,
          bottom: 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Artisan info row
              GestureDetector(
                onTap: () => ArtisanStorySheet.show(context, post),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.ochre,
                      backgroundImage: artisan?.avatarUrl != null
                          ? NetworkImage(artisan!.avatarUrl!)
                          : null,
                      child: artisan?.avatarUrl == null
                          ? Text(
                              artisan?.name.substring(0, 1) ?? 'A',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  artisan?.name ?? 'Artisan',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.check_circle, size: 14, color: AppColors.forestGreen),
                            ],
                          ),
                          Text(
                            artisan?.location ?? 'Handcrafted in India',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.75),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Product Title
              Text(
                post.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 4),

              // Description snippet
              Text(
                post.description,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 13,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 10),

              // Price & Stock Tag
              Row(
                children: [
                  Text(
                    '₹${post.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: AppColors.goldAccent,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isSoldOut ? AppColors.soldOutBadge : AppColors.forestGreen,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isSoldOut ? 'SOLD OUT' : 'Only ${post.stockQuantity} left',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // PROMINENT BUY NOW BUTTON (Features prominent Buy Now instead of traditional Like)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: isSoldOut ? null : onBuyNow,
                  icon: Icon(
                    isSoldOut ? Icons.block : Icons.bolt_rounded,
                    size: 20,
                    color: Colors.white,
                  ),
                  label: Text(
                    isSoldOut
                        ? 'Piece Sold Out'
                        : '⚡ Buy Now • ₹${post.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSoldOut ? Colors.grey.shade700 : AppColors.terracotta,
                    disabledBackgroundColor: Colors.grey.shade800,
                    foregroundColor: Colors.white,
                    disabledForegroundColor: Colors.white54,
                    elevation: 4,
                    shadowColor: AppColors.terracotta.withOpacity(0.6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.45),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24, width: 1),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
