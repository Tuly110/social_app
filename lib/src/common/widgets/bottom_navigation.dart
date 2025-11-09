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
        // chưa có trang Explore
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Explore feature coming soon!')),
        );
        break;
      case 2:
        // chưa có trang New Post
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: ColorName.mint,
        selectedItemColor: ColorName.white,
        unselectedItemColor: ColorName.white.withOpacity(0.7),
        currentIndex: currentIndex,
        onTap: (i) => _onTap(context, i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: ''),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_box_outlined), label: ''),
          BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
      ),
    );
  }
}
