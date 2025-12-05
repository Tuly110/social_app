// lib/src/modules/newpost/data/datasources/post_remote_datasource_impl.dart
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/post_entity.dart';
import '../models/post_model.dart';
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
  Future<List<PostEntity>> getFeed({int page = 0, int limit = 20}) async {
    // page param giờ không dùng nữa, luôn load từ page=0 đến hết
    print('>>> [DS] getFeed (FULL) called, limit=$limit');

    final headers = _authHeaders();
    print('>>> [DS] getFeed headers=$headers');

    final List<PostEntity> allPosts = [];
    int currentPage = 0;
    bool hasNext = true;

    try {
      while (hasNext) {
        print('>>> [DS] fetching page=$currentPage, limit=$limit');

        final response = await _dio.get(
          '/posts/',
          queryParameters: {
            'page': currentPage,
            'limit': limit,
          },
          options: Options(headers: headers),
        );

        print('>>> [DS] GET /posts status=${response.statusCode}');
        print('>>> [DS] GET /posts data=${response.data}');

        final data = response.data;

        List<dynamic> items = [];
        bool next = false;

        if (data is Map<String, dynamic>) {
          // backend dạng: { posts: [...], has_next: true/false, ... }
          items = (data['posts'] as List<dynamic>? ?? []);
          next = data['has_next'] == true;
        } else if (data is List<dynamic>) {
          // fallback: backend trả thẳng List
          items = data;
          next = false;
        } else {
          throw Exception('Unexpected feed response: ${data.runtimeType}');
        }

        if (items.isEmpty) {
          // không còn gì nữa → dừng luôn
          break;
        }

        allPosts.addAll(
          items
              .map(
                (e) => PostModel.fromJson(e as Map<String, dynamic>).toEntity(),
              )
              .toList(),
        );

        if (!next) {
          // has_next = false → hết trang
          break;
        }

        currentPage++;
      }

      print('>>> [DS] total posts loaded = ${allPosts.length}');
      return allPosts;
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

    try {
      final res = await _dio.post(
        '/posts/',
        data: payload,
        options: Options(
          headers: _authHeaders(),
          responseType: ResponseType.plain, 
        ),
      );

      print('>>> [PostRemoteDS] HTTP Status: ${res.statusCode}');
      print('>>> [PostRemoteDS] Raw Response: ${res.data}');
      dynamic parsedData;
      
      if (res.data is String) {
        try {
          parsedData = jsonDecode(res.data as String);
        } catch (e) {
          throw Exception('Invalid JSON response from server');
        }
      } else {
        parsedData = res.data;
      }

      if (parsedData is! Map<String, dynamic>) {
        throw Exception('Invalid response format from server');
      }


      if (parsedData['success'] == false) {
        final errorMessage = parsedData['error'] as String? ?? 
                            parsedData['message'] as String? ?? 
                            'Failed to create post';
        throw Exception(errorMessage);
      }
      if (parsedData.containsKey('post') && 
          parsedData['post'] is Map<String, dynamic>) {
        
        final postJson = parsedData['post'] as Map<String, dynamic>;
        return PostModel.fromJson(postJson).toEntity();
        
      } else if (parsedData.containsKey('id')) {
        // Direct post object
        return PostModel.fromJson(parsedData).toEntity();
      } else {
        throw Exception('Unexpected response format: $parsedData');
      }
      
    } on DioException catch (e) {

      if (e.response?.data != null) {
        if (e.response!.data is Map<String, dynamic>) {
          final errorData = e.response!.data as Map<String, dynamic>;
          final errorMessage = errorData['error'] as String? ?? 
                              errorData['message'] as String? ?? 
                              'Failed to create post';
          throw Exception(errorMessage);
        } else if (e.response!.data is String) {
          try {
            final parsed = jsonDecode(e.response!.data as String);
            if (parsed is Map<String, dynamic>) {
              final errorMessage = parsed['error'] as String? ?? 
                                  parsed['message'] as String? ?? 
                                  'Failed to create post';
              throw Exception(errorMessage);
            }
          } catch (_) {
            // Ignore parse error
          }
        }
      }
      
      throw Exception(e.message ?? 'Network error occurred');
    } catch (e) {
      rethrow;
    }
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
  Future<bool> getLikeStatus(String postId) async {
    print('>>> [DS] getLikeStatus called with postId=$postId');

    try {
      final response = await _dio.get(
        '/likes/status/$postId',
        options: Options(headers: _authHeaders()),
      );

      print('>>> [DS] GET /likes/status status=${response.statusCode}');
      print('>>> [DS] response.data=${response.data}');

      return response.data as bool;
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
