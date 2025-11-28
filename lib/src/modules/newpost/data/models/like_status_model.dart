// lib/src/modules/newpost/data/models/like_status_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/like_status_entity.dart';

part 'like_status_model.freezed.dart';
part 'like_status_model.g.dart';

@freezed
class LikeStatusModel with _$LikeStatusModel {
  const factory LikeStatusModel({
    required String postId,
    required bool isLiked,
  }) = _LikeStatusModel;

  factory LikeStatusModel.fromJson(Map<String, dynamic> json) =>
      _$LikeStatusModelFromJson(json);

  
  LikeStatusEntity toEntity() {
    return LikeStatusEntity(
      postId: postId,
      isLiked: isLiked,
    );
  }
}