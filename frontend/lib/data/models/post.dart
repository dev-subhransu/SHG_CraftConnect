import 'package:artisan_market/data/models/artisan.dart';

class ProductPost {
  final int id;
  final int artisanId;
  final String title;
  final String description;
  final String? craftStory;
  final String mediaUrl;
  final String mediaType; // 'image' or 'video'
  final String? thumbnailUrl;
  final double price;
  final String currency;
  final int stockQuantity;
  final String status; // 'AVAILABLE' or 'SOLD_OUT'
  final int likesCount;
  final int viewsCount;
  final DateTime? createdAt;
  final Artisan? artisan;

  const ProductPost({
    required this.id,
    required this.artisanId,
    required this.title,
    required this.description,
    this.craftStory,
    required this.mediaUrl,
    this.mediaType = 'image',
    this.thumbnailUrl,
    required this.price,
    this.currency = 'INR',
    required this.stockQuantity,
    required this.status,
    this.likesCount = 0,
    this.viewsCount = 0,
    this.createdAt,
    this.artisan,
  });

  bool get isSoldOut => status.toUpperCase() == 'SOLD_OUT' || stockQuantity <= 0;

  factory ProductPost.fromJson(Map<String, dynamic> json) {
    return ProductPost(
      id: json['id'] as int? ?? 0,
      artisanId: json['artisan_id'] as int? ?? 0,
      title: json['title'] as String? ?? 'Handcrafted Art',
      description: json['description'] as String? ?? '',
      craftStory: json['craft_story'] as String?,
      mediaUrl: json['media_url'] as String? ?? '',
      mediaType: json['media_type'] as String? ?? 'image',
      thumbnailUrl: json['thumbnail_url'] as String?,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'INR',
      stockQuantity: json['stock_quantity'] as int? ?? 0,
      status: json['status'] as String? ?? 'AVAILABLE',
      likesCount: json['likes_count'] as int? ?? 0,
      viewsCount: json['views_count'] as int? ?? 0,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      artisan: json['artisan'] != null ? Artisan.fromJson(json['artisan']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'artisan_id': artisanId,
      'title': title,
      'description': description,
      'craft_story': craftStory,
      'media_url': mediaUrl,
      'media_type': mediaType,
      'thumbnail_url': thumbnailUrl,
      'price': price,
      'currency': currency,
      'stock_quantity': stockQuantity,
      'status': status,
      'likes_count': likesCount,
      'views_count': viewsCount,
      'created_at': createdAt?.toIso8601String(),
      'artisan': artisan?.toJson(),
    };
  }

  ProductPost copyWith({
    int? stockQuantity,
    String? status,
  }) {
    return ProductPost(
      id: id,
      artisanId: artisanId,
      title: title,
      description: description,
      craftStory: craftStory,
      mediaUrl: mediaUrl,
      mediaType: mediaType,
      thumbnailUrl: thumbnailUrl,
      price: price,
      currency: currency,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      status: status ?? this.status,
      likesCount: likesCount,
      viewsCount: viewsCount,
      createdAt: createdAt,
      artisan: artisan,
    );
  }
}
