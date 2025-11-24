import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'profile_api_models.dart';

class ProfileApi {
  final String baseUrl;
  final SupabaseClient _supabase;

  ProfileApi({
    required this.baseUrl,
    SupabaseClient? supabase,
  }) : _supabase = supabase ?? Supabase.instance.client;

  Future<String> _getTokenOrThrow() async {
    final session = _supabase.auth.currentSession;
    final token = session?.accessToken;
    if (token == null || token.isEmpty) {
      throw Exception('No access token found – user not logged in?');
    }
    return token;
  }

  Future<Map<String, String>> _buildHeaders() async {
    final token = await _getTokenOrThrow();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ========= PROFILE =========

  /// GET /profile/me
  Future<ProfileModel> getMyProfile() async {
    final headers = await _buildHeaders();
    final uri = Uri.parse('$baseUrl/profile/me');

    final res = await http.get(uri, headers: headers);
    if (res.statusCode != 200) {
      throw Exception(
          'Failed to get my profile: ${res.statusCode} ${res.body}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return ProfileModel.fromJson(data);
  }

  /// GET /profile/{user_id}
  Future<ProfileModel> getUserProfile(String userId) async {
    final headers = await _buildHeaders();
    final uri = Uri.parse('$baseUrl/profile/$userId');

    final res = await http.get(uri, headers: headers);
    if (res.statusCode != 200) {
      throw Exception(
          'Failed to get user profile: ${res.statusCode} ${res.body}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return ProfileModel.fromJson(data);
  }

  /// PUT /profile/
  Future<ProfileModel> updateMyProfile(ProfileUpdateRequest request) async {
    final headers = await _buildHeaders();
    final uri = Uri.parse('$baseUrl/profile/');

    final res = await http.put(
      uri,
      headers: headers,
      body: jsonEncode(request.toJson()),
    );

    if (res.statusCode != 200) {
      throw Exception(
          'Failed to update profile: ${res.statusCode} ${res.body}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return ProfileModel.fromJson(data);
  }

  // ========= FOLLOW / UNFOLLOW =========

  /// POST /users/{user_id}/follow
  Future<void> followUser(String userId) async {
    final headers = await _buildHeaders();
    final uri = Uri.parse('$baseUrl/users/$userId/follow');

    final res = await http.post(uri, headers: headers);
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Failed to follow user: ${res.statusCode} ${res.body}');
    }
  }

  /// DELETE /users/{user_id}/follow
  Future<void> unfollowUser(String userId) async {
    final headers = await _buildHeaders();
    final uri = Uri.parse('$baseUrl/users/$userId/follow');

    final res = await http.delete(uri, headers: headers);
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Failed to unfollow user: ${res.statusCode} ${res.body}');
    }
  }

  // ========= FOLLOWERS / FOLLOWING LIST =========
  // Vì backend không khai báo response_model nên mình
  // xử lý linh hoạt: có thể là List hoặc dạng { "items": [...] }

  Future<List<ProfileModel>> getFollowers(
    String userId, {
    int page = 0,
    int limit = 20,
  }) async {
    final headers = await _buildHeaders();
    final uri = Uri.parse(
      '$baseUrl/users/$userId/followers?page=$page&limit=$limit',
    );

    final res = await http.get(uri, headers: headers);
    if (res.statusCode != 200) {
      throw Exception('Failed to get followers: ${res.statusCode} ${res.body}');
    }

    final body = jsonDecode(res.body);

    if (body is! Map || body['follows'] is! List) {
      throw Exception('Unexpected followers response format: ${res.body}');
    }

    final List<dynamic> list = body['follows'];

    return list.map((item) {
      return ProfileModel(
        id: item['follower_id'] ?? '',
        username: item['follower_username'] ?? '',
        email: '',
        avatarUrl: item['follower_avatar'],
        followerCount: 0,
        followingCount: 0,
        postCount: 0,
      );
    }).toList();
  }

  Future<List<ProfileModel>> getFollowing(
    String userId, {
    int page = 0,
    int limit = 20,
  }) async {
    final headers = await _buildHeaders();
    final uri = Uri.parse(
      '$baseUrl/users/$userId/following?page=$page&limit=$limit',
    );

    final res = await http.get(uri, headers: headers);
    if (res.statusCode != 200) {
      throw Exception('Failed to get following: ${res.statusCode} ${res.body}');
    }

    final body = jsonDecode(res.body);

    if (body is! Map || body['follows'] is! List) {
      throw Exception('Unexpected following response format: ${res.body}');
    }

    final List<dynamic> list = body['follows'];

    return list.map((item) {
      return ProfileModel(
        id: item['following_id'] ?? '',
        username: item['following_username'] ?? '',
        email: '',
        avatarUrl: item['following_avatar'],
        followerCount: 0,
        followingCount: 0,
        postCount: 0,
      );
    }).toList();
  }
}
