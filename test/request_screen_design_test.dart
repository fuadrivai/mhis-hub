import 'package:fl_mhis_hr/pages/request_approval/bloc/request_approval_bloc.dart';
import 'package:fl_mhis_hr/pages/request_approval/screen/request_screen.dart';
import 'package:fl_mhis_hr/pages/timeoff/bloc/timeoff_bloc.dart' as timeoff;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class RecordingRequestBloc extends RequestApprovalBloc {
  final events = <RequestApprovalEvent>[];

  @override
  RequestApprovalState get state =>
      const RequestApprovalState(isBalanceEmpty: true);

  @override
  void add(RequestApprovalEvent event) => events.add(event);
}

class RecordingTimeoffBloc extends timeoff.TimeoffBloc {
  @override
  void add(timeoff.TimeoffEvent event) {}
}

void main() {
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
      expect(bloc.events.whereType<OnInitApproval>(), isNotEmpty);
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
