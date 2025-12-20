import 'package:dio/dio.dart';
import '../base/api_error.dart';

class ErrorInterceptor extends InterceptorsWrapper {
  bool isRefreshing = false;
  bool isShowingExpireTokenDialog = false;

  int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    final s = v.toString();
    return int.tryParse(s);
  }

  String _extractMessage(dynamic data) {
    if (data == null) return '';
    if (data is Map) {
      final v = data['message'] ?? data['detail'] ?? data['error'];
      if (v == null) return data.toString();
      return v.toString();
    }
    return data.toString();
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final data = response.data;

    if (data is Map) {
      final errField = data['error'];

      if (errField != null) {
        if (errField is Map) {
          final int? code = _parseInt(errField['code']);
          final String message =
              (errField['message'] ?? _extractMessage(data)).toString();

          throw ApiError.server(
            code: code,
            message: message,
          );
        } else {
          throw ApiError.server(
            code: null,
            message: errField.toString(),
          );
        }
      }
    }

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      handler.next(err);
      return;
    }

    handler.next(err);
  }
}
