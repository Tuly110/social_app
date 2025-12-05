import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oktoast/oktoast.dart';

import '../../../../../generated/colors.gen.dart';
import '../../../../common/widgets/toast_custom.dart';
import '../../../app/app_router.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';

class ActionDialogs {
  void showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out of your account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: ColorName.textGray,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Handle logout logic here
            },
            child: Text(
              'Log Out',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showDeleteAccountDialog(BuildContext context) {
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) {
        return BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            state.whenOrNull(
              deleteAccount: () {
                Navigator.of(context).pop();
                showToastWidget(
                  ToastWidget(
                    title: 'Success',
                    description: 'Account deleted successfully',
                  ),
                  duration: const Duration(seconds: 4),
                );
                // TODO: Navigate to login screen
                context.router.replaceAll([const LoginRoute()]);
              },
              failure: (message) {
                Navigator.of(context).pop();
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
          child: StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text('Delete Account'),
                content: const Text('This action cannot be undone. All your data will be permanently deleted.'),
                actions: [
                  TextButton(
                    onPressed: isLoading ? null : () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: ColorName.textGray,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: isLoading ? null : () {
                      setState(() {
                        isLoading = true;
                      });
                      
                      // Gọi delete account từ cubit
                      final cubit = context.read<AuthCubit>();
                      cubit.deleteAccount();
                    },
                    child: isLoading
                      ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                        ),
                      )
                    : const Text(
                        'Delete',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}