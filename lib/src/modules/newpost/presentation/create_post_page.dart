// lib/src/modules/newpost/presentation/create_post_page.dart

import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../generated/colors.gen.dart';
import '../../../common/utils/getit_utils.dart';
import '../../auth/presentation/cubit/auth_cubit.dart';
import '../domain/usecase/create_post_usecase.dart';
import 'widgets/create_post_app_bar.dart';
import 'widgets/post_action_bar.dart';
import 'widgets/post_content_field.dart';

/// 2 chế độ hiển thị bài viết
enum PostVisibility { public, private }

extension PostVisibilityX on PostVisibility {
  String get label {
    switch (this) {
      case PostVisibility.public:
        return 'Public';
      case PostVisibility.private:
        return 'Private';
    }
  }

  IconData get icon {
    switch (this) {
      case PostVisibility.public:
        return Icons.public;
      case PostVisibility.private:
        return Icons.lock;
    }
  }

  /// Giá trị gửi lên backend: 'public' | 'private'
  String get backendValue {
    switch (this) {
      case PostVisibility.public:
        return 'public';
      case PostVisibility.private:
        return 'private';
    }
  }
}

@RoutePage()
class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final TextEditingController _postController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  static const int _maxCharacters = 280;
  int _characterCount = 0;

  bool _isSubmitting = false;

  /// Trạng thái hiển thị bài viết
  PostVisibility _visibility = PostVisibility.public;

  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;

  @override
  void initState() {
    super.initState();
    _postController.addListener(() {
      setState(() {
        _characterCount = _postController.text.length;
      });
    });
  }

  @override
  void dispose() {
    _postController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // chọn ảnh
  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImage = picked;
      });
    }
  }

  // upload ảnh lên Supabase bucket 'post-images'
  Future<String?> _uploadPostImage(XFile image) async {
    try {
      final client = Supabase.instance.client;
      final bytes = await image.readAsBytes();

      final fileExt = image.path.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = 'posts/$fileName';

      await client.storage.from('post-images').uploadBinary(
            filePath,
            bytes,
            fileOptions: FileOptions(
              contentType: 'image/$fileExt',
              upsert: false,
            ),
          );

      final publicUrl =
          client.storage.from('post-images').getPublicUrl(filePath);

      print('>>> [Create] Upload image success: $publicUrl');
      return publicUrl;
    } catch (e, st) {
      print('>>> [Create] Upload image ERROR: $e');
      print(st);
      return null;
    }
  }

  /// Bottom sheet chọn Public / Private
  Future<void> _showVisibilitySheet() async {
    final selected = await showModalBottomSheet<PostVisibility>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: Icon(PostVisibility.public.icon),
                title: Text(PostVisibility.public.label),
                trailing: _visibility == PostVisibility.public
                    ? const Icon(Icons.check)
                    : null,
                onTap: () => Navigator.of(ctx).pop(PostVisibility.public),
              ),
              ListTile(
                leading: Icon(PostVisibility.private.icon),
                title: Text(PostVisibility.private.label),
                trailing: _visibility == PostVisibility.private
                    ? const Icon(Icons.check)
                    : null,
                onTap: () => Navigator.of(ctx).pop(PostVisibility.private),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );

    if (selected != null && selected != _visibility) {
      setState(() {
        _visibility = selected;
      });
    }
  }

  Future<void> _createPost() async {
    final content = _postController.text.trim();
    print('[Create] _createPost content="$content", visibility=${_visibility.backendValue}');

    if (content.isEmpty && _selectedImage == null) {
      _showErrorDialog(
        'Please write something or add a photo before posting.',
      );
      return;
    }

    if (_characterCount > _maxCharacters) {
      _showErrorDialog(
        'Post exceeds the character limit of $_maxCharacters.',
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      String? imageUrl;

      // nếu có ảnh thì upload trước
      if (_selectedImage != null) {
        imageUrl = await _uploadPostImage(_selectedImage!);
      }

      // gọi usecase trực tiếp qua getIt
      final createUseCase = getIt<CreatePostUseCase>();

      final newPost = await createUseCase(
        content,
        imageUrl: imageUrl,
        visibility: _visibility.backendValue, // 'public' | 'private'
      );

      print('>>> [Create] New post id=${newPost.id}');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Post created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      context.router.pop(true);
    } catch (e, st) {
    print('>>> [Create] ERROR TYPE: ${e.runtimeType}');
    print('>>> [Create] ERROR TO STRING: "${e.toString()}"');
    print('>>> [Create] ERROR MESSAGE: "${(e as Exception).toString()}"');
    
    // detail log
    final errorStr = e.toString();
    print('>>> [Create] Error contains "daily": ${errorStr.contains("daily")}');
    print('>>> [Create] Error contains "limit": ${errorStr.contains("limit")}');
    print('>>> [Create] Error contains "exceeded": ${errorStr.contains("exceeded")}');
    
    if (!mounted) return;
    
    String errorMessage = 'Failed to create post. Please try again.';
    bool isDailyLimitError = false;

    if (errorStr.contains('Daily posts limit exceeded') ||
        errorStr.contains('daily post limit') ||
        errorStr.contains('limit exceeded') ||
        errorStr.contains('daily limit')) {
      errorMessage = '''DAILY POST LIMIT REACHED

        You have used all your daily posts for today.

        • **Limit:** 1 post per day
        • **Reset:** Every day at midnight
        • **Remaining:** 0 posts left today

        Please come back tomorrow to share more! ''';
      
      isDailyLimitError = true;
    }

    if (isDailyLimitError) {
      print('>>> [Create] Showing daily limit dialog');
      _showDailyLimitDialog();
    } else {
      print('>>> [Create] Showing general error dialog: $errorMessage');
      _showErrorDialog(errorMessage);
    }
  }finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showErrorDialog(String message) {
  // Kiểm tra mounted trước
    if (!mounted) return;
    
    showDialog<void>(
      context: context,
      barrierDismissible: false, // Ngăn tap outside để close
      builder: (_) => AlertDialog(
        title: const Text('Cannot Post'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              // Kiểm tra mounted trước khi pop
              if (mounted) {
                Navigator.of(context, rootNavigator: true).pop();
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showDailyLimitDialog() {
  // Delay để đảm bảo mounted
  Future.delayed(Duration.zero, () {
    if (!mounted) return;
    
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => WillPopScope(
        onWillPop: () async {
          // Khi user ấn back hardware, đóng dialog và màn hình create
          if (mounted) {
            Navigator.of(context, rootNavigator: true).pop();
            Future.delayed(Duration.zero, () {
              if (mounted) context.router.pop();
            });
          }
          return false;
        },
        child: AlertDialog(
          title: Expanded(
            child: Row(
              children: [
                Icon(Icons.timer_off_rounded, color: ColorName.navBackground),
                Gap(10),
                const Text(
                  'Daily Limit ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'You have reached your daily posting limit.',
                  style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                ),
                Gap(10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                    // border: Border.all(color: Colors.orange[200]),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.orange[800], size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'LIMIT DETAILS',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange[800],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• 1 post per day per user\n• Resets at midnight (00:00)\n• No carryover to next day',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.orange[800],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  'Please come back tomorrow to share more!',
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
                // Đóng màn hình create post sau khi OK
                Future.delayed(const Duration(milliseconds: 300), () {
                  if (mounted) {
                    context.router.pop();
                  }
                });
              },
              style: TextButton.styleFrom(
                backgroundColor: ColorName.navBackground,
                foregroundColor: ColorName.black,
              ),
              child: const Text('Ok, I understand'),
            ),
          ],
        ),
      ),
    );
  });
}

  @override
  Widget build(BuildContext context) {
    // 🔥 Lấy thông tin user đang đăng nhập từ AuthCubit
    final authState = context.watch<AuthCubit>().state;

    final currentUser = authState.maybeWhen(
      userInfoLoaded: (user) => user,
      orElse: () => null,
    );

    final currentUsername = currentUser?.username ?? 'User';

    final canPost = !_isSubmitting &&
        (_postController.text.trim().isNotEmpty || _selectedImage != null) &&
        _characterCount <= _maxCharacters;

    return Scaffold(
      backgroundColor: ColorName.backgroundWhite,
      appBar: CreatePostAppBar(
        canPost: canPost,
        onPostPressed: _isSubmitting ? null : _createPost,
        onBackPressed: () {
          print('>>> [CreatePostPage] Back callback');
          context.router.maybePop(); // hoặc Navigator.of(context).maybePop();
        },
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  PostContentField(
                    postController: _postController,
                    focusNode: _focusNode,
                    currentUsername: currentUsername,
                    isPublic: _visibility == PostVisibility.public,
                    onPrivacyChanged:
                        _showVisibilitySheet, // 👈 bấm chip để chọn
                    characterCount: _characterCount,
                    maxCharacters: _maxCharacters,
                  ),
                  if (_selectedImage != null) ...[
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(
                        File(_selectedImage!.path),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          PostActionBar(
            postController: _postController,
            onClearPost: () {
              _postController.clear();
              setState(() {
                _selectedImage = null;
              });
            },
            onAddPhoto: _pickImage,
            onAddMention: () {},
            onAddEmoji: () {},
          ),
        ],
      ),
    );
  }
}
