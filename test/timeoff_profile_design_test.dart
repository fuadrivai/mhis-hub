import 'package:fl_mhis_hr/injector/injector.dart';
import 'package:fl_mhis_hr/models/v2/models.dart';
import 'package:fl_mhis_hr/pages/profile/bloc/profile_bloc.dart' as profile;
import 'package:fl_mhis_hr/pages/profile/screen/profile_screen.dart';
import 'package:fl_mhis_hr/pages/timeoff/bloc/timeoff_bloc.dart' as timeoff;
import 'package:fl_mhis_hr/pages/timeoff/screen/timeoff_screen.dart';
import 'package:fl_mhis_hr/pages/timeoff/screen/timeoff_screen2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeTimeoffBloc extends timeoff.TimeoffBloc {
  FakeTimeoffBloc(this.testState);

  final timeoff.TimeoffState testState;
  final events = <timeoff.TimeoffEvent>[];

  @override
  timeoff.TimeoffState get state => testState;

  @override
  void add(timeoff.TimeoffEvent event) => events.add(event);
}

class FakeProfileBloc extends profile.ProfileBloc {
  FakeProfileBloc(this.testState);

  final profile.ProfileState testState;
  final events = <profile.ProfileEvent>[];

  @override
  profile.ProfileState get state => testState;

  @override
  void add(profile.ProfileEvent event) => events.add(event);
}

void main() {
  setUpAll(() {
    locator.registerSingleton<NavigationService>(NavigationService());
  });
  tearDownAll(() => locator.unregister<NavigationService>());

  for (final size in [const Size(320, 568), const Size(1024, 768)]) {
    testWidgets('timeoff tab and form navigation fit $size', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final item = Timeoff(
        name: 'Annual Leave',
        code: 'A very long timeoff code',
        isActive: true,
      );
      final bloc = FakeTimeoffBloc(timeoff.TimeoffState(timeoffs: [item]));
      addTearDown(bloc.close);
      final router = GoRouter(routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const TimeoffScreen(),
          routes: [
            GoRoute(
              path: 'form',
              name: 'create-timeoff',
              builder: (_, state) {
                final data = state.extra as Map<String, dynamic>;
                return Scaffold(body: Text((data['data'] as Timeoff).name!));
              },
            ),
          ],
        ),
      ]);
      addTearDown(router.dispose);
      await tester.pumpWidget(BlocProvider<timeoff.TimeoffBloc>.value(
        value: bloc,
        child: MaterialApp.router(routerConfig: router),
      ));
      await tester.pumpAndSettle();
      expect(bloc.events.whereType<timeoff.OnInit>(), hasLength(1));
      expect(find.text('Request Timeoff'), findsOneWidget);
      expect(find.text('Available Timeoff'), findsOneWidget);
      expect(find.text('Plan your time off'), findsOneWidget);
      expect(find.byTooltip('Back'), findsNothing);
      expect(find.text('Active'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Annual Leave'));
      await tester.pumpAndSettle();
      expect(find.text('Annual Leave'), findsOneWidget);
      expect(find.text('Request Timeoff'), findsNothing);
    });

    testWidgets('profile fits $size and retains actions', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final bloc = FakeProfileBloc(profile.ProfileState(
        isLoading: false,
        employee: Employee(
          personal: Person(fullname: 'Jane', email: 'jane@example.com'),
        ),
        canAuthenticateWithBiometrics: true,
        isBiometric: true,
      ));
      addTearDown(bloc.close);
      await tester.pumpWidget(BlocProvider<profile.ProfileBloc>.value(
        value: bloc,
        child: const MaterialApp(home: ProfileScreen()),
      ));
      await tester.pumpAndSettle();
      expect(bloc.events.whereType<profile.OnGetUserById>(), hasLength(1));
      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('Jane'), findsOneWidget);
      expect(find.text('jane@example.com'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.byIcon(Icons.person).first);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Profile Picture'), findsOneWidget);
      expect(find.text('Edit Picture'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byType(Switch));
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      expect(bloc.events.whereType<profile.OnResetAuthenticationBiometrics>(),
          hasLength(1));
      await tester.ensureVisible(find.text('Logout'));
      await tester.tap(find.text('Logout'));
      expect(bloc.events.whereType<profile.OnLogout>(), hasLength(1));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('biometric password dialog validates, toggles, and cancels',
      (tester) async {
    SharedPreferences.setMockInitialValues({'password': 'correct'});
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final bloc = FakeProfileBloc(const profile.ProfileState(
      isLoading: false,
      canAuthenticateWithBiometrics: true,
      isBiometric: false,
    ));
    addTearDown(bloc.close);
    await tester.pumpWidget(BlocProvider<profile.ProfileBloc>.value(
      value: bloc,
      child: const MaterialApp(home: ProfileScreen()),
    ));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byType(Switch));
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(find.text('Enable Biometric'), findsOneWidget);
    final cancelPosition = tester.getCenter(find.text('Cancel'));
    final savePosition = tester.getCenter(find.text('Save'));
    expect(cancelPosition.dx, lessThan(savePosition.dx));
    expect(cancelPosition.dy, closeTo(savePosition.dy, 1));
    expect(
        tester.widget<TextField>(find.byType(TextField)).obscureText, isTrue);
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Field cannot be empty'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), 'wrong');
    await tester.tap(find.byTooltip('Show password'));
    await tester.pumpAndSettle();
    expect(
        tester.widget<TextField>(find.byType(TextField)).obscureText, isFalse);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Enable Biometric'), findsNothing);
    expect(bloc.events.whereType<profile.OnResetAuthenticationBiometrics>(),
        isEmpty);
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    final field = tester.widget<TextFormField>(find.byType(TextFormField));
    expect(field.controller!.text, isEmpty);
    expect(
        tester.widget<TextField>(find.byType(TextField)).obscureText, isTrue);
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    expect(find.text('Enable Biometric'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty and error states remain refreshable', (tester) async {
    for (final isError in [false, true]) {
      final bloc = FakeTimeoffBloc(timeoff.TimeoffState(isError: isError));
      addTearDown(bloc.close);
      await tester.pumpWidget(BlocProvider<timeoff.TimeoffBloc>.value(
        value: bloc,
        child: MaterialApp(
          key: ValueKey(isError),
          home: const TimeoffScreen(),
        ),
      ));
      await tester.pumpAndSettle();
      expect(
        find.text(isError
            ? 'Unable to load timeoff types. Pull down to retry.'
            : 'No timeoff types available.'),
        findsOneWidget,
      );
      await tester.drag(find.byType(CustomScrollView), const Offset(0, 300));
      await tester.pumpAndSettle();
      expect(bloc.events.whereType<timeoff.OnInit>().length, greaterThan(1));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });

  testWidgets('inactive timeoff fits with larger text', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final bloc = FakeTimeoffBloc(timeoff.TimeoffState(timeoffs: [
      Timeoff(
        name: 'A longer timeoff type name',
        code: 'A long code for timeoff',
        isActive: false,
      ),
    ]));
    addTearDown(bloc.close);
    await tester.pumpWidget(BlocProvider<timeoff.TimeoffBloc>.value(
      value: bloc,
      child: MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(1.5)),
          child: child!,
        ),
        home: const TimeoffScreen(),
      ),
    ));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Inactive'),
      120,
      scrollable: find.byType(Scrollable),
    );
    expect(find.text('Inactive'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('secondary timeoff page retains back navigation', (tester) async {
    final bloc = FakeTimeoffBloc(const timeoff.TimeoffState());
    addTearDown(bloc.close);
    await tester.pumpWidget(BlocProvider<timeoff.TimeoffBloc>.value(
      value: bloc,
      child: MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () =>
                  Navigator.of(context).push(MaterialPageRoute<void>(
                builder: (_) => const TimeoffScreen2(),
              )),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('Request Timeoff'), findsOneWidget);
    expect(bloc.events.whereType<timeoff.OnInit>(), hasLength(1));
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Open'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
