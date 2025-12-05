import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:oktoast/oktoast.dart';

import '../../../../../generated/colors.gen.dart';
import '../../../../common/widgets/toast_custom.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';

class ChangePasswordBottomSheet extends StatefulWidget {
  const ChangePasswordBottomSheet({super.key});

  @override
  State<ChangePasswordBottomSheet> createState() => _ChangePasswordBottomSheetState();
}

class _ChangePasswordBottomSheetState extends State<ChangePasswordBottomSheet> {
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  
  bool isLoading = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        state.whenOrNull(
          changePassword: () {
            Navigator.of(context).pop();
            showToastWidget(
              ToastWidget(
                title: 'Success', 
                description: 'Password changed successfully'
              ),
              duration: const Duration(seconds: 4),
            );
          },
          failure: (message) {
            showToastWidget(
              ToastWidget(
                title: 'Error',
                description: message,
                // isError: true,
              ),
              duration: const Duration(seconds: 4),
            );
          },
        );
      },
      builder: (context, state) {
        final cubit = context.read<AuthCubit>();
        // final isLoading = state is _Loading;
        
        // Lấy validation state từ cubit
        final passwordError = state.maybeWhen(
          unauthenticated: (emailErr, passErr, msg, isEmailValid, isPasswordValid) => passErr,
          orElse: () => '',
        );

        final isPasswordValid = state.maybeWhen(
          unauthenticated: (emailErr, passErr, msg, isEmailValid, isPasswordValid) => isPasswordValid,
          orElse: () => false,
        );

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom, 
          ),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.r),
                topRight: Radius.circular(20.r),
              ),
            ),
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min, 
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Change Password',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const FaIcon(FontAwesomeIcons.xmark),
                      ),
                    ],
                  ),
                  
                  Gap(32.h),
                  
                  // Current Password
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Current password", 
                      style: TextStyle(fontSize: 15.sp),
                    ),
                  ),
                  Gap(8.h),
                  Container(
                    decoration: BoxDecoration(
                      color: ColorName.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4.0,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: TextField(
                      controller: _currentPasswordController,
                      obscureText: _obscureCurrentPassword,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.transparent, 
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        hintText: 'Your current password',
                        suffixIcon: IconButton(
                          icon: FaIcon(
                            _obscureCurrentPassword 
                                ? FontAwesomeIcons.eyeSlash 
                                : FontAwesomeIcons.eye,
                            size: 18.sp,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureCurrentPassword = !_obscureCurrentPassword;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  
                  Gap(24.h),
                  
                  // New Password - CÓ VALIDATION REALTIME TỪ CUBIT
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "New password", 
                      style: TextStyle(fontSize: 15.sp),
                    ),
                  ),
                  Gap(8.h),
                  Container(
                    decoration: BoxDecoration(
                      color: ColorName.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4.0,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: TextField(
                      controller: _newPasswordController,
                      obscureText: _obscureNewPassword,
                      decoration: InputDecoration(
                        errorText: passwordError.isNotEmpty ? passwordError : null,
                        filled: true,
                        fillColor: Colors.transparent, 
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        hintText: 'Your new password',
                        suffixIcon: IconButton(
                          icon: FaIcon(
                            _obscureNewPassword 
                                ? FontAwesomeIcons.eyeSlash 
                                : FontAwesomeIcons.eye,
                            size: 18.sp,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureNewPassword = !_obscureNewPassword;
                            });
                          },
                        ),
                      ),
                      // GỌI TRỰC TIẾP TỪ CUBIT - REALTIME VALIDATION
                      onChanged: (value) {
                        cubit.onChangedPassword(value);
                      },
                    ),
                  ),
                  
                  Gap(24.h),

                  Row(
                    children: [
                      // Cancel Button
                      Expanded(
                        child: OutlinedButton(
                          onPressed: isLoading ? null : () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.grey.shade700,
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                          child: Text(
                            'Cancel',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      
                      Gap(12.w),
                      
                      // Change Button - GỌI TRỰC TIẾP TỪ CUBIT
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isLoading || !isPasswordValid ? null : () {
                            // GỌI TRỰC TIẾP TỪ CUBIT
                            final cubit = context.read<AuthCubit>();
                            cubit.changePassword(
                              currentPassword: _currentPasswordController.text,
                              newPassword: _newPasswordController.text,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorName.background,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                          ),
                          child: isLoading
                              ? SizedBox(
                                  width: 20.w,
                                  height: 20.h,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Text(
                                  'Change',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}