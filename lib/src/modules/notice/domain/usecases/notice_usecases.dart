import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/notice_entity.dart';
import '../repositories/notice_repository.dart';

class GetNotificationsUseCase {
  final NoticeRepository repository;
  GetNotificationsUseCase(this.repository);
  Future<Either<Failure, List<NoticeEntity>>> call() => repository.getNotifications();
}

class GetUnreadCountUseCase {
  final NoticeRepository repository;
  GetUnreadCountUseCase(this.repository);
  Future<Either<Failure, int>> call() => repository.getUnreadCount();
}

class MarkAsReadUseCase {
  final NoticeRepository repository;
  MarkAsReadUseCase(this.repository);
  Future<Either<Failure, bool>> call(String id) => repository.markAsRead(id);
}

class MarkAllAsReadUseCase {
  final NoticeRepository repository;
  MarkAllAsReadUseCase(this.repository);
  Future<Either<Failure, bool>> call() => repository.markAllAsRead();
}

class DeleteNotificationUseCase {
  final NoticeRepository repository;
  DeleteNotificationUseCase(this.repository);
  Future<Either<Failure, bool>> call(String id) => repository.deleteNotification(id);
}