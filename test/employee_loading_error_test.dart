import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:fl_mhis_hr/injector/injector.dart';
import 'package:fl_mhis_hr/models/model.dart';
import 'package:fl_mhis_hr/pages/employee/bloc/employee_bloc.dart';
import 'package:fl_mhis_hr/pages/employee/screen/employee_screen_v2.dart';
import 'package:fl_mhis_hr/service/api.dart';
import 'package:fl_mhis_hr/widget/loading_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

DioException _error(int status, String message) {
  final request = RequestOptions(path: 'employee/datatable');
  return DioException(
    requestOptions: request,
    response: Response<dynamic>(
      requestOptions: request,
      statusCode: status,
      data: {'message': message},
    ),
  );
}

class _ErrorAdapter implements HttpClientAdapter {
  _ErrorAdapter(this.status);
  final int status;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async =>
      ResponseBody.fromString('{"message":"Failed"}', status, headers: {
        Headers.contentTypeHeader: ['application/json'],
      });
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({'token': 'test-token'});
  });

  testWidgets('loading uses shimmer and errors appear inline with retry',
      (tester) async {
    final firstRequest = Completer<Pagination>();
    var requests = 0;
    final bloc = EmployeeBloc(getEmployees: (_) {
      requests++;
      if (requests == 1) return firstRequest.future;
      if (requests == 2) return Future.error(_error(500, 'Server unavailable'));
      return Future.value(Pagination(data: []));
    });
    addTearDown(bloc.close);
    await tester.pumpWidget(BlocProvider.value(
      value: bloc,
      child: const MaterialApp(home: EmployeeScreenV2()),
    ));
    await tester.pump();
    expect(find.byType(LoadingShimmer), findsNWidgets(3));
    expect(find.byType(CircularProgressIndicator), findsNothing);

    firstRequest.completeError(_error(403, 'Access denied'));
    await tester.pumpAndSettle();
    expect(find.text('Access denied'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('Server unavailable'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);

    await tester.enterText(find.byType(TextFormField), 'Jane');
    await tester.pumpAndSettle();
    expect(find.text('No Data'), findsOneWidget);
    expect(bloc.state.isError, isFalse);
    expect(tester.takeException(), isNull);
  });

  test('load more retains employees on error and can be retried', () async {
    var requests = 0;
    final bloc = EmployeeBloc(getEmployees: (_) async {
      requests++;
      if (requests == 2) throw _error(500, 'Page unavailable');
      if (requests == 1) {
        return Pagination(
          data: [
            {'id': 1}
          ],
          nextPageUrl: 'https://example.test/api/employee/datatable?page=2',
        );
      }
      return Pagination(data: [
        {'id': 2}
      ]);
    });
    addTearDown(bloc.close);

    var result = bloc.stream.firstWhere((state) => state.isSuccess);
    bloc.add(const OnSearchChanged({}));
    await result;
    result = bloc.stream.firstWhere((state) => state.loadMoreError);
    bloc.add(const OnLoadMore({}));
    await result;
    expect(bloc.state.employees2, hasLength(1));
    expect(bloc.state.errorMessage, 'Page unavailable');

    result = bloc.stream.firstWhere((state) =>
        !state.loadMore &&
        !state.loadMoreError &&
        state.employees2?.length == 2);
    bloc.add(const OnLoadMore({}));
    await result;
    expect(bloc.state.employees2, hasLength(2));
  });

  test('an older failed search does not replace newer results', () async {
    final oldRequest = Completer<Pagination>();
    final bloc = EmployeeBloc(getEmployees: (params) {
      if (params['search'] == 'old') return oldRequest.future;
      return Future.value(Pagination(data: []));
    });
    addTearDown(bloc.close);

    bloc.add(const OnSearchChanged({'search': 'old'}));
    await bloc.stream.firstWhere((state) => state.isLoading);
    final result = bloc.stream.firstWhere((state) => state.isSuccess);
    bloc.add(const OnSearchChanged({'search': 'new'}));
    await result;
    oldRequest.completeError(_error(500, 'Old request failed'));
    await Future<void>.delayed(Duration.zero);
    expect(bloc.state.isError, isFalse);
    expect(bloc.state.employees2, isEmpty);
  });

  test('locally handled 403 and server errors do not clear session', () async {
    locator.registerSingleton<NavigationService>(NavigationService());
    addTearDown(() => locator.unregister<NavigationService>());
    for (final status in [403, 500]) {
      final dio = await Api.dioClient(
        extra: {DioInterceptors.handleErrorsLocally: true},
      );
      dio.httpClientAdapter = _ErrorAdapter(status);
      await expectLater(
        dio.get<dynamic>('https://example.test/api/employee/datatable'),
        throwsA(isA<DioException>()
            .having((error) => error.response?.statusCode, 'status', status)),
      );
      dio.close();
    }
    expect((await SharedPreferences.getInstance()).getString('token'),
        'test-token');
  });
}
