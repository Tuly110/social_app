import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../../../../generated/assets.gen.dart';
import '../../../../../generated/colors.gen.dart';
import '../../../app/app_router.dart';
import '../component/widget_textfield.dart';
@RoutePage()
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(30.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Assets.authImages.login.image(
                  width: 250.w,
                  height: 250.h,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome back",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Sign in to access your account",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    ),
                  ),
                  WidgetTextfield(),
                  Gap(5.h),
                  Align(
                      alignment: Alignment.centerRight,
                      child:  GestureDetector(
                          onTap: () => {

                          },
                          child: Text( "Fogot password?", 
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: ColorName.primary, fontWeight: FontWeight.w600
                          ),
                      ),
                      )

                  ),
                  Gap(45.h),
                  GestureDetector(
                      onTap: () => {

                      },
                      child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 13.h, horizontal: 10.w),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15.r),
                              color:ColorName.background,
                          ),
                          child: Center(
                              child: Text(
                                  "Continue with Google", 
                                  style: Theme.of(context).textTheme.titleSmall
                              ),
                          ),
                      ),
                  ),
                  Gap(15.h),
                  GestureDetector(
                      onTap: () => {

                      },
                      child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 13.h, horizontal: 10.w),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15.r),
                              color:ColorName.background,
                          ),
                          child: Center(
                              child: Text(
                                  "Login", 
                                  style: Theme.of(context).textTheme.titleSmall
                              ),
                          ),
                      ),
                  ),
                  Gap(15.h),
                  Center(
                      child: GestureDetector(
                          onTap: ()=>{
                              context.router.push(const SignupRoute())
                          },
                          child: RichText(
                              text: TextSpan(
                                  text: "New member? ",
                                  style: Theme.of(context).textTheme.bodySmall,
                                  children: [
                                      TextSpan(
                                          text: "Register now", style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                              color: ColorName.primary,
                                          )
                                      )
                                  ]
                              )
                          ),
                      ),
                  )
                ],
              ),
            ],
          ),
        );
  }
}