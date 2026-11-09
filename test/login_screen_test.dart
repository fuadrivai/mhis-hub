import 'package:fl_mhis_hr/pages/login/bloc/login_bloc.dart';
import 'package:fl_mhis_hr/pages/login/screen/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('top wave reaches screen edge while logo remains in safe area',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(top: 36, bottom: 24);
    tester.view.viewPadding = const FakeViewPadding(top: 36, bottom: 24);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);
    addTearDown(tester.view.resetViewPadding);
    final bloc = LoginBloc();
    addTearDown(bloc.close);
    await tester.pumpWidget(BlocProvider.value(
      value: bloc,
      child: const MaterialApp(home: LoginScreen()),
    ));
    await tester.pumpAndSettle();
    expect(
        tester.getTopLeft(find.byKey(const ValueKey('auth-top-wave'))).dy, 0);
    expect(tester.getTopLeft(find.byType(Image).first).dy,
        greaterThanOrEqualTo(36));
    expect(tester.takeException(), isNull);
  });

  for (final size in [
    const Size(320, 568),
    const Size(390, 844),
    const Size(1024, 768),
  ]) {
    testWidgets('login fits ${size.width}x${size.height} and keyboard',
        (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final bloc = LoginBloc();
      addTearDown(bloc.close);
      await tester.pumpWidget(BlocProvider.value(
        value: bloc,
        child: const MaterialApp(home: LoginScreen()),
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Sign In'), findsOneWidget);

      tester.view.viewInsets = const FakeViewPadding(bottom: 260);
      addTearDown(tester.view.resetViewInsets);
      await tester.showKeyboard(find.byType(TextField).last);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Sign In'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(tester.getRect(find.text('Sign In')).bottom,
          lessThanOrEqualTo(size.height - 260));
    });
  }

  testWidgets('password visibility toggles and forgot password navigates',
      (tester) async {
    final bloc = LoginBloc();
    addTearDown(bloc.close);
    final router = GoRouter(
      initialLocation: '/auth',
      routes: [
        GoRoute(
            path: '/auth', builder: (context, state) => const LoginScreen()),
        GoRoute(
          path: '/forgot-password',
          builder: (context, state) => const Scaffold(body: Text('Reset page')),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(BlocProvider.value(
      value: bloc,
      child: MaterialApp.router(routerConfig: router),
    ));
    expect(tester.widget<TextField>(find.byType(TextField).last).obscureText,
        isTrue);
    await tester.tap(find.byTooltip('Show password'));
    await tester.pump();
    expect(tester.widget<TextField>(find.byType(TextField).last).obscureText,
        isFalse);
    await tester.tap(find.byTooltip('Hide password'));
    await tester.pump();
    expect(tester.widget<TextField>(find.byType(TextField).last).obscureText,
        isTrue);
    await tester.ensureVisible(find.text('Forgot Password?'));
    await tester.tap(find.text('Forgot Password?'));
    await tester.pumpAndSettle();
    expect(find.text('Reset page'), findsOneWidget);
  });
}
