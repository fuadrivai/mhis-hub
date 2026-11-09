import 'dart:ui' as ui;

import 'package:fl_mhis_hr/models/v2/models.dart';
import 'package:fl_mhis_hr/pages/employee/bloc/employee_bloc.dart';
import 'package:fl_mhis_hr/pages/employee/screen/employee_screen_v2.dart';
import 'package:fl_mhis_hr/pages/home/screen/contact_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecordingEmployeeBloc extends EmployeeBloc {
  RecordingEmployeeBloc([this.testState = const EmployeeState()]);

  final EmployeeState testState;
  final List<EmployeeEvent> events = [];

  @override
  EmployeeState get state => testState;

  @override
  void add(EmployeeEvent event) {
    events.add(event);
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  for (final size in [const Size(320, 568), const Size(1024, 768)]) {
    testWidgets('employee tab fits and retains search and filters at $size',
        (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final bloc = RecordingEmployeeBloc();
      addTearDown(bloc.close);
      await tester.pumpWidget(BlocProvider<EmployeeBloc>.value(
        value: bloc,
        child: const MaterialApp(home: EmployeeScreenV2()),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Contact'), findsOneWidget);
      expect(find.byTooltip('Back'), findsNothing);
      expect(bloc.events.whereType<OnInitV2>(), hasLength(1));
      await tester.enterText(find.byType(TextFormField), 'Jane');
      expect(
          bloc.events.whereType<OnSearchChanged>().last.map['search'], 'Jane');
      tester.testTextInput.hide();
      await tester.tap(find.byTooltip('Filter'));
      await tester.pumpAndSettle();
      expect(find.text('Filter Employees'), findsOneWidget);
      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();
      expect(
          bloc.events.whereType<OnSearchChanged>().last.map['search'], 'Jane');
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('employee card and actions fit a narrow screen', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final person = Person(
      fullname: 'Jane',
      email: 'jane@example.com',
      mobilePhone: '08123456789',
    );
    final recorder = ui.PictureRecorder();
    Canvas(recorder);
    final image = recorder.endRecording().toImageSync(1, 1);
    final provider = NetworkImage(person.avatarLink);
    PaintingBinding.instance.imageCache.putIfAbsent(
      provider,
      () => OneFrameImageStreamCompleter(Future.value(ImageInfo(image: image))),
    );
    addTearDown(() {
      PaintingBinding.instance.imageCache.evict(provider);
    });

    final bloc = RecordingEmployeeBloc(
      EmployeeState(employees2: [Employee(personal: person)]),
    );
    addTearDown(bloc.close);
    await tester.pumpWidget(BlocProvider<EmployeeBloc>.value(
      value: bloc,
      child: const MaterialApp(home: EmployeeScreenV2()),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Jane'), findsOneWidget);
    expect(find.text('jane@example.com'), findsOneWidget);
    expect(find.text('Phone'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('WhatsApp'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('contact route retains back navigation', (tester) async {
    final bloc = RecordingEmployeeBloc();
    addTearDown(bloc.close);
    await tester.pumpWidget(BlocProvider<EmployeeBloc>.value(
      value: bloc,
      child: MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () =>
                  Navigator.of(context).push(MaterialPageRoute<void>(
                builder: (_) => const ContactScreen(),
              )),
              child: const Text('Open Contact'),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('Open Contact'));
    await tester.pumpAndSettle();
    expect(find.text('Contact'), findsOneWidget);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Open Contact'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
