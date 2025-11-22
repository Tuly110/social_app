import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:oktoast/oktoast.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'src/common/utils/getit_utils.dart';
import 'src/modules/app/app_widget.dart'; // dùng router của bạn

const SUPABASE_URL = "https://miagiyhyjpibwljojfbk.supabase.co" ;
const SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1pYWdpeWh5anBpYndsam9qZmJrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE1NzI2OTQsImV4cCI6MjA3NzE0ODY5NH0.QhfFq2EPuGjk730X7QJi2PR12HOKB42oA7XkC8FIIdo" ;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configLoading();
  await GetItUtils.setup();
  await Supabase.initialize(
      url: SUPABASE_URL,
      anonKey: SUPABASE_ANON_KEY,
  );

  runApp(OKToast( 
    child: const AppWidget(),
  ));
  configLoading();
  

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
