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
      decoration: BoxDecoration(
        color: ColorName.backgroundWhite,
        border: Border(
          bottom: BorderSide(color: ColorName.borderLight, width: 0.5),
        ),
      ),
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: ColorName.mint,
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
                    // Header with username, time
                    Row(
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
                          postData.isPublic ? Icons.public : Icons.lock_outline,
                          size: 14,
                          color: ColorName.grey,
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
                        Expanded(child: Container()),
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
          
          // Icon 3 chấm
          Positioned(
            top: 0, 
            right: 6, 
            child: GestureDetector(
              onTap: () {
                _showPostOptions(context);
              },
              child: const Icon(
                Icons.more_vert,
                color: ColorName.grey,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
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
}