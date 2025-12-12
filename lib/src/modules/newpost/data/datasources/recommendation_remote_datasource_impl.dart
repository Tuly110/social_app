import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/post_entity.dart';

@injectable
class RecommendationRemoteDatasourceImpl {
  final Dio _dio;
  RecommendationRemoteDatasourceImpl(this._dio);

  Future<List<PostEntity>> getRecommendedFeed({
    required String userId,
    int limit = 20,
  }) async {
    try {
      print('[RecDS] Getting recommendations for user: $userId');
      
      final response = await _dio.get(
        '/recommendations/feed/$userId',
        queryParameters: {'limit': limit},
      );

      print('[RecDS] Response: ${response.statusCode}');
      
      final data = response.data as Map<String, dynamic>;
      
      // Kết hợp cả recommended_posts và trending_posts
      final allPosts = [
        ...(data['recommended_posts'] as List<dynamic>? ?? []),
        ...(data['trending_posts'] as List<dynamic>? ?? []),
      ];

      // Chuyển đổi sang PostEntity
      return allPosts.map((postData) {
        // Recommendation API trả về field khác với Post API
        return PostEntity(
          id: postData['post_id']?.toString() ?? '',
          authorId: postData['user_id']?.toString() ?? '',
          authorName: postData['username']?.toString() ?? 'Ẩn danh',
          authorAvatarUrl: postData['avatar_url']?.toString(),
          content: postData['content']?.toString() ?? '',
          imageUrl: postData['image_url']?.toString(),
          createdAt: _parseDateTime(postData['created_at']),
          updatedAt: _parseDateTime(postData['created_at']),
          likeCount: (postData['likes_count'] as int?) ?? 0,
          commentCount: (postData['comments_count'] as int?) ?? 0,
          isLiked: false,
          visibility: 'public',
          type: 'original',
          originalPostId: null,
        );
      }).toList();
    } catch (e, st) {
      print('[RecDS] Error: $e');
      print(st);
      rethrow;
    }
  }

  DateTime _parseDateTime(dynamic dateString) {
    try {
      if (dateString == null) return DateTime.now();
      return DateTime.parse(dateString.toString());
    } catch (_) {
      return DateTime.now();
    }
  }
}
