// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

abstract class _$AppRouter extends RootStackRouter {
  // ignore: unused_element
  _$AppRouter({super.navigatorKey});

  @override
  final Map<String, PageFactory> pagesMap = {
    ChatDetailRoute.name: (routeData) {
      final args = routeData.argsAs<ChatDetailRouteArgs>(
          orElse: () => const ChatDetailRouteArgs());
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: ChatDetailPage(
          userName: args.userName,
          userAvatarUrl: args.userAvatarUrl,
        ),
      );
    },
    ChatRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const ChatPage(),
      );
    },
    CreatePostRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const CreatePostPage(),
      );
    },
    EditPostRoute.name: (routeData) {
      final args = routeData.argsAs<EditPostRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: EditPostPage(
          key: args.key,
          post: args.post,
        ),
      );
    },
    EmptyShellRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const EmptyShellPage(),
      );
    },
    FollowersRoute.name: (routeData) {
      final args = routeData.argsAs<FollowersRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: FollowersPage(
          key: args.key,
          userId: args.userId,
          username: args.username,
        ),
      );
    },
    FollowingRoute.name: (routeData) {
      final args = routeData.argsAs<FollowingRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: FollowingPage(
          key: args.key,
          userId: args.userId,
          username: args.username,
        ),
      );
    },
    HomeRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const HomePage(),
      );
    },
    LoginRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const LoginPage(),
      );
    },
    NoticeRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const NoticePage(),
      );
    },
    ProfileRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const ProfilePage(),
      );
    },
    SearchRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const SearchPage(),
      );
    },
    SettingsRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const SettingsPage(),
      );
    },
    SignupRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const SignupPage(),
      );
    },
    SplashScreenRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const SplashScreenPage(),
      );
    },
    UpdatePasswordRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const UpdatePasswordPage(),
      );
    },
    UserProfileRoute.name: (routeData) {
      final args = routeData.argsAs<UserProfileRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: UserProfilePage(
          key: args.key,
          userId: args.userId,
        ),
      );
    },
  };
}

/// generated route for
/// [ChatDetailPage]
class ChatDetailRoute extends PageRouteInfo<ChatDetailRouteArgs> {
  ChatDetailRoute({
    String userName = 'xyz',
    String userAvatarUrl =
        'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200',
    List<PageRouteInfo>? children,
  }) : super(
          ChatDetailRoute.name,
          args: ChatDetailRouteArgs(
            userName: userName,
            userAvatarUrl: userAvatarUrl,
          ),
          initialChildren: children,
        );

  static const String name = 'ChatDetailRoute';

  static const PageInfo<ChatDetailRouteArgs> page =
      PageInfo<ChatDetailRouteArgs>(name);
}

class ChatDetailRouteArgs {
  const ChatDetailRouteArgs({
    this.userName = 'xyz',
    this.userAvatarUrl =
        'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200',
  });

  final String userName;

  final String userAvatarUrl;

  @override
  String toString() {
    return 'ChatDetailRouteArgs{userName: $userName, userAvatarUrl: $userAvatarUrl}';
  }
}

/// generated route for
/// [ChatPage]
class ChatRoute extends PageRouteInfo<void> {
  const ChatRoute({List<PageRouteInfo>? children})
      : super(
          ChatRoute.name,
          initialChildren: children,
        );

  static const String name = 'ChatRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [CreatePostPage]
class CreatePostRoute extends PageRouteInfo<void> {
  const CreatePostRoute({List<PageRouteInfo>? children})
      : super(
          CreatePostRoute.name,
          initialChildren: children,
        );

  static const String name = 'CreatePostRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [EditPostPage]
class EditPostRoute extends PageRouteInfo<EditPostRouteArgs> {
  EditPostRoute({
    Key? key,
    required PostResponse post,
    List<PageRouteInfo>? children,
  }) : super(
          EditPostRoute.name,
          args: EditPostRouteArgs(
            key: key,
            post: post,
          ),
          initialChildren: children,
        );

  static const String name = 'EditPostRoute';

  static const PageInfo<EditPostRouteArgs> page =
      PageInfo<EditPostRouteArgs>(name);
}

class EditPostRouteArgs {
  const EditPostRouteArgs({
    this.key,
    required this.post,
  });

  final Key? key;

  final PostResponse post;

  @override
  String toString() {
    return 'EditPostRouteArgs{key: $key, post: $post}';
  }
}

/// generated route for
/// [EmptyShellPage]
class EmptyShellRoute extends PageRouteInfo<void> {
  const EmptyShellRoute({List<PageRouteInfo>? children})
      : super(
          EmptyShellRoute.name,
          initialChildren: children,
        );

  static const String name = 'EmptyShellRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [FollowersPage]
class FollowersRoute extends PageRouteInfo<FollowersRouteArgs> {
  FollowersRoute({
    Key? key,
    required String userId,
    required String username,
    List<PageRouteInfo>? children,
  }) : super(
          FollowersRoute.name,
          args: FollowersRouteArgs(
            key: key,
            userId: userId,
            username: username,
          ),
          initialChildren: children,
        );

  static const String name = 'FollowersRoute';

  static const PageInfo<FollowersRouteArgs> page =
      PageInfo<FollowersRouteArgs>(name);
}

class FollowersRouteArgs {
  const FollowersRouteArgs({
    this.key,
    required this.userId,
    required this.username,
  });

  final Key? key;

  final String userId;

  final String username;

  @override
  String toString() {
    return 'FollowersRouteArgs{key: $key, userId: $userId, username: $username}';
  }
}

/// generated route for
/// [FollowingPage]
class FollowingRoute extends PageRouteInfo<FollowingRouteArgs> {
  FollowingRoute({
    Key? key,
    required String userId,
    required String username,
    List<PageRouteInfo>? children,
  }) : super(
          FollowingRoute.name,
          args: FollowingRouteArgs(
            key: key,
            userId: userId,
            username: username,
          ),
          initialChildren: children,
        );

  static const String name = 'FollowingRoute';

  static const PageInfo<FollowingRouteArgs> page =
      PageInfo<FollowingRouteArgs>(name);
}

class FollowingRouteArgs {
  const FollowingRouteArgs({
    this.key,
    required this.userId,
    required this.username,
  });

  final Key? key;

  final String userId;

  final String username;

  @override
  String toString() {
    return 'FollowingRouteArgs{key: $key, userId: $userId, username: $username}';
  }
}

/// generated route for
/// [HomePage]
class HomeRoute extends PageRouteInfo<void> {
  const HomeRoute({List<PageRouteInfo>? children})
      : super(
          HomeRoute.name,
          initialChildren: children,
        );

  static const String name = 'HomeRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [LoginPage]
class LoginRoute extends PageRouteInfo<void> {
  const LoginRoute({List<PageRouteInfo>? children})
      : super(
          LoginRoute.name,
          initialChildren: children,
        );

  static const String name = 'LoginRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [NoticePage]
class NoticeRoute extends PageRouteInfo<void> {
  const NoticeRoute({List<PageRouteInfo>? children})
      : super(
          NoticeRoute.name,
          initialChildren: children,
        );

  static const String name = 'NoticeRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [ProfilePage]
class ProfileRoute extends PageRouteInfo<void> {
  const ProfileRoute({List<PageRouteInfo>? children})
      : super(
          ProfileRoute.name,
          initialChildren: children,
        );

  static const String name = 'ProfileRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [SearchPage]
class SearchRoute extends PageRouteInfo<void> {
  const SearchRoute({List<PageRouteInfo>? children})
      : super(
          SearchRoute.name,
          initialChildren: children,
        );

  static const String name = 'SearchRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [SettingsPage]
class SettingsRoute extends PageRouteInfo<void> {
  const SettingsRoute({List<PageRouteInfo>? children})
      : super(
          SettingsRoute.name,
          initialChildren: children,
        );

  static const String name = 'SettingsRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [SignupPage]
class SignupRoute extends PageRouteInfo<void> {
  const SignupRoute({List<PageRouteInfo>? children})
      : super(
          SignupRoute.name,
          initialChildren: children,
        );

  static const String name = 'SignupRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [SplashScreenPage]
class SplashScreenRoute extends PageRouteInfo<void> {
  const SplashScreenRoute({List<PageRouteInfo>? children})
      : super(
          SplashScreenRoute.name,
          initialChildren: children,
        );

  static const String name = 'SplashScreenRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [UpdatePasswordPage]
class UpdatePasswordRoute extends PageRouteInfo<void> {
  const UpdatePasswordRoute({List<PageRouteInfo>? children})
      : super(
          UpdatePasswordRoute.name,
          initialChildren: children,
        );

  static const String name = 'UpdatePasswordRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [UserProfilePage]
class UserProfileRoute extends PageRouteInfo<UserProfileRouteArgs> {
  UserProfileRoute({
    Key? key,
    required String userId,
    List<PageRouteInfo>? children,
  }) : super(
          UserProfileRoute.name,
          args: UserProfileRouteArgs(
            key: key,
            userId: userId,
          ),
          initialChildren: children,
        );

  static const String name = 'UserProfileRoute';

  static const PageInfo<UserProfileRouteArgs> page =
      PageInfo<UserProfileRouteArgs>(name);
}

class UserProfileRouteArgs {
  const UserProfileRouteArgs({
    this.key,
    required this.userId,
  });

  final Key? key;

  final String userId;

  @override
  String toString() {
    return 'UserProfileRouteArgs{key: $key, userId: $userId}';
  }
}
