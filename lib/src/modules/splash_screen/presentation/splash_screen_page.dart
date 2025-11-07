import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../generated/assets.gen.dart';
import '../../../../generated/colors.gen.dart';
import '../../app/app_router.dart';
import '../../auth/presentation/cubit/auth_cubit.dart';
import '../../auth/presentation/cubit/auth_state.dart';

@RoutePage()
class SplashScreenPage extends StatefulWidget {
  const SplashScreenPage({super.key});

  @override
  State<SplashScreenPage> createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage> {


  @override
  void initState() {
    super.initState();
    navigateHome();
  }
  void navigateHome() async {
    await Future.delayed(const Duration(seconds: 3));
    
if (!mounted) return;
    final supabase = context.read<AuthCubit>().supabaseClient;
    final currentSession = supabase.auth.currentSession;

    // Nếu user đang trong flow reset password (có access token đặc biệt)
    if (currentSession?.user != null &&
        currentSession?.user.email != null &&
        currentSession!.user.emailConfirmedAt == null) {
      // Chuyển sang trang cập nhật mật khẩu
      if (!mounted) return;
      context.router.replace(const UpdatePasswordRoute());
      return;
    }

    // Nếu user đã login
    if (currentSession?.user != null) {
      if (!mounted) return;
      context.router.replace(const HomeRoute());
      return;
    }

    // Mặc định quay lại trang login
    if (!mounted) return;
    context.router.replace(const LoginRoute());
  
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorName.background,
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          state.maybeWhen(
            authenticated: (_) {
              context.router.replace(const HomeRoute());
            },
            unauthenticated: (_, __, ___, ____, _____) {
              context.router.replace(const LoginRoute());
            },
            passwordRecovery: () {
              // ✅ Khi Supabase phát hiện user click link reset password
              context.router.replace(const UpdatePasswordRoute());
            },
            orElse: () {},
          );
        },
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
      )
    );
    
  }
}