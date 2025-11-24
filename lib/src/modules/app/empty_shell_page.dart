// lib/src/modules/app/empty_shell_page.dart
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../common/widgets/bottom_navigation.dart';
import 'app_router.dart';

@RoutePage()
class EmptyShellPage extends StatefulWidget {
  const EmptyShellPage({super.key});

  @override
  State<EmptyShellPage> createState() => _EmptyShellPageState();
}

class _EmptyShellPageState extends State<EmptyShellPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AutoRouter(), //current page
      bottomNavigationBar: WidgetBottomNav(
        currentIndex: _currentIndex,
        onTap: _onNavItemTapped,
      ),
    );
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0: // Home
        context.router.navigate(const HomeRoute());
        break;
      case 1: // Chat
        context.router.navigate(const ChatRoute());
        break;
      case 2: // CreatePost
        context.router.navigate(const CreatePostRoute());
        break;
      case 3: // Notice
        context.router.navigate(const NoticeRoute());
        break;
      case 4: // Profile
        context.router.navigate(const ProfileRoute());
        break;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateCurrentIndex();
  }

  void _updateCurrentIndex() {
    final currentPath = context.router.currentPath;

    if (currentPath.contains('home')) {
      _currentIndex = 0;
    } else if (currentPath.contains('chat')) {
      _currentIndex = 1;
    } else if (currentPath.contains('create-post')) {
      _currentIndex = 2;
    } else if (currentPath.contains('notice')) {
      _currentIndex = 3;
    } else if (currentPath.contains('profile')) {
      _currentIndex = 4;
    }

    if (mounted) setState(() {});
  }
}
