import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart'; 
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../common/utils/getit_utils.dart';
import '../../app/app_router.dart';

import '../data/datasources/notice_remote_datasource.dart';
import '../data/repositories/notice_repository_impl.dart';
import '../domain/usecases/notice_usecases.dart';

import 'cubit/notice_cubit.dart';
import 'cubit/notice_state.dart';
import 'component/widget__notice_tile.dart';

@RoutePage()
class NoticePage extends StatelessWidget {
  const NoticePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final dio = getIt<Dio>(); 

        final dataSource = NoticeRemoteDataSourceImpl(dio);

        final repository = NoticeRepositoryImpl(dataSource);

        return NoticeCubit(
          getNotificationsUseCase: GetNotificationsUseCase(repository),
          getUnreadCountUseCase: GetUnreadCountUseCase(repository),
          markAsReadUseCase: MarkAsReadUseCase(repository),
          markAllAsReadUseCase: MarkAllAsReadUseCase(repository),
          deleteNotificationUseCase: DeleteNotificationUseCase(repository),
        )..fetchNotifications();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Notification', style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: false,
          actions: [
            BlocBuilder<NoticeCubit, NoticeState>(
              builder: (context, state) {
                return IconButton(
                  icon: const Icon(Icons.done_all),
                  onPressed: () => context.read<NoticeCubit>().markAllRead(),
                  tooltip: "Mark all as read",
                );
              },
            )
          ],
        ),
        body: BlocBuilder<NoticeCubit, NoticeState>(
          builder: (context, state) {
            if (state is NoticeLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is NoticeError) {
              return Center(child: Text("Lỗi: ${state.message}"));
            } else if (state is NoticeLoaded) {
              if (state.notices.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_off_outlined, size: 60, color: Colors.grey),
                      SizedBox(height: 16),
                      Text("No notifications", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => context.read<NoticeCubit>().fetchNotifications(),
                child: ListView.separated(
                  itemCount: state.notices.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, indent: 70),
                  itemBuilder: (context, index) {
                    final notice = state.notices[index];
                    return NoticeTile(
                      notice: notice,
                      onMarkRead: () {
                        context.read<NoticeCubit>().markAsRead(notice.id);
                      },
                      onDelete: () {
                        context.read<NoticeCubit>().deleteNotification(notice.id);
                      },
                      onTap: () {
                        if (notice.type == 'follow' && notice.fromUserId != null) {
                          context.router.push(UserProfileRoute(userId: notice.fromUserId!));
                        } else if (notice.postId != null) {
                          // context.router.push(CommentRoute(post: notice.postId!));
                        }
                        
                        if (!notice.isRead) {
                          context.read<NoticeCubit>().markAsRead(notice.id);
                        }
                      },
                    );
                  },
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}