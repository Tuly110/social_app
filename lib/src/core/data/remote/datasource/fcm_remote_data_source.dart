
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class FCMRemoteDataSource {
  final Dio dio;

  FCMRemoteDataSource({required this.dio});

  Future<void> saveFCMToken(String token, {String deviceType = "android"}) async {
    try {
      await dio.post(
        '/fcm/fcm-token',  
        queryParameters: {  
          'token': token,
          'device_type': deviceType,
        },
      );
      print('FCM token saved to backend');
    } on DioException catch (e) {
      print('Error saving FCM token: ${e.response?.data}');
      rethrow;
    }
  }

  Future<void> deleteFCMToken(String token) async {
    try {
      await dio.delete(
        '/fcm/fcm-token',  
        queryParameters: {  
          'token': token,
        },
      );
      print('✅ FCM token deleted from backend');
    } on DioException catch (e) {
      print('Error deleting FCM token: ${e.response?.data}');
      rethrow;
    }
  }
}