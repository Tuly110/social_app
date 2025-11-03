import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../models/post_data.dart';
import 'comment_button.dart';
import 'repost_button.dart';
import 'like_button.dart';
import 'action_button.dart';

class PostItem extends StatelessWidget {
  final PostData postData;
  final VoidCallback onLikePressed;
  final VoidCallback onRepostPressed;
  final VoidCallback onCommentPressed;

  const PostItem({
    super.key,
    required this.postData,
    required this.onLikePressed,
    required this.onRepostPressed,
    required this.onCommentPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E5E5), width: 0.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF1D9BF0),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                postData.username[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
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
                // Header with username, handle, time
                Row(
                  children: [
                    Text(
                      postData.username,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${postData.handle} · ${postData.time}',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Content text
                Text(
                  postData.content,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                // Show thread button (if applicable)
                if (postData.showThread)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: const Text(
                      'Show this thread',
                      style: TextStyle(
                        color: Color(0xFF1D9BF0),
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
                      icon: Iconsax.share,
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