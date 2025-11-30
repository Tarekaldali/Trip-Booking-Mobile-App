// UserProfile model for 'profiles' table
class UserProfile {
  final String id;
  final String? fullName;
  final String? imageUrl;
  final String role;
  final DateTime? createdAt;

  UserProfile({
    required this.id,
    this.fullName,
    this.imageUrl,
    this.role = 'user',
    this.createdAt,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as String,
      fullName: map['full_name'] as String?,
      imageUrl: map['image_url'] as String?,
      role: map['role'] as String? ?? 'user',
      createdAt:
          map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'image_url': imageUrl,
      'role': role,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
