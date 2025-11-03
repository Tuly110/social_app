import 'package:flutter/material.dart';

class WidgetNoticeAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const WidgetNoticeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 0,
      title: const Text(
        'Notifications',
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.settings_outlined, color: Colors.black54),
          tooltip: 'Settings',
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
