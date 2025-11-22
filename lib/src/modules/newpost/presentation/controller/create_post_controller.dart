import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/data/api/post_api.dart';
import '../models/post_api_models.dart';

class CreatePostController extends ChangeNotifier {
  final TextEditingController contentController = TextEditingController();
  final int maxCharacters;

  final String currentUsername;

  bool isPublic = true; // true = public, false = private/friends only
  bool isFriends = true;
  bool isSubmitting = false;

  XFile? selectedImage;

  final PostApi _postApi;
  final ImagePicker _picker = ImagePicker();

  CreatePostController({
    required this.currentUsername,
    required String baseUrl,
    this.maxCharacters = 280,
  }) : _postApi = PostApi(baseUrl: baseUrl) {
    contentController.addListener(_onContentChanged);
  }

  int _characterCount = 0;
  int get characterCount => _characterCount;

  void _onContentChanged() {
    _characterCount = contentController.text.length;
    notifyListeners();
  }

  void disposeController() {
    contentController.removeListener(_onContentChanged);
    contentController.dispose();
  }

  void togglePrivacy() {
    if (isPublic) {
      isPublic = false;
      isFriends = true; // friends only
    } else if (isFriends) {
      isFriends = false; // only me
    } else {
      isPublic = true;
      isFriends = true;
    }
    notifyListeners();
  }

  Future<void> pickImage() async {
    try {
      final XFile? picked = await _picker.pickImage(
          source: ImageSource.gallery, imageQuality: 80);
      if (picked != null) {
        selectedImage = picked;
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  void clearImage() {
    selectedImage = null;
    notifyListeners();
  }

  void clearPost() {
    contentController.clear();
    selectedImage = null;
    _characterCount = 0;
    notifyListeners();
  }

  bool get canPost {
    final text = contentController.text.trim();
    return text.isNotEmpty && text.length <= maxCharacters && !isSubmitting;
  }

  Future<PostResponse> submit() async {
    final content = contentController.text.trim();

    if (content.isEmpty && selectedImage == null) {
      throw Exception('Nội dung hoặc hình ảnh phải có ít nhất một trong hai.');
    }

    if (content.length > maxCharacters) {
      throw Exception('Nội dung vượt quá $maxCharacters ký tự.');
    }

    if (isSubmitting) {
      throw Exception('Đang gửi, vui lòng chờ.');
    }

    isSubmitting = true;
    notifyListeners();

    try {
      String? imageUrl;

      if (selectedImage != null) {
        final client = Supabase.instance.client;
        final bytes = await selectedImage!.readAsBytes();
        final fileName =
            'posts/${DateTime.now().millisecondsSinceEpoch}_${selectedImage!.name}';

        await client.storage.from('post-images').uploadBinary(
              fileName,
              bytes,
              fileOptions: const FileOptions(
                contentType: 'image/jpeg',
              ),
            );

        imageUrl = client.storage.from('post-images').getPublicUrl(fileName);
      }

      final request = PostCreateRequest(
        content: content,
        imageUrl: imageUrl,
        visibility: isPublic ? 'public' : 'private',
      );

      final createdPost = await _postApi.createPost(request);

      // reset form
      clearPost();
      isSubmitting = false;
      notifyListeners();

      return createdPost;
    } catch (e) {
      isSubmitting = false;
      notifyListeners();
      rethrow;
    }
  }
}
