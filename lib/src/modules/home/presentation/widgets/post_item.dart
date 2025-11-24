import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/post_data.dart';
import 'comment_button.dart';
import 'repost_button.dart';
import 'like_button.dart';
import 'action_button.dart';
import '../../../../../generated/colors.gen.dart';

class PostItem extends StatelessWidget {
  final PostData postData;
  final VoidCallback onLikePressed;
  final VoidCallback onRepostPressed;
  final VoidCallback onCommentPressed;

  /// true nếu là chủ bài đăng (hiện Edit/Delete)
  final bool canManage;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  /// Khi tap vào avatar hoặc username
  final VoidCallback? onUserTap;

  const PostItem({
    super.key,
    required this.postData,
    required this.onLikePressed,
    required this.onRepostPressed,
    required this.onCommentPressed,
    this.canManage = false,
    this.onEdit,
    this.onDelete,
    this.onUserTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorName.backgroundWhite,
        border: Border(
          bottom: BorderSide(color: ColorName.borderLight, width: 0.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar (tap để vào profile)
          GestureDetector(
            onTap: onUserTap,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: ColorName.mint,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  postData.username.isNotEmpty
                      ? postData.username[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with username, time
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // phần thông tin user + thời gian (tap để vào profile)
                    Expanded(
                      child: GestureDetector(
                        onTap: onUserTap,
                        behavior: HitTestBehavior.opaque,
                        child: Row(
                          children: [
                            Text(
                              postData.username,
                              style: TextStyle(
                                color: ColorName.textBlack,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              postData.isPublic
                                  ? Icons.public
                                  : Icons.lock_outline,
                              size: 14,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              postData.time,
                              style: TextStyle(
                                color: ColorName.textBlack,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // icon 3 chấm:
                    // - Nếu là chủ bài (canManage = true) -> Edit/Delete
                    // - Nếu không -> Report/Mute/Block/Copy link
                    if (canManage)
                      PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_vert,
                          color: Colors.grey.shade600,
                        ),
                        onSelected: (value) {
                          if (value == 'edit') {
                            if (onEdit != null) onEdit!();
                          } else if (value == 'delete') {
                            if (onDelete != null) onDelete!();
                          }
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem<String>(
                            value: 'edit',
                            child: Text('Edit'),
                          ),
                          PopupMenuItem<String>(
                            value: 'delete',
                            child: Text('Delete'),
                          ),
                        ],
                      )
                    else
                      IconButton(
                        icon: Icon(
                          Icons.more_vert,
                          color: Colors.grey.shade600,
                        ),
                        onPressed: () => _showPostOptions(context),
                      ),
                  ],
                ),
                const SizedBox(height: 4),

                // Content text
                Text(
                  postData.content,
                  style: TextStyle(
                    color: ColorName.textBlack,
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),

                // Hiển thị ảnh nếu có
                if (postData.imageUrl != null &&
                    postData.imageUrl!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      postData.imageUrl!,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const SizedBox(
                          height: 180,
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const SizedBox(
                          height: 120,
                          child: Center(
                            child: Text('Không tải được ảnh'),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                ],

                const SizedBox(height: 12),

                // Show thread button (if applicable)
                if (postData.showThread)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      'Show this thread',
                      style: TextStyle(
                        color: ColorName.mint,
                        fontSize: 14,
                      ),
                    ),
                  ),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CommentButton(
                      commentCount: postData.comments,
                      onPressed: onCommentPressed,
                    ),
                    RepostButton(
                      isReposted: postData.isReposted,
                      repostCount: postData.shares,
                      onPressed: onRepostPressed,
                    ),
                    LikeButton(
                      isLiked: postData.isLiked,
                      likeCount: postData.likes,
                      onPressed: onLikePressed,
                    ),
                    ActionButton(
                      icon: FontAwesomeIcons.share,
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void _showPostOptions(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.flag_outlined),
              title: const Text('Report post'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Xử lý report post
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications_off_outlined),
              title: const Text('Mute this author'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Xử lý mute author
              },
            ),
            ListTile(
              leading: const Icon(Icons.block),
              title: const Text('Block this author'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Xử lý block author
              },
            ),
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('Copy link'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Xử lý copy link
              },
            ),
          ],
        ),
      );
    },
  );
}
