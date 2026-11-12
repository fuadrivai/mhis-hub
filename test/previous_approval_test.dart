import 'dart:async';

import 'package:dio/dio.dart';
import 'package:fl_mhis_hr/models/v2/models.dart';
import 'package:fl_mhis_hr/pages/request_approval/bloc/request_approval_bloc.dart';
import 'package:fl_mhis_hr/pages/request_approval/screen/request_detail_screen.dart';
import 'package:fl_mhis_hr/service/restclient.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _RecordingBloc extends RequestApprovalBloc {
  _RecordingBloc(this.current);

  RequestApprovalState current;
  final events = <RequestApprovalEvent>[];
  final controller = StreamController<RequestApprovalState>.broadcast();

  @override
  RequestApprovalState get state => current;

  @override
  Stream<RequestApprovalState> get stream => controller.stream;

  @override
  void add(RequestApprovalEvent event) => events.add(event);

  void update(RequestApprovalState next) {
    current = next;
    controller.add(next);
  }

  @override
  Future<void> close() async {
    await controller.close();
    await super.close();
  }
}

void main() {
  test('previous endpoint uses approval ID and parses the response', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test/api/'));
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      expect(options.method, 'GET');
      expect(options.path, 'time/request/approval/10/previous');
      handler.resolve(Response(
        requestOptions: options,
        data: {
          'data': {
            'id': 9,
            'approval_request': {'id': 2},
          },
        },
      ));
    }));
    final result = await RestClient(dio).getPreviousApproval(10);
    expect(result.data?.id, 9);
    expect(result.data?.approvalRequest?.id, 2);
  });

  test('previous approval emits loading and success', () async {
    final pending = Completer<Approval?>();
    var requestedId = 0;
    final bloc = RequestApprovalBloc(loadPreviousApproval: (id) {
      requestedId = id;
      return pending.future;
    });
    addTearDown(bloc.close);
    final loading = bloc.stream.firstWhere((state) => state.isPreviousLoading);
    bloc.add(const OnGetPreviousApproval(10));
    await loading;
    expect(requestedId, 10);
    final completed =
        bloc.stream.firstWhere((state) => !state.isPreviousLoading);
    pending.complete(Approval(id: 9, approvalRequest: ApprovalRequest(id: 2)));
    final state = await completed;
    expect(state.previousApproval?.id, 9);
    expect(state.previousApproval?.approvalRequest?.id, 2);
  });

  test('previous approval reports empty and server errors', () async {
    for (final status in [404, 500]) {
      final bloc = RequestApprovalBloc(loadPreviousApproval: (id) async {
        final options = RequestOptions(path: '/previous');
        throw DioException(
          requestOptions: options,
          response: Response(
            requestOptions: options,
            statusCode: status,
            data: {'message': 'Server error'},
          ),
        );
      });
      final completed = bloc.stream.firstWhere(
          (state) => state.isPreviousEmpty || state.isPreviousError);
      bloc.add(const OnGetPreviousApproval(10));
      final state = await completed;
      expect(state.isPreviousEmpty, status == 404);
      expect(state.isPreviousError, status == 500);
      if (status == 500) expect(state.errorMessage, 'Server error');
      await bloc.close();
    }

    final bloc = RequestApprovalBloc(loadPreviousApproval: (_) async => null);
    final completed = bloc.stream.firstWhere((state) => state.isPreviousEmpty);
    bloc.add(const OnGetPreviousApproval(10));
    expect((await completed).isPreviousLoading, isFalse);
    await bloc.close();
  });

  testWidgets('previous navigation updates IDs and disables both buttons',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final bloc = _RecordingBloc(RequestApprovalState(
      request: ApprovalRequest(id: 1),
    ));
    addTearDown(bloc.close);
    await tester.pumpWidget(BlocProvider<RequestApprovalBloc>.value(
      value: bloc,
      child: const MaterialApp(
        home: RequestDetailScreen(requestId: 1, approvalId: 10),
      ),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Previous pending approval'));
    expect(bloc.events.whereType<OnGetPreviousApproval>().last.approvalId, 10);

    bloc.update(bloc.state.copyWith(isPreviousLoading: true));
    await tester.pump();
    expect(
      tester
          .widget<IconButton>(find.byWidgetPredicate((widget) =>
              widget is IconButton &&
              widget.tooltip == 'Previous pending approval'))
          .onPressed,
      isNull,
    );
    expect(
      tester
          .widget<IconButton>(find.byWidgetPredicate((widget) =>
              widget is IconButton &&
              widget.tooltip == 'Next pending approval'))
          .onPressed,
      isNull,
    );
    final previous = Approval(id: 9, approvalRequest: ApprovalRequest(id: 2));
    bloc.update(bloc.state.copyWith(
      isPreviousLoading: false,
      previousApproval: previous,
    ));
    await tester.pump();
    expect(bloc.events.whereType<OnInitDetail>().last.id, 2);
    await tester.tap(find.byTooltip('Next pending approval'));
    expect(bloc.events.whereType<OnGetNextApproval>().last.approvalId, 9);
    bloc.update(bloc.state.copyWith(isNextLoading: true));
    await tester.pump();
    bloc.update(bloc.state.copyWith(
      isNextLoading: false,
      nextApproval: Approval(id: 10, approvalRequest: ApprovalRequest(id: 1)),
    ));
    await tester.pump();
    await tester.tap(find.byTooltip('Previous pending approval'));
    expect(bloc.events.whereType<OnGetPreviousApproval>().last.approvalId, 10);
    bloc.update(bloc.state.copyWith(isPreviousLoading: true));
    await tester.pump();
    bloc.update(bloc.state.copyWith(
      isPreviousLoading: false,
      previousApproval: previous,
    ));
    await tester.pump();
    expect(
        bloc.events.whereType<OnInitDetail>().map((e) => e.id), [1, 2, 1, 2]);
    expect(tester.takeException(), isNull);
  });

  testWidgets('previous navigation shows empty and error messages',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final bloc = _RecordingBloc(RequestApprovalState(
      request: ApprovalRequest(id: 1),
    ));
    addTearDown(bloc.close);
    await tester.pumpWidget(BlocProvider<RequestApprovalBloc>.value(
      value: bloc,
      child: const MaterialApp(
        home: RequestDetailScreen(requestId: 1, approvalId: 10),
      ),
    ));
    await tester.pumpAndSettle();
    bloc.update(bloc.state.copyWith(isPreviousLoading: true));
    await tester.pump();
    bloc.update(bloc.state.copyWith(
      isPreviousLoading: false,
      isPreviousEmpty: true,
    ));
    await tester.pumpAndSettle();
    expect(find.text('No previous pending approvals'), findsOneWidget);
    expect(bloc.events.whereType<OnInitDetail>().map((e) => e.id), [1]);

    ScaffoldMessenger.of(tester.element(find.byType(RequestDetailScreen)))
        .removeCurrentSnackBar();
    bloc.update(bloc.state.copyWith(
      isPreviousLoading: true,
      isPreviousEmpty: false,
    ));
    await tester.pump();
    bloc.update(bloc.state.copyWith(
      isPreviousLoading: false,
      isPreviousError: true,
      errorMessage: 'Server error',
    ));
    await tester.pumpAndSettle();
    expect(find.text('Error: Server error'), findsOneWidget);
    expect(bloc.events.whereType<OnInitDetail>().map((e) => e.id), [1]);
  });
}
