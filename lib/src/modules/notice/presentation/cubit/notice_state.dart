import '../../domain/entities/notice_entity.dart';

abstract class NoticeState {}

class NoticeInitial extends NoticeState {}

class NoticeLoading extends NoticeState {}

class NoticeLoaded extends NoticeState {
  final List<NoticeEntity> notices;
  final int unreadCount;

  NoticeLoaded({
    required this.notices,
    this.unreadCount = 0,
  });

  NoticeLoaded copyWith({
    List<NoticeEntity>? notices,
    int? unreadCount,
  }) {
    return NoticeLoaded(
      notices: notices ?? this.notices,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

class NoticeError extends NoticeState {
  final String message;
  NoticeError(this.message);
}