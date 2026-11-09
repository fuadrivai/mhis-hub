import 'package:fl_mhis_hr/pages/login/screen/login_biometric.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('biometric login reports unavailable and returns to login',
      (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    const channel = MethodChannel('plugins.flutter.io/local_auth');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'getAvailableBiometrics') return <String>[];
      throw PlatformException(code: 'unexpected-method');
    });
    addTearDown(() => TestDefaultBinaryMessengerBinding
        .instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null));
    final router = GoRouter(
      initialLocation: '/fingerprint',
      routes: [
        GoRoute(
          path: '/fingerprint',
          builder: (context, state) => const FingerprintLoginScreen(),
        ),
        GoRoute(
          path: '/auth',
          builder: (context, state) => const Scaffold(body: Text('Login page')),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
    expect(find.text('Biometric not available on this device'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.text('Back to Login'));
    await tester.tap(find.text('Back to Login'));
    await tester.pumpAndSettle();
    expect(find.text('Login page'), findsOneWidget);
  });
}
