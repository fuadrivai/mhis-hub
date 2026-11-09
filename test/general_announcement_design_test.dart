import 'package:fl_mhis_hr/models/v2/models.dart';
import 'package:fl_mhis_hr/pages/general_announcement/bloc/general_announcement_bloc.dart';
import 'package:fl_mhis_hr/pages/general_announcement/screen/general_announcement_screen.dart';
import 'package:fl_mhis_hr/pages/general_announcement/screen/general_announcement_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';

class RecordingAnnouncementBloc extends GeneralAnnouncementBloc {
  RecordingAnnouncementBloc(this.current);

  final GeneralAnnouncementState current;
  final events = <GeneralAnnouncementEvent>[];

  @override
  GeneralAnnouncementState get state => current;

  @override
  void add(GeneralAnnouncementEvent event) => events.add(event);
}

void main() {
  setUpAll(() async => initializeDateFormatting('en'));

  for (final size in [const Size(320, 568), const Size(1024, 768)]) {
    testWidgets('announcement list and details fit $size', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      tester.view.padding = const FakeViewPadding(top: 24, bottom: 24);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPadding);
      final announcement = Announcement(
        title: 'Important company announcement',
        content: '<p>Details for everyone</p>',
        publishAt: '2026-11-09',
        allEmployees: false,
        branches: [Branch(name: 'Head office')],
        category: AnnouncementCategory(name: 'General'),
        link: 'https://example.com',
      );
      final bloc = RecordingAnnouncementBloc(
          GeneralAnnouncementState(announcements: [announcement]));
      addTearDown(bloc.close);
      final router = GoRouter(routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            body: TextButton(
              onPressed: () => context.go('/announcements'),
              child: const Text('Open announcements'),
            ),
          ),
          routes: [
            GoRoute(
              path: 'announcements',
              builder: (context, state) => const GeneralAnnouncementScreen(),
              routes: [
                GoRoute(
                  path: 'view',
                  name: 'general-announcement-view',
                  builder: (context, state) => GeneralAnnouncementView(
                    announcement:
                        (state.extra as Map<String, dynamic>)['announcement']
                            as Announcement,
                  ),
                ),
              ],
            ),
          ],
        ),
      ]);
      addTearDown(router.dispose);
      await tester.pumpWidget(BlocProvider<GeneralAnnouncementBloc>.value(
        value: bloc,
        child: MaterialApp.router(routerConfig: router),
      ));
      await tester.tap(find.text('Open announcements'));
      await tester.pumpAndSettle();
      expect(bloc.events.whereType<OnInit>(), hasLength(1));
      expect(find.text('Unknown creator'), findsOneWidget);
      expect(find.text('09 Nov 2026'), findsOneWidget);
      await tester.tap(find.text('Important company announcement'));
      await tester.pumpAndSettle();
      expect(find.text('Announcement details'), findsOneWidget);
      expect(find.text('Head office'), findsOneWidget);
      expect(find.text('General'), findsOneWidget);
      expect(find.text('Details for everyone'), findsOneWidget);
      await tester.ensureVisible(find.text('Link'));
      expect(find.text('Link'), findsOneWidget);
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(find.text('Stay up to date with the latest news'), findsOneWidget);
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(find.text('Open announcements'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('empty announcements can be refreshed', (tester) async {
    final bloc = RecordingAnnouncementBloc(const GeneralAnnouncementState());
    addTearDown(bloc.close);
    await tester.pumpWidget(BlocProvider<GeneralAnnouncementBloc>.value(
      value: bloc,
      child: const MaterialApp(home: GeneralAnnouncementScreen()),
    ));
    await tester.pump();
    expect(find.text('No announcements found'), findsOneWidget);
    await tester.tap(find.text('Refresh'));
    expect(bloc.events.whereType<OnInit>(), hasLength(2));
  });

  testWidgets('detail handles missing optional information', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: GeneralAnnouncementView(
        announcement: Announcement(title: 'Update', allEmployees: null),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Uncategorized'), findsOneWidget);
    expect(find.text('Post on : -'), findsOneWidget);
    expect(find.text('From Unknown creator'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('detail shows all employees', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: GeneralAnnouncementView(
        announcement: Announcement(allEmployees: true),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('All Employees'), findsOneWidget);
  });
}
