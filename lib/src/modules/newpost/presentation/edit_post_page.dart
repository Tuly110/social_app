import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../generated/colors.gen.dart';
import '../../app/app_router.dart';
import '../../../core/data/api/post_api.dart';
import 'models/post_api_models.dart';

// widgets giống create_post
import 'widgets/post_action_bar.dart';
import 'widgets/post_content_field.dart';

@RoutePage()
class EditPostPage extends StatefulWidget {
  final PostResponse post;

  const EditPostPage({
    super.key,
    required this.post,
  });

  @override
  State<EditPostPage> createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  late final TextEditingController _postController;
  final FocusNode _focusNode = FocusNode();

  late bool _isPublic;
  bool _isFriends = true;
  bool _isSubmitting = false;

  int _characterCount = 0;
  static const int _maxCharacters = 300;

  late final PostApi _postApi;

  XFile? _newImage;
  String? _imageUrl;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    _postController = TextEditingController(text: widget.post.content);
    _characterCount = widget.post.content.length;

    _isPublic = widget.post.visibility == 'public';
    _imageUrl = widget.post.imageUrl;

    _postApi = PostApi(
      baseUrl: 'http://10.0.2.2:8001',
    );

    _postController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {
      _characterCount = _postController.text.length;
    });
  }

  @override
  void dispose() {
    _postController.removeListener(_onTextChanged);
    _postController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _togglePrivacy() {
    setState(() {
      if (_isPublic) {
        _isPublic = false;
        _isFriends = true;
      } else if (_isFriends) {
        _isFriends = false;
      } else {
        _isPublic = true;
        _isFriends = true;
      }
    });
  }

  Future<void> _pickImage() async {
    try {
      final picked = await _picker.pickImage(
          source: ImageSource.gallery, imageQuality: 80);
      if (picked != null) {
        setState(() {
          _newImage = picked;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không chọn được ảnh: $e')),
      );
    }
  }

  Future<String?> _uploadNewImage(XFile image) async {
    final client = Supabase.instance.client;
    final bytes = await image.readAsBytes();
    final fileName =
        'posts/${DateTime.now().millisecondsSinceEpoch}_${image.name}';

    await client.storage.from('post-images').uploadBinary(
          fileName,
          bytes,
          fileOptions: const FileOptions(
            contentType: 'image/jpeg',
          ),
        );

    return client.storage.from('post-images').getPublicUrl(fileName);
  }

  Future<void> _submitPost() async {
    final content = _postController.text.trim();

    if (content.isEmpty) {
      _showErrorDialog('Nội dung không được để trống.');
      return;
    }

    if (content.length > _maxCharacters) {
      _showErrorDialog('Nội dung vượt quá $_maxCharacters ký tự.');
      return;
    }

    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      String? finalImageUrl = _imageUrl;

      if (_newImage != null) {
        finalImageUrl = await _uploadNewImage(_newImage!);
      }

      final request = PostUpdateRequest(
        content: content,
        visibility: _isPublic ? 'public' : 'private',
        imageUrl: finalImageUrl,
      );

      final updatedPost = await _postApi.updatePost(widget.post.id, request);

      if (!mounted) return;

      setState(() => _isSubmitting = false);

      // quay về màn trước, trả post đã update
      context.router.pop(updatedPost);
    } catch (e) {
      if (!mounted) return;

      setState(() => _isSubmitting = false);
      _showErrorDialog('Cập nhật bài viết thất bại:\n$e');
    }
  }

  void _showErrorDialog(String message) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Lỗi'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _clearPost() {
    setState(() {
      _postController.clear();
      _characterCount = 0;
      _newImage = null;
      _imageUrl = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final canSave = _postController.text.trim().isNotEmpty &&
        _postController.text.length <= _maxCharacters &&
        !_isSubmitting;

    return Scaffold(
      backgroundColor: ColorName.backgroundWhite,
      appBar: AppBar(
        backgroundColor: ColorName.backgroundWhite,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.router.pop(),
        ),
        title: Text(
          'Edit Post',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: ColorName.textBlack,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: canSave ? _submitPost : null,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    canSave ? ColorName.navBackground : Colors.grey,
                foregroundColor: ColorName.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'Save',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
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
                    // có thể truyền username thật lấy từ AuthCubit
                    currentUsername: widget.post.username ?? 'User',
                    isPublic: _isPublic,
                    onPrivacyChanged: _togglePrivacy,
                    characterCount: _characterCount,
                    maxCharacters: _maxCharacters,
                    isFriends: _isFriends,
                  ),
                  if (_newImage != null || _imageUrl != null) ...[
                    const SizedBox(height: 12),
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: _newImage != null
                              ? Image.file(
                                  File(_newImage!.path),
                                  height: 220,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                )
                              : Image.network(
                                  _imageUrl!,
                                  height: 220,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _newImage = null;
                                _imageUrl = null;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.all(4),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          PostActionBar(
            postController: _postController,
            onClearPost: _clearPost,
            onAddPhoto: _pickImage,
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
  }
}
