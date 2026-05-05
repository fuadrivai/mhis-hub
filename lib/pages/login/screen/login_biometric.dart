import 'package:fl_mhis_hr/library/constant.dart';
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

  Future<void> _authenticate() async {
    try {
      final isAvailable = await auth.canCheckBiometrics;
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

      if (didAuthenticate) {
        if (!mounted) return;
        context.go('/');
      } else {
        setState(() {
          _message = "Authentication failed. Try again.";
        });
      }
    } catch (e) {
      setState(() {
        _message = "Error: $e";
      });
    }
  }

  @override
  void initState() {
    _authenticate();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Fingerprint Login"),
      ),
      body: Center(
        child: Column(
          children: [
            Image.asset(Common.logoSplash, width: 300, height: 300),
            const Icon(Icons.fingerprint, size: 80, color: Colors.blue),
            const SizedBox(height: 20),
            Text(_message, textAlign: TextAlign.center),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _authenticate,
              icon: const Icon(Icons.fingerprint),
              label: const Text("Login with Fingerprint"),
            ),
          ],
        ),
      ),
    );
  }
}
