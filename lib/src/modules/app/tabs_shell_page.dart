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
        CreatePostRoute(),
        ChatRoute(),
        NoticeRoute(),
        ProfileRoute(),
      ],
      bottomNavigationBuilder: (context, tabsRouter) {
        return WidgetBottomNav(
          currentIndex: _externalIndexFromInternal(tabsRouter.activeIndex),
          onTap: (i) {
            if (i == 1) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Search coming soon!')),
              );
              return;
            }
            // if (i == 2) {
            //   showModalBottomSheet(
            //     context: context,
            //     builder: (_) => const _NewPostSheet(),
            //   );
            //   return;
            // }
            tabsRouter.setActiveIndex(_internalIndexFromExternal(i));
          },
        );
      },
    );
  }
}

int _internalIndexFromExternal(int external) {
  if (external <= 0) return 0; // Home
  if (external == 2) return 1; // NewPost
  if (external == 3) return 2; // Chat
  if (external == 4) return 3; // Notice
  if (external >= 5) return 4; // Profile
  return 0;
}

int _externalIndexFromInternal(int internal) {
  switch (internal) {
    case 0:
      return 0; // Home
    case 1: 
      return 2; //NewPost
    case 2:
      return 3; // Chat
    case 3:
      return 4; // Notice
    case 4:
      return 5; // Profile
    default:
      return 0;
  }
}

// // ===== Demo sheet cho nút Add =====
// class _NewPostSheet extends StatelessWidget {
//   const _NewPostSheet();

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: SizedBox(
//         height: 220,
//         child: Center(child: Text('Compose new post here')),
//       ),
//     );
//   }
// }
