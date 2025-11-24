import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:social_app/src/modules/app/app_router.dart';
import 'package:intl/intl.dart';

import '../models/post_data.dart';
import 'post_item.dart';
import '../pages/comments_page.dart';

import '../../../newpost/presentation/models/post_api_models.dart';
import '../../../newpost/presentation/edit_post_page.dart';
import '../../../../core/data/api/post_api.dart';

class PostList extends StatefulWidget {
  const PostList({super.key});

  @override
  State<PostList> createState() => _PostListState();
}

class _PostListState extends State<PostList> {
  late final PostApi _postApi;

  @override
  void initState() {
    super.initState();
    _postApi = PostApi(baseUrl: 'http://10.0.2.2:8001');
  }

  Future<List<PostResponse>> _loadPosts() async {
    // Gọi API lấy danh sách post từ backend
    return _postApi.getPosts();
  }

  String formatTwitterTime(DateTime dt) {
    final hour = DateFormat('h:mm a').format(dt);
    final date = DateFormat('MMM d, yyyy').format(dt);
    return '$hour · $date';
  }

  PostData _mapToPostData(PostResponse p) {
    final timeText = formatTwitterTime(p.createdAt);

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

  void _openComments(PostData post, BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommentsPage(
          post: post,
          onLikePressed: () {
            // TODO: sau này bạn có thể thêm logic like local
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;

    return FutureBuilder<List<PostResponse>>(
      future: _loadPosts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Lỗi tải bài viết:\n${snapshot.error}'),
          );
        }

        final apiPosts = snapshot.data ?? [];

        if (apiPosts.isEmpty) {
          return const Center(child: Text('Chưa có bài viết nào'));
        }

        return ListView.builder(
          itemCount: apiPosts.length,
          itemBuilder: (context, i) {
            final p = apiPosts[i];
            final post = _mapToPostData(p);

            final bool isMine =
                currentUserId != null && p.userId == currentUserId;

            return PostItem(
              postData: post,
              onLikePressed: () {
                // TODO: sau này nếu muốn like local thì thêm logic ở đây
              },
              onRepostPressed: () {
                // TODO: sau này nếu muốn repost local thì thêm logic ở đây
              },
              onCommentPressed: () => _openComments(post, context),
              canManage: isMine,
              onEdit: isMine
                  ? () async {
                      final updated =
                          await Navigator.of(context).push<PostResponse>(
                        MaterialPageRoute(
                          builder: (_) => EditPostPage(post: p),
                        ),
                      );

                      if (updated != null && mounted) {
                        setState(() {});
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
                        await _postApi.deletePost(p.id);
                        if (mounted) setState(() {});
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Xoá thất bại: $e'),
                          ),
                        );
                      }
                    }
                  : null,

              // 👇 Thêm onUserTap: mở UserProfilePage
              onUserTap: () {
                if (p.userId.isEmpty) return;

                final currentUserId =
                    Supabase.instance.client.auth.currentUser?.id;

                if (currentUserId != null && p.userId == currentUserId) {
                  // Chính chủ → mở trang profile của mình
                  context.router.navigate(const ProfileRoute());
                } else {
                  // Người khác → mở UserProfilePage
                  context.router.push(
                    UserProfileRoute(userId: p.userId),
                  );
                }
              },
            );
          },
        );
      },
    );
  }
}
