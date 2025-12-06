import 'package:auto_route/auto_route.dart';
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
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: ColorName.black54),
        onPressed: () {
          final r = context.router;

          if (r.canPop()) {
            r.pop();
            return;
          }
          
          r.navigateNamed('/app/home');
        
        },
        tooltip: 'Back',
      ),
      title: const Text(
        'Notifications',
        style: TextStyle(fontWeight: FontWeight.bold, color: ColorName.black87),
      ),
      centerTitle: true,
      actions: const [],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
