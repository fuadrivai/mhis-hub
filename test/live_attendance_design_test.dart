import 'package:fl_mhis_hr/models/cutoff.dart';
import 'package:fl_mhis_hr/models/v2/models.dart';
import 'package:fl_mhis_hr/pages/attendance/bloc/attendance_bloc.dart';
import 'package:fl_mhis_hr/pages/attendance/screen/attendance_history_detail_screen.dart';
import 'package:fl_mhis_hr/pages/attendance/screen/attendance_history_screen.dart';
import 'package:fl_mhis_hr/pages/attendance/screen/attendance_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';

class RecordingLiveAttendanceBloc extends AttendanceBloc {
  RecordingLiveAttendanceBloc(this.current);

  final AttendanceState current;
  final events = <AttendanceEvent>[];

  @override
  AttendanceState get state => current;

  @override
  void add(AttendanceEvent event) => events.add(event);
}

void main() {
  setUpAll(() async => initializeDateFormatting('en'));

  for (final size in [const Size(320, 568), const Size(1024, 768)]) {
    testWidgets('live attendance schedule and logs fit $size', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      tester.view.padding = const FakeViewPadding(top: 24, bottom: 24);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPadding);
      final older = AttendanceLog(
          type: 'check_in',
          clockDate: '2026-11-09',
          time: '08:00',
          clockDatetime: '2026-11-09 08:00:00');
      final newer = AttendanceLog(
          type: 'check_out',
          clockDate: '2026-11-09',
          time: '17:00',
          clockDatetime: '2026-11-09 17:00:00');
      final logs = List<AttendanceLog>.unmodifiable([older, newer]);
      final bloc = RecordingLiveAttendanceBloc(AttendanceState(
        shift: Shift(
          name: 'Regular',
          scheduleIn: '08:00:00',
          scheduleOut: '17:00:00',
        ),
        logs: logs,
      ));
      addTearDown(bloc.close);
      final router = GoRouter(routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            body: TextButton(
              onPressed: () => context.push('/attendance'),
              child: const Text('Open attendance'),
            ),
          ),
          routes: [
            GoRoute(
              path: 'attendance',
              builder: (context, state) => const AttendanceScreen(),
            ),
          ],
        ),
      ]);
      addTearDown(router.dispose);
      await tester.pumpWidget(BlocProvider<AttendanceBloc>.value(
        value: bloc,
        child: MaterialApp.router(routerConfig: router),
      ));
      await tester.tap(find.text('Open attendance'));
      await tester.pumpAndSettle();
      expect(bloc.events.whereType<OnInit>(), hasLength(1));
      expect(find.text('Live Attendance'), findsOneWidget);
      expect(find.text('Regular'), findsOneWidget);
      expect(find.text('08:00 AM - 05:00 PM'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Clock In'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Clock Out'), findsOneWidget);
      expect(find.text('17:00'), findsOneWidget);
      expect(find.text('08:00'), findsOneWidget);
      expect(tester.getTopLeft(find.text('17:00')).dy,
          lessThan(tester.getTopLeft(find.text('08:00')).dy));
      expect(logs.first, same(older));
      await tester
          .ensureVisible(find.byTooltip('View attendance detail').first);
      await tester.tap(find.byTooltip('View attendance detail').first);
      await tester.pumpAndSettle();
      expect(find.byType(AttendanceHistoryDetailScreen), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('View Log'));
      await tester.tap(find.text('View Log'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(AttendanceHistoryScreen), findsOneWidget);
      expect(bloc.events.whereType<OnGetCutoff>(), hasLength(1));
      await tester.tap(find.byTooltip('Back').last);
      await tester.pumpAndSettle();
      expect(find.text('Live Attendance'), findsOneWidget);
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(find.text('Open attendance'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('empty and error states remain clear and retryable',
      (tester) async {
    for (final error in [false, true]) {
      final bloc = RecordingLiveAttendanceBloc(AttendanceState(
        isError: error,
        errorMessage: error ? 'Connection failed' : null,
        cutoff: Cutoff(cutoffDay: 20),
      ));
      addTearDown(bloc.close);
      await tester.pumpWidget(BlocProvider<AttendanceBloc>.value(
        value: bloc,
        child:
            MaterialApp(key: ValueKey(error), home: const AttendanceScreen()),
      ));
      await tester.pumpAndSettle();
      if (error) {
        expect(find.text('Unable to load attendance'), findsOneWidget);
        expect(find.text('Connection failed'), findsOneWidget);
        await tester.tap(find.text('Refresh'));
        expect(bloc.events.whereType<OnInit>(), hasLength(2));
      } else {
        expect(find.text('No attendance log available for this month yet.'),
            findsOneWidget);
        expect(find.text('Clock In'), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
    }
  });
}
