import 'package:dio/dio.dart';
import 'package:fl_mhis_hr/library/app_colors.dart';
import 'package:fl_mhis_hr/pages/login/repository/login_api.dart';
import 'package:fl_mhis_hr/pages/login/screen/auth_layout.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({
    super.key,
    this.sendRequest = LoginApi.forgotPassword,
  });

  final Future<void> Function(String email) sendRequest;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _submitted = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isLoading || !_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await widget.sendRequest(_emailController.text.trim());
      if (!mounted) return;
      setState(() => _submitted = true);
    } on DioException catch (error) {
      if (!mounted) return;
      final data = error.response?.data;
      final message = data is Map ? data['message'] : null;
      setState(() {
        _errorMessage = message is String && message.isNotEmpty
            ? message
            : 'Unable to send the request. Please try again.';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      onBack: () {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/auth');
        }
      },
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AuthTitle('FORGOT PASSWORD'),
            const SizedBox(height: 24),
            if (_submitted) ...[
              const Text(
                'Your request has been submitted. Please check your email for further instructions.',
              ),
              const SizedBox(height: 24),
              AuthAction(
                label: 'Back to Login',
                onPressed: () => context.go('/auth'),
              ),
            ] else ...[
              const Text('Enter your email to request a password reset.'),
              const SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.email],
                enabled: !_isLoading,
                onFieldSubmitted: (_) => _submit(),
                decoration: authFieldDecoration('Email')
                    .copyWith(hintText: 'user@example.com'),
                validator: (value) {
                  final email = value?.trim() ?? '';
                  if (email.isEmpty) return 'Please enter your email.';
                  if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
                    return 'Please enter a valid email address.';
                  }
                  return null;
                },
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: AppColors.danger),
                ),
              ],
              const SizedBox(height: 24),
              AuthAction(
                label: 'Send Request',
                isLoading: _isLoading,
                onPressed: _submit,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
