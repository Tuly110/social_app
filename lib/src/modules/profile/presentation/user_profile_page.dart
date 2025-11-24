import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../generated/colors.gen.dart';
import '../../auth/presentation/cubit/auth_cubit.dart';
import '../../auth/presentation/cubit/auth_state.dart';
import '../../home/presentation/models/post_data.dart';
import '../../home/presentation/widgets/post_item.dart';
import '../../newpost/presentation/models/post_api_models.dart';
import '../../../core/data/api/post_api.dart';
import '../../../core/data/api/profile_api.dart';
import '../../../core/data/api/profile_api_models.dart';
import 'component/widget__avatar.dart';
import 'component/widget__placeholder.dart';
import 'component/widget__circle_icon.dart';
import '../../app/app_router.dart';

@RoutePage()
class UserProfilePage extends StatefulWidget {
  final String userId;

  const UserProfilePage({
    super.key,
    required this.userId,
  });

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage>
    with SingleTickerProviderStateMixin {
  late final ProfileApi _profileApi;
  late final PostApi _postApi;

  ProfileModel? _profile;
  bool _loadingProfile = true;
  String? _profileError;

  bool _isFollowing = false;
  bool _togglingFollow = false;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _profileApi = ProfileApi(baseUrl: 'http://10.0.2.2:8001');
    _postApi = PostApi(baseUrl: 'http://10.0.2.2:8001');
    _tabController = TabController(length: 2, vsync: this);
    _loadProfile();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      // Lấy profile của user đang xem
      final p = await _profileApi.getUserProfile(widget.userId);

      // Lấy current user id từ Supabase
      final currentUserId = Supabase.instance.client.auth.currentUser?.id;

      bool isFollowing = false;

      if (currentUserId != null) {
        // Gọi API lấy danh sách followers của user này
        // (những người đang follow user mà bạn đang xem)
        final followers = await _profileApi.getFollowers(widget.userId);

        // Nếu currentUser nằm trong danh sách followers này => mình đang follow họ
        isFollowing = followers.any((f) => f.id == currentUserId);
      }

      setState(() {
        _profile = p;
        _isFollowing = isFollowing;
        _loadingProfile = false;
      });
    } catch (e) {
      setState(() {
        _loadingProfile = false;
        _profileError = e.toString();
      });
    }
  }

  Future<void> _toggleFollow() async {
    if (_profile == null || _togglingFollow) return;

    final wasFollowing = _isFollowing;
    final oldProfile = _profile!; // lưu lại để revert nếu fail
    final targetId = oldProfile.id;

    setState(() {
      _togglingFollow = true;
      _isFollowing = !wasFollowing;

      // Update follower count local cho mượt
      if (!wasFollowing) {
        _profile = oldProfile.copyWith(
          followerCount: oldProfile.followerCount + 1,
        );
      } else {
        _profile = oldProfile.copyWith(
          followerCount:
              oldProfile.followerCount > 0 ? oldProfile.followerCount - 1 : 0,
        );
      }
    });

    try {
      if (wasFollowing) {
        await _profileApi.unfollowUser(targetId);
      } else {
        await _profileApi.followUser(targetId);
      }
    } catch (e) {
      // revert nếu lỗi
      setState(() {
        _isFollowing = wasFollowing;
        _profile = oldProfile;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Thao tác thất bại: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _togglingFollow = false);
      }
    }
  }

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
    final authState = context.watch<AuthCubit>().state;
    final currentUser = authState.maybeWhen(
      userInfoLoaded: (user) => user,
      orElse: () => null,
    );

    final bool isMe = currentUser != null && currentUser.id == _profile?.id;

    // Loading / error
    if (_loadingProfile) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_profileError != null) {
      return Scaffold(
        body: Center(child: Text('Lỗi tải profile:\n$_profileError')),
      );
    }
    if (_profile == null) {
      return const Scaffold(
        body: Center(child: Text('Không tìm thấy user này')),
      );
    }

    final p = _profile!;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: ColorName.bgF4f7f7,
        body: ListView(
          padding: EdgeInsets.zero,
          children: [
            _HeaderStack(
              profile: p,
              isMe: isMe,
              isFollowing: _isFollowing,
              togglingFollow: _togglingFollow,
              onToggleFollow: isMe ? null : _toggleFollow,
            ),
            _TabAndContentSection(
              tabController: _tabController,
              userId: widget.userId,
              postApi: _postApi,
              mapToPostData: _mapToPostData,
              currentUserId: currentUser?.id,
            ),
          ],
        ),
      ),
    );
  }
}

/// Header: cover + avatar + panel trắng
class _HeaderStack extends StatelessWidget {
  final ProfileModel profile;
  final bool isMe;
  final bool isFollowing;
  final bool togglingFollow;
  final VoidCallback? onToggleFollow;

  const _HeaderStack({
    required this.profile,
    required this.isMe,
    required this.isFollowing,
    required this.togglingFollow,
    required this.onToggleFollow,
  });

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    const double coverHeight = 220;
    const double panelTop = 160;
    const double avatarRadius = 36;

    return SizedBox(
      height: panelTop + 200,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Cover
          Positioned.fill(
            top: 0,
            bottom: null,
            child: SizedBox(
              height: coverHeight,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(28),
                      bottomRight: Radius.circular(28),
                    ),
                    child: Image.network(
                      'https://images.unsplash.com/photo-1761901175711-b6e3dd720a66?w=1600&auto=format&fit=crop',
                      fit: BoxFit.cover,
                    ),
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
                ],
              ),
            ),
          ),

          // Back
          Positioned(
            left: 16,
            top: top + 12,
            child: WidgetCircleIcon(
              icon: Icons.arrow_back,
              onTap: () => Navigator.of(context).maybePop(),
            ),
          ),

          // More
          Positioned(
            right: 16,
            top: top + 12,
            child: const WidgetCircleIcon(
              icon: Icons.more_horiz,
            ),
          ),

          // Panel trắng
          Positioned(
            left: 0,
            right: 0,
            top: panelTop,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, avatarRadius + 10, 16, 12),
              decoration: const BoxDecoration(
                color: ColorName.bgF4f7f7,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(35),
                  topRight: Radius.circular(35),
                ),
              ),
              child: _PanelContent(
                profile: profile,
                isMe: isMe,
                isFollowing: isFollowing,
                togglingFollow: togglingFollow,
                onToggleFollow: onToggleFollow,
              ),
            ),
          ),

          // Avatar
          Positioned(
            top: panelTop - avatarRadius,
            left: 0,
            right: 0,
            child: Center(
              child: WidgetAvatar(
                radius: avatarRadius,
                imageUrl: profile.avatarUrl,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Nội dung trong panel trắng: tên, bio, stats, nút follow
class _PanelContent extends StatelessWidget {
  final ProfileModel profile;
  final bool isMe;
  final bool isFollowing;
  final bool togglingFollow;
  final VoidCallback? onToggleFollow;

  const _PanelContent({
    required this.profile,
    required this.isMe,
    required this.isFollowing,
    required this.togglingFollow,
    required this.onToggleFollow,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Username
        Text(
          profile.username,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),

        // Bio
        if (profile.bio != null && profile.bio!.isNotEmpty)
          Text(
            profile.bio!,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: ColorName.grey700,
              height: 1.3,
            ),
          ),

        const SizedBox(height: 12),

        // Stats
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Followers
            GestureDetector(
              onTap: () {
                context.router.push(
                  FollowersRoute(
                    userId: profile.id,
                    username: profile.username,
                  ),
                );
              },
              child: _StatItem(
                label: 'Followers',
                value: profile.followerCount.toString(),
              ),
            ),
            const SizedBox(width: 24),

            // Following
            GestureDetector(
              onTap: () {
                context.router.push(
                  FollowingRoute(
                    userId: profile.id,
                    username: profile.username,
                  ),
                );
              },
              child: _StatItem(
                label: 'Following',
                value: profile.followingCount.toString(),
              ),
            ),
            const SizedBox(width: 24),

            // Posts
            _StatItem(
              label: 'Posts',
              value: profile.postCount.toString(),
            ),
          ],
        ),

        const SizedBox(height: 12),

        if (!isMe)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // FOLLOW BUTTON
              SizedBox(
                height: 38,
                child: ElevatedButton(
                  onPressed: togglingFollow ? null : onToggleFollow,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isFollowing ? ColorName.white : ColorName.mint,
                    foregroundColor:
                        isFollowing ? ColorName.mint : ColorName.white,
                    side: const BorderSide(color: ColorName.mint, width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: togglingFollow
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(isFollowing ? 'Unfollow' : 'Follow'),
                ),
              ),

              const SizedBox(width: 12),

              // MESSAGE BUTTON
              SizedBox(
                height: 38,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: mở màn chat
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Message feature coming soon!"),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorName.white,
                    foregroundColor: ColorName.mint,
                    side: const BorderSide(color: ColorName.mint, width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: const Text("Message"),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: ColorName.grey700,
          ),
        ),
      ],
    );
  }
}

/// Phần tab + nội dung (Posts / Media) bên dưới header
class _TabAndContentSection extends StatelessWidget {
  final TabController tabController;
  final String userId;
  final PostApi postApi;
  final PostData Function(PostResponse) mapToPostData;
  final String? currentUserId;

  const _TabAndContentSection({
    required this.tabController,
    required this.userId,
    required this.postApi,
    required this.mapToPostData,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        const SizedBox(height: 8),
        TabBar(
          controller: tabController,
          labelColor: ColorName.textBlack,
          unselectedLabelColor: ColorName.textGray,
          indicatorColor: ColorName.mint,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),
          tabs: const [
            Tab(text: 'Posts'),
            Tab(text: 'Media'),
          ],
        ),
        SizedBox(
          height: screenHeight * 0.9,
          child: TabBarView(
            controller: tabController,
            children: [
              _UserPostsTab(
                userId: userId,
                postApi: postApi,
                mapToPostData: mapToPostData,
                currentUserId: currentUserId,
              ),
              const WidgetPlaceholder(text: 'Media'),
            ],
          ),
        ),
      ],
    );
  }
}

class _UserPostsTab extends StatelessWidget {
  final String userId;
  final PostApi postApi;
  final PostData Function(PostResponse) mapToPostData;
  final String? currentUserId;

  const _UserPostsTab({
    super.key,
    required this.userId,
    required this.postApi,
    required this.mapToPostData,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
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

        final userPosts = allPosts.where((p) => p.userId == userId).toList();

        if (userPosts.isEmpty) {
          return const Center(child: Text('User này chưa có bài viết nào'));
        }

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 80),
          itemCount: userPosts.length,
          itemBuilder: (context, i) {
            final p = userPosts[i];
            final postData = mapToPostData(p);

            final bool isMine =
                currentUserId != null && p.userId == currentUserId;

            return PostItem(
              postData: postData,
              onLikePressed: () {},
              onRepostPressed: () {},
              onCommentPressed: () {},
              canManage: isMine,
              onEdit: null,
              onDelete: null,
            );
          },
        );
      },
    );
  }
}
