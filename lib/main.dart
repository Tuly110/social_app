import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:oktoast/oktoast.dart';
import 'package:social_app/src/common/utils/app_environment.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'src/common/utils/getit_utils.dart';
import 'src/core/data/remote/firebase/firebase_service.dart';
import 'src/modules/app/app_widget.dart';

// THÊM BACKGROUND HANDLER - phải có để background notification hoạt động
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("📱 [BACKGROUND] Notification received: ${message.messageId}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
    // 1. Load env
    await dotenv.load(fileName: "env/.env.dev");

    // 2. Config EasyLoading TRƯỚC
    configLoading();

    // 3. Khởi tạo Firebase (nhanh)
    await Firebase.initializeApp();
    
    // 4. Setup background handler (phải làm trước khi khởi tạo service)
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 5. Init Supabase
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    );

    // 6. Setup dependency injection
    await GetItUtils.setup();

    // 7. RUN APP TRƯỚC - không chờ FirebaseService
    runApp(
      OKToast(
        child: const AppWidget(),
      ),
    );

    // 8. KHỞI TẠO FIREBASE SERVICE SAU KHI APP ĐÃ CHẠY (background)
    _initializeFirebaseServiceAsync();

  } catch (e, stackTrace) {
    print('❌ Error during initialization: $e');
    print('Stack trace: $stackTrace');
    
    // Vẫn chạy app dù có lỗi Firebase
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('App starting... (Firebase init may be delayed)'),
          ),
        ),
      ),
    );
  }
}

// Hàm khởi tạo FirebaseService trong background
void _initializeFirebaseServiceAsync() {
  Future.delayed(const Duration(milliseconds: 500), () async {
    try {
      final firebaseService = getIt<FirebaseService>();
      print('🚀 Starting FirebaseService initialization in background...');
      
      // Khởi tạo với timeout
      await firebaseService.initialize().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('⚠️ FirebaseService init timeout (continuing anyway)');
          return null;
        },
      ).catchError((e) {
        print('⚠️ FirebaseService init error (non-critical): $e');
      });
      
      print('✅ FirebaseService background initialization completed');
    } catch (e) {
      print('⚠️ Failed to initialize FirebaseService: $e');
    }
  });
}

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2500)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.custom
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = Colors.white
    ..backgroundColor = Colors.black
    ..indicatorColor = Colors.white
    ..textColor = Colors.white
    ..userInteractions = false
    ..maskType = EasyLoadingMaskType.black
    ..dismissOnTap = true;
}
