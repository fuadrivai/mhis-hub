import 'package:fl_mhis_hr/models/v2/models.dart';
import 'package:fl_mhis_hr/pages/request_approval/bloc/request_approval_bloc.dart';
import 'package:fl_mhis_hr/pages/request_approval/screen/all_timeoff_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class RecordingAllTimeoffBloc extends RequestApprovalBloc {
  RecordingAllTimeoffBloc(this.testState);

  final RequestApprovalState testState;
  final events = <RequestApprovalEvent>[];

  @override
  RequestApprovalState get state => testState;

  @override
  void add(RequestApprovalEvent event) => events.add(event);
}

void main() {
  for (final size in [const Size(320, 568), const Size(1024, 768)]) {
    testWidgets('all timeoff actions and layout at $size', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final bloc = RecordingAllTimeoffBloc(RequestApprovalState(
        allTimeoffRequests: [
          ApprovalRequest(
            id: 17,
            status: 'pending',
            note: 'Annual leave',
            requester: Employee(personal: Person(fullname: 'Jane Doe')),
            type: Timeoff(name: 'Leave'),
          ),
        ],
      ));
      addTearDown(bloc.close);
      final router = GoRouter(routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            body: TextButton(
              onPressed: () => context.push('/requests'),
              child: const Text('Open requests'),
            ),
          ),
        ),
        GoRoute(
          path: '/requests',
          builder: (context, state) => const AllTimeoffScreen(),
        ),
        GoRoute(
          path: '/timeoff',
          builder: (context, state) =>
              const Scaffold(body: Text('Timeoff page')),
        ),
        GoRoute(
          path: '/detail',
          name: 'timeoff-detail',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>;
            return Scaffold(body: Text('Request ${extra['requestId']}'));
          },
        ),
      ]);
      addTearDown(router.dispose);
      await tester.pumpWidget(BlocProvider<RequestApprovalBloc>.value(
        value: bloc,
        child: MaterialApp.router(routerConfig: router),
      ));
      await tester.tap(find.text('Open requests'));
      await tester.pumpAndSettle();
      expect(find.text('Time off requests'), findsOneWidget);
      expect(find.textContaining('Jane Doe'), findsOneWidget);
      expect(find.text('Awaiting approval'), findsOneWidget);
      expect(bloc.events.whereType<OnInitAllTimeoff>(), hasLength(1));
      expect(bloc.events.whereType<OnInitAllTimeoffFilters>(), hasLength(1));
      expect(tester.takeException(), isNull);
      await tester.enterText(find.byType(TextField), ' Jane ');
      await tester.pump(const Duration(milliseconds: 450));
      expect(
          bloc.events.whereType<OnInitAllTimeoff>().last.map['requester_name'],
          'Jane');
      tester.testTextInput.hide();
      await tester.tap(find.byTooltip('Filter'));
      await tester.pumpAndSettle();
      expect(find.text('Filter requests'), findsOneWidget);
      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();
      expect(bloc.events.whereType<OnInitAllTimeoff>().last.map['status'],
          'pending');
      await tester.tap(find.textContaining('Jane Doe'));
      await tester.pumpAndSettle();
      expect(find.text('Request 17'), findsOneWidget);
      router.pop();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Request'));
      await tester.pumpAndSettle();
      expect(find.text('Timeoff page'), findsOneWidget);
      router.pop();
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(find.text('Open requests'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
