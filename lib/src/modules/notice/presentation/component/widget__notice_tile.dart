import 'package:flutter/material.dart';
import '../../../../../generated/colors.gen.dart';
import '../../domain/entities/notice_entity.dart';

class NoticeTile extends StatelessWidget {
  final NoticeEntity notice;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onMarkRead;

  const NoticeTile({
    Key? key,
    required this.notice,
    required this.onTap,
    required this.onDelete,
    required this.onMarkRead,
  }) : super(key: key);

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inSeconds < 60) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      // Format : dd/MM/yyyy
      return '${time.day.toString().padLeft(2, '0')}/${time.month.toString().padLeft(2, '0')}/${time.year}';
    }
  }

  String _buildContentText() {
    final username = notice.fromUser?.username ?? "Someone"; 
    switch (notice.type) {
      case 'like':
        return "$username liked your post.";
      case 'comment':
        return "$username commented on your post.";
      case 'share':
        return "$username shared your post.";
      case 'follow':
        return "$username followed you.";
      default:
        return "You have notification from $username.";
    }
  }

  Widget _buildTypeIcon() {
    switch (notice.type) {
      case 'like':
        return const Icon(Icons.favorite, size: 14, color: ColorName.white);
      case 'comment':
        return const Icon(Icons.comment, size: 14, color: ColorName.white);
      case 'share':
        return const Icon(Icons.share, size: 14, color: ColorName.white);
      case 'follow':
        return const Icon(Icons.person_add, size: 14, color: ColorName.white);
      default:
        return const Icon(Icons.notifications, size: 14, color: ColorName.white);
    }
  }

  Color _getTypeColor() {
    switch (notice.type) {
      case 'like': return ColorName.primary;
      case 'comment': return ColorName.primaryBlue;
      case 'share': return ColorName.primaryGreen;
      case 'follow': return ColorName.mint;
      default: return ColorName.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isUnread = !notice.isRead;
    final backgroundColor = isUnread ? Colors.blue.withOpacity(0.05) : ColorName.white;

    return InkWell(
      onTap: () {
        onTap();
        if (isUnread) onMarkRead();
      },
      child: Container(
        color: backgroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar Stack
            Stack(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundImage: NetworkImage(
                    notice.fromUser?.avatarUrl ?? "https://via.placeholder.com/150",
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: _getTypeColor(),
                      shape: BoxShape.circle,
                      border: Border.all(color: ColorName.white, width: 2),
                    ),
                    child: _buildTypeIcon(),
                  ),
                )
              ],
            ),
            const SizedBox(width: 14),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: DefaultTextStyle.of(context).style.copyWith(fontSize: 15, height: 1.3),
                      children: [
                        TextSpan(
                          text: notice.fromUser?.username ?? "User",
                          style: const TextStyle(fontWeight: FontWeight.bold, color: ColorName.black),
                        ),
                        TextSpan(
                          text: " ${_buildContentText().replaceFirst(notice.fromUser?.username ?? "", "").trim()}",
                          style: TextStyle(
                            color: isUnread ? ColorName.black87 : ColorName.grey500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatTime(notice.createdAt), 
                    style: TextStyle(
                      fontSize: 12,
                      color: isUnread ? ColorName.primaryBlue : ColorName.grey,
                      fontWeight: isUnread ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),

            // Action Menu
            Column(
              children: [
                SizedBox(
                  width: 30,
                  height: 30,
                  child: PopupMenuButton<String>(
                    padding: EdgeInsets.zero,
                    icon: Icon(Icons.more_horiz, color: ColorName.grey600),
                    onSelected: (value) {
                      if (value == 'delete') onDelete();
                      if (value == 'markRead') onMarkRead();
                    },
                    itemBuilder: (context) => [
                      if (isUnread)
                        const PopupMenuItem(
                          value: 'markRead',
                          child: Row(
                            children: [Icon(Icons.check, size: 18), SizedBox(width: 8), Text("Mark as read")],
                          ),
                        ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [Icon(Icons.delete_outline, size: 18, color: ColorName.primary), SizedBox(width: 8), Text("Delete", style: TextStyle(color: ColorName.primary))],
                        ),
                      ),
                    ],
                  ),
                ),
                if (isUnread)
                  Container(
                    margin: const EdgeInsets.only(top: 8, right: 10),
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: ColorName.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }
}