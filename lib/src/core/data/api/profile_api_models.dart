import 'package:equatable/equatable.dart';

class ProfileModel extends Equatable {
  final String id;
  final String username;
  final String email;
  final String? avatarUrl;

  final bool isEmailVerified;

  final String? bio;
  final String? website;
  final int followerCount;
  final int followingCount;
  final int postCount;
  final String? createdAt;
  final bool isFollowing;

  const ProfileModel({
    required this.id,
    required this.username,
    required this.email,
    this.avatarUrl,
    this.isEmailVerified = false,
    this.bio,
    this.website,
    this.followerCount = 0,
    this.followingCount = 0,
    this.postCount = 0,
    this.createdAt,
    this.isFollowing = false,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatar_url'] as String?,
      isEmailVerified: json['is_email_verified'] as bool? ?? false,
      bio: json['bio'] as String?,
      website: json['website'] as String?,
      followerCount: (json['follower_count'] ?? 0) as int,
      followingCount: (json['following_count'] ?? 0) as int,
      postCount: (json['post_count'] ?? 0) as int,
      createdAt: json['created_at'] as String?,
      isFollowing: json['is_following'] as bool? ?? false,
      
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'avatar_url': avatarUrl,
      'is_email_verified': isEmailVerified,
      'bio': bio,
      'website': website,
      'follower_count': followerCount,
      'following_count': followingCount,
      'post_count': postCount,
      'created_at': createdAt,
      'is_following': isFollowing,
    };
  }

  ProfileModel copyWith({
    String? username,
    String? email,
    String? avatarUrl,
    bool? isEmailVerified,
    String? bio,
    String? website,
    int? followerCount,
    int? followingCount,
    int? postCount,
    String? createdAt,
    bool? isFollowing,
  }) {
    return ProfileModel(
      id: id,
      username: username ?? this.username,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      bio: bio ?? this.bio,
      website: website ?? this.website,
      followerCount: followerCount ?? this.followerCount,
      followingCount: followingCount ?? this.followingCount,
      postCount: postCount ?? this.postCount,
      createdAt: createdAt ?? this.createdAt,
      isFollowing: isFollowing ?? this.isFollowing,
    );
  }

  @override
  List<Object?> get props => [
        id,
        username,
        email,
        avatarUrl,
        isEmailVerified,
        bio,
        website,
        followerCount,
        followingCount,
        postCount,
        createdAt,
        isFollowing,
      ];
}

/// Body gửi lên cho PUT /profile/
class ProfileUpdateRequest {
  final String? username;
  final String? avatarUrl;
  final String? bio;

  const ProfileUpdateRequest({
    this.username,
    this.avatarUrl,
    this.bio,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (username != null) map['username'] = username;
    if (avatarUrl != null) map['avatar_url'] = avatarUrl;
    if (bio != null) map['bio'] = bio;
    return map;
  }
}
