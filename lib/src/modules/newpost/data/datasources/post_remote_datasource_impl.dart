// lib/src/modules/newpost/data/datasources/post_remote_datasource_impl.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/post_entity.dart';
import '../models/post_model.dart';
import '../models/like_status_model.dart';
import 'post_remote_datasource.dart';

@LazySingleton(as: PostRemoteDataSource)
class PostRemoteDataSourceImpl implements PostRemoteDataSource {
  final Dio _dio;
  final SupabaseClient _supabase;

  PostRemoteDataSourceImpl(this._dio, this._supabase);

  Map<String, String> _authHeaders() {
    final token = _supabase.auth.currentSession?.accessToken;
    print('>>> [DS] current token = $token');

    if (token == null) {
      print('>>> [DS] ERROR: No Supabase session found!');
      throw Exception('Not authenticated');
    }

    return {
      'Authorization': 'Bearer $token',
      'accept': 'application/json',
      'content-type': 'application/json',
    };
  }

  @override
  Future<List<PostEntity>> getFeed({int page = 0, int limit = 10}) async {
    print('>>> [DS] getFeed called: page=$page, limit=$limit');

    try {
      final headers = _authHeaders();
      print('>>> [DS] getFeed headers=$headers');

      final response = await _dio.get(
        '/posts/',
        queryParameters: {'page': page, 'limit': limit},
        options: Options(headers: headers),
      );

      print('>>> [DS] GET /posts status=${response.statusCode}');
      print('>>> [DS] GET /posts data=${response.data}');

      final data = response.data;

      final List<dynamic> items;
      if (data is Map<String, dynamic> && data['posts'] is List<dynamic>) {
        items = data['posts'] as List<dynamic>;
      } else if (data is List<dynamic>) {
        items = data;
      } else {
        throw Exception('Unexpected feed response: ${data.runtimeType}');
      }

      return items
          .map((e) => PostModel.fromJson(e as Map<String, dynamic>).toEntity())
          .toList();
    } on DioException catch (e) {
      print('>>> [DS] getFeed DioException status=${e.response?.statusCode}');
      print('>>> [DS] getFeed response data=${e.response?.data}');
      print('>>> [DS] getFeed message=${e.message}');
      rethrow;
    } catch (e, st) {
      print('>>> [DS] getFeed OTHER ERROR: $e');
      print(st);
      rethrow;
    }
  }

  @override
  @override
  Future<PostEntity> createPost(
    String content, {
    String? imageUrl,
    required String visibility,
  }) async {
    final payload = <String, dynamic>{
      'content': content,
      if (imageUrl != null) 'image_url': imageUrl,
      'visibility': visibility,
    };

    print('>>> [PostRemoteDS] payload=$payload');

    final res = await _dio.post(
      '/posts/',
      data: payload,
    );

    print('>>> [PostRemoteDS] response=${res.data}');

    return PostEntity.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<PostEntity> toggleLike(String postId) async {
    print('>>> [DS] toggleLike called with postId=$postId');

    final response = await _dio.post(
      '/likes/toggle/$postId',
      options: Options(headers: _authHeaders()),
    );

    print('>>> [DS] POST /likes/toggle status=${response.statusCode}');
    print('>>> [DS] response.data=${response.data}');

    return _parsePostFromResponse(response.data);
  }

  // 🔹 UPDATE POST (PUT /posts/{post_id})
  @override
  Future<PostEntity> updatePost(
    String postId, {
    String? content,
    String? imageUrl,
  }) async {
    final Map<String, dynamic> body = {};
    if (content != null) body['content'] = content;
    if (imageUrl != null) body['image_url'] = imageUrl;

    print('>>> [DS] updatePost id=$postId body=$body');

    try {
      final response = await _dio.put(
        '/posts/$postId',
        data: {
          "content": content,
          "image_url": imageUrl,
        },
        options: Options(headers: _authHeaders()),
      );

      print('>>> [DS] PUT /posts/$postId status=${response.statusCode}');
      print('>>> [DS] data=${response.data}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
          'updatePost failed: status=${response.statusCode}, data=${response.data}',
        );
      }

      return _parsePostFromResponse(response.data);
    } on DioException catch (e) {
      print(
          '>>> [DS] DioException (updatePost) status=${e.response?.statusCode}');
      print('>>> [DS] DioException data=${e.response?.data}');
      print('>>> [DS] DioException message=${e.message}');
      rethrow;
    } catch (e, st) {
      print('>>> [DS] OTHER ERROR (updatePost): $e');
      print(st);
      rethrow;
    }
  }

  // 🔹 DELETE POST (DELETE /posts/{post_id})
  @override
  Future<void> deletePost(String postId) async {
    print('>>> [DS] deletePost id=$postId');

    try {
      final response = await _dio.delete(
        '/posts/$postId',
        options: Options(headers: _authHeaders()),
      );

      print('>>> [DS] DELETE /posts/$postId status=${response.statusCode}');
      print('>>> [DS] data=${response.data}');

      if (response.statusCode != 200 &&
          response.statusCode != 202 &&
          response.statusCode != 204) {
        throw Exception(
          'deletePost failed: status=${response.statusCode}, data=${response.data}',
        );
      }
    } on DioException catch (e) {
      print(
          '>>> [DS] DioException (deletePost) status=${e.response?.statusCode}');
      print('>>> [DS] DioException data=${e.response?.data}');
      print('>>> [DS] DioException message=${e.message}');
      rethrow;
    } catch (e, st) {
      print('>>> [DS] OTHER ERROR (deletePost): $e');
      print(st);
      rethrow;
    }
  }

@override
  Future<LikeStatusModel> getLikeStatus(String postId) async {
    print('>>> [DS] getLikeStatus called with postId=$postId');

    try {
      final response = await _dio.get(
        '/likes/status/$postId',
        options: Options(headers: _authHeaders()),
      );

      print('>>> [DS] GET /likes/status status=${response.statusCode}');
      print('>>> [DS] response.data=${response.data}');

      return LikeStatusModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      print('>>> [DS] getLikeStatus DioException status=${e.response?.statusCode}');
      print('>>> [DS] getLikeStatus response data=${e.response?.data}');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getDailyLimits() async {
    print('>>> [DS] getDailyLimits called');

    try {
      final response = await _dio.get(
        '/likes/daily-limits/me',
        options: Options(headers: _authHeaders()),
      );

      print('>>> [DS] GET /likes/daily-limits status=${response.statusCode}');
      print('>>> [DS] response.data=${response.data}');

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      print('>>> [DS] getDailyLimits DioException status=${e.response?.statusCode}');
      print('>>> [DS] getDailyLimits response data=${e.response?.data}');
      rethrow;
    }
  }

  @override
  Future<int> getLikeCount(String postId) async {
    print('>>> [DS] getLikeCount called with postId=$postId');

    try {
      final response = await _dio.get(
        '/likes/count/$postId',
        options: Options(headers: _authHeaders()),
      );

      print('>>> [DS] GET /likes/count status=${response.statusCode}');
      print('>>> [DS] response.data=${response.data}');

      final data = response.data as Map<String, dynamic>;
      return data['count'] as int;
    } on DioException catch (e) {
      print('>>> [DS] getLikeCount DioException status=${e.response?.statusCode}');
      print('>>> [DS] getLikeCount response data=${e.response?.data}');
      rethrow;
    }
  }

  @override
  Future<List<String>> getPostLikes(String postId) async {
    print('>>> [DS] getPostLikes called with postId=$postId');

    try {
      final response = await _dio.get(
        '/likes/post/$postId',
        options: Options(headers: _authHeaders()),
      );

      print('>>> [DS] GET /likes/post status=${response.statusCode}');
      print('>>> [DS] response.data=${response.data}');

      final data = response.data as Map<String, dynamic>;
      final List<dynamic> users = data['users'] as List<dynamic>;
      return users.map((user) => user['user_id'] as String).toList();
    } on DioException catch (e) {
      print('>>> [DS] getPostLikes DioException status=${e.response?.statusCode}');
      print('>>> [DS] getPostLikes response data=${e.response?.data}');
      rethrow;
    }
  }

  @override
  Future<List<String>> getUserLikes() async {
    print('>>> [DS] getUserLikes called');

    try {
      final response = await _dio.get(
        '/likes/user/me/likes',
        options: Options(headers: _authHeaders()),
      );

      print('>>> [DS] GET /likes/user/me/likes status=${response.statusCode}');
      print('>>> [DS] response.data=${response.data}');

      final data = response.data as Map<String, dynamic>;
      final List<dynamic> posts = data['posts'] as List<dynamic>;
      return posts.map((post) => post['post_id'] as String).toList();
    } on DioException catch (e) {
      print('>>> [DS] getUserLikes DioException status=${e.response?.statusCode}');
      print('>>> [DS] getUserLikes response data=${e.response?.data}');
      rethrow;
    }
  }

  // 🔧 Helper parse PostResponse từ backend (có thể là {post: {...}} hoặc {...})
  PostEntity _parsePostFromResponse(dynamic raw) {
    late final Map<String, dynamic> json;

    if (raw is Map<String, dynamic>) {
      if (raw['post'] is Map<String, dynamic>) {
        json = raw['post'] as Map<String, dynamic>;
      } else {
        json = raw;
      }
    } else {
      throw Exception('Unexpected post response: ${raw.runtimeType}');
    }

    print('>>> [DS] Parsed Post JSON = $json');
    return PostModel.fromJson(json).toEntity();
  }
}
