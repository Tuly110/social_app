import 'package:flutter/material.dart';

import '../../../../../generated/colors.gen.dart';
import 'privacy_selector.dart';
import 'user_avatar.dart';

class PostContentField extends StatelessWidget {
  final TextEditingController postController;
  final FocusNode focusNode;
  final String currentUsername;
  final bool isPublic;
  final bool isFriends;
  final VoidCallback onPrivacyChanged;
  final int characterCount;
  final int maxCharacters;

  const PostContentField({
    super.key,
    required this.postController,
    required this.focusNode,
    required this.currentUsername,
    required this.isPublic,
    required this.isFriends,
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
                      
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Privacy selector
                  PrivacySelector(
                    isPublic: isPublic,
                    onPrivacyChanged: onPrivacyChanged, 
                    isFriends: isFriends,
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