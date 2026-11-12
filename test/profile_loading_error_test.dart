import 'dart:async';
import 'package:dio/dio.dart';
import 'package:fl_mhis_hr/injector/injector.dart';
import 'package:fl_mhis_hr/pages/profile/bloc/profile_bloc.dart';
import 'package:fl_mhis_hr/pages/profile/screen/profile_screen.dart';
import 'package:fl_mhis_hr/service/api.dart';
import 'package:fl_mhis_hr/service/restclient.dart';
import 'package:fl_mhis_hr/widget/loading_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _ProfileAdapter implements HttpClientAdapter {
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
    return ResponseBody.fromString(
      success
          ? '{"id":1,"personal":{"fullname":"Jane"}}'
          : '{"message":"Profile unavailable"}',
      success ? 200 : (requests == 1 ? 403 : 500),
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }
}

void main() {
  testWidgets('profile uses shimmer and recovers from inline errors', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'token': 'test-token'});
    PackageInfo.setMockInitialValues(
      appName: 'Test',
      packageName: 'test',
      version: '1.0',
      buildNumber: '1',
      buildSignature: '',
    );
    const channel = MethodChannel('plugins.flutter.io/local_auth');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'getAvailableBiometrics') return <String>[];
      throw PlatformException(code: 'unexpected-method');
    });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null),
    );
    locator.registerSingleton<NavigationService>(NavigationService());
    addTearDown(() => locator.unregister<NavigationService>());
    final adapter = _ProfileAdapter();
    final dio = await Api.dioClient(
      extra: {DioInterceptors.handleErrorsLocally: true},
    );
    dio.httpClientAdapter = adapter;
    addTearDown(dio.close);
    final client = RestClient(dio, baseUrl: 'https://example.test/api/');
    final bloc = ProfileBloc(getProfile: client.getEmployeeProfile);
    addTearDown(bloc.close);

    await tester.pumpWidget(
      BlocProvider.value(
        value: bloc,
        child: const MaterialApp(home: ProfileScreen()),
      ),
    );
    await tester.pump();
    expect(find.text('Profile'), findsOneWidget);
    expect(find.byType(LoadingShimmer), findsNWidgets(3));
    expect(find.byType(CircularProgressIndicator), findsNothing);

    adapter.firstRequest.complete();
    await tester.pumpAndSettle();
    expect(find.text('Profile unavailable'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.byTooltip('Profile options'), findsOneWidget);
    expect(
      (await SharedPreferences.getInstance()).getString('token'),
      'test-token',
    );

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('Profile unavailable'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('Jane'), findsOneWidget);
    expect(find.text('Retry'), findsNothing);

    bloc.add(OnGetUserById());
    await tester.pumpAndSettle();
    expect(find.text('Profile unavailable'), findsOneWidget);
    expect(find.text('Jane'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('Jane'), findsOneWidget);
    expect(find.text('Retry'), findsNothing);
    expect(bloc.state.isError, isFalse);
    expect(adapter.requests, 5);
    expect(tester.takeException(), isNull);
  });
}
