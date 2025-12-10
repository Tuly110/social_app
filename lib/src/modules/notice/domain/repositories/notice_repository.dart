import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/notice_entity.dart';

abstract class NoticeRepository {
  Future<Either<Failure, List<NoticeEntity>>> getNotifications();
  Future<Either<Failure, int>> getUnreadCount();
  Future<Either<Failure, bool>> markAsRead(String notificationId);
  Future<Either<Failure, bool>> markAllAsRead();
  Future<Either<Failure, bool>> deleteNotification(String notificationId);
}