import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:fl_mhis_hr/injector/injector.dart';
import 'package:fl_mhis_hr/pages/timeoff/bloc/timeoff_bloc.dart';
import 'package:fl_mhis_hr/pages/timeoff/screen/timeoff_screen.dart';
import 'package:fl_mhis_hr/service/api.dart';
import 'package:fl_mhis_hr/service/restclient.dart';
import 'package:fl_mhis_hr/widget/loading_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _TimeoffAdapter implements HttpClientAdapter {
  final firstRequest = Completer<void>();
  int requests = 0;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests++;
    if (requests == 1) await firstRequest.future;
    final success = requests == 3 || requests == 5;
    final body = success
        ? (requests == 3
            ? '[{"id":1,"name":"Annual Leave","is_active":true}]'
            : '[]')
        : '{"message":"Timeoff unavailable"}';
    return ResponseBody.fromString(
      body,
      success ? 200 : (requests == 1 ? 403 : 500),
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }
}

void main() {
  testWidgets('timeoff shows shimmer, inline errors and recovers on retry',
      (tester) async {
    SharedPreferences.setMockInitialValues({'token': 'test-token'});
    locator.registerSingleton<NavigationService>(NavigationService());
    addTearDown(() => locator.unregister<NavigationService>());
    final adapter = _TimeoffAdapter();
    final dio = await Api.dioClient(
      extra: {DioInterceptors.handleErrorsLocally: true},
    );
    dio.httpClientAdapter = adapter;
    addTearDown(dio.close);
    final client = RestClient(dio, baseUrl: 'https://example.test/api/');
    final bloc = TimeoffBloc(getTimeoffs: client.getTimeoffs);
    addTearDown(bloc.close);

    await tester.pumpWidget(BlocProvider.value(
      value: bloc,
      child: const MaterialApp(home: TimeoffScreen()),
    ));
    await tester.pump();
    expect(find.byType(LoadingShimmer), findsNWidgets(3));
    expect(find.byType(CircularProgressIndicator), findsNothing);

    adapter.firstRequest.complete();
    await tester.pumpAndSettle();
    expect(find.text('Timeoff unavailable'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
    expect((await SharedPreferences.getInstance()).getString('token'),
        'test-token');

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('Timeoff unavailable'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('Annual Leave'), findsOneWidget);
    expect(find.text('Retry'), findsNothing);

    bloc.add(const OnInit());
    await tester.pumpAndSettle();
    expect(find.text('Timeoff unavailable'), findsOneWidget);
    expect(find.text('Annual Leave'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('No timeoff types available.'), findsOneWidget);
    expect(bloc.state.isError, isFalse);
    expect(adapter.requests, 5);
    expect(tester.takeException(), isNull);
  });
}
