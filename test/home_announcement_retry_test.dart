import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:fl_mhis_hr/injector/injector.dart';
import 'package:fl_mhis_hr/pages/home/bloc/home_bloc.dart';
import 'package:fl_mhis_hr/pages/home/screen/announcement_card.dart';
import 'package:fl_mhis_hr/service/api.dart';
import 'package:fl_mhis_hr/service/restclient.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _AnnouncementAdapter implements HttpClientAdapter {
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
    if (requests < 3) {
      return ResponseBody.fromString(
        requests == 1 ? '{"message":"Forbidden"}' : '<html>Forbidden</html>',
        403,
        headers: {
          Headers.contentTypeHeader: [
            requests == 1 ? 'application/json' : 'text/html'
          ],
        },
      );
    }
    return ResponseBody.fromString(
      '[]',
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }
}

void main() {
  testWidgets('announcement retry keeps session and recovers after 403',
      (tester) async {
    SharedPreferences.setMockInitialValues({'token': 'test-token'});
    locator.registerSingleton<NavigationService>(NavigationService());
    addTearDown(() => locator.unregister<NavigationService>());

    final adapter = _AnnouncementAdapter();
    final dio = await Api.dioClient(
      extra: {DioInterceptors.handleForbiddenLocally: true},
    );
    dio.httpClientAdapter = adapter;
    addTearDown(dio.close);
    final client = RestClient(dio, baseUrl: 'https://example.test/api/');
    final bloc = HomeBloc(getAnnouncements: client.getAnnouncement);
    addTearDown(bloc.close);

    await tester.pumpWidget(BlocProvider.value(
      value: bloc,
      child: const MaterialApp(
        home: Scaffold(body: AnnouncementCard()),
      ),
    ));

    bloc.add(const OnInitAnnouncement());
    await tester.pumpAndSettle();
    expect(find.text('Forbidden'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
    expect((await SharedPreferences.getInstance()).getString('token'),
        'test-token');

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('Retry'), findsOneWidget);
    expect(bloc.state.announcementError, isTrue);
    expect((await SharedPreferences.getInstance()).getString('token'),
        'test-token');

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(adapter.requests, 3);
    expect(bloc.state.announcementError, isFalse);
    expect(find.text('No announcements yet'), findsOneWidget);
    expect(find.text('Retry'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
