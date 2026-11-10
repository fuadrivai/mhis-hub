import 'dart:async';

import 'package:fl_mhis_hr/models/v2/models.dart';
import 'package:fl_mhis_hr/pages/request_approval/bloc/request_approval_bloc.dart';
import 'package:fl_mhis_hr/pages/request_approval/screen/my_approval_widget.dart';
import 'package:fl_mhis_hr/pages/request_approval/screen/my_request_widget.dart';
import 'package:fl_mhis_hr/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class TestRequestBloc extends RequestApprovalBloc {
  TestRequestBloc({super.loadRequests, super.loadApprovals});

  @override
  void add(RequestApprovalEvent event) {
    if (event is! OnGetBalance) super.add(event);
  }
}

ApprovalRequest request(int id) => ApprovalRequest(
      id: id,
      status: 'pending',
      type: Timeoff(name: 'Leave $id'),
    );

List<Approval> approvals() => List.generate(
      20,
      (index) => Approval(
        id: index + 1,
        status: 'pending',
        approvalRequest: request(index + 1),
      ),
    );

void main() {
  for (final isApproval in [true, false]) {
    testWidgets(
        '${isApproval ? "approvals" : "requests"} refresh in background after return',
        (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final nextApprovals = Completer<List<Approval>>();
      final nextRequests = Completer<List<ApprovalRequest>>();
      var calls = 0;
      final maps = <Map<String, dynamic>>[];
      final bloc = TestRequestBloc(
        loadApprovals: (map) {
          maps.add(Map.of(map));
          return ++calls == 1
              ? Future.value(approvals())
              : nextApprovals.future;
        },
        loadRequests: (map) {
          maps.add(Map.of(map));
          return ++calls == 1
              ? Future.value(List.generate(20, (index) => request(index + 1)))
              : nextRequests.future;
        },
      );
      addTearDown(bloc.close);
      final router = GoRouter(routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => Scaffold(
            body:
                isApproval ? const MyApprovalWidget() : const MyRequestWidget(),
          ),
        ),
        GoRoute(
          path: '/detail',
          name: 'timeoff-detail',
          builder: (context, state) => Scaffold(
            body: TextButton(
              onPressed: () => context.pop(),
              child: const Text('Return'),
            ),
          ),
        ),
      ]);
      addTearDown(router.dispose);

      await tester.pumpWidget(BlocProvider<RequestApprovalBloc>.value(
        value: bloc,
        child: MaterialApp.router(routerConfig: router),
      ));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Leave 10'));
      await tester.pumpAndSettle();
      final scroll = tester.widget<SingleChildScrollView>(
          find.byType(SingleChildScrollView).first);
      final offset = scroll.controller!.offset;
      expect(offset, greaterThan(0));
      await tester.tap(find.text('Leave 10'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Return'));
      await tester.pumpAndSettle();

      expect(calls, 2);
      expect(maps[1], maps[0]);
      expect(scroll.controller!.offset, closeTo(offset, 0.1));
      expect(find.text('Leave 10'), findsOneWidget);
      expect(find.byType(LoadingWidget), findsNothing);
      expect(bloc.state.isApprovalLoading, isFalse);
      expect(bloc.state.isRequestLoading, isFalse);
      final itemTop = tester.getTopLeft(find.text('Leave 10')).dy;

      if (isApproval) {
        nextApprovals.complete(approvals().sublist(1));
      } else {
        nextRequests.complete(List.generate(19, (index) => request(index + 2)));
      }
      await tester.pumpAndSettle();
      expect(tester.getTopLeft(find.text('Leave 10')).dy, closeTo(itemTop, 1));
      expect(find.text('Leave 1'), findsNothing);
      expect(find.text('Leave 10'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  for (final isApproval in [true, false]) {
    testWidgets(
        'background failure keeps ${isApproval ? "approvals" : "requests"}',
        (tester) async {
      final nextApprovals = Completer<List<Approval>>();
      final nextRequests = Completer<List<ApprovalRequest>>();
      var calls = 0;
      final bloc = TestRequestBloc(
        loadApprovals: (_) =>
            ++calls == 1 ? Future.value(approvals()) : nextApprovals.future,
        loadRequests: (_) =>
            ++calls == 1 ? Future.value([request(1)]) : nextRequests.future,
      );
      addTearDown(bloc.close);
      await tester.pumpWidget(BlocProvider<RequestApprovalBloc>.value(
        value: bloc,
        child: MaterialApp(
          home: Scaffold(
            body:
                isApproval ? const MyApprovalWidget() : const MyRequestWidget(),
          ),
        ),
      ));
      await tester.pumpAndSettle();
      if (isApproval) {
        bloc.add(const OnInitApproval({'status': 'pending'}, background: true));
      } else {
        bloc.add(const OnInitRequest({}, background: true));
      }
      await tester.pump();
      if (isApproval) {
        nextApprovals.completeError(Exception('offline'));
      } else {
        nextRequests.completeError(Exception('offline'));
      }
      await tester.pumpAndSettle();
      expect(find.text('Leave 1'), findsOneWidget);
      expect(
        find.textContaining(
            'Failed to refresh ${isApproval ? "approvals" : "requests"}'),
        findsOneWidget,
      );
      expect(
          isApproval ? bloc.state.approvals.length : bloc.state.requests.length,
          isApproval ? 20 : 1);
    });
  }

  testWidgets('older refresh cannot overwrite newer filter results',
      (tester) async {
    final old = Completer<List<Approval>>();
    final newer = Completer<List<Approval>>();
    final bloc = TestRequestBloc(
      loadApprovals: (map) =>
          map['status'] == 'pending' ? old.future : newer.future,
    );
    addTearDown(bloc.close);
    bloc.add(const OnInitApproval({'status': 'pending'}, background: true));
    await tester.pump();
    bloc.add(const OnInitApproval({'status': 'approved'}));
    await tester.pump();
    newer.complete([Approval(id: 2, status: 'approved')]);
    await tester.pump();
    old.complete([Approval(id: 1, status: 'pending')]);
    await tester.pump();
    expect(bloc.state.approvals.single.id, 2);
    expect(bloc.state.isApprovalLoading, isFalse);
  });
}
