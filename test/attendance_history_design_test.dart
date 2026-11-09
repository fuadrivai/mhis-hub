import 'package:fl_mhis_hr/models/attendance_summary.dart';
import 'package:fl_mhis_hr/models/cutoff.dart';
import 'package:fl_mhis_hr/models/v2/attendance.dart';
import 'package:fl_mhis_hr/models/v2/attendance_log.dart';
import 'package:fl_mhis_hr/pages/attendance/bloc/attendance_bloc.dart';
import 'package:fl_mhis_hr/pages/attendance/screen/attendance_history_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

class RecordingAttendanceBloc extends AttendanceBloc {
  final events = <AttendanceEvent>[];

  @override
  void add(AttendanceEvent event) => events.add(event);

  void update(AttendanceState next) => emit(next);
}

void main() {
  setUpAll(() async => initializeDateFormatting('en'));

  for (final size in [const Size(320, 568), const Size(1024, 768)]) {
    testWidgets('attendance history interactions fit $size', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      tester.view.padding = const FakeViewPadding(top: 24, bottom: 24);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPadding);
      final bloc = RecordingAttendanceBloc();
      addTearDown(bloc.close);
      await tester.pumpWidget(BlocProvider<AttendanceBloc>.value(
        value: bloc,
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const AttendanceHistoryScreen()),
                ),
                child: const Text('Open attendance'),
              ),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('Open attendance'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(bloc.events.whereType<OnGetCutoff>(), hasLength(1));
      final date = DateTime.now();
      bloc.update(AttendanceState(
        cutoff: Cutoff(cutoffDay: 31),
        histories: [
          Attendance(
            date: '${date.year}-${date.month.toString().padLeft(2, '0')}-'
                '${date.day.toString().padLeft(2, '0')}',
            shiftName: 'Regular',
            scheduleIn: '08:00',
            scheduleOut: '17:00',
            checkIn: '08:00',
            checkOut: '17:00',
            logs: [AttendanceLog(type: 'check_in', time: '08:00')],
          ),
        ],
        attendanceSummary: AttendanceSummary(
          period: AttendancePeriod(
              start: DateTime(date.year, date.month), end: date, cutoffDay: 31),
          totals: AttendanceTotals.fromJson({'late_clockin': 1}),
        ),
      ));
      await tester.pumpAndSettle();
      expect(bloc.events.whereType<OnGetHistory>(), hasLength(1));
      expect(bloc.events.whereType<OnGetAttendanceSummary>(), hasLength(1));
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Late clock-in'), findsOneWidget);
      await tester.ensureVisible(find.text('Show less'));
      await tester.tap(find.text('Show less'));
      await tester.pumpAndSettle();
      expect(find.text('Show more'), findsOneWidget);
      await tester.tap(find.text('Show more'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Today'));
      await tester.tap(find.text('Today'));
      await tester.pumpAndSettle();
      expect(find.text('Check In'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.close).last);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byType(TextFormField));
      await tester.tap(find.byType(TextFormField));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(bloc.events.whereType<OnGetHistory>(), hasLength(1));
      await tester.tap(find.byType(TextFormField));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Jan').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(bloc.events.whereType<OnGetHistory>().last.map['month'], '1');
      expect(bloc.events.whereType<OnGetAttendanceSummary>(), hasLength(2));
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(find.text('Open attendance'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('cutoff errors are visible', (tester) async {
    final bloc = RecordingAttendanceBloc();
    addTearDown(bloc.close);
    await tester.pumpWidget(BlocProvider<AttendanceBloc>.value(
      value: bloc,
      child: const MaterialApp(home: AttendanceHistoryScreen()),
    ));
    bloc.update(const AttendanceState(cutoffError: true));
    await tester.pumpAndSettle();
    expect(find.text('Unable to load cutoff'), findsOneWidget);
  });
}
