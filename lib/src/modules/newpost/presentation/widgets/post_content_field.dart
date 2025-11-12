import 'package:flutter/material.dart';
import '../../../../../generated/colors.gen.dart';

import 'user_avatar.dart';
import 'privacy_selector.dart';

class PostContentField extends StatelessWidget {
  final TextEditingController postController;
  final FocusNode focusNode;
  final String currentUsername;
  final String currentHandle;
  final bool isPublic;
  final VoidCallback onPrivacyChanged;
  final int characterCount;
  final int maxCharacters;

  const PostContentField({
    super.key,
    required this.postController,
    required this.focusNode,
    required this.currentUsername,
    required this.currentHandle,
    required this.isPublic,
    required this.onPrivacyChanged,
    required this.characterCount,
    required this.maxCharacters,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // User info and avatar
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Avatar
            UserAvatar(username: currentUsername),
            const SizedBox(width: 12),
            // User info and text field
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User name and handle
                  Row(
                    children: [
                      Text(
                        currentUsername,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: ColorName.textBlack,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        currentHandle,
                        style: TextStyle(
                          color: ColorName.textGray,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Privacy selector
                  PrivacySelector(
                    isPublic: isPublic,
                    onPrivacyChanged: onPrivacyChanged,
                  ),
                  const SizedBox(height: 8),
                  // Text field
                  TextField(
                    controller: postController,
                    focusNode: focusNode,
                    maxLines: null,
                    style: TextStyle(
                      color: ColorName.textBlack,
                      fontSize: 18,
                    ),
                    decoration: const InputDecoration(
                      hintText: "What's happening?",
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 18,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Character count
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '$characterCount/$maxCharacters',
            style: TextStyle(
              color: characterCount > maxCharacters
                  ? Colors.red
                  : ColorName.textGray,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}