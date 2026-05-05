import 'package:fl_mhis_hr/library/constant.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    await Future.delayed(const Duration(seconds: 1));
    String? token = await Session.get("token");
    String? isBiometric = await Session.get("isBiometric");

    if (!mounted) return;

    if (token == null || token.isEmpty) {
      context.go('/auth');
    } else {
      if (isBiometric == "true") {
        context.go('/finggerprint');
      } else {
        context.go('/');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // warna background splash
      body: Center(
        child: Image.asset(
          Common.logoHub, // ganti dengan logo/gambar kamu
          width: 150,
          height: 150,
        ),
      ),
    );
  }
}
