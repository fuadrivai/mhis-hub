import 'package:fl_mhis_hr/injector/injector.dart';
import 'package:fl_mhis_hr/models/v2/visitor.dart';
import 'package:fl_mhis_hr/pages/visitor/bloc/visitor_bloc.dart';
import 'package:fl_mhis_hr/pages/visitor/repository/visitor_api.dart';
import 'package:fl_mhis_hr/pages/visitor/screen/visitor_screen.dart';
import 'package:fl_mhis_hr/router/routers.dart';
import 'package:fl_mhis_hr/widget/information_home_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';

class EmptyVisitorApi extends VisitorApi {
  @override
  Future<VisitorPage<Visit>> visits(String endpoint,
          {int page = 1, Map<String, dynamic> filters = const {}}) async =>
      VisitorPage(data: const [], page: page, perPage: 20, total: 0);
}

void main() {
  setUpAll(() => initializeDateFormatting('en'));

  test('visitor destination is registered in the app router', () {
    setupLocator();
    expect(RouteNavigation.router.namedLocation('visitor'), '/visitor');
  });

  testWidgets('visitor opens from home and All Apps', (tester) async {
    final router = GoRouter(routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const Scaffold(body: HorizontalMenu()),
        routes: [
          GoRoute(
            path: 'visitor',
            name: 'visitor',
            builder: (context, state) => const VisitorScreen(),
          ),
        ],
      ),
    ]);
    addTearDown(router.dispose);
    await tester.pumpWidget(BlocProvider(
      create: (_) => VisitorBloc(api: EmptyVisitorApi()),
      child: MaterialApp.router(routerConfig: router),
    ));

    expect(find.text('Visitor'), findsOneWidget);
    expect(find.text('KPI Score'), findsNothing);
    await tester.tap(find.text('Visitor'));
    await tester.pumpAndSettle();
    expect(find.text('Invitations'), findsOneWidget);
    expect(find.text('Monitoring'), findsOneWidget);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('All Apps'));
    await tester.pumpAndSettle();
    expect(find.text('KPI Score'), findsOneWidget);
    await tester.tap(find.text('Visitor').last);
    await tester.pumpAndSettle();
    expect(find.text('Invitations'), findsOneWidget);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('All Apps'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
