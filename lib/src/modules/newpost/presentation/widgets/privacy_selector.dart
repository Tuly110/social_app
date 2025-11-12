import 'package:flutter/material.dart';

class PrivacySelector extends StatelessWidget {
  final bool isPublic;
  final VoidCallback onPrivacyChanged;

  const PrivacySelector({
    super.key,
    required this.isPublic,
    required this.onPrivacyChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPrivacyChanged,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isPublic ? Icons.public : Icons.lock_outline,
              size: 14,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              isPublic ? 'Public' : 'Private',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}