import 'package:freezed_annotation/freezed_annotation.dart';

part 'like_status_entity.freezed.dart';
part 'like_status_entity.g.dart';

@freezed
class LikeStatusEntity with _$LikeStatusEntity {
  const factory LikeStatusEntity({
    required String postId,
    required bool isLiked,
  }) = _LikeStatusEntity;

  factory LikeStatusEntity.fromJson(Map<String, dynamic> json) =>
      _$LikeStatusEntityFromJson(json);
}