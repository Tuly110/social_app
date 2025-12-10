import 'package:injectable/injectable.dart';

import '../entities/post_entity.dart';
import '../repositories/post_repository.dart';

@injectable
class GetPostByIdUseCase {
  final PostRepository repository;

  GetPostByIdUseCase(this.repository);

  Future<PostEntity> call(String postId) {
    return repository.getPostById(postId);
  }
}