import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:fl_mhis_hr/models/v2/branch.dart';
import 'package:fl_mhis_hr/models/v2/employment.dart';
import 'package:fl_mhis_hr/models/v2/employee.dart';
import 'package:fl_mhis_hr/models/v2/job_level.dart';
import 'package:fl_mhis_hr/models/v2/job_position.dart';
import 'package:fl_mhis_hr/models/v2/organization.dart';
import 'package:fl_mhis_hr/models/v2/person.dart';
import 'package:fl_mhis_hr/models/v2/visitor.dart';
import 'package:fl_mhis_hr/pages/visitor/bloc/visitor_bloc.dart';
import 'package:fl_mhis_hr/pages/visitor/library/visitor_attachment_validation.dart';
import 'package:fl_mhis_hr/pages/visitor/repository/visitor_api.dart';
import 'package:fl_mhis_hr/pages/visitor/screen/visitor_screen.dart';
import 'package:fl_mhis_hr/pages/visitor/screen/visitor_host_search_screen.dart';
import 'package:fl_mhis_hr/pages/visitor/screen/visitor_attachment_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';

final visitJson = <String, dynamic>{
  'id': 42,
  'visit_code': 'ABCDE',
  'status': 'expected',
  'visit_date': '2027-01-20',
  'can_cancel': true,
  'visitor': {'full_name': 'Nama Tamu', 'phone': '08123456789'},
  'host': {'name': 'Nama Host'},
  'branch': {'name': 'School'},
  'category': {'name': 'Guest'},
  'purpose': {'name': 'Meeting'},
};

Future<Employee> _fakeEmployeeProfile() async => Employee(
      id: 10,
      personal: Person(fullname: 'Fuad Rifai'),
    );

class FakeVisitorApi extends VisitorApi {
  final calls = <String>[];
  final hostFilterCalls = <Map<String, int?>>[];
  Map<String, dynamic>? submitted;
  String? cancellationReason;
  bool cancelled = false;

  @override
  Future<VisitorPage<Visit>> visits(String endpoint, {int page = 1}) async {
    calls.add('$endpoint:$page');
    final json = {...visitJson, 'can_cancel': !cancelled};
    return VisitorPage(
      data: [Visit.fromJson(json)],
      page: page,
      perPage: 20,
      total: 1,
    );
  }

  @override
  Future<Visit> detail(int id) async {
    calls.add('detail:$id');
    return Visit.fromJson(visitJson);
  }

  @override
  Future<void> cancel(int id, String reason) async {
    calls.add('cancel:$id');
    cancellationReason = reason;
    cancelled = true;
  }

  @override
  Future<VisitorFormOptions> formOptions() async => const VisitorFormOptions(
        branches: [VisitorOption(id: 1, name: 'School')],
        categories: [VisitorOption(id: 2, name: 'Guest')],
        purposes: [VisitorOption(id: 3, name: 'Meeting')],
        defaultBranchId: 1,
        defaultHostId: 10,
      );

  @override
  Future<VisitorPage<VisitorHost>> hosts(String search,
      {int page = 1, Map<String, int?> filters = const {}}) async {
    calls.add('hosts:$search:$page');
    hostFilterCalls.add(Map<String, int?>.from(filters));
    return VisitorPage(
      data: const [
        VisitorHost(
          id: 11,
          name: 'Other Host',
          email: 'host@example.com',
          phone: '08123456789',
          branch: 'School',
          organization: 'Education',
          level: 'Manager',
          position: 'Teacher',
        )
      ],
      page: page,
      perPage: 20,
      total: 1,
    );
  }

  @override
  Future<VisitorHostFilters> hostFilters() async => VisitorHostFilters(
        branches: [Branch(id: 1, name: 'School')],
        levels: [JobLevel(id: 2, name: 'Manager')],
        positions: [JobPosition(id: 3, name: 'Teacher')],
      );

  @override
  Future<void> create(
      Map<String, dynamic> fields, VisitorAttachment? photo) async {
    submitted = fields;
  }
}

class RecordingAdapter implements HttpClientAdapter {
  RequestOptions? request;
  final List<int> body = [];

  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    request = options;
    if (requestStream != null) {
      await for (final chunk in requestStream) {
        body.addAll(chunk);
      }
    }
    return ResponseBody.fromString(
      '{"message":"Visitor invitation created."}',
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType]
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class RetryingVisitorApi extends FakeVisitorApi {
  int attempts = 0;

  @override
  Future<VisitorPage<Visit>> visits(String endpoint, {int page = 1}) async {
    attempts++;
    if (attempts == 1) {
      throw DioException(
        requestOptions: RequestOptions(path: endpoint),
        response: Response(
          requestOptions: RequestOptions(path: endpoint),
          statusCode: 500,
          data: {'message': 'Server unavailable'},
        ),
      );
    }
    return VisitorPage(
      data: [
        Visit.fromJson({
          ...visitJson,
          'id': page,
          'visitor': {'full_name': 'Visitor $page'}
        })
      ],
      page: page,
      perPage: 1,
      total: 2,
    );
  }
}

class DelayedVisitorApi extends FakeVisitorApi {
  final listRequests = <Completer<VisitorPage<Visit>>>[];
  final hostRequests = <Completer<VisitorPage<VisitorHost>>>[];

  @override
  Future<VisitorPage<Visit>> visits(String endpoint, {int page = 1}) {
    final request = Completer<VisitorPage<Visit>>();
    listRequests.add(request);
    return request.future;
  }

  @override
  Future<VisitorPage<VisitorHost>> hosts(String search,
      {int page = 1, Map<String, int?> filters = const {}}) {
    final request = Completer<VisitorPage<VisitorHost>>();
    hostRequests.add(request);
    return request.future;
  }
}

class DelayedMutationApi extends FakeVisitorApi {
  final requests = <Completer<void>>[];

  @override
  Future<void> create(Map<String, dynamic> fields, VisitorAttachment? photo) {
    final request = Completer<void>();
    requests.add(request);
    return request.future;
  }
}

void main() {
  setUpAll(() => initializeDateFormatting('en'));

  test('attachments enforce supported formats and 5 MB limit', () {
    const limit = 5 * 1024 * 1024;
    for (final name in ['a.jpg', 'a.jpeg', 'a.png', 'a.WEBP']) {
      expect(visitorAttachmentError(name, limit), isNull);
    }
    expect(visitorAttachmentError('a.pdf', 1), isNotNull);
    expect(visitorAttachmentError('png', 1), isNotNull);
    expect(visitorAttachmentError('a.png', limit + 1), isNotNull);
  });

  testWidgets('attachment preview shows the selected file and can remove it',
      (tester) async {
    var removed = false;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: VisitorAttachmentPreview(
          attachment: VisitorAttachment(
              'visitor.png', Uint8List.fromList([0x89, 0x50, 0x4e, 0x47])),
          onRemove: () => removed = true,
        ),
      ),
    ));
    expect(find.text('visitor.png'), findsOneWidget);
    expect(
      find.byWidgetPredicate((widget) =>
          widget is Image && widget.semanticLabel == 'Attachment preview'),
      findsOneWidget,
    );
    await tester.tap(find.byTooltip('Remove attachment'));
    expect(removed, isTrue);
  });

  testWidgets('host cards show employee details and filter results',
      (tester) async {
    final api = FakeVisitorApi();
    await tester.pumpWidget(BlocProvider(
      create: (_) => VisitorBloc(api: api),
      child: const MaterialApp(home: VisitorHostSearchScreen()),
    ));
    await tester.pumpAndSettle();

    expect(find.text('host@example.com'), findsOneWidget);
    expect(find.text('08123456789'), findsOneWidget);
    expect(find.text('Branch: School'), findsWidgets);
    expect(find.text('Level: Manager'), findsOneWidget);
    expect(find.text('Organization: Education'), findsOneWidget);
    expect(find.text('Position: Teacher'), findsOneWidget);
    expect(find.text('Phone'), findsNothing);
    expect(find.text('WhatsApp'), findsNothing);

    await tester.tap(find.byTooltip('Filter employees'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<int?>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('School').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();

    expect(api.hostFilterCalls.last, {'branch': 1});
    expect(find.text('Branch: School'), findsWidgets);
  });

  test('BLoC ignores stale list refresh and host search responses', () async {
    final api = DelayedVisitorApi();
    final bloc = VisitorBloc(api: api);
    addTearDown(bloc.close);
    bloc.add(const LoadVisitorList(VisitorListType.invitations, reset: true));
    bloc.add(const SearchVisitorHosts(query: 'old', reset: true));
    await Future<void>.delayed(Duration.zero);
    bloc.add(const LoadVisitorList(VisitorListType.invitations, reset: true));
    bloc.add(const SearchVisitorHosts(query: 'new', reset: true));
    await Future<void>.delayed(Duration.zero);
    expect(api.listRequests, hasLength(2));
    expect(api.hostRequests, hasLength(2));

    api.listRequests[1].complete(VisitorPage(
      data: [
        Visit.fromJson({...visitJson, 'visit_code': 'NEW'})
      ],
      page: 1,
      perPage: 20,
      total: 1,
    ));
    api.hostRequests[1].complete(const VisitorPage(
      data: [VisitorHost(id: 2, name: 'New host')],
      page: 1,
      perPage: 20,
      total: 1,
    ));
    await Future<void>.delayed(Duration.zero);
    api.listRequests[0].complete(VisitorPage(
      data: [
        Visit.fromJson({...visitJson, 'visit_code': 'OLD'})
      ],
      page: 1,
      perPage: 20,
      total: 1,
    ));
    api.hostRequests[0].complete(const VisitorPage(
      data: [VisitorHost(id: 1, name: 'Old host')],
      page: 1,
      perPage: 20,
      total: 1,
    ));
    await Future<void>.delayed(Duration.zero);
    expect(bloc.state.invitations.items.single.code, 'NEW');
    expect(bloc.state.hosts.query, 'new');
    expect(bloc.state.hosts.items.single.name, 'New host');
  });

  test('BLoC prevents duplicate submits and permits retry after failure',
      () async {
    final api = DelayedMutationApi();
    final bloc = VisitorBloc(api: api);
    addTearDown(bloc.close);
    bloc.add(const LoadVisitorForm());
    await Future<void>.delayed(Duration.zero);
    bloc.add(const SubmitVisitorInvitation({}, null));
    bloc.add(const SubmitVisitorInvitation({}, null));
    await Future<void>.delayed(Duration.zero);
    expect(api.requests, hasLength(1));
    expect(bloc.state.form.submitting, isTrue);
    final options = RequestOptions(path: '/invitations');
    api.requests.first.completeError(DioException(
      requestOptions: options,
      response: Response(
        requestOptions: options,
        statusCode: 422,
        data: {
          'errors': {
            'phone': ['Phone is required.']
          }
        },
      ),
    ));
    await Future<void>.delayed(Duration.zero);
    expect(bloc.state.form.submitting, isFalse);
    expect(bloc.state.form.submissionError, 'Phone is required.');
    expect(bloc.state.form.options, isNotNull);
    bloc.add(const SubmitVisitorInvitation({}, null));
    await Future<void>.delayed(Duration.zero);
    expect(api.requests, hasLength(2));
    api.requests.last.complete();
    await Future<void>.delayed(Duration.zero);
    expect(bloc.state.form.created, isTrue);
  });

  test('create sends multipart body even with JSON client defaults', () async {
    final adapter = RecordingAdapter();
    final dio = Dio(BaseOptions(headers: {'Content-Type': 'application/json'}))
      ..httpClientAdapter = adapter;
    final api = VisitorApi(client: () async => dio);
    await api.create(
      {'full_name': 'Nama Tamu', 'host_employee_id': 10},
      VisitorAttachment('photo.jpg', Uint8List.fromList([1, 2, 3])),
    );
    expect(adapter.request!.headers['content-type'],
        startsWith('multipart/form-data; boundary='));
    final body = latin1.decode(adapter.body);
    expect(body, contains('name="full_name"'));
    expect(body, contains('Nama Tamu'));
    expect(body, contains('name="photo"; filename="photo.jpg"'));
  });

  test('API uses paginated endpoints and multipart photo contract', () async {
    final requests = <RequestOptions>[];
    final dio = Dio();
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      requests.add(options);
      final path = options.path;
      final dynamic data;
      if (path.endsWith('/form-options')) {
        data = {
          'data': {
            'branches': [
              {'id': 1, 'name': 'School'}
            ],
            'categories': [
              {'id': 2, 'name': 'Guest', 'requires_additional_info': true}
            ],
            'purposes': [
              {'id': 3, 'name': 'Meeting', 'requires_approval': true}
            ],
            'default_branch_id': 1,
            'default_host_employee_id': 10,
          }
        };
      } else if (path.endsWith('/hosts')) {
        data = {
          'current_page': 2,
          'per_page': 20,
          'total': 21,
          'data': [
            {'id': 11, 'name': 'Other Host'}
          ],
        };
      } else if (options.method == 'GET' && path.endsWith('/42')) {
        data = {'data': visitJson};
      } else if (options.method == 'GET') {
        data = {
          'current_page': 1,
          'per_page': 20,
          'total': 21,
          'data': [visitJson],
        };
      } else {
        data = {'message': 'OK'};
      }
      handler.resolve(Response(requestOptions: options, data: data));
    }));
    Map<String, dynamic>? employeeLookupParams;
    final api = VisitorApi(
      client: () async => dio,
      getHostEmployees: (params) async {
        employeeLookupParams = params;
        return [
          Employee(
            id: 999,
            personal: Person(fullname: 'Other Host'),
            employment: Employment(
              branch: Branch(id: 1, name: 'School'),
              organization: Organization(id: 4, name: 'Education'),
              jobPosition: JobPosition(id: 3, name: 'Teacher'),
              jobLevel: JobLevel(id: 2, name: 'Manager'),
            ),
          )
        ];
      },
    );
    final visits = await api.visits('invitations');
    expect(visits.hasMore, isTrue);
    expect(visits.data.single.visitor, 'Nama Tamu');
    await api.visits('monitoring', page: 2);
    final hosts = await api.hosts('Nama',
        page: 2, filters: {'branch': 1, 'position': 3, 'level': 2});
    expect(hosts.data.single.id, 11);
    expect(hosts.data.single.branch, 'School');
    expect(hosts.data.single.organization, 'Education');
    expect(hosts.data.single.position, 'Teacher');
    expect(hosts.data.single.level, 'Manager');
    expect(employeeLookupParams, {
      'search': 'Nama',
      'page': 2,
      'perpage': 20,
      'is_active': 1,
      'branch': 1,
      'position': 3,
      'level': 2,
    });
    expect(hosts.hasMore, isFalse);
    expect((await api.detail(42)).code, 'ABCDE');
    await api.create(
      {'full_name': 'Nama Tamu', 'host_employee_id': 10},
      VisitorAttachment('photo.webp', Uint8List.fromList([1, 2, 3])),
    );
    await api.cancel(42, 'Changed schedule');
    final options = await api.formOptions();
    expect(options.defaultBranchId, 1);
    expect(options.defaultHostId, 10);
    expect(options.categories.single.requiresAdditionalInfo, isTrue);
    expect(options.purposes.single.requiresApproval, isTrue);
    expect(requests[0].path, endsWith('/api/visitor/invitations'));
    expect(requests[1].path, endsWith('/api/visitor/monitoring'));
    expect(requests[1].queryParameters['page'], 2);
    expect(requests[2].queryParameters, {
      'search': 'Nama',
      'per_page': 20,
      'page': 2,
      'branch': 1,
      'position': 3,
      'level': 2,
    });
    expect(requests[3].path, endsWith('/api/visitor/invitations/42'));
    final form = requests[4].data as FormData;
    expect(Map.fromEntries(form.fields)['host_employee_id'], '10');
    expect(form.files.single.key, 'photo');
    expect(form.files.single.value.filename, 'photo.webp');
    expect(requests[5].data, {'reason': 'Changed schedule'});
    expect(requests[6].path, endsWith('/api/visitor/form-options'));
  });

  testWidgets('tabs load separate lists and cancellation refreshes them',
      (tester) async {
    final api = FakeVisitorApi();
    final router = GoRouter(routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => const Scaffold(),
        routes: [
          GoRoute(
            path: 'visitor',
            builder: (_, __) => const VisitorScreen(),
          ),
        ],
      ),
    ], initialLocation: '/visitor');
    addTearDown(router.dispose);
    await tester.pumpWidget(BlocProvider(
      create: (_) => VisitorBloc(api: api, getProfile: _fakeEmployeeProfile),
      child: MaterialApp.router(routerConfig: router),
    ));
    await tester.pumpAndSettle();
    expect(api.calls, contains('invitations:1'));
    await tester.tap(find.text('Monitoring'));
    await tester.pumpAndSettle();
    expect(api.calls, contains('monitoring:1'));
    await tester.tap(find.text('Nama Tamu').last);
    await tester.pumpAndSettle();
    expect(api.calls, contains('detail:42'));
    await tester.scrollUntilVisible(find.text('Cancel invitation'), 250,
        scrollable: find.byType(Scrollable).last);
    await tester.tap(find.text('Cancel invitation'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm cancellation'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a cancellation reason'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), 'Jadwal berubah');
    await tester.tap(find.text('Confirm cancellation'));
    await tester.pumpAndSettle();
    expect(api.cancellationReason, 'Jadwal berubah');
    expect(api.calls.where((call) => call == 'monitoring:1').length, 2);
    expect(api.calls.where((call) => call == 'invitations:1').length, 2);
    expect(tester.takeException(), isNull);
  });

  testWidgets('list reports failures, retries, and loads later pages',
      (tester) async {
    final api = RetryingVisitorApi();
    await tester.pumpWidget(BlocProvider(
      create: (_) => VisitorBloc(api: api, getProfile: _fakeEmployeeProfile),
      child: const MaterialApp(home: VisitorScreen()),
    ));
    await tester.pumpAndSettle();
    expect(find.textContaining('Server unavailable'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('Visitor 1'), findsOneWidget);
    await tester.tap(find.text('Load more'));
    await tester.pumpAndSettle();
    expect(find.text('Visitor 2'), findsOneWidget);
    expect(find.text('Load more'), findsNothing);
  });

  testWidgets('form selects host, validates contact and creates invitation',
      (tester) async {
    final api = FakeVisitorApi();
    await tester.pumpWidget(BlocProvider(
      create: (_) => VisitorBloc(api: api, getProfile: _fakeEmployeeProfile),
      child: const MaterialApp(home: VisitorScreen()),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Invitation'));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.byKey(const ValueKey('visitor-full-name')), 'Nama Tamu');

    await tester.ensureVisible(find.byKey(const ValueKey('visitor-category')));
    await tester.tap(find.byKey(const ValueKey('visitor-category')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Guest').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('visitor-purpose')));
    await tester.tap(find.byKey(const ValueKey('visitor-purpose')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Meeting').last);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const ValueKey('visitor-branch')));
    await tester.ensureVisible(find.byKey(const ValueKey('visitor-host')));
    await tester.pumpAndSettle();
    final hostField = tester
        .widget<TextFormField>(find.byKey(const ValueKey('visitor-host')));
    expect(hostField.controller!.text, 'Fuad Rifai');
    expect(
      tester.getTopLeft(find.byKey(const ValueKey('visitor-branch'))).dy,
      lessThan(
          tester.getTopLeft(find.byKey(const ValueKey('visitor-host'))).dy),
    );
    final arrivalTime = tester.widget<TextField>(find.descendant(
      of: find.byKey(const ValueKey('visitor-arrival-time')),
      matching: find.byType(TextField),
    ));
    expect(arrivalTime.readOnly, isTrue);
    expect(arrivalTime.decoration!.filled, isTrue);
    expect(arrivalTime.decoration!.hintText, 'Expected arrival time');
    expect(arrivalTime.decoration!.suffixIcon, isA<Icon>());
    expect(find.text('Add Attachment'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('visitor-host')));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.widgetWithText(TextField, 'Employee name'), 'Other');
    await tester.tap(find.byTooltip('Search hosts'));
    await tester.pumpAndSettle();
    expect(api.calls, contains('hosts:Other:1'));
    await tester.tap(find.text('Other Host'));
    await tester.pumpAndSettle();

    tester.testTextInput.hide();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Submit invitation'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Submit invitation'));
    await tester.pumpAndSettle();
    expect(api.submitted, isNull);
    await tester.ensureVisible(find.widgetWithText(TextFormField, 'Phone'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a phone number or email'), findsWidgets);
    await tester.enterText(
        find.byKey(const ValueKey('visitor-phone')), '08123456789');
    tester.testTextInput.hide();
    await tester.pumpAndSettle();
    await tester
        .ensureVisible(find.byKey(const ValueKey('visitor-arrival-time')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('visitor-arrival-time')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester
        .ensureVisible(find.byKey(const ValueKey('visitor-departure-time')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('visitor-departure-time')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Submit invitation'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Submit invitation'));
    await tester.pumpAndSettle();
    expect(api.submitted?['full_name'], 'Nama Tamu');
    expect(api.submitted?['host_employee_id'], 11);
    expect(api.submitted?['visitor_category_id'], 2);
    expect(api.submitted?['visitor_purpose_id'], 3);
    expect(api.submitted?['branch_id'], 1);
    expect(api.submitted?['expected_arrival_time'], matches(r'^\d{2}:\d{2}$'));
    expect(api.submitted?['expected_arrival_date'],
        matches(r'^\d{1,2} [A-Za-z]+ \d{4}$'));
    expect(find.text('Invitations'), findsOneWidget);
    expect(api.calls.where((call) => call == 'invitations:1').length, 2);
    expect(tester.takeException(), isNull);
  });
}
