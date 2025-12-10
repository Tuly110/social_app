import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/notice_entity.dart';
import '../../domain/repositories/notice_repository.dart';
import '../datasources/notice_remote_datasource.dart';

class NoticeRepositoryImpl implements NoticeRepository {
  final NoticeRemoteDataSource dataSource;

  NoticeRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, List<NoticeEntity>>> getNotifications() async {
    try {
      final result = await dataSource.getNotifications();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadCount() async {
    try {
      final result = await dataSource.getUnreadCount();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> markAsRead(String notificationId) async {
    try {
      final result = await dataSource.markAsRead(notificationId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> markAllAsRead() async {
     try {
      final result = await dataSource.markAllAsRead();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteNotification(String notificationId) async {
     try {
      final result = await dataSource.deleteNotification(notificationId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}