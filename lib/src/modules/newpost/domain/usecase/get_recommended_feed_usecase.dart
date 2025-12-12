// lib/src/modules/newpost/domain/usecase/get_recommended_feed_usecase.dart
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../entities/post_entity.dart';
import '../repositories/post_repository.dart';

@injectable
class GetRecommendedFeedUseCase {
  final PostRepository _repository;
  final SupabaseClient _supabaseClient;

  GetRecommendedFeedUseCase(this._repository, this._supabaseClient);

  Future<List<PostEntity>> call({int limit = 20}) async {
    // Lấy userId từ Supabase auth
    final userId = _supabaseClient.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    return await _repository.getRecommendedFeed(
      userId: userId, // ← TRUYỀN userId Ở ĐÂY
      limit: limit,
    );
  }
}