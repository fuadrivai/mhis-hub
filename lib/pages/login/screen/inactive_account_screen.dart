import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/pages/login/screen/auth_layout.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class InactiveAccountScreen extends StatelessWidget {
  const InactiveAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      onBack: () => context.go('/auth'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AuthTitle('ACCOUNT INACTIVE'),
          const SizedBox(height: 32),
          const Icon(Icons.person_off_outlined,
              size: 80, color: AppColors.danger),
          const SizedBox(height: 24),
          const Text(
            'Your account is inactive. Please contact your administrator for assistance.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          AuthAction(
            label: 'Back to Login',
            onPressed: () => context.go('/auth'),
          ),
        ],
      ),
    );
  }
}
