// 🔹 Import các component tái sử dụng
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Supabase;

import '../../../../generated/colors.gen.dart';
import '../../app/app_router.dart';
import '../../auth/presentation/cubit/auth_cubit.dart';
import '../../auth/presentation/cubit/auth_state.dart';
import '../../home/presentation/widgets/post_item.dart';
import '../../home/presentation/models/post_data.dart';
import 'package:intl/intl.dart';
import '../../newpost/presentation/edit_post_page.dart';
import '../../newpost/presentation/models/post_api_models.dart';
import '../../../core/data/api/post_api.dart';
import 'component/select_friends_page.dart';
import 'component/widget__avatar.dart';
import 'component/widget__friend_avatar.dart';
import 'component/widget__gallery_grid.dart';
import 'component/widget__placeholder.dart';
import 'component/widget__section_title.dart';
import 'component/widget__stats_card.dart';

@RoutePage()
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const double _avatarRadius = 38;
  static const double _horizontalMargin = 24;
  static const double _tabBarHeight = 48;
  static final double _expandedHeight = 310 + _avatarRadius * 1.5;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        state.whenOrNull(
          unauthenticated: (emailError, passwordError, errorMessage,
              isEmailValid, isPasswordValid) {
            context.router.replaceAll([const LoginRoute()]);
          },
          loading: () {
            AuthState.loading();
          },
          failure: (message) {
            AuthState.failure(message);
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
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Color(0xFF9CA3AF), size: 22),
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
                            content: const Text('Are you sure logout?'),
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
                      PopupMenuItem(value: 'logout', child: Text('Logout')),
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
                            colors: [Colors.transparent, ColorName.black26],
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
                          child: _ProfileCard(avatarRadius: _avatarRadius),
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
            body: const TabBarView(
              children: [
                _AllTab(),
                _UserPostsTab(),
                WidgetPlaceholder(text: 'Replies'),
                WidgetPlaceholder(text: 'Media'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final double avatarRadius;
  const _ProfileCard({required this.avatarRadius});

  @override
  Widget build(BuildContext context) {
    final double nameBlockTopPadding = 18;
    final double nameBlockHeight =
        (2 * avatarRadius) + nameBlockTopPadding + 10;

    return BlocBuilder<AuthCubit, AuthState>(builder: (context, state) {
      print('state current in profile page: $state');
      final user =
          state.maybeWhen(userInfoLoaded: (user) => user, orElse: () => null);

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
                  // FIX: ĐÃ SỬA LỖI NGOẶC Ở ĐÂY
                  Positioned(
                    left: 0,
                    right: 0,
                    top: avatarRadius + 5,
                    child: Column(
                      children: [
                        Text(
                          user?.username ?? 'User Name',
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
                    child: Center(child: WidgetAvatar(radius: avatarRadius)),
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
                      'Trong bộ tộc Bodi Tribe (Ethiopia)...',
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
                              onPressed: () {},
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
                                style: TextStyle(fontWeight: FontWeight.w600),
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
    });
  }
}

class _AllTab extends StatelessWidget {
  const _AllTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
      children: [
        const WidgetSectionTitle('Friends'),
        const SizedBox(height: 8),

        // Dãy avatar + nút 3 chấm
        Row(
          children: [
            const WidgetFriendAvatar(
              'https://images.unsplash.com/photo-1531123897727-8f129e1688ce?w=200',
            ),
            const SizedBox(width: 10),
            const WidgetFriendAvatar(
              'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=200',
            ),
            const SizedBox(width: 10),
            const WidgetFriendAvatar(
              'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=200',
            ),
            const SizedBox(width: 10),
            const WidgetFriendAvatar(
              'https://images.unsplash.com/photo-1520813792240-56fc4a3765a7?w=200',
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.more_horiz),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SelectFriendsPage()),
                );
              },
              tooltip: 'All friends',
            ),
          ],
        ),

        const SizedBox(height: 16),
        const _TwoColumnStatsAndGallery(),
      ],
    );
  }
}

class _UserPostsTab extends StatelessWidget {
  const _UserPostsTab();

  String _formatTwitterTime(DateTime dt) {
    final hour = DateFormat('h:mm a').format(dt);
    final date = DateFormat('MMM d, yyyy').format(dt);
    return '$hour · $date';
  }

  PostData _mapToPostData(PostResponse p) {
    final timeText = _formatTwitterTime(p.createdAt);

    return PostData(
      username: p.username ?? 'User',
      time: timeText,
      content: p.content,
      likes: p.likeCount,
      comments: p.commentCount,
      shares: 0,
      isLiked: p.isLiked,
      isReposted: false,
      isPublic: p.visibility == 'public',
      showThread: false,
      imageUrl: p.imageUrl,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AuthCubit>().state;
    final user = state.maybeWhen(
      userInfoLoaded: (user) => user,
      orElse: () => null,
    );

    if (user == null) {
      return const Center(child: Text('Không tìm thấy thông tin người dùng'));
    }

    final username = user.username;
    final currentUserId = user.id;

    final postApi = PostApi(baseUrl: 'http://10.0.2.2:8001');

    return FutureBuilder<List<PostResponse>>(
      future: postApi.getPosts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Lỗi tải bài viết:\n${snapshot.error}'),
          );
        }

        final allPosts = snapshot.data ?? [];

        // Lọc bài viết theo username của user này
        final userPosts =
            allPosts.where((p) => p.username == username).toList();

        if (userPosts.isEmpty) {
          return const Center(child: Text('User này chưa có bài viết nào'));
        }

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 80),
          itemCount: userPosts.length,
          itemBuilder: (context, i) {
            final p = userPosts[i];
            final postData = _mapToPostData(p);

            final bool isMine = p.userId == currentUserId;

            return PostItem(
              postData: postData,
              onLikePressed: () {
                // TODO: thêm logic like nếu muốn
              },
              onRepostPressed: () {
                // TODO: thêm logic repost nếu muốn
              },
              onCommentPressed: () {
                // TODO: mở màn comment nếu có
              },

              // 🔹 Cho phép quản lý (hiện icon 3 chấm) nếu là bài của mình
              canManage: isMine,
              onEdit: isMine
                  ? () async {
                      final updated =
                          await Navigator.of(context).push<PostResponse>(
                        MaterialPageRoute(
                          builder: (_) => EditPostPage(post: p),
                        ),
                      );

                      if (updated != null && context.mounted) {
                        // reload list
                        (context as Element).markNeedsBuild();
                      }
                    }
                  : null,
              onDelete: isMine
                  ? () async {
                      final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Xoá bài viết'),
                              content: const Text(
                                  'Bạn có chắc muốn xoá bài viết này không?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Huỷ'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text('Xoá'),
                                ),
                              ],
                            ),
                          ) ??
                          false;

                      if (!confirm) return;

                      try {
                        await postApi.deletePost(p.id);
                        if (context.mounted) {
                          (context as Element).markNeedsBuild();
                        }
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Xoá thất bại: $e')),
                        );
                      }
                    }
                  : null,
            );
          },
        );
      },
    );
  }
}

class _TwoColumnStatsAndGallery extends StatefulWidget {
  const _TwoColumnStatsAndGallery();

  @override
  State<_TwoColumnStatsAndGallery> createState() =>
      _TwoColumnStatsAndGalleryState();
}

class _TwoColumnStatsAndGalleryState extends State<_TwoColumnStatsAndGallery> {
  final postApi = PostApi(baseUrl: 'http://10.0.2.2:8001');

  List<String> myImages = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadMyImages();
  }

  Future<void> _loadMyImages() async {
    try {
      final currentUser = Supabase.instance.client.auth.currentUser;
      final currentUserId = currentUser?.id;

      if (currentUserId == null) {
        setState(() => loading = false);
        return;
      }

      final posts = await postApi.getPosts();

      // lọc ảnh của user
      final imgs = posts
          .where((p) =>
              p.userId == currentUserId &&
              p.imageUrl != null &&
              p.imageUrl!.isNotEmpty)
          .map((p) => p.imageUrl!)
          .toList();

      setState(() {
        myImages = imgs;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
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
              child: const WidgetStatsCard(),
            ),
            const SizedBox(width: 16),

            // HIỂN THỊ GALLERY
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : WidgetGalleryGrid(imageUrls: myImages),
            ),
          ],
        );
      },
    );
  }
}
