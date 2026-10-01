class Artisan {
  final int id;
  final String name;
  final String shgName;
  final String craftType;
  final String location;
  final String? avatarUrl;
  final String? bio;
  final String? phone;
  final bool isVerified;

  const Artisan({
    required this.id,
    required this.name,
    required this.shgName,
    required this.craftType,
    required this.location,
    this.avatarUrl,
    this.bio,
    this.phone,
    this.isVerified = true,
  });

  factory Artisan.fromJson(Map<String, dynamic> json) {
    return Artisan(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'Artisan',
      shgName: json['shg_name'] as String? ?? 'Self Help Group',
      craftType: json['craft_type'] as String? ?? 'Handicrafts',
      location: json['location'] as String? ?? 'India',
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
      phone: json['phone'] as String?,
      isVerified: json['is_verified'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'shg_name': shgName,
      'craft_type': craftType,
      'location': location,
      'avatar_url': avatarUrl,
      'bio': bio,
      'phone': phone,
      'is_verified': isVerified,
    };
  }
}
