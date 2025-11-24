import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

/// BaseApi: lớp cơ sở dùng chung cho các API client (Post/Comment/User...)
class BaseApi {
  final String baseUrl;
  final http.Client client;

  BaseApi({
    required this.baseUrl,
    http.Client? client,
  }) : client = client ?? http.Client();

  /// Lấy access token của user hiện tại từ Supabase
  String? get accessToken =>
      Supabase.instance.client.auth.currentSession?.accessToken;

  /// Headers cho request có auth
  ///
  /// Nếu chưa đăng nhập -> throw Exception để caller xử lý
  Map<String, String> get authHeaders {
    final token = accessToken;
    if (token == null) {
      throw Exception('User chưa đăng nhập (không có accessToken)');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Build Uri từ path tương đối
  Uri url(String path) => Uri.parse('$baseUrl$path');

  /// Helper parse body JSON nếu cần dùng chung sau này
  dynamic decodeBody(http.Response res) {
    if (res.body.isEmpty) return null;
    return jsonDecode(res.body);
  }
}
