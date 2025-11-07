import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:social_app/src/modules/auth/presentation/cubit/auth_cubit.dart';

import '../../app/app_router.dart';

@RoutePage()
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(30.w),
          child: Column(
            children: [
              Text("home"),
              GestureDetector(
                child: Text("sign out"),
                onTap: ()async{
                  await context.read<AuthCubit>().signOut();
                  Future.delayed(const Duration(seconds: 2),(){
                    context.router.replaceAll([const LoginRoute()]);
                  });
                },
              )
            ],
          )
        );
  }
}