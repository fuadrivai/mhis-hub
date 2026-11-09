import 'package:fl_mhis_hr/models/model.dart' as legacy;
import 'package:fl_mhis_hr/models/v2/models.dart' as v2;
import 'package:fl_mhis_hr/pages/home/bloc/home_bloc.dart' as home;
import 'package:fl_mhis_hr/pages/home/screen/calendar_screen.dart';
import 'package:fl_mhis_hr/pages/home/screen/newsletter_screen.dart';
import 'package:fl_mhis_hr/pages/home/screen/sop_screen.dart';
import 'package:fl_mhis_hr/pages/kpi/bloc/kpi_bloc.dart' as kpi;
import 'package:fl_mhis_hr/pages/kpi/screen/kpi_screen.dart';
import 'package:fl_mhis_hr/pages/payslip/bloc/payslip_bloc.dart' as pay;
import 'package:fl_mhis_hr/pages/payslip/screen/paymentslip_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class FakeHomeBloc extends home.HomeBloc {
  FakeHomeBloc(this.current);
  final home.HomeState current;
  final events = <home.HomeEvent>[];
  @override
  home.HomeState get state => current;
  @override
  void add(home.HomeEvent event) => events.add(event);
}

class FakePayBloc extends pay.PayslipBloc {
  FakePayBloc(this.current);
  final pay.PayslipState current;
  final events = <pay.PayslipEvent>[];
  @override
  pay.PayslipState get state => current;
  @override
  void add(pay.PayslipEvent event) => events.add(event);
}

class FakeKpiBloc extends kpi.KpiBloc {
  FakeKpiBloc(this.current);
  final kpi.KpiState current;
  final events = <kpi.KpiEvent>[];
  @override
  kpi.KpiState get state => current;
  @override
  void add(kpi.KpiEvent event) => events.add(event);
}

void main() {
  setUpAll(() async => initializeDateFormatting('en'));

  for (final size in [const Size(320, 568), const Size(1024, 768)]) {
    testWidgets('information pages display and navigate at $size',
        (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      tester.view.padding = const FakeViewPadding(top: 24, bottom: 24);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPadding);
      final homeBloc = FakeHomeBloc(home.HomeState(
        sopLoading: false,
        sops: [const v2.Sop(title: 'Procedure', link: 'https://example.com')],
        newsletterLoading: false,
        newsletters: [v2.Newsletter(newsletter: 'School news', level: 'All')],
        calendarLoading: false,
        calendarSchool: const [],
      ));
      final payBloc = FakePayBloc(pay.PayslipState(payslips: [
        legacy.Payslip(periode: '2026-11-01'),
      ]));
      final kpiBloc = FakeKpiBloc(
          kpi.KpiState(kpi: legacy.Kpi(sKL: 95, kPIScoreAutomate: 12345)));
      addTearDown(homeBloc.close);
      addTearDown(payBloc.close);
      addTearDown(kpiBloc.close);
      final routes = <String, Widget>{
        'SOP': const SopScreen(),
        'Newsletter': const NewsletterScreen(),
        'Payment Slip': const PaymentslipScreen(),
        'KPI Score': const KpiScreen(),
        'School Calendar': const CalendarScreen(),
      };
      final router = GoRouter(routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            body: ListView(
              children: routes.keys
                  .map((key) => TextButton(
                        onPressed: () => context
                            .push('/${routes.keys.toList().indexOf(key)}'),
                        child: Text('Open $key'),
                      ))
                  .toList(),
            ),
          ),
          routes: [
            for (var i = 0; i < routes.length; i++)
              GoRoute(
                path: '$i',
                builder: (context, state) => routes.values.elementAt(i),
              ),
          ],
        ),
      ]);
      addTearDown(router.dispose);
      await tester.pumpWidget(MultiBlocProvider(
        providers: [
          BlocProvider<home.HomeBloc>.value(value: homeBloc),
          BlocProvider<pay.PayslipBloc>.value(value: payBloc),
          BlocProvider<kpi.KpiBloc>.value(value: kpiBloc),
        ],
        child: MaterialApp.router(routerConfig: router),
      ));
      for (final title in routes.keys) {
        await tester.tap(find.text('Open $title'));
        await tester.pumpAndSettle();
        expect(find.text(title), findsWidgets);
        if (title == 'SOP') expect(find.text('Procedure'), findsOneWidget);
        if (title == 'Newsletter') {
          expect(find.text('School news'), findsOneWidget);
        }
        if (title == 'Payment Slip') {
          expect(find.text('Periode : November 2026'), findsOneWidget);
          await tester.tap(find.text('Periode : November 2026'));
          await tester.pump();
          expect(find.text('Unable to open payment slip link'), findsOneWidget);
        }
        if (title == 'KPI Score') {
          expect(find.text('SKL'), findsOneWidget);
          await tester.ensureVisible(find.text('12345'));
          expect(find.text('12345'), findsOneWidget);
        }
        if (title == 'School Calendar') {
          expect(find.byType(SfCalendar), findsOneWidget);
          await tester.tap(find.byTooltip('Refresh calendar'));
          expect(
              homeBloc.events.whereType<home.OnInitCalendar>(), hasLength(2));
        }
        await tester.tap(find.byTooltip('Back'));
        await tester.pumpAndSettle();
        expect(find.text('Open $title'), findsOneWidget);
      }
      expect(homeBloc.events.whereType<home.OnGetSop>(), hasLength(1));
      expect(homeBloc.events.whereType<home.OnGetNewsletter>(), hasLength(1));
      expect(payBloc.events.whereType<pay.OnInit>(), hasLength(1));
      expect(kpiBloc.events.whereType<kpi.OnGetKpi>(), hasLength(1));
      expect(kpiBloc.events.whereType<kpi.OnGetEmployee>(), hasLength(1));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('empty and error states offer retries', (tester) async {
    final homeBloc = FakeHomeBloc(const home.HomeState(
      sopLoading: false,
      sopError: true,
      sopErrorMessage: 'Network error',
      newsletterLoading: false,
      newsletterError: true,
      newsletterErrorMessage: 'Offline',
      calendarLoading: false,
      calendarError: true,
    ));
    final payBloc = FakePayBloc(const pay.PayslipState());
    addTearDown(homeBloc.close);
    addTearDown(payBloc.close);
    Future<void> show(Widget child) async {
      await tester.pumpWidget(MultiBlocProvider(
        providers: [
          BlocProvider<home.HomeBloc>.value(value: homeBloc),
          BlocProvider<pay.PayslipBloc>.value(value: payBloc),
        ],
        child: MaterialApp(home: child),
      ));
      await tester.pump();
    }

    await show(const SopScreen());
    expect(find.text('Network error'), findsOneWidget);
    await tester.tap(find.text('Coba lagi'));
    expect(homeBloc.events.whereType<home.OnGetSop>(), hasLength(2));
    await show(const NewsletterScreen());
    expect(find.text('Offline'), findsOneWidget);
    await tester.tap(find.text('Refresh'));
    expect(homeBloc.events.whereType<home.OnGetNewsletter>(), hasLength(2));
    await show(const CalendarScreen());
    expect(find.text('Unable to load calendar'), findsOneWidget);
    await tester.tap(find.text('Try again'));
    expect(homeBloc.events.whereType<home.OnInitCalendar>(), hasLength(2));
    await show(const PaymentslipScreen());
    expect(find.text('No payment slips found'), findsOneWidget);
    await tester.tap(find.text('Refresh'));
    expect(payBloc.events.whereType<pay.OnInit>(), hasLength(2));
    expect(tester.takeException(), isNull);
  });
}
