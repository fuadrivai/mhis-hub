import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:fl_mhis_hr/injector/injector.dart';
import 'package:fl_mhis_hr/pages/login/bloc/login_bloc.dart';
import 'package:fl_mhis_hr/pages/login/screen/inactive_account_screen.dart';
import 'package:fl_mhis_hr/pages/login/screen/login_screen.dart';
import 'package:fl_mhis_hr/service/restclient.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _ForbiddenAdapter implements HttpClientAdapter {
  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async =>
      ResponseBody.fromString('Forbidden', 403);
}

void main() {
  testWidgets('login 403 shows inactive page and allows returning to login',
      (tester) async {
    SharedPreferences.setMockInitialValues({'token': 'old-token'});
    locator.registerSingleton<NavigationService>(NavigationService());
    addTearDown(() => locator.unregister<NavigationService>());
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test/api/'))
      ..httpClientAdapter = _ForbiddenAdapter();
    dio.interceptors.add(DioInterceptors(dio));
    addTearDown(dio.close);
    final bloc = LoginBloc(
      getMessagingToken: () async => null,
      login: (data) =>
          RestClient(dio, baseUrl: 'https://example.test/api/').onLogin(data),
    );
    addTearDown(bloc.close);
    final router = GoRouter(
      initialLocation: '/auth',
      routes: [
        GoRoute(path: '/auth', builder: (_, __) => const LoginScreen()),
        GoRoute(
          path: '/account-inactive',
          builder: (_, __) => const InactiveAccountScreen(),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(BlocProvider.value(
      value: bloc,
      child: MaterialApp.router(routerConfig: router),
    ));

    await tester.enterText(find.byType(TextField).first, 'user@example.com');
    await tester.enterText(find.byType(TextField).last, 'password');
    await tester.ensureVisible(find.text('Sign In'));
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    expect(find.text('ACCOUNT INACTIVE'), findsOneWidget);
    expect(find.textContaining('contact your administrator'), findsOneWidget);
    expect(find.text('Error'), findsNothing);
    expect((await SharedPreferences.getInstance()).getString('token'),
        'old-token');

    await tester.ensureVisible(find.text('Back to Login'));
    await tester.tap(find.text('Back to Login'));
    await tester.pumpAndSettle();
    expect(find.text('Sign In'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('other login errors remain errors and a retry resets inactive state',
      () async {
    var status = 403;
    final bloc = LoginBloc(
      getMessagingToken: () async => null,
      login: (_) async {
        final options = RequestOptions(path: 'login');
        throw DioException(
          requestOptions: options,
          response: Response<dynamic>(
            requestOptions: options,
            statusCode: status,
            data: {'message': 'Invalid credentials'},
          ),
        );
      },
    );
    addTearDown(bloc.close);

    bloc.add(OnLogin({'password': 'password'}));
    await expectLater(
        bloc.stream,
        emitsThrough(isA<LoginState>()
            .having((state) => state.isInactive, 'isInactive', true)));
    status = 422;
    bloc.add(OnLogin({'password': 'password'}));
    await expectLater(
        bloc.stream,
        emitsThrough(isA<LoginState>()
            .having((state) => state.isError, 'isError', true)));
    expect(bloc.state.isInactive, isFalse);
    expect(bloc.state.errorMessage, 'Invalid credentials');
  });
}
