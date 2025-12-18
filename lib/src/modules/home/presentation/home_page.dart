// lib/src/modules/home/presentation/home_page.dart

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../generated/colors.gen.dart';
import '../../app/app_router.dart';
import '../../newpost/presentation/cubit/post_cubit.dart';
import 'widgets/post_list.dart';

@RoutePage()
class HomePage extends StatefulWidget implements AutoRouteWrapper {
  const HomePage({super.key});

  @override
  Widget wrappedRoute(BuildContext context) {
    return this;
  }

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _avatarUrl;

  // THÊM: Biến để track current feed mode
  FeedMode _currentFeedMode = FeedMode.recommended;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadMyAvatar();

    // THÊM: Lắng nghe sự kiện chuyển tab
    _tabController.addListener(_onTabChanged);

    // THÊM: Load feed ban đầu cho tab đầu tiên
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFeedForCurrentTab();
    });
  }

  // THÊM: Xử lý khi chuyển tab
  void _onTabChanged() {
    if (!_tabController.indexIsChanging && mounted) {
      _loadFeedForCurrentTab();
    }
  }

  // THÊM: Load feed tương ứng với tab hiện tại
  Future<void> _loadFeedForCurrentTab() async {
    final cubit = context.read<PostCubit>();

    if (_tabController.index == 0) {
      // TAB 1: FOR YOU (Recommendations)
      _currentFeedMode = FeedMode.recommended;
      await cubit.loadFeed(
        mode: FeedMode.recommended,
        onlyFollowing: false,
      );
    } else {
      // TAB 2: FOLLOWING (Latest posts from followed users)
      _currentFeedMode =
          FeedMode.latest; // Hoặc FeedMode.following nếu bạn đã implement
      await cubit.loadFeed(
        mode: FeedMode.latest,
        onlyFollowing: true,
      );
    }
  }

  Future<void> _loadMyAvatar() async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;

    if (user == null) return;

    try {
      final res = await client
          .from('profiles')
          .select('avatar_url')
          .eq('id', user.id)
          .maybeSingle();

      if (res != null && mounted) {
        setState(() {
          _avatarUrl = res['avatar_url'] as String?;
        });
      }
    } catch (_) {
      // ignore
    }
  }

  Future<void> _openCreatePost() async {
    await context.router.push(const CreatePostRoute());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorName.backgroundWhite,
        title: RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            children: [
              TextSpan(
                text: 'City',
                style: TextStyle(color: Colors.black),
              ),
              TextSpan(
                text: ' Life',
                style: TextStyle(color: ColorName.mint),
              ),
            ],
          ),
        ),
        actions: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(50),
              border: Border.all(
                color: Colors.grey.shade300,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                IconButton(
                  icon: const FaIcon(
                    FontAwesomeIcons.magnifyingGlass,
                    color: Colors.black,
                    size: 20,
                  ),
                  onPressed: () {
                    context.router.replace(const SearchRoute());
                  },
                ),
                IconButton(
                  icon: const FaIcon(FontAwesomeIcons.bell),
                  color: Colors.black,
                  onPressed: () {
                    context.router.navigate(const NoticeRoute());
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.smart_toy_outlined,
                    color: Colors.black,
                    size: 22,
                  ),
                  onPressed: () {
                    context.router.push(const ChatbotRoute());
                  },
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () async {
                    final changed = await context.router.push(ProfileRoute());

                    if (changed == true) {
                      _loadMyAvatar();
                    }
                  },
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage:
                        (_avatarUrl != null && _avatarUrl!.isNotEmpty)
                            ? NetworkImage(_avatarUrl!)
                            : null,
                    child: (_avatarUrl == null || _avatarUrl!.isEmpty)
                        ? const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 18,
                          )
                        : null,
                  ),
                ),
              ],
            ),
          )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: ColorName.borderLight,
                  width: 0.5,
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: ColorName.mint,
              labelColor: ColorName.textBlack,
              unselectedLabelColor: ColorName.textGray,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w400,
              ),
              tabs: const [
                Tab(text: 'For You'),
                Tab(text: 'Following'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: FOR YOU (Recommendations)
          BlocBuilder<PostCubit, PostState>(
            builder: (context, state) {
              return RefreshIndicator(
                onRefresh: () async {
                  await context.read<PostCubit>().loadFeed(
                        mode: FeedMode.recommended,
                        onlyFollowing: false,
                      );
                },
                child: Builder(
                  builder: (context) {
                    // XỬ LÝ STATE TRỰC TIẾP Ở ĐÂY CHO "FOR YOU" TAB
                    return switch (state) {
                      PostStateInitial() =>
                        const Center(child: CircularProgressIndicator()),
                      PostStateLoading() =>
                        const Center(child: CircularProgressIndicator()),
                      PostStateError(:final message) =>
                        Center(child: Text(message)),
                      PostStateLoaded(:final posts) =>
                        // DÙNG PostList HIỆN TẠI NHƯNG VỚI CUSTOM EMPTY STATE
                        posts.isEmpty
                            ? _buildEmptyRecommendations()
                            : PostList(
                                onlyFollowing: false,
                                // THÊM key để force rebuild khi chuyển tab
                                key: ValueKey('for-you-${posts.length}'),
                              ),
                      _ => const Center(child: Text('Unknown state')),
                    };
                  },
                ),
              );
            },
          ),

          // TAB 2: FOLLOWING
          BlocBuilder<PostCubit, PostState>(
            builder: (context, state) {
              return RefreshIndicator(
                onRefresh: () async {
                  await context.read<PostCubit>().loadFeed(
                        mode: FeedMode.latest,
                        onlyFollowing: true,
                      );
                },
                child: Builder(
                  builder: (context) {
                    // XỬ LÝ STATE TRỰC TIẾP CHO "FOLLOWING" TAB
                    return switch (state) {
                      PostStateInitial() =>
                        const Center(child: CircularProgressIndicator()),
                      PostStateLoading() =>
                        const Center(child: CircularProgressIndicator()),
                      PostStateError(:final message) =>
                        Center(child: Text(message)),
                      PostStateLoaded(:final posts) =>
                        // PostList sẽ tự filter onlyFollowing = true
                        PostList(
                          onlyFollowing: true,
                          key: ValueKey('following-${posts.length}'),
                        ),
                      _ => const Center(child: Text('Unknown state')),
                    };
                  },
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: ColorName.mint,
        onPressed: _openCreatePost,
        child: const Icon(Icons.edit, color: Colors.white),
      ),
    );
  }

  // THÊM: Widget hiển thị khi không có recommendations
  Widget _buildEmptyRecommendations() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_awesome,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            const Text(
              'Chưa có gợi ý cho bạn',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Hãy like vài bài viết để hệ thống\nhiểu sở thích của bạn hơn!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // CHUYỂN SANG TAB LATEST (tất cả bài)
                _tabController.animateTo(0); // Vẫn ở tab For You
                context.read<PostCubit>().loadFeed(
                      mode: FeedMode
                          .latest, // Load bài mới nhất thay vì recommendations
                      onlyFollowing: false,
                    );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorName.mint,
                foregroundColor: Colors.white,
              ),
              child: const Text('Xem bài mới nhất'),
            ),
          ],
        ),
      ),
    );
  }
}
