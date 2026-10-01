import 'package:flutter/material.dart';
import 'package:artisan_market/core/theme/app_theme.dart';
import 'package:artisan_market/data/models/post.dart';

class ArtisanStorySheet extends StatelessWidget {
  final ProductPost post;

  const ArtisanStorySheet({super.key, required this.post});

  static void show(BuildContext context, ProductPost post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => ArtisanStorySheet(post: post),
    );
  }

  @override
  Widget build(BuildContext context) {
    final artisan = post.artisan;

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              // Header: Artisan Profile
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.terracotta.withOpacity(0.15),
                    backgroundImage: artisan?.avatarUrl != null ? NetworkImage(artisan!.avatarUrl!) : null,
                    child: artisan?.avatarUrl == null
                        ? Text(
                            artisan?.name.substring(0, 1) ?? 'A',
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.terracotta),
                          )
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              artisan?.name ?? 'Master Artisan',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.verified, size: 18, color: AppColors.forestGreen),
                          ],
                        ),
                        Text(
                          artisan?.shgName ?? 'Self Help Group Collective',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.terracotta),
                        ),
                        Text(
                          artisan?.location ?? 'India',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 12),

              // Craft technique badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.goldAccent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.handyman_outlined, size: 16, color: AppColors.deepTerracotta),
                    const SizedBox(width: 6),
                    Text(
                      artisan?.craftType ?? 'Handmade Craft',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.deepTerracotta),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              Text(
                post.title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              const SizedBox(height: 12),

              // Description
              Text(
                post.description,
                style: const TextStyle(fontSize: 15, height: 1.5, color: AppColors.textDark),
              ),

              if (post.craftStory != null && post.craftStory!.isNotEmpty) ...[
                const SizedBox(height: 20),
                const Text(
                  'Heritage Technique & Story',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.parchment,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    post.craftStory!,
                    style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic, height: 1.5, color: AppColors.textDark),
                  ),
                ),
              ],

              if (artisan?.bio != null && artisan!.bio!.isNotEmpty) ...[
                const SizedBox(height: 20),
                const Text(
                  'About the SHG Collective',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
                ),
                const SizedBox(height: 8),
                Text(
                  artisan.bio!,
                  style: TextStyle(fontSize: 14, height: 1.5, color: Colors.grey.shade800),
                ),
              ],

              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
