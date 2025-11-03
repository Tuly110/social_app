import 'package:flutter/material.dart';
import '../model/notice_model.dart';
import 'widget__notice_tile.dart';

class WidgetNoticeList extends StatelessWidget {
  final List<NoticeItem> items;
  const WidgetNoticeList({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) => WidgetNoticeTile(item: items[i], onTap: () {
        // TODO: điều hướng vào chi tiết nếu cần
      }),
    );
  }
}
