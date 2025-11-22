import 'dart:convert';
import 'package:http/http.dart' as http;

import 'base_api.dart';
import '../../../modules/newpost/presentation/models/post_api_models.dart';

class PostApi extends BaseApi {
  PostApi({
    required super.baseUrl,
    http.Client? client,
  }) : super(client: client);

  /// Tạo bài viết mới
  Future<PostResponse> createPost(PostCreateRequest request) async {
    final uri = url('/posts/');

    final body = {
      'content': request.content,
      'image_url': request.imageUrl,
      'visibility': request.visibility,
    };

    final res = await client.post(
      uri,
      headers: authHeaders, // lấy từ BaseApi
      body: jsonEncode(body),
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return PostResponse.fromJson(data);
    } else if (res.statusCode == 401 || res.statusCode == 403) {
      throw Exception('Không có quyền (401/403): ${res.body}');
    } else {
      throw Exception(
        'Tạo post thất bại: ${res.statusCode} - ${res.body}',
      );
    }
  }

  /// Lấy danh sách posts
  Future<List<PostResponse>> getPosts() async {
    final uri = url('/posts/');

    final res = await client.get(uri, headers: authHeaders);

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List<dynamic>;
      return data
          .map((e) => PostResponse.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception(
        'Lấy danh sách post thất bại: ${res.statusCode} - ${res.body}',
      );
    }
  }

  /// Cập nhật post
  Future<PostResponse> updatePost(String id, PostUpdateRequest request) async {
    final uri = url('/posts/$id');

    final res = await client.put(
      uri,
      headers: authHeaders,
      body: jsonEncode(request.toJson()),
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return PostResponse.fromJson(data);
    } else if (res.statusCode == 401 || res.statusCode == 403) {
      throw Exception('Không có quyền (401/403): ${res.body}');
    } else {
      throw Exception(
        'Cập nhật post thất bại: ${res.statusCode} - ${res.body}',
      );
    }
  }

  /// Xoá post
  Future<void> deletePost(String id) async {
    final uri = url('/posts/$id');

    final res = await client.delete(uri, headers: authHeaders);

    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception(
        'Xoá post thất bại: ${res.statusCode} - ${res.body}',
      );
    }
  }
}
