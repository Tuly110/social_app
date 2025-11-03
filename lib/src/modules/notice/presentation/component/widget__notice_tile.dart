import 'package:flutter/material.dart';
import '../model/notice_model.dart';

class WidgetNoticeTile extends StatelessWidget {
  final NoticeItem item;
  final VoidCallback? onTap;

  const WidgetNoticeTile({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = BorderRadius.circular(16);
    final bgColor = item.unread ? const Color(0xFFEFF6FF) : theme.colorScheme.surface;

    return Material(
      color: bgColor,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _LeadingAvatarOrIcon(item: item),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tiêu đề + thời gian
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          item.time,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.message,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.black87,
                        fontWeight:
                            item.unread ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              if (item.unread) ...[
                const SizedBox(width: 8),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _LeadingAvatarOrIcon extends StatelessWidget {
  final NoticeItem item;
  const _LeadingAvatarOrIcon({required this.item});

  @override
  Widget build(BuildContext context) {
    if (item.avatarUrl != null && item.avatarUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 22,
        backgroundImage: NetworkImage(item.avatarUrl!),
      );
    }
    return CircleAvatar(
      radius: 22,
      backgroundColor: const Color(0xFFE5E7EB),
      child: Icon(
        item.icon ?? Icons.notifications_outlined,
        color: Colors.black54,
      ),
    );
  }
}
