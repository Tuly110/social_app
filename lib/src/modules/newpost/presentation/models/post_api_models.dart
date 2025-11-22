import 'package:json_annotation/json_annotation.dart';

part 'post_api_models.g.dart';

@JsonSerializable()
class PostCreateRequest {
  final String content;
  final String? imageUrl;
  final String visibility;

  PostCreateRequest({
    required this.content,
    this.imageUrl,
    required this.visibility,
  });

  Map<String, dynamic> toJson() => _$PostCreateRequestToJson(this);

  factory PostCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$PostCreateRequestFromJson(json);
}

@JsonSerializable()
class PostUpdateRequest {
  final String? content;
  final String? imageUrl;
  final String? visibility; // 'public' | 'private' | ...

  PostUpdateRequest({
    this.content,
    this.imageUrl,
    this.visibility,
  });

  factory PostUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$PostUpdateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$PostUpdateRequestToJson(this);
}

@JsonSerializable()
class PostResponse {
  final String id;
  final String content;

  @JsonKey(name: 'image_url')
  final String? imageUrl;

  final String visibility;

  @JsonKey(name: 'user_id')
  final String userId;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  // thêm các field backend trả về
  final String? username;

  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;

  @JsonKey(name: 'like_count', defaultValue: 0)
  final int likeCount;

  @JsonKey(name: 'comment_count', defaultValue: 0)
  final int commentCount;

  @JsonKey(name: 'is_liked', defaultValue: false)
  final bool isLiked;

  PostResponse({
    required this.id,
    required this.content,
    this.imageUrl,
    required this.visibility,
    required this.userId,
    required this.createdAt,
    this.updatedAt,
    this.username,
    this.avatarUrl,
    this.likeCount = 0,
    this.commentCount = 0,
    this.isLiked = false,
  });

  factory PostResponse.fromJson(Map<String, dynamic> json) =>
      _$PostResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PostResponseToJson(this);
}
