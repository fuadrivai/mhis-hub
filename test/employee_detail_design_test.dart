import 'dart:ui' as ui;

import 'package:fl_mhis_hr/models/v2/models.dart';
import 'package:fl_mhis_hr/pages/employee/screen/employee_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  for (final size in [const Size(320, 568), const Size(1024, 768)]) {
    testWidgets('employee detail fits $size and preserves navigation',
        (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      tester.view.padding = const FakeViewPadding(top: 24, bottom: 24);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPadding);

      final person = Person(
        fullname: 'Jane Doe',
        email: 'jane@example.com',
        birthDate: '2000-01-02',
        gendre: '2',
        maritalStatus: '1',
      );
      final employee = Employee(
        personal: person,
        employment: Employment(
          employeeId: 'EMP-123',
          employmentStatus: 'Permanent',
        ),
      );
      final recorder = ui.PictureRecorder();
      Canvas(recorder);
      final image = recorder.endRecording().toImageSync(1, 1);
      final provider = NetworkImage(person.avatarLink);
      PaintingBinding.instance.imageCache.putIfAbsent(
        provider,
        () =>
            OneFrameImageStreamCompleter(Future.value(ImageInfo(image: image))),
      );
      addTearDown(() => PaintingBinding.instance.imageCache.evict(provider));

      final router = GoRouter(routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            body: TextButton(
              onPressed: () => context.push('/details'),
              child: const Text('Open'),
            ),
          ),
          routes: [
            GoRoute(
              path: 'details',
              builder: (context, state) =>
                  EmployeeDetailScreen(employee: employee),
            ),
          ],
        ),
      ]);
      addTearDown(router.dispose);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Employee Details'), findsOneWidget);
      expect(find.text('Jane Doe'), findsWidgets);
      expect(find.text('Female'), findsOneWidget);
      expect(find.text('02 January 2000'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Employment'));
      await tester.pumpAndSettle();
      expect(find.text('Employment information'), findsOneWidget);
      expect(find.text('EMP-123'), findsOneWidget);
      expect(find.text('Permanent'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(find.text('Open'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
