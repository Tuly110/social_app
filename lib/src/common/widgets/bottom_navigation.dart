import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import '../../../generated/colors.gen.dart';
import '../../modules/app/app_router.dart';

class WidgetBottomNav extends StatelessWidget {
  final int currentIndex;

  const WidgetBottomNav({
    super.key,
    required this.currentIndex,
  });

  void _onTap(BuildContext context, int index) {
    if (index == currentIndex) return;

    final r = context.router;

    switch (index) {
      case 0:
        r.replace(const HomeRoute());
        break;
      case 1:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Explore feature coming soon!')),
        );
        break;
      case 2:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('New Post feature coming soon!')),
        );
        break;
      case 3:
        r.replace(const ChatRoute());
        break;
      case 4:
        r.replace(const NoticeRoute());
        break;
      case 5:
        r.replace(const ProfileRoute());
        break;
      case 6:
        r.replace(const UserProfileRoute());
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ColorName.mint,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            backgroundColor: Colors.transparent,
            indicatorColor: Colors.white.withOpacity(0.20),
            labelTextStyle: const WidgetStatePropertyAll(
              TextStyle(fontSize: 11, color: Colors.white),
            ),
            iconTheme: WidgetStateProperty.resolveWith((states) {
              final isSelected = states.contains(WidgetState.selected);
              return IconThemeData(
                color: isSelected ? Colors.white : Colors.white70,
                size: isSelected ? 28 : 24,
              );
            }),
            height: 68,
          ),
          child: NavigationBar(
            selectedIndex: currentIndex,
            onDestinationSelected: (i) => _onTap(context, i),
            labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
            surfaceTintColor: Colors.transparent,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.search),
                selectedIcon: Icon(Icons.search_rounded),
                label: 'Search',
              ),
              NavigationDestination(
                icon: Icon(Icons.add_box_outlined),
                selectedIcon: Icon(Icons.add_box_rounded),
                label: 'Post',
              ),
              NavigationDestination(
                icon: Icon(Icons.chat_bubble_outline),
                selectedIcon: Icon(Icons.chat_bubble_rounded),
                label: 'Chat',
              ),
              NavigationDestination(
                icon: Icon(Icons.notifications_none_rounded),
                selectedIcon: Icon(Icons.notifications_rounded),
                label: 'Notice',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person_rounded),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
