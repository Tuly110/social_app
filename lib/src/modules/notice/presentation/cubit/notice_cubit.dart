import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/notice_usecases.dart'; 
import '../../domain/entities/notice_entity.dart';
import 'notice_state.dart';

class NoticeCubit extends Cubit<NoticeState> {
  final GetNotificationsUseCase getNotificationsUseCase;
  final GetUnreadCountUseCase getUnreadCountUseCase;
  final MarkAsReadUseCase markAsReadUseCase;
  final MarkAllAsReadUseCase markAllAsReadUseCase;
  final DeleteNotificationUseCase deleteNotificationUseCase;

  NoticeCubit({
    required this.getNotificationsUseCase,
    required this.getUnreadCountUseCase,
    required this.markAsReadUseCase,
    required this.markAllAsReadUseCase,
    required this.deleteNotificationUseCase,
  }) : super(NoticeInitial());

  Future<void> fetchNotifications() async {
    emit(NoticeLoading());
    final results = await Future.wait([
      getNotificationsUseCase(),
      getUnreadCountUseCase(),
    ]);

    final noticesResult = results[0]; 
    final countResult = results[1];   

    int unreadCount = 0;
    if (countResult.isRight()) {
      countResult.fold((l) => null, (r) => unreadCount = r as int);
    }

    // Xử lý danh sách
    noticesResult.fold(
      (failure) => emit(NoticeError(failure.toString())),
      (data) {
        final notices = data as List<NoticeEntity>; 
        emit(NoticeLoaded(notices: notices, unreadCount: unreadCount));
      },
    );
  }

  Future<void> markAsRead(String id) async {
    if (state is NoticeLoaded) {
      final currentState = state as NoticeLoaded;

      bool isReducingCount = false;
      
      final updatedList = currentState.notices.map((notice) {
        if (notice.id == id) {
          if (!notice.isRead) isReducingCount = true;
          return notice.copyWith(isRead: true); 
        }
        return notice;
      }).toList();

      final newCount = isReducingCount 
          ? (currentState.unreadCount > 0 ? currentState.unreadCount - 1 : 0)
          : currentState.unreadCount;

      emit(currentState.copyWith(notices: updatedList, unreadCount: newCount));

      final result = await markAsReadUseCase(id);
      result.fold(
        (l) {
            // for API error
            fetchNotifications(); 
        },
        (r) => null,
      );
    }
  }

  Future<void> markAllRead() async {
    if (state is NoticeLoaded) {
      final currentState = state as NoticeLoaded;

      final updatedList = currentState.notices.map((n) => n.copyWith(isRead: true)).toList();
      
      emit(currentState.copyWith(notices: updatedList, unreadCount: 0));
      
      await markAllAsReadUseCase();
    }
  }

  Future<void> deleteNotification(String id) async {
    if (state is NoticeLoaded) {
      final currentState = state as NoticeLoaded;
      
      final updatedList = currentState.notices.where((n) => n.id != id).toList();
      
      emit(currentState.copyWith(notices: updatedList));

      await deleteNotificationUseCase(id);
    }
  }
}