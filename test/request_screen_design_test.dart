import 'package:fl_mhis_hr/models/v2/models.dart';
import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/pages/request_approval/bloc/request_approval_bloc.dart';
import 'package:fl_mhis_hr/pages/request_approval/screen/request_detail_screen.dart';
import 'package:fl_mhis_hr/pages/request_approval/screen/request_screen.dart';
import 'package:fl_mhis_hr/pages/timeoff/bloc/timeoff_bloc.dart' as timeoff;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecordingRequestBloc extends RequestApprovalBloc {
  RecordingRequestBloc({
    this.testState = const RequestApprovalState(isBalanceEmpty: true),
  });

  final RequestApprovalState testState;
  final events = <RequestApprovalEvent>[];

  @override
  RequestApprovalState get state => testState;

  @override
  void add(RequestApprovalEvent event) => events.add(event);
}

class RecordingTimeoffBloc extends timeoff.TimeoffBloc {
  @override
  void add(timeoff.TimeoffEvent event) {}
}

void main() {
  testWidgets('next pending approval stays reachable on a small screen',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final bloc = RecordingRequestBloc(
      testState: RequestApprovalState(
        request: ApprovalRequest(
          id: 1,
          status: 'pending',
          type: Timeoff(
            name: 'Annual leave',
            schema: [
              TimeoffSchema(name: 'date', label: 'Date'),
              TimeoffSchema(name: 'start_date', label: 'Start Date'),
              TimeoffSchema(name: 'end_date', label: 'End Date'),
              TimeoffSchema(name: 'start_time', label: 'Start Time'),
              TimeoffSchema(name: 'end_time', label: 'End Time'),
            ],
          ),
          data: ApprovalRequestData(payload: {
            'date': '2027-01-03',
            'start_date': '2027-01-04',
            'end_date': '2027-01-05',
            'start_time': '09:00',
            'end_time': '17:00',
          }),
        ),
      ),
    );
    addTearDown(bloc.close);
    final router = GoRouter(routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => Scaffold(
          body: TextButton(
            onPressed: () => context.pushNamed(
              'timeoff-detail',
              extra: {
                'requestId': 1,
                'approvalId': 10,
              },
            ),
            child: const Text('Open approval'),
          ),
        ),
      ),
      GoRoute(
        path: '/detail',
        name: 'timeoff-detail',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return RequestDetailScreen(
            requestId: extra['requestId'] as int,
            approvalId: extra['approvalId'] as int?,
          );
        },
      ),
    ]);
    addTearDown(router.dispose);

    await tester.pumpWidget(BlocProvider<RequestApprovalBloc>.value(
      value: bloc,
      child: MaterialApp.router(routerConfig: router),
    ));
    await tester.tap(find.text('Open approval'));
    await tester.pumpAndSettle();

    expect(
      tester.getTopLeft(find.text('Date')).dy,
      closeTo(tester.getTopLeft(find.text('03 January 2027')).dy, 1),
    );
    expect(
      tester.getTopLeft(find.text('Start Date')).dy,
      closeTo(tester.getTopLeft(find.text('04 January 2027')).dy, 1),
    );
    expect(
      tester.getTopLeft(find.text('End Date')).dy,
      closeTo(tester.getTopLeft(find.text('05 January 2027')).dy, 1),
    );
    expect(
      tester.getTopLeft(find.text('Start Time')).dy,
      closeTo(tester.getTopLeft(find.text('09:00')).dy, 1),
    );
    expect(
      tester.getTopLeft(find.text('End Time')).dy,
      closeTo(tester.getTopLeft(find.text('17:00')).dy, 1),
    );

    expect(
      tester
          .widget<RequestDetailScreen>(find.byType(RequestDetailScreen))
          .approvalId,
      10,
    );
    final nextButton = find.byTooltip('Next pending approval');
    expect(nextButton, findsOneWidget);
    final nextIconButton =
        find.widgetWithIcon(IconButton, Icons.arrow_forward_rounded);
    final nextAction = tester.widget<IconButton>(nextIconButton);
    expect(
      nextAction.style?.foregroundColor?.resolve({}),
      AppColors.danger,
    );
    expect(nextAction.style?.side?.resolve({})?.style, BorderStyle.solid);
    expect(
      nextAction.style?.minimumSize?.resolve({}),
      const Size(40, 40),
    );
    expect(
      tester.widget<Icon>(find.byIcon(Icons.arrow_forward_rounded)).size,
      18,
    );

    await tester.tap(nextButton);
    await tester.pumpAndSettle();
    expect(
      bloc.events.whereType<OnGetNextApproval>().map((e) => e.approvalId),
      [10],
    );
    expect(bloc.events.whereType<OnInitDetail>().map((e) => e.id), [1]);
    expect(nextButton, findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final size in [const Size(320, 568), const Size(1024, 768)]) {
    testWidgets('request tabs and navigation fit $size', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      tester.view.padding = const FakeViewPadding(top: 24, bottom: 24);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPadding);
      final bloc = RecordingRequestBloc();
      final timeoffBloc = RecordingTimeoffBloc();
      addTearDown(bloc.close);
      addTearDown(timeoffBloc.close);
      final router = GoRouter(routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            body: TextButton(
              onPressed: () => context.push('/request'),
              child: const Text('Open request'),
            ),
          ),
        ),
        GoRoute(
          path: '/request',
          builder: (context, state) => const RequestScreen(),
        ),
      ]);
      addTearDown(router.dispose);
      await tester.pumpWidget(MultiBlocProvider(
        providers: [
          BlocProvider<RequestApprovalBloc>.value(value: bloc),
          BlocProvider<timeoff.TimeoffBloc>.value(value: timeoffBloc),
        ],
        child: MaterialApp.router(routerConfig: router),
      ));
      await tester.tap(find.text('Open request'));
      await tester.pumpAndSettle();
      expect(find.text('Timeoff Request'), findsOneWidget);
      expect(find.text('No policy assigned'), findsOneWidget);
      expect(bloc.events.whereType<OnInitRequest>(), hasLength(1));
      expect(bloc.events.whereType<OnGetBalance>(), hasLength(1));
      await tester.tap(find.text('My Approvals'));
      await tester.pumpAndSettle();
      expect(find.text('No approvals found'), findsOneWidget);
      expect(bloc.events.whereType<OnInitApproval>(), hasLength(1));
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is TextField &&
              widget.decoration?.hintText == 'All months',
        ),
        findsOneWidget,
      );
      expect(
        bloc.events.whereType<OnInitApproval>().first.map,
        {'status': 'pending'},
      );
      await tester.tap(find.text('My requests'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Request'));
      await tester.pumpAndSettle();
      expect(find.text('Request Timeoff'), findsOneWidget);
      await tester.tap(find.byTooltip('Back').last);
      await tester.pumpAndSettle();
      expect(find.text('Timeoff Request'), findsOneWidget);
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(find.text('Open request'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
