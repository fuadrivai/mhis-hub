import 'package:fl_mhis_hr/injector/injector.dart';
import 'package:fl_mhis_hr/models/v2/models.dart';
import 'package:fl_mhis_hr/pages/profile/bloc/profile_bloc.dart' as profile;
import 'package:fl_mhis_hr/pages/profile/screen/change_password_screen.dart';
import 'package:fl_mhis_hr/pages/profile/screen/my_info/employment_info.dart';
import 'package:fl_mhis_hr/pages/profile/screen/my_info/personal_info_form.dart';
import 'package:fl_mhis_hr/pages/timeoff/bloc/timeoff_bloc.dart' as timeoff;
import 'package:fl_mhis_hr/pages/timeoff/screen/timeoff_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class RecordingProfileBloc extends profile.ProfileBloc {
  final events = <profile.ProfileEvent>[];
  @override
  void add(profile.ProfileEvent event) => events.add(event);
}

class RecordingTimeoffBloc extends timeoff.TimeoffBloc {
  final events = <timeoff.TimeoffEvent>[];
  @override
  void add(timeoff.TimeoffEvent event) => events.add(event);
}

void main() {
  setUpAll(() {
    locator.registerSingleton<NavigationService>(NavigationService());
  });
  tearDownAll(() => locator.unregister<NavigationService>());

  for (final size in [const Size(320, 568), const Size(1024, 768)]) {
    testWidgets('profile information and forms fit $size', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      tester.view.padding = const FakeViewPadding(top: 24, bottom: 24);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPadding);
      final profileBloc = RecordingProfileBloc();
      final timeoffBloc = RecordingTimeoffBloc();
      addTearDown(profileBloc.close);
      addTearDown(timeoffBloc.close);
      final leave = Timeoff(id: 7, name: 'Annual Leave', schema: [
        TimeoffSchema(
          name: 'reason',
          type: 'text',
          label: 'Reason',
          required: true,
        ),
        TimeoffSchema(
          name: 'start_date',
          type: 'date',
          label: 'Start date',
        ),
        TimeoffSchema(
          name: 'end_date',
          type: 'date',
          label: 'End date',
        ),
      ]);
      final routes = <String, Widget>{
        'Personal Info': const PersonalInfo(title: 'Personal Info', listForm: [
          {'title': 'Fullname', 'value': 'Jane Doe'},
          {'title': 'Phone', 'value': null},
        ]),
        'Employment Info': EmplymentInfo(
            employment: Employment(employeeId: 'EMP-01', barcode: 'BC123')),
        'Change Password': const ChangePasswordScreen(),
        'Annual Leave': TimeoffFormScreen(timeoff: leave),
      };
      final router = GoRouter(routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            body: ListView(
              children: [
                for (var i = 0; i < routes.length; i++)
                  TextButton(
                    onPressed: () => context.push('/$i'),
                    child: Text('Open ${routes.keys.elementAt(i)}'),
                  ),
              ],
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
          BlocProvider<profile.ProfileBloc>.value(value: profileBloc),
          BlocProvider<timeoff.TimeoffBloc>.value(value: timeoffBloc),
        ],
        child: MaterialApp.router(routerConfig: router),
      ));
      await tester.tap(find.text('Open Personal Info'));
      await tester.pumpAndSettle();
      expect(find.text('Jane Doe'), findsOneWidget);
      expect(find.text('--'), findsOneWidget);
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Open Employment Info'));
      await tester.pumpAndSettle();
      expect(find.text('EMP-01'), findsOneWidget);
      expect(find.text('BC123'), findsOneWidget);
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Open Change Password'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Submit'));
      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();
      expect(find.text('Field cannot be empty'), findsWidgets);
      await tester.enterText(find.byType(TextFormField).at(0), 'old');
      await tester.enterText(find.byType(TextFormField).at(1), 'new');
      await tester.enterText(find.byType(TextFormField).at(2), 'new');
      await tester.ensureVisible(find.text('Show Password'));
      await tester.tap(find.text('Show Password'));
      await tester.pumpAndSettle();
      expect(tester.widget<TextField>(find.byType(TextField).first).obscureText,
          isFalse);
      await tester.ensureVisible(find.text('Submit'));
      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();
      expect(
          profileBloc.events.whereType<profile.OnChangePassword>().single.data,
          {'oldPassword': 'old', 'newPassword': 'new'});
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Open Annual Leave'));
      await tester.pumpAndSettle();
      expect(timeoffBloc.events.whereType<timeoff.OnInitForm>(), hasLength(1));
      await tester.ensureVisible(find.text('Submit Request'));
      await tester.tap(find.text('Submit Request'));
      await tester.pumpAndSettle();
      expect(find.text('Reason is required'), findsOneWidget);
      final reason = find.byType(TextFormField).at(0);
      await tester.ensureVisible(reason);
      await tester.enterText(reason, 'Vacation');
      tester.testTextInput.hide();
      await tester.pumpAndSettle();
      final startDate = find.byType(TextFormField).at(1);
      final endDate = find.byType(TextFormField).at(2);
      expect(tester.widget<TextFormField>(endDate).enabled, isFalse);
      await tester.ensureVisible(startDate);
      await tester.tap(startDate);
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(tester.widget<TextFormField>(endDate).enabled, isTrue);
      final chosenDate =
          tester.widget<TextFormField>(startDate).controller!.text;
      expect(chosenDate, isNotEmpty);
      await tester.ensureVisible(find.text('Add Attachment'));
      await tester.tap(find.text('Add Attachment'));
      await tester.pumpAndSettle();
      expect(find.text('Camera'), findsOneWidget);
      expect(find.text('Gallery'), findsOneWidget);
      expect(find.text('File'), findsOneWidget);
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();
      expect(find.text('Camera'), findsNothing);
      final note = find.byType(TextFormField).last;
      await tester.ensureVisible(note);
      await tester.enterText(note, 'Family trip');
      tester.testTextInput.hide();
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Submit Request'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Submit Request'));
      await tester.pumpAndSettle();
      final submission =
          timeoffBloc.events.whereType<timeoff.OnSubmitTimeoffForm>().single;
      expect(submission.timeoffId, 7);
      expect(submission.formData,
          {'reason': 'Vacation', 'start_date': chosenDate});
      expect(submission.note, 'Family trip');
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(find.text('Open Annual Leave'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
