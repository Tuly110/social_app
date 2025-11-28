import 'package:injectable/injectable.dart';

import '../entities/like_status_entity.dart';
import '../repositories/post_repository.dart';

@injectable
class GetLikeStatusUseCase {
  final PostRepository repository;

  GetLikeStatusUseCase(this.repository);

  Future<LikeStatusEntity> call(String postId) => repository.getLikeStatus(postId);
}