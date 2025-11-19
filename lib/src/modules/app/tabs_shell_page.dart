// lib/src/modules/app/tabs_shell_page.dart
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'app_router.dart';
import '../../common/widgets/bottom_navigation.dart';

@RoutePage()
class TabsShellPage extends StatelessWidget {
  const TabsShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AutoTabsScaffold(
      routes: [
        HomeRoute(),
        ChatRoute(),
        CreatePostRoute(),
        NoticeRoute(),
        ProfileRoute(),
      ],
      bottomNavigationBuilder: (context, tabsRouter) {
        return WidgetBottomNav(
          currentIndex: _externalIndexFromInternal(tabsRouter.activeIndex),
          onTap: (i) {
                        
            tabsRouter.setActiveIndex(_internalIndexFromExternal(i));
          },
        );
      },
    );
  }
}

int _internalIndexFromExternal(int external) {
  if (external <= 0) return 0; // Home
  if (external == 1) return 1; // Chat
  if (external == 2) return 2; // NewPost
  if (external == 3) return 3; // Notice
  if (external >= 4) return 4; // Profile
  return 0;
}

int _externalIndexFromInternal(int internal) {
  switch (internal) {
    case 0:
      return 0; // Home
    case 1: 
      return 1; //Chat
    case 2:
      return 2; // NewPost
    case 3:
      return 3; // Notice
    case 4:
      return 4; // Profile
    default:
      return 0;
  }
}

