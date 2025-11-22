import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../generated/colors.gen.dart';
import '../../app/app_router.dart';
import '../../auth/presentation/cubit/auth_cubit.dart';
import '../../auth/presentation/cubit/auth_state.dart';

import 'controller/create_post_controller.dart';
import 'widgets/create_post_app_bar.dart';
import 'widgets/post_action_bar.dart';
import 'widgets/post_content_field.dart';

@RoutePage()
class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  late final CreatePostController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    // Lấy username từ AuthCubit
    final authState = context.read<AuthCubit>().state;
    final currentUsername = authState.maybeWhen(
          userInfoLoaded: (user) => user.username,
          orElse: () => null,
        ) ??
        'Unknown'; // luôn là String (không null)

    _controller = CreatePostController(
      currentUsername: currentUsername,
      baseUrl: 'http://10.0.2.2:8001',
      maxCharacters: 280,
    );
  }

  @override
  void dispose() {
    _controller.disposeController();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _handlePost() async {
    try {
      final createdPost = await _controller.submit();
      if (!mounted) return;

      // Hiển thị thông báo thành công
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Post created successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
            bottom: 100,
            left: 20,
            right: 20,
          ),
        ),
      );

      // Quay về màn trước, trả PostResponse để list có thể refresh nếu cần
      context.router.pop(createdPost);
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog(e.toString());
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cannot Post'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final canPost = _controller.canPost;

        return Scaffold(
          backgroundColor: ColorName.backgroundWhite,
          appBar: CreatePostAppBar(
            canPost: canPost,
            // luôn truyền callback sync, bên trong gọi async
            onPostPressed: () {
              _handlePost();
            },
            onBackPressed: () => AutoTabsRouter.of(context).setActiveIndex(0),
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      PostContentField(
                        postController: _controller.contentController,
                        focusNode: _focusNode,
                        currentUsername: _controller.currentUsername,
                        isPublic: _controller.isPublic,
                        onPrivacyChanged: _controller.togglePrivacy,
                        characterCount: _controller.characterCount,
                        maxCharacters: _controller.maxCharacters,
                        isFriends: _controller.isFriends,
                      ),

                      // Preview ảnh đã chọn
                      if (_controller.selectedImage != null) ...[
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(
                            File(_controller.selectedImage!.path),
                            height: 220,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              PostActionBar(
                postController: _controller.contentController,
                onClearPost: _controller.clearPost,
                onAddPhoto: () async {
                  try {
                    await _controller.pickImage();
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Không chọn được ảnh: $e'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
                onAddMention: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Mention coming soon!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                onAddEmoji: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Emoji picker coming soon!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
