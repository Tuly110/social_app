// lib/src/modules/newpost/presentation/create_post_page.dart

import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../generated/colors.gen.dart';
import '../../../common/utils/getit_utils.dart';
import '../../auth/presentation/cubit/auth_cubit.dart';
import '../domain/usecase/create_post_usecase.dart';
import 'cubit/post_cubit.dart';
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

      // ignore: avoid_print
      print('>>> [Create] Upload image success: $publicUrl');
      return publicUrl;
    } catch (e, st) {
      // ignore: avoid_print
      print('>>> [Create] Upload image ERROR: $e');
      // ignore: avoid_print
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

  // ====== DAILY LIMIT DETECTOR (mạnh hơn check string đơn giản) ======

  bool _containsAny(String? text, List<String> keys) {
    if (text == null || text.isEmpty) return false;
    final t = text.toLowerCase();
    return keys.any((k) => t.contains(k.toLowerCase()));
  }

  bool _isDailyPostLimitError(Object e) {
    final parts = <String>[];

    if (e is PostgrestException) {
      parts.addAll([
        e.message.toString(),
        (e.details ?? '').toString(),
        (e.hint ?? '').toString(),
        (e.code ?? '').toString(),
      ]);
    }

    if (e is DioException) {
      parts.add((e.message ?? '').toString());
      final data = e.response?.data;
      if (data != null) parts.add(data.toString());
    }

    parts.add(e.toString());

    final blob = parts.join(' | ').toLowerCase();

    // ✅ Keyword cho limit
    final limitKeywords = <String>[
      'daily_post_limit',
      'daily posts limit',
      'daily limit',
      'limit exceeded',
      'reached your daily',
      'only 1 post per day',
      '1 post per day',
      'post per day',
      'hết lượt đăng',
      'giới hạn bài đăng',
      'vượt quá giới hạn',
      'p0001',
      '23505',
      'duplicate key',
      'unique constraint',
    ];

    // ✅ Keyword cho RLS (rất hay gặp khi limit bằng policy)
    final rlsKeywords = <String>[
      'row-level security',
      'row level security',
      'violates row-level security',
      'violates row level security',
      'new row violates row-level security policy',
      'permission denied',
      '42501',
    ];

    final isLimitText = limitKeywords.any((k) => blob.contains(k));
    final isRlsBlock = rlsKeywords.any((k) => blob.contains(k));

    // Trong flow create post, RLS block gần như chính là "đã hết lượt"
    return isLimitText || isRlsBlock;
  }

  // ====== UI DIALOGS ======

  void _showErrorDialog(String message) {
    if (!mounted) return;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Cannot Post'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
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
    Future.delayed(Duration.zero, () {
      if (!mounted) return;

      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => WillPopScope(
          onWillPop: () async {
            // chặn back, thay vào đó đóng dialog rồi pop page
            if (mounted) {
              Navigator.of(context, rootNavigator: true).pop();
              Future.delayed(Duration.zero, () {
                if (mounted) context.router.pop();
              });
            }
            return false;
          },
          child: AlertDialog(
            title: Row(
              children: [
                Icon(Icons.timer_off_rounded, color: ColorName.navBackground),
                const Gap(10),
                const Expanded(
                  child: Text(
                    'Posting limit reached.',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            content: const Text(
              'Posting limit for today has been reached..',
              style: TextStyle(fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop();
                  Future.delayed(const Duration(milliseconds: 250), () {
                    if (mounted) {
                      context.router.pop();
                    }
                  });
                },
                style: TextButton.styleFrom(
                  backgroundColor: ColorName.navBackground,
                  foregroundColor: ColorName.black,
                ),
                child: const Text('OK'),
              ),
            ],
          ),
        ),
      );
    });
  }

  // ====== CREATE POST ======

  Future<void> _createPost() async {
    final content = _postController.text.trim();
    // ignore: avoid_print
    print(
        '[Create] _createPost content="$content", visibility=${_visibility.backendValue}');

    if (content.isEmpty && _selectedImage == null) {
      _showErrorDialog('Please write something or add a photo before posting.');
      return;
    }

    if (_characterCount > _maxCharacters) {
      _showErrorDialog('Post exceeds the character limit of $_maxCharacters.');
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

      // createUseCase trả về PostEntity
      final newPost = await createUseCase(
        content,
        imageUrl: imageUrl,
        visibility: _visibility.backendValue, // 'public' | 'private'
      );

      // ignore: avoid_print
      print('>>> [Create] New post id=${newPost.id}');

      if (!mounted) return;

      // 🔥 ĐẨY POST MỚI VÀO PostCubit DÙ MỞ TỪ ĐÂU ĐI NỮA
      try {
        final postCubit = context.read<PostCubit>();
        if (!postCubit.isClosed) {
          postCubit.addPostOnTop(newPost);
        }
      } catch (e) {
        // nếu không tìm được PostCubit thì thôi, vẫn không crash
        // ignore: avoid_print
        print('>>> [Create] Không tìm thấy PostCubit trong context: $e');
      }

      // clear form
      _postController.clear();
      setState(() {
        _selectedImage = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Post created successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // ✅ chỉ cần pop() là đủ
      context.router.pop();
    } catch (e, st) {
      // ===== log mạnh để debug đúng loại lỗi =====
      // ignore: avoid_print
      print('>>> [Create] ERROR TYPE: ${e.runtimeType}');
      // ignore: avoid_print
      print('>>> [Create] ERROR TO STRING: "${e.toString()}"');
      final debugBlob = () {
        final parts = <String>[];
        if (e is PostgrestException) {
          parts.addAll([
            e.message.toString(),
            (e.details ?? '').toString(),
            (e.hint ?? '').toString(),
            (e.code ?? '').toString(),
          ]);
        }
        parts.add(e.toString());
        return parts.join(' | ');
      }();

      print('>>> [Create] DAILY_LIMIT_CHECK_BLOB: $debugBlob');

      if (e is PostgrestException) {
        // ignore: avoid_print
        print('>>> [Create] PostgrestException.code: ${e.code}');
        // ignore: avoid_print
        print('>>> [Create] PostgrestException.message: ${e.message}');
        // ignore: avoid_print
        print('>>> [Create] PostgrestException.details: ${e.details}');
        // ignore: avoid_print
        print('>>> [Create] PostgrestException.hint: ${e.hint}');
      }

      // ignore: avoid_print
      print('>>> [Create] ERROR STACK: $st');

      if (!mounted) return;

      if (_isDailyPostLimitError(e)) {
        _showDailyLimitDialog();
      } else {
        _showErrorDialog('Failed to create post. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
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
          // ignore: avoid_print
          print('>>> [CreatePostPage] Back callback');
          context.router.maybePop();
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
                    onPrivacyChanged: _showVisibilitySheet,
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
