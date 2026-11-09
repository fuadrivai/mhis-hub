import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/pages/login/screen/auth_layout.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:go_router/go_router.dart';

class FingerprintLoginScreen extends StatefulWidget {
  const FingerprintLoginScreen({super.key});

  @override
  State<FingerprintLoginScreen> createState() => _FingerprintLoginScreenState();
}

class _FingerprintLoginScreenState extends State<FingerprintLoginScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  String _message = "Tap button to login with Fingerprint";
  bool _isAuthenticating = false;

  Future<void> _authenticate() async {
    if (_isAuthenticating) return;
    setState(() => _isAuthenticating = true);
    try {
      final isAvailable = await auth.canCheckBiometrics;
      if (!mounted) return;
      if (!isAvailable) {
        setState(() {
          _message = "Biometric not available on this device";
        });
        return;
      }

      final didAuthenticate = await auth.authenticate(
        localizedReason: 'Please authenticate to login',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (!mounted) return;
      if (didAuthenticate) {
        context.go('/');
      } else {
        setState(() {
          _message = "Authentication failed. Try again.";
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _message = "Error: $e";
      });
    } finally {
      if (mounted) setState(() => _isAuthenticating = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _authenticate();
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      onBack: () => context.go('/auth'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AuthTitle('FINGERPRINT LOGIN'),
          const SizedBox(height: 32),
          const Icon(Icons.fingerprint, size: 80, color: AppColors.danger),
          const SizedBox(height: 20),
          Text(_message, textAlign: TextAlign.center),
          const SizedBox(height: 30),
          AuthAction(
            label: 'Login with Fingerprint',
            isLoading: _isAuthenticating,
            onPressed: _authenticate,
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => context.go('/auth'),
              style: TextButton.styleFrom(foregroundColor: AppColors.danger),
              child: const Text('Back to Login'),
            ),
          ),
        ],
      ),
    );
  }
}
