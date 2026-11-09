import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/pages/request_approval/bloc/request_approval_bloc.dart';
import 'package:fl_mhis_hr/pages/request_approval/screen/my_request_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

class RecordingRequestBloc extends RequestApprovalBloc {
  final List<RequestApprovalEvent> events = [];

  @override
  RequestApprovalState get state =>
      const RequestApprovalState(isBalanceEmpty: true);

  @override
  void add(RequestApprovalEvent event) => events.add(event);
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en');
  });

  test('shared picker uses maroon colors and retains its configuration', () {
    final settings = Common.monthPickerDialog();
    expect(settings.headerSettings.headerBackgroundColor, AppColors.danger);
    expect(settings.dateButtonsSettings.selectedMonthBackgroundColor,
        AppColors.danger);
    expect(settings.dateButtonsSettings.selectedMonthTextColor, Colors.white);
    expect(settings.dialogSettings.locale, const Locale('en'));
  });

  testWidgets('month selection and cancellation retain request filters',
      (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final bloc = RecordingRequestBloc();
    addTearDown(bloc.close);
    await tester.pumpWidget(BlocProvider<RequestApprovalBloc>.value(
      value: bloc,
      child: const MaterialApp(home: Scaffold(body: MyRequestWidget())),
    ));
    await tester.pumpAndSettle();
    expect(bloc.events.whereType<OnInitRequest>(), hasLength(1));
    final initial = Map<String, dynamic>.from(
        bloc.events.whereType<OnInitRequest>().last.map);
    await tester.tap(find.byType(TextFormField));
    await tester.pumpAndSettle();
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('OK'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(bloc.events.whereType<OnInitRequest>(), hasLength(1));
    await tester.tap(find.byType(TextFormField));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Jan').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    final requests = bloc.events.whereType<OnInitRequest>().toList();
    expect(requests, hasLength(2));
    expect(requests.last.map['month'], '1');
    expect(requests.last.map['year'], initial['year']);
    expect(
        tester
            .widget<TextFormField>(find.byType(TextFormField))
            .controller!
            .text,
        'January ${initial['year']}');
    expect(tester.takeException(), isNull);
  });
}
