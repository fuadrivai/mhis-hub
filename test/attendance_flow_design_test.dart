import 'dart:async';

import 'package:fl_mhis_hr/models/v2/models.dart';
import 'package:fl_mhis_hr/pages/attendance/bloc/attendance_bloc.dart';
import 'package:fl_mhis_hr/pages/attendance/screen/attendance_history_detail_screen.dart';
import 'package:fl_mhis_hr/pages/attendance/screen/attendance_history_screen.dart';
import 'package:fl_mhis_hr/pages/attendance/screen/clockin_clockout_screen.dart';
import 'package:fl_mhis_hr/pages/attendance/screen/map_screen.dart';
import 'package:fl_mhis_hr/pages/attendance/screen/success_screen.dart';
import 'package:fl_mhis_hr/widget/map_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/date_symbol_data_local.dart';

class FakeAttendanceBloc extends AttendanceBloc {
  final events = <AttendanceEvent>[];
  @override
  void add(AttendanceEvent event) => events.add(event);
}

class PendingLocationPlatform extends GeolocatorPlatform {
  final serviceStatus = Completer<bool>();

  @override
  Future<bool> isLocationServiceEnabled() => serviceStatus.future;
}

void main() {
  setUpAll(() async => initializeDateFormatting('en'));

  for (final size in [const Size(320, 568), const Size(1024, 768)]) {
    testWidgets('attendance details and result fit $size', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      tester.view.padding = const FakeViewPadding(top: 24, bottom: 24);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPadding);
      final bloc = FakeAttendanceBloc();
      addTearDown(bloc.close);
      final log = AttendanceLog(
        type: 'check_in',
        fullname: 'Jane Doe',
        shiftName: 'Regular',
        clockDatetime: '2026-11-09 08:15:00',
        attendance: Attendance(scheduleIn: '08:00:00'),
        employee: Employee(personal: Person(fullname: 'Jane Doe')),
      );
      final router = GoRouter(routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            body: Column(children: [
              TextButton(
                  onPressed: () => context.push('/detail'),
                  child: const Text('Open detail')),
              TextButton(
                  onPressed: () => context.push('/result'),
                  child: const Text('Open result')),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CheckPermissionScreen(
                      title: 'Camera Permission',
                      text: 'Camera required',
                      message: 'Allow camera',
                    ),
                  ),
                ),
                child: const Text('Open permission'),
              ),
            ]),
          ),
          routes: [
            GoRoute(
              path: 'detail',
              builder: (_, __) => AttendanceHistoryDetailScreen(log: log),
            ),
            GoRoute(
              path: 'result',
              builder: (_, __) => AttendanceResponseScreen(attendance: log),
            ),
          ],
        ),
      ]);
      addTearDown(router.dispose);
      await tester.pumpWidget(BlocProvider<AttendanceBloc>.value(
        value: bloc,
        child: MaterialApp.router(routerConfig: router),
      ));
      await tester.tap(find.text('Open detail'));
      await tester.pumpAndSettle();
      expect(find.text('Check-In Detail'), findsOneWidget);
      expect(find.text('Jane Doe'), findsOneWidget);
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
      expect(find.byIcon(Icons.location_off_outlined), findsOneWidget);
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Open result'));
      await tester.pumpAndSettle();
      expect(find.text('Success'), findsOneWidget);
      final successIcon = find.byIcon(Icons.check_circle_rounded);
      expect(tester.widget<Icon>(successIcon).color, Colors.green);
      final whiteCards = find.ancestor(
        of: successIcon,
        matching: find.byWidgetPredicate((widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration! as BoxDecoration).color == Colors.white),
      );
      expect(whiteCards, findsWidgets);
      expect(
        find.descendant(of: whiteCards.first, matching: find.text('Success')),
        findsOneWidget,
      );
      expect(find.text('You arrived 15 minutes late'), findsOneWidget);
      expect(find.text('Jane Doe'), findsOneWidget);
      await tester.ensureVisible(find.text('Attendance History'));
      await tester.tap(find.text('Attendance History'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(AttendanceHistoryScreen), findsOneWidget);
      expect(bloc.events.whereType<OnGetCutoff>(), hasLength(1));
      expect(tester.takeException(), isNull);
    });

    testWidgets('camera permission screen fits and returns $size',
        (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CheckPermissionScreen(
                    title: 'Camera Permission',
                    text: 'Camera required',
                    message: 'Allow camera',
                  ),
                ),
              ),
              child: const Text('Open permission'),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('Open permission'));
      await tester.pumpAndSettle();
      expect(find.text('Camera Access Required'), findsOneWidget);
      expect(find.text('Open Settings'), findsOneWidget);
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(find.text('Open permission'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('success screen handles missing date and preserves early warning',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: AttendanceResponseScreen(
        attendance: AttendanceLog(
          type: 'check_out',
          clockDate: '2026-11-09',
          time: '16:45:00',
          attendance: Attendance(scheduleOut: '17:00:00'),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('-'), findsWidgets);
    expect(find.text('You clocked out 15 minutes early'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('map retains camera navigation and can close while loading',
      (tester) async {
    final oldPlatform = GeolocatorPlatform.instance;
    final platform = PendingLocationPlatform();
    GeolocatorPlatform.instance = platform;
    addTearDown(() => GeolocatorPlatform.instance = oldPlatform);
    final router = GoRouter(routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => const MapScreen(type: 'checkin'),
        routes: [
          GoRoute(
            path: 'camera',
            name: 'clockin',
            builder: (_, __) =>
                const Scaffold(body: Text('Camera destination')),
          ),
        ],
      ),
    ]);
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pump();
    expect(find.text('Confirm your attendance location'), findsOneWidget);
    final map = tester.widget<MapWidget>(find.byType(MapWidget));
    expect(map.centerButton, isTrue);
    map.onTap!();
    await tester.pumpAndSettle();
    expect(find.text('Camera destination'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    platform.serviceStatus.complete(true);
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
