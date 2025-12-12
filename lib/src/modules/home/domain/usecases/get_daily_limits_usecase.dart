import 'package:injectable/injectable.dart';

import '../repositories/comment_repository.dart';

@injectable
class GetDailyLimitsUseCase {
  final CommentRepository repository;

  GetDailyLimitsUseCase(this.repository);

  Future<Map<String, dynamic>> call() => repository.getDailyLimits();
}