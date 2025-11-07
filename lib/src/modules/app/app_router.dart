import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

import '../auth/presentation/login/login_page.dart';
import '../auth/presentation/reset_password/update_password_page.dart';
import '../auth/presentation/signup/signup_page.dart';
import '../chat/presentation/chat_detail_page.dart';
import '../chat/presentation/chats_page.dart';
import '../home/presentation/home_page.dart';
import '../notice/presentation/notice_page.dart';
import '../profile/presentation/profile_page.dart';
import '../profile/presentation/user_profile_page.dart';
import '../splash_screen/presentation/splash_screen_page.dart';

part 'app_router.gr.dart';

@singleton
@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends _$AppRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: SplashScreenRoute.page, path: '/', initial: true),
    AutoRoute(page: HomeRoute.page, path: '/home'),
    AutoRoute(page: LoginRoute.page, path: '/login'),
    AutoRoute(page: SignupRoute.page, path: '/signup'),
    AutoRoute(page: UpdatePasswordRoute.page),
    AutoRoute(page: ProfileRoute.page, path: '/profile'),
    AutoRoute(page: UserProfileRoute.page, path: '/user/:username'),
    AutoRoute(page: ChatRoute.page, path: '/chats'),
    AutoRoute(page: ChatDetailRoute.page, path: '/chats/:id'),
    AutoRoute(page: NoticeRoute.page, path: '/notifications')
  ];
}
