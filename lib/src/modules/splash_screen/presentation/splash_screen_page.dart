import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../generated/assets.gen.dart';
import '../../../../generated/colors.gen.dart';
import '../../../common/utils/getit_utils.dart';
import '../../app/app_router.dart';

@RoutePage()
class SplashScreenPage extends StatefulWidget {
  const SplashScreenPage({super.key});

  @override
  State<SplashScreenPage> createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage> {
  final _router = getIt<AppRouter>();

  @override
  void initState() {
    super.initState();
    navigateHome();
  }
  void navigateHome() async {
    await Future.delayed(const Duration(seconds: 3));
    _router.replaceAll([const LoginRoute()]);
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColorName.background,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          
        children: [
          Center(
            child: Assets.authImages.splash.image(
              width: 250.w,
              height: 250.h,
            ),
          ),
          Center(
            child: Text(
              'City Life',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: ColorName.textSplash,
                fontWeight: FontWeight.bold,fontSize: 35.sp,
                fontFamily: 'Asimovian'
              ),
            ),
          ),
        ],
      ),
      )
    );
  }
}