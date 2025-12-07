import 'package:dio/dio.dart';
import '../models/notice_model.dart';

abstract class NoticeRemoteDataSource {
  Future<List<NoticeModel>> getNotifications();
  Future<int> getUnreadCount();
  Future<bool> markAsRead(String id);
  Future<bool> markAllAsRead();
  Future<bool> deleteNotification(String id);
}

class NoticeRemoteDataSourceImpl implements NoticeRemoteDataSource {
  final Dio _dio; 

  NoticeRemoteDataSourceImpl(this._dio);

  @override
  Future<List<NoticeModel>> getNotifications() async {
    try {
      final response = await _dio.get('/notifications/');
      
      if (response.statusCode == 200) {
        final data = response.data;
        List<dynamic> list = [];
        if (data is List) {
          list = data;
        } else if (data is Map && data['data'] is List) {
          list = data['data'];
        }

        return list.map((e) => NoticeModel.fromJson(e)).toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        );
      }
    } catch (e) {
      rethrow; 
    }
  }

  @override
  Future<int> getUnreadCount() async {
    final response = await _dio.get('/notifications/unread/count');
    if (response.data is Map && response.data.containsKey('count')) {
      return int.parse(response.data['count'].toString());
    }
    return 0;
  }

  @override
  Future<bool> markAsRead(String id) async {
    await _dio.patch('/notifications/$id/read');
    return true;
  }

  @override
  Future<bool> markAllAsRead() async {
    await _dio.patch('/notifications/read/all');
    return true;
  }

  @override
  Future<bool> deleteNotification(String id) async {
    await _dio.delete('/notifications/$id');
    return true;
  }
}