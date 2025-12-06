import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../datasource/fcm_remote_data_source.dart';

@lazySingleton
class FirebaseService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FCMRemoteDataSource _fcmDataSource;
  final SupabaseClient _supabase;
  
  // Thêm local notifications plugin
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  FirebaseService(this._fcmDataSource, this._supabase);

  Future<void> initialize() async {
    print(' Initializing FirebaseService');
    
    try {
      // Request permission
      await _requestPermission();
      
      // Setup local notifications (cho foreground)
      await _setupLocalNotifications();
      
      // Get and save token nếu đã login
      await _handleFCMToken();
      
      // Setup notification handlers
      _setupNotificationHandlers();
      
      // Listen for token refresh
      _setupTokenRefreshListener();
      
      print('FirebaseService initialized successfully');
    } catch (e) {
      print('FirebaseService initialization error: $e');
    }
  }

  Future<void> _requestPermission() async {
    try {
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false, // Yêu cầu permission 
      );
      
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('Notification permission granted');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        print('Provisional notification permission granted');
      } else {
        print('Notification permission denied: ${settings.authorizationStatus}');
      }
    } catch (e) {
      print('Error requesting permission: $e');
    }
  }

  Future<void> _setupLocalNotifications() async {
    try {
      // Cấu hình cho Android
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      
      // Cấu hình cho iOS
      // const iosSettings = DarwinInitializationSettings(
      //   requestAlertPermission: true,
      //   requestBadgePermission: true,
      //   requestSoundPermission: true,
      // );
      
      await _localNotificationsPlugin.initialize(
        const InitializationSettings(
          android: androidSettings,
          // iOS: iosSettings,
        ),
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          // Xử lý khi nhấn vào local notification
          print('Local notification tapped: ${response.payload}');
          if (response.payload != null) {
            _handleNotificationPayload(response.payload!);
          }
        },
      );
      
      print('Local notifications setup completed');
    } catch (e) {
      print('Error setting up local notifications: $e');
    }
  }

  Future<void> _handleFCMToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        print('FCM Token: $token');
        
        // Save nếu user đã login
        final user = _supabase.auth.currentUser;
        if (user != null) {
          print('User is logged in, saving token...');
          await _fcmDataSource.saveFCMToken(token);
        } else {
          print('User not logged in, token not saved');
        }
      } else {
        print('No FCM token available');
      }
    } catch (e) {
      print('Error handling FCM token: $e');
    }
  }

  void _setupNotificationHandlers() {
    print('Setting up notification handlers...');
    
    // Khi app đang mở
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('FOREGROUND notification received:');
      print('   Title: ${message.notification?.title}');
      print('   Body: ${message.notification?.body}');
      print('   Data: ${message.data}');
      
      // Hiển thị local notification khi app ở foreground
      _showLocalNotification(
        title: message.notification?.title ?? 'New Notification',
        body: message.notification?.body ?? '',
        data: message.data,
      );
    });

    // Khi app đang chạy ngầm
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print(' App opened from BACKGROUND notification');
      print('   Data: ${message.data}');
      
      // Xử lý navigation
      _handleNotificationData(message.data);
    });

    // Khi app bị đóng hoàn toàn
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print('App launched from TERMINATED state by notification');
        print('   Data: ${message.data}');
        
        // Xử lý navigation khi app khởi động từ notification
        _handleNotificationData(message.data);
      }
    });
    
    print('Notification handlers setup completed');
  }

  void _setupTokenRefreshListener() {
    // Lắng nghe khi token được refresh
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      print('FCM token refreshed: $newToken');
      _handleTokenRefresh(newToken);
    });
  }

  Future<void> _handleTokenRefresh(String newToken) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        print('Saving refreshed token for user: ${user.id}');
        await _fcmDataSource.saveFCMToken(newToken);
        print(' Refreshed token saved');
      }
    } catch (e) {
      print('Error saving refreshed token: $e');
    }
  }

  Future<void> _showLocalNotification({
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'high_importance_channel', 
        'High Importance Notifications',
        channelDescription: 'This channel is used for important notifications.',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
      );
      
      const notificationDetails = NotificationDetails(
        android: androidDetails,
        // iOS: DarwinNotificationDetails(
        //   presentAlert: true,
        //   presentBadge: true,
        //   presentSound: true,
        // ),
      );
      
      await _localNotificationsPlugin.show(
        0, // Notification ID
        title,
        body,
        notificationDetails,
        payload: jsonEncode(data), // Chuyển data thành string để lưu payload
      );
      
      print('Local notification shown: $title');
    } catch (e) {
      print('Error showing local notification: $e');
    }
  }

  void _handleNotificationData(Map<String, dynamic> data) {
    print('Handling notification data: $data');
    
    final type = data['type'];
    
    // Xử lý navigation dựa trên notification type
    switch (type) {
      case 'new_post':
        final postId = data['post_id'];
        print('Should navigate to post: $postId');
        // TODO: Implement navigation
        break;
      case 'new_comment':
        final postId = data['post_id'];
        final commentId = data['comment_id'];
        print(' Should navigate to post $postId, comment $commentId');
        break;
      case 'new_like':
        final postId = data['post_id'];
        print('Should navigate to post: $postId');
        break;
      case 'new_follower':
        final followerId = data['follower_id'];
        print(' Should navigate to profile: $followerId');
        break;
      case 'test':
        print(' Test notification received!');
        break;
      default:
        print(' Unknown notification type: $type');
    }
    
    // TODO: Trigger navigation trong app
    // Ví dụ: getIt<AppRouter>().push('/post/$postId');
  }

  void _handleNotificationPayload(String payload) {
    try {
      print('📦 Parsing notification payload: $payload');
      final data = jsonDecode(payload) as Map<String, dynamic>;
      _handleNotificationData(data);
    } catch (e) {
      print(' Error parsing notification payload: $e');
    }
  }

  Future<void> saveTokenOnLogin() async {
    try {
      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        await _fcmDataSource.saveFCMToken(token);

      }
    } catch (e) {
      print(' Error saving token on login (non-critical): $e');
      // Không rethrow để không ảnh hưởng đến login flow
    }
  }

  Future<void> deleteTokenOnLogout() async {
    try {
      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        await _fcmDataSource.deleteFCMToken(token);
      }
    } catch (e) {
      print('Error deleting token on logout (non-critical): $e');
      // Không rethrow để logout vẫn tiếp tục
    }
  }
  
  // Optional: Subscribe/unsubscribe to topics
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
    } catch (e) {
      print('Error subscribing to topic $topic: $e');
    }
  }
  
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
    } catch (e) {
      print(' Error unsubscribing from topic $topic: $e');
    }
  }
}