import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import '../../../../generated/colors.gen.dart';
import '../../app/app_router.dart';
import '../../auth/presentation/cubit/auth_cubit.dart';
import '../../auth/presentation/cubit/auth_state.dart' as auth;
import '../../newpost/presentation/cubit/post_cubit.dart';
import '../../../common/utils/getit_utils.dart';
import 'component/select_friends_page.dart';
import 'component/widget__friend_avatar.dart';
import 'component/widget__stats_card.dart';
import 'component/widget__section_title.dart';
import 'component/widget__placeholder.dart';
import 'cubit/profile_cubit.dart';
import 'cubit/profile_state.dart';
import 'component/user_posts_tab.dart';
import 'component/user_gallery_grid.dart';

@RoutePage()
class ProfilePage extends StatefulWidget implements AutoRouteWrapper {
  const ProfilePage({super.key});

  @override
  Widget wrappedRoute(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PostCubit>(
          create: (_) => getIt<PostCubit>(),
        ),
        BlocProvider<ProfileCubit>(
          create: (_) => getIt<ProfileCubit>(),
        ),
      ],
      child: this,
    );
  }

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> 
    with AutomaticKeepAliveClientMixin {
  
  @override
  bool get wantKeepAlive => true;

  static const double _avatarRadius = 38;
  static const double _horizontalMargin = 24;
  static const double _tabBarHeight = 48;
  static final double _expandedHeight = 310 + _avatarRadius * 1.5;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final token = Supabase.instance.client.auth.currentSession?.accessToken;
    if (token != null) {
      context.read<ProfileCubit>().loadMyProfile(token);
    }
    
    context.read<PostCubit>().loadFeed();
  }

  Future<void> _openEditProfile(BuildContext context) async {
    final authState = context.read<AuthCubit>().state;
    final user = authState.maybeWhen(
      userInfoLoaded: (u) => u,
      orElse: () => null,
    );

    if (user == null) return;

    final profileState = context.read<ProfileCubit>().state;
    final currentUsername = profileState.maybeWhen(
      loaded: (profile) => profile.username,
      orElse: () => user.username ?? '',
    );
    
    final currentBio = profileState.maybeWhen(
      loaded: (profile) => profile.bio,
      orElse: () => null,
    );
    
    final currentAvatar = profileState.maybeWhen(
      loaded: (profile) => profile.avatarUrl,
      orElse: () => null,
    );

    await context.router.push(
      EditProfileRoute(
        initialUsername: currentUsername,
        initialBio: currentBio,
        initialAvatarUrl: currentAvatar,
      ),
    );

    final token = Supabase.instance.client.auth.currentSession?.accessToken;
    if (token != null) {
      context.read<ProfileCubit>().loadMyProfile(token);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return BlocListener<AuthCubit, auth.AuthState>(
      listener: (context, state) {
        state.whenOrNull(
          unauthenticated: (emailError, passwordError, errorMessage,
              isEmailValid, isPasswordValid) {
            context.router.replaceAll([const LoginRoute()]);
          },
          failure: (message) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message)),
            );
          },
        );
      },
      child: DefaultTabController(
        length: 4,
        child: Scaffold(
          backgroundColor: ColorName.softBg,
          body: NestedScrollView(
            headerSliverBuilder: (context, inner) => [
              SliverAppBar(
                pinned: true,
                expandedHeight: _expandedHeight,
                backgroundColor: ColorName.white,
                surfaceTintColor: ColorName.white,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Color(0xFF9CA3AF),
                    size: 22,
                  ),
                  onPressed: () => context.router.pop(),
                ),
                actions: [
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_horiz,
                      color: inner ? ColorName.black87 : ColorName.white,
                    ),
                    onSelected: (value) async {
                      if (value == 'logout') {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Logout'),
                            content:
                                const Text('Are you sure you want to logout?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(true),
                                child: const Text('Logout'),
                              ),
                            ],
                          ),
                        );

                        if (ok == true) {
                          context.read<AuthCubit>().signOut();
                        }
                      }
                    },
                    itemBuilder: (ctx) => const [
                      PopupMenuItem(
                        value: 'logout',
                        child: Text('Logout'),
                      ),
                    ],
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        'https://images.unsplash.com/photo-1495562569060-2eec283d3391?q=80&w=1600&auto=format&fit=crop',
                        fit: BoxFit.cover,
                      ),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              ColorName.black26,
                            ],
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: _horizontalMargin,
                            right: _horizontalMargin,
                            bottom: _avatarRadius - 6,
                          ),
                          child: BlocBuilder<ProfileCubit, ProfileState>(
                            builder: (context, profileState) {
                              return ProfileCardWidget(
                                avatarRadius: _avatarRadius,
                                bio: profileState.maybeWhen(
                                  loaded: (profile) => profile.bio,
                                  orElse: () => null,
                                ),
                                avatarUrl: profileState.maybeWhen(
                                  loaded: (profile) => profile.avatarUrl,
                                  orElse: () => null,
                                ),
                                displayUsername: profileState.maybeWhen(
                                  loaded: (profile) => profile.username,
                                  orElse: () => null,
                                ),
                                onEditPressed: () => _openEditProfile(context),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(_tabBarHeight),
                  child: Container(
                    padding: const EdgeInsets.only(left: 8, right: 16),
                    color: ColorName.white,
                    child: const TabBar(
                      isScrollable: true,
                      labelColor: ColorName.black,
                      unselectedLabelColor: ColorName.black54,
                      indicatorColor: ColorName.black,
                      indicatorWeight: 2,
                      indicatorSize: TabBarIndicatorSize.label,
                      labelPadding: EdgeInsets.symmetric(horizontal: 20),
                      tabs: [
                        Tab(text: 'All'),
                        Tab(text: 'Post'),
                        Tab(text: 'Replies'),
                        Tab(text: 'Media'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            body: TabBarView(
              children: [
                BlocBuilder<ProfileCubit, ProfileState>(
                  builder: (context, profileState) {
                    final userId = profileState.maybeWhen(
                      loaded: (profile) => profile.id,
                      orElse: () => '',
                    );
                    return AllTab(userId: userId);
                  },
                ),
                Builder(
                  builder: (context) {
                    final profileState = context.read<ProfileCubit>().state;
                    final userId = profileState.maybeWhen(
                      loaded: (profile) => profile.id,
                      orElse: () => '',
                    );
                    if (userId.isEmpty) {
                      return const Center(
                          child: Text('No user info loaded yet.'));
                    }
                    return UserPostsTab(userId: userId);
                  },
                ),
                const WidgetPlaceholder(text: 'Replies'),
                const WidgetPlaceholder(text: 'Media'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


  class ProfileCardWidget extends StatelessWidget {
    final double avatarRadius;
    final String? bio;
    final String? avatarUrl;
    final String? displayUsername;
    final VoidCallback? onEditPressed;

    const ProfileCardWidget({
      super.key,
      required this.avatarRadius,
      this.bio,
      this.avatarUrl,
      this.displayUsername,
      this.onEditPressed,
    });

    @override
    Widget build(BuildContext context) {
      final double nameBlockTopPadding = 18;
      final double nameBlockHeight =
          (2 * avatarRadius) + nameBlockTopPadding + 10;

      return BlocBuilder<AuthCubit, auth.AuthState>(
        builder: (context, state) {
          final user =
              state.maybeWhen(userInfoLoaded: (user) => user, orElse: () => null);

          final nameToShow = displayUsername ?? user?.username ?? 'User Name';

          final ImageProvider? avatarImage;
          if (avatarUrl != null && avatarUrl!.isNotEmpty) {
            avatarImage = NetworkImage(avatarUrl!);
          } else {
            avatarImage = const AssetImage('');
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 0),
            padding: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: ColorName.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: ColorName.black15,
                  blurRadius: 25,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: nameBlockHeight,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        left: 0,
                        right: 0,
                        top: avatarRadius + 5,
                        child: Column(
                          children: [
                            Text(
                              nameToShow,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: ColorName.black87,
                              ),
                            ),
                            Text(
                              user?.email ?? 'email@example.com',
                              style: TextStyle(
                                color: ColorName.grey600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        top: -avatarRadius,
                        child: Center(
                          child: CircleAvatar(
                            radius: avatarRadius,
                            backgroundImage: avatarImage,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Text(
                          bio ?? 'Viết đôi dòng giới thiệu về bạn…',
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: ColorName.grey800,
                            height: 1.25,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 42,
                                child: ElevatedButton(
                                  onPressed:
                                      (user == null || onEditPressed == null)
                                          ? null
                                          : onEditPressed,
                                  style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    backgroundColor: ColorName.mint,
                                    foregroundColor: ColorName.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'Edit',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () {
                                context.router.replace(const SettingsRoute());
                              },
                              child: Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: ColorName.mint.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.settings_rounded,
                                  color: ColorName.mint,
                                  size: 22,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    }
  }


  class AllTab extends StatelessWidget {
    final String userId;
    const AllTab({super.key, required this.userId});

    @override
    Widget build(BuildContext context) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
        children: [
          const WidgetSectionTitle('Followers'),
          const SizedBox(height: 8),
          FollowersPreviewRow(userId: userId), // 👈 Đổi tên
          const SizedBox(height: 16),
          TwoColumnStatsAndGallery(userId: userId), // 👈 Đổi tên
        ],
      );
    }
  }

  class FollowersPreviewRow extends StatefulWidget {
    final String userId;

    const FollowersPreviewRow({super.key, required this.userId});

    @override
    State<FollowersPreviewRow> createState() => _FollowersPreviewRowState();
  }

  class _FollowerPreview {
    final String id;
    final String username;
    final String? avatarUrl;

    _FollowerPreview({
      required this.id,
      required this.username,
      this.avatarUrl,
    });
  }

  class _FollowersPreviewRowState extends State<FollowersPreviewRow> {
    bool _loading = true;
    final List<_FollowerPreview> _followers = [];

    @override
    void initState() {
      super.initState();
      _loadFollowers();
    }

    Future<void> _loadFollowers() async {
      try {
        final client = Supabase.instance.client;

        final rows = await client
            .from('follows')
            .select('follower_id')
            .eq('following_id', widget.userId)
            .limit(4);

        final List data = (rows as List?) ?? [];
        if (data.isEmpty) {
          if (!mounted) return;
          setState(() {
            _followers.clear();
            _loading = false;
          });
          return;
        }

        final futures = data.map((e) async {
          final followerId = e['follower_id'] as String?;
          if (followerId == null) return null;

          final profile = await client
              .from('profiles')
              .select('id, username, avatar_url')
              .eq('id', followerId)
              .maybeSingle();

          if (profile == null) return null;

          return _FollowerPreview(
            id: profile['id'] as String,
            username: (profile['username'] as String?) ?? '',
            avatarUrl: profile['avatar_url'] as String?,
          );
        }).toList();

        final results = await Future.wait(futures);
        final valid = results.whereType<_FollowerPreview>().toList();

        if (!mounted) return;
        setState(() {
          _followers
            ..clear()
            ..addAll(valid);
          _loading = false;
        });
      } catch (_) {
        if (!mounted) return;
        setState(() {
          _followers.clear();
          _loading = false;
        });
      }
    }

    @override
    Widget build(BuildContext context) {
      if (_loading && _followers.isEmpty) {
        return const SizedBox(
          height: 56,
          child: Center(child: CircularProgressIndicator()),
        );
      }

      return Row(
        children: [
          if (_followers.isEmpty)
            const Text(
              'No followers yet',
              style: TextStyle(color: ColorName.grey600),
            )
          else
            ..._followers.map(
              (f) => Padding(
                padding: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: () {
                    context.router.push(
                      UserProfileRoute(userId: f.id),
                    );
                  },
                  child: CircleAvatar(
                    radius: 18,
                    backgroundImage:
                        (f.avatarUrl != null && f.avatarUrl!.isNotEmpty)
                            ? NetworkImage(f.avatarUrl!)
                            : null,
                    child: (f.avatarUrl == null || f.avatarUrl!.isEmpty)
                        ? Text(
                            f.username.isNotEmpty
                                ? f.username[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                ),
              ),
            ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.more_horiz),
            tooltip: 'View all followers',
            onPressed: () {
              context.router.push(
                FollowersRoute(userId: widget.userId),
              );
            },
          ),
        ],
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final isNarrow = c.maxWidth < 360;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: isNarrow ? 96 : 110,
              child: WidgetStatsCard(
                onPostsTap: () {
                  final controller = DefaultTabController.of(context);
                  controller?.animateTo(1);
                },
                onFollowingTap: () async {
                  final changed = await context.router.push<bool>(
                    FollowingRoute(userId: userId),
                  );
                  if (changed == true && context.mounted) {
                    final token = Supabase
                        .instance.client.auth.currentSession?.accessToken;
                    if (token != null) {
                      context.read<ProfileCubit>().loadMyProfile(token);
                    }
                  }
                },
                onFollowersTap: () async {
                  final changed = await context.router.push<bool>(
                    FollowersRoute(userId: userId),
                  );
                  if (changed == true && context.mounted) {
                    final token = Supabase
                        .instance.client.auth.currentSession?.accessToken;
                    if (token != null) {
                      context.read<ProfileCubit>().loadMyProfile(token);
                    }
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: UserGalleryGrid(userId: userId),
              ),
            ],
          );
        },
      );
    }
  }