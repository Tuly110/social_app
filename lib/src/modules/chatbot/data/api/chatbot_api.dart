import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'dart:io';
import '../models/chatbot_message_model.dart';

class ChatbotCreatePostResult {
  final String caption;
  final String postId;

  ChatbotCreatePostResult({
    required this.caption,
    required this.postId,
  });
}

@lazySingleton
class ChatbotApi {
  final Dio _dio;
  ChatbotApi(this._dio);

  Future<String> sendMessage({
    required String message,
    required List<ChatbotMessageModel> history,
  }) async {
    final historyPayload = history.map((m) {
      return {
        'role': m.isUser ? 'user' : 'assistant',
        'content': m.text,
      };
    }).toList();

    final response = await _dio.post(
      '/chatbot/message',
      data: {
        'message': message,
        'history': historyPayload,
      },
    );

    return response.data['reply'] as String;
  }

  // 🔥 API MỚI: AI viết caption + tự đăng post
  Future<ChatbotCreatePostResult> createPostWithAI({
    required String prompt,
    String visibility = 'public',
  }) async {
    final res = await _dio.post(
      '/chatbot/create-post',
      data: {
        'prompt': prompt,
        'visibility': visibility,
        // image_url: hiện tại chưa hỗ trợ, để null
      },
    );

    final data = res.data as Map<String, dynamic>;
    final caption = data['caption'] as String;
    final post = data['post'] as Map<String, dynamic>;
    final postId = post['id'].toString();

    return ChatbotCreatePostResult(
      caption: caption,
      postId: postId,
    );
  }

  Future<String> stylizeImageToChibi({
    required File imageFile,
  }) async {
    final fileName = imageFile.path.split('/').last;

    final formData = FormData.fromMap({
      'style': 'chibi',
      'image': await MultipartFile.fromFile(
        imageFile.path,
        filename: fileName,
      ),
    });

    final res = await _dio.post(
      '/chatbot/image-style',
      data: formData,
    );

    final data = res.data as Map<String, dynamic>;
    return data['image_url'] as String;
  }

  Future<void> runScheduledPosts() async {
    await _dio.post('/chatbot/run-scheduled-posts');
  }
}
