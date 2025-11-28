import '../../domain/entities/post_entity.dart';
import '../../data/models/like_status_model.dart';

abstract class PostRemoteDataSource {
  Future<List<PostEntity>> getFeed({int page, int limit});

  Future<PostEntity> createPost(
    String content, {
    String? imageUrl,
    required String visibility,
  });

  Future<PostEntity> toggleLike(String postId);

  Future<PostEntity> updatePost(
    String postId, {
    String? content,
    String? imageUrl,
  });

  Future<void> deletePost(String postId);

  Future<LikeStatusModel> getLikeStatus(String postId);

  Future<Map<String, dynamic>> getDailyLimits();

  Future<int> getLikeCount(String postId);

  Future<List<String>> getPostLikes(String postId);

  Future<List<String>> getUserLikes();
}
