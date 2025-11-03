import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';

import 'model/notice_model.dart';
import 'component/widget__notice_app_bar.dart';
import 'component/widget__notice_list.dart';

@RoutePage()
class NoticePage extends StatelessWidget {
  const NoticePage({super.key});

  static const _softBg = Color(0xFFF5F6F8);

  @override
  Widget build(BuildContext context) {
    // TODO: thay bằng data thật (từ API/BLoC/Provider)
    final notices = <NoticeItem>[
      NoticeItem(
        title: 'User 1',
        message: 'liked your post',
        time: '10:02',
        unread: true,
        avatarUrl: 'https://i.pravatar.cc/80?img=1',
      ),
      NoticeItem(
        title: 'User 2',
        message: 'commented: "Nice work!"',
        time: '09:47',
        avatarUrl: 'https://i.pravatar.cc/80?img=2',
      ),
      NoticeItem(
        title: 'System',
        message: 'Your password was changed',
        time: 'Yesterday',
        icon: Icons.shield_outlined,
      ),
    ];

    return Scaffold(
      backgroundColor: _softBg,
      appBar: const WidgetNoticeAppBar(),
      body: SafeArea(
        child: WidgetNoticeList(items: notices),
      ),
    );
  }
}
