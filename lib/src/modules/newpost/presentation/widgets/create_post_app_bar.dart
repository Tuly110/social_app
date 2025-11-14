import 'package:flutter/material.dart';
import '../../../../../generated/colors.gen.dart';
class CreatePostAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool canPost;
  final VoidCallback onPostPressed;
  final VoidCallback onBackPressed;

  const CreatePostAppBar({
    super.key,
    required this.canPost,
    required this.onPostPressed,
    required this.onBackPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: ColorName.backgroundWhite,
      elevation: 1,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        onPressed: onBackPressed,
      ),
      title: Text(
        'Create Post',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: ColorName.textBlack,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: canPost ? onPostPressed : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: canPost ? ColorName.navBackground : Colors.grey,
              foregroundColor: ColorName.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            ),
            child: const Text(
              'Post',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}