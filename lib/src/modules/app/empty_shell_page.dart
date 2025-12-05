import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../common/utils/getit_utils.dart';
import '../../common/widgets/bottom_navigation.dart';
import '../newpost/presentation/cubit/post_cubit.dart';
import 'app_router.dart';

@RoutePage()
class EmptyShellPage extends StatefulWidget implements AutoRouteWrapper {
  const EmptyShellPage({super.key});

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider<PostCubit>(
      create: (_) => getIt<PostCubit>()..loadFeed(),
      child: this,
    );
  }

  @override
  State<EmptyShellPage> createState() => _EmptyShellPageState();
}

class _EmptyShellPageState extends State<EmptyShellPage> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Cập nhật index sau khi build xong
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateCurrentIndexFromRoute();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const AutoRouter(),
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
        context.navigateTo(const HomeRoute());
        break;
      case 1: // Chat
        context.navigateTo(const ChatRoute());
        break;
      case 2: // Create Post
        context.pushRoute(const CreatePostRoute());
        break;
      case 3: // Notice
        context.navigateTo(const NoticeRoute());
        break;
      case 4: // Profile
        context.navigateTo(const ProfileRoute());
        break;
    }
  }

  void _updateCurrentIndexFromRoute() {
    if (!mounted) return;
    
    final currentPath = context.routeData.path;
    
    int newIndex = 0; // Default Home
    if (currentPath.contains('home') || 
        currentPath == '/app' || 
        currentPath.isEmpty) {
      newIndex = 0;
    } else if (currentPath.contains('chat')) {
      newIndex = 1;
    } else if (currentPath.contains('newpost')) {
      newIndex = 2;
    } else if (currentPath.contains('notice')) {
      newIndex = 3;
    } else if (currentPath.contains('profile')) {
      newIndex = 4;
    }
    
    if (_currentIndex != newIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _currentIndex = newIndex;
          });
        }
      });
    }
  }
}