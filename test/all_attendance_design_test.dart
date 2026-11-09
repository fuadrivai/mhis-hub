import 'package:fl_mhis_hr/models/serverside/pagination.dart';
import 'package:fl_mhis_hr/models/v2/models.dart';
import 'package:fl_mhis_hr/pages/attendance/bloc/attendance_bloc.dart';
import 'package:fl_mhis_hr/pages/attendance/screen/all_attendance_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class RecordingAllAttendanceBloc extends AttendanceBloc {
  RecordingAllAttendanceBloc(this.current);

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
    testWidgets('all attendance interactions fit $size', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      tester.view.padding = const FakeViewPadding(top: 24, bottom: 24);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPadding);
      final bloc = RecordingAllAttendanceBloc(AttendanceState(histories: [
        Attendance(
          fullname: 'Jane Doe',
          employeeId: 123,
          date: '2026-11-09',
          shiftName: 'Regular',
          scheduleIn: '08:00',
          scheduleOut: '17:00',
          checkIn: '2026-11-09 08:00:00',
          checkOut: '2026-11-09 17:00:00',
        ),
        Attendance(fullname: 'John Smith', employeeId: 456),
      ]));
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
              builder: (context, state) => const AllAttendanceScreen(),
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
      expect(find.text('All Attendance'), findsOneWidget);
      expect(bloc.events.whereType<OnGetAll>(), hasLength(1));
      expect(find.text('Jane Doe'), findsOneWidget);
      expect(find.text('John Smith'), findsOneWidget);
      await tester.tap(find.byTooltip('Show attendance details').first);
      await tester.pumpAndSettle();
      expect(find.text('Regular (08:00 - 17:00)'), findsOneWidget);
      await tester.tap(find.text('Clock in'));
      await tester.pumpAndSettle();
      expect(find.text('Clock in details'), findsOneWidget);
      expect(find.text('Coordinate'), findsOneWidget);
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'john');
      await tester.pumpAndSettle();
      expect(bloc.events.whereType<OnGetAll>().last.map['search'], 'john');
      expect(find.text('Jane Doe'), findsNothing);
      expect(find.text('John Smith'), findsOneWidget);
      await tester.tap(find.byTooltip('Clear search'));
      await tester.pumpAndSettle();
      expect(bloc.events.whereType<OnGetAll>().last.map.containsKey('search'),
          isFalse);
      final dateLabel = DateFormat('dd MMM yyyy').format(DateTime.now());
      await tester.tap(find.text(dateLabel));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text(dateLabel), findsOneWidget);
      await tester.tap(find.text(dateLabel));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Previous month'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('15').last);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      final today = DateTime.now();
      final selected = DateTime(today.year, today.month - 1, 15);
      expect(bloc.events.whereType<OnGetAll>().last.map['date'],
          DateFormat('yyyy-MM-dd').format(selected));
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(find.text('Open attendance'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('empty and error states allow retry', (tester) async {
    for (final error in [false, true]) {
      final bloc = RecordingAllAttendanceBloc(AttendanceState(
        isError: error,
        errorMessage: error ? 'Network error' : null,
      ));
      addTearDown(bloc.close);
      await tester.pumpWidget(BlocProvider<AttendanceBloc>.value(
        value: bloc,
        child: MaterialApp(
            key: ValueKey(error), home: const AllAttendanceScreen()),
      ));
      await tester.pumpAndSettle();
      expect(
          find.text(
              error ? 'Unable to load attendance' : 'No attendance found'),
          findsOneWidget);
      if (error) expect(find.text('Network error'), findsOneWidget);
      await tester.tap(find.text('Refresh'));
      expect(bloc.events.whereType<OnGetAll>(), hasLength(2));
    }
  });

  testWidgets('scrolling loads the next page with current filters',
      (tester) async {
    final bloc = RecordingAllAttendanceBloc(AttendanceState(
      histories:
          List.generate(30, (index) => Attendance(fullname: 'Employee $index')),
      serverside: Pagination(currentPage: 2, nextPageUrl: 'next'),
    ));
    addTearDown(bloc.close);
    await tester.pumpWidget(BlocProvider<AttendanceBloc>.value(
      value: bloc,
      child: const MaterialApp(home: AllAttendanceScreen()),
    ));
    await tester.pumpAndSettle();
    await tester.fling(find.byType(ListView), const Offset(0, -3000), 3000);
    await tester.pumpAndSettle();
    final event = bloc.events.whereType<OnLoadMore>().last;
    expect(event.map['page'], 3);
    expect(event.map['date'], DateFormat('yyyy-MM-dd').format(DateTime.now()));
    expect(tester.takeException(), isNull);
  });
}
