import 'package:flutter/material.dart';

import '../../../../../generated/colors.gen.dart';

class WidgetNoticeAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const WidgetNoticeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: ColorName.white,
      surfaceTintColor: ColorName.white,
      elevation: 0,
      title: const Text(
        'Notifications',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: ColorName.black87,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.settings_outlined, color: ColorName.black54),
          tooltip: 'Settings',
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
