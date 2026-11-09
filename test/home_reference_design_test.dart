import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/pages/home/bloc/home_bloc.dart';
import 'package:fl_mhis_hr/pages/home/screen/announcement_card.dart';
import 'package:fl_mhis_hr/pages/home/screen/home_header.dart';
import 'package:fl_mhis_hr/widget/card_clockinout.dart';
import 'package:fl_mhis_hr/widget/information_home_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void main() {
  for (final size in [const Size(320, 568), const Size(1024, 768)]) {
    testWidgets('home cards fit ${size.width}x${size.height}', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final bloc = HomeBloc();
      addTearDown(bloc.close);
      await tester.pumpWidget(BlocProvider.value(
        value: bloc,
        child: const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(children: [
                CardClockInOut(shift: null),
                InformationHomeWidget(),
                AnnouncementCard(),
              ]),
            ),
          ),
        ),
      ));
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.text('Clock In'), findsOneWidget);
      expect(find.text('Clock Out'), findsOneWidget);
      expect(find.text('Information'), findsOneWidget);
      expect(find.text('Announcement'), findsOneWidget);
      expect(find.text('All Apps'), findsOneWidget);
      final icon = tester.widget<FaIcon>(
        find
            .descendant(
              of: find.byType(InformationHomeWidget),
              matching: find.byType(FaIcon),
            )
            .first,
      );
      expect(
          icon.color,
          Common.seededColor(Menu.front.first.seed,
              saturation: 0.72, lightness: 0.44));
      await tester.ensureVisible(find.text('All Apps'));
      await tester.tap(find.text('All Apps'));
      await tester.pumpAndSettle();
      expect(find.text('All Apps'), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('header displays time-based greeting and profile fallback',
      (tester) async {
    for (final entry in {
      8: 'Good Morning',
      13: 'Good Afternoon',
      16: 'Good Evening',
      20: 'Good Night',
    }.entries) {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: HomeHeader(name: 'Jane', avatar: null, hour: entry.key),
        ),
      ));
      expect(find.text(entry.value), findsOneWidget);
      expect(find.text('Jane'), findsOneWidget);
      expect(tester.getTopLeft(find.text('Jane')).dy,
          greaterThan(tester.getBottomLeft(find.text(entry.value)).dy));
      expect(find.byIcon(Icons.person), findsOneWidget);
      expect(tester.getTopLeft(find.byTooltip('Profile photo')).dx,
          lessThan(tester.getTopLeft(find.text(entry.value)).dx));
      expect(tester.getTopLeft(find.text('Jane')).dx,
          tester.getTopLeft(find.text(entry.value)).dx);
    }
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: HomeHeader(
          name: null,
          avatar: null,
          hour: 8,
          profileError: true,
        ),
      ),
    ));
    expect(find.text('Good Morning'), findsOneWidget);
    expect(find.byTooltip('Unable to load profile photo'), findsOneWidget);
  });

  testWidgets('header fits narrow screen with a long employee name',
      (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: Padding(
          padding: EdgeInsets.all(16),
          child: HomeHeader(
            name: 'A very long employee name that must fit on a small screen',
            avatar: null,
            hour: 13,
          ),
        ),
      ),
    ));
    expect(tester.takeException(), isNull);
    expect(find.byTooltip('Profile photo'), findsOneWidget);
    expect(find.text('Good Afternoon'), findsOneWidget);
  });

  testWidgets('attendance buttons retain destinations', (tester) async {
    final router = GoRouter(routes: [
      GoRoute(
        path: '/',
        builder: (context, state) =>
            const Scaffold(body: CardClockInOut(shift: null)),
      ),
      GoRoute(
        path: '/in',
        name: 'clockin',
        builder: (context, state) => const Scaffold(body: Text('In page')),
      ),
      GoRoute(
        path: '/out',
        name: 'clockout',
        builder: (context, state) => const Scaffold(body: Text('Out page')),
      ),
    ]);
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.tap(find.text('Clock In'));
    await tester.pumpAndSettle();
    expect(find.text('In page'), findsOneWidget);
    router.go('/');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Clock Out'));
    await tester.pumpAndSettle();
    expect(find.text('Out page'), findsOneWidget);
  });
}
