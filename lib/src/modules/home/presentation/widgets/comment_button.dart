import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class CommentButton extends StatelessWidget {
  final int commentCount;
  final VoidCallback onPressed;

  const CommentButton({
    super.key,
    required this.commentCount,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Row(
        children: [
          const Icon(
            Iconsax.message,
            color: Colors.grey,
            size: 18,
          ),
          const SizedBox(width: 6),
          Text(
            _formatCount(commentCount),
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count < 1000) return count.toString();
    if (count < 1000000) return '${(count / 1000).toStringAsFixed(1)}K';
    return '${(count / 1000000).toStringAsFixed(1)}M';
  }
}