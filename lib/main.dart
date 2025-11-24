import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:oktoast/oktoast.dart';
import 'package:social_app/src/common/utils/app_environment.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'src/common/utils/getit_utils.dart';
import 'src/modules/app/app_widget.dart'; // dùng router của bạn


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: "env/.env.dev");

  configLoading();

  await GetItUtils.setup();

  await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  testApiConnection();
  
  runApp(OKToast( 
    child: const AppWidget(),
  ));
  configLoading();
  

}

void testApiConnection() async {
  final dio = Dio(BaseOptions(baseUrl: AppEnvironment.apiUrl));

  try {
    final response = await dio.get('/health');
    if (response.statusCode == 200) {
      print('✅ API connected successfully: ${response.data}');
    } else {
      print('⚠️ API returned status: ${response.statusCode}');
    }
  } on DioException catch (e) {
    print('❌ API connection failed: ${e.message}');
  } catch (e) {
    print('❌ Unexpected error: $e');
  }
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
