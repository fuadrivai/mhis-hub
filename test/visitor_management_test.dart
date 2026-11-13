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
import 'package:fl_mhis_hr/pages/visitor/library/visitor_date_time.dart';
import 'package:fl_mhis_hr/pages/visitor/repository/visitor_api.dart';
import 'package:fl_mhis_hr/pages/visitor/screen/visitor_screen.dart';
import 'package:fl_mhis_hr/pages/visitor/screen/visitor_host_search_screen.dart';
import 'package:fl_mhis_hr/pages/visitor/screen/visitor_attachment_preview.dart';
import 'package:fl_mhis_hr/pages/visitor/screen/visitor_form_screen.dart';
import 'package:fl_mhis_hr/pages/home/screen/visitor_today_home_card.dart';
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
  'expected_arrival_at': '2027-01-20T09:00:00+07:00',
  'expected_departure_at': '2027-01-20T10:00:00+07:00',
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
  final visitFilterCalls = <Map<String, dynamic>>[];
  final hostFilterCalls = <Map<String, int?>>[];
  Map<String, dynamic>? submitted;
  String? cancellationReason;
  bool cancelled = false;

  @override
  Future<VisitorPage<Visit>> visits(String endpoint,
      {int page = 1, Map<String, dynamic> filters = const {}}) async {
    visitFilterCalls.add(Map<String, dynamic>.from(filters));
    if (filters.containsKey('visit_date')) {
      calls.add('today:$endpoint:${filters['visit_date']}');
    } else {
      calls.add('$endpoint:$page');
    }
    final json = {
      ...visitJson,
      if (filters['visit_date'] is String) 'visit_date': filters['visit_date'],
      'can_cancel': !cancelled,
    };
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
    return Visit.fromJson({
      ...visitJson,
      'visitor': {
        ...visitJson['visitor'] as Map<String, dynamic>,
        'media': {
          'data': [
            {
              'file_name': 'visitor-photo.png',
              'file_path': 'visitors/visitor-photo.png',
              'mime_type': 'image/png',
            }
          ],
        },
      },
    });
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
        categories: [
          VisitorOption(
            id: 2,
            name: 'Guest',
            requiresAdditionalInfo: true,
          )
        ],
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
          avatar: 'https://example.test/storage/avatars/host.png',
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
  Future<VisitorPage<Visit>> visits(String endpoint,
      {int page = 1, Map<String, dynamic> filters = const {}}) async {
    if (filters.containsKey('visit_date')) {
      return super.visits(endpoint, page: page, filters: filters);
    }
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
  Future<VisitorPage<Visit>> visits(String endpoint,
      {int page = 1, Map<String, dynamic> filters = const {}}) {
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

class EmptyTodayVisitorApi extends FakeVisitorApi {
  @override
  Future<VisitorPage<Visit>> visits(String endpoint,
      {int page = 1, Map<String, dynamic> filters = const {}}) async {
    if (filters.containsKey('visit_date')) {
      return VisitorPage(
        data: const [],
        page: page,
        perPage: 20,
        total: 0,
      );
    }
    return super.visits(endpoint, page: page, filters: filters);
  }
}

class MonitoringOnlyVisitorApi extends FakeVisitorApi {
  @override
  Future<VisitorPage<Visit>> visits(String endpoint,
      {int page = 1, Map<String, dynamic> filters = const {}}) async {
    if (endpoint == 'invitations' && filters.containsKey('visit_date')) {
      return VisitorPage(
        data: const [],
        page: page,
        perPage: 20,
        total: 0,
      );
    }
    return super.visits(endpoint, page: page, filters: filters);
  }
}

class FailedTodayVisitorApi extends FakeVisitorApi {
  @override
  Future<VisitorPage<Visit>> visits(String endpoint,
      {int page = 1, Map<String, dynamic> filters = const {}}) async {
    if (filters.containsKey('visit_date')) {
      throw StateError('Visitor service unavailable');
    }
    return super.visits(endpoint, page: page, filters: filters);
  }
}

class TimedVisitorApi extends FakeVisitorApi {
  TimedVisitorApi(this.now);

  final DateTime Function() now;

  @override
  Future<VisitorPage<Visit>> visits(String endpoint,
      {int page = 1, Map<String, dynamic> filters = const {}}) async {
    if (!filters.containsKey('visit_date')) {
      return super.visits(endpoint, page: page, filters: filters);
    }

    final current = now();
    Map<String, dynamic> timedVisit(String name, DateTime departure) => {
          ...visitJson,
          'visit_code': name,
          'visit_date': filters['visit_date'],
          'expected_arrival_at': current.toIso8601String(),
          'expected_departure_at': departure.toIso8601String(),
          'visitor': {'full_name': name},
          'host': {'name': '$name Host'},
        };
    return VisitorPage(
      data: [
        Visit.fromJson(
            timedVisit('Ending soon', current.add(const Duration(seconds: 3)))),
        Visit.fromJson(
            timedVisit('Next visit', current.add(const Duration(minutes: 3)))),
      ],
      page: page,
      perPage: 20,
      total: 2,
    );
  }
}

class PagedTimedVisitorApi extends FakeVisitorApi {
  PagedTimedVisitorApi(this.now);

  final DateTime Function() now;
  int invitationRequests = 0;

  @override
  Future<VisitorPage<Visit>> visits(String endpoint,
      {int page = 1, Map<String, dynamic> filters = const {}}) async {
    if (!filters.containsKey('visit_date')) {
      return super.visits(endpoint, page: page, filters: filters);
    }
    if (endpoint == 'monitoring') {
      return VisitorPage(
        data: const [],
        page: page,
        perPage: 1,
        total: 0,
      );
    }

    invitationRequests++;
    final current = now();
    final firstPage = invitationRequests == 1;
    final name = firstPage ? 'Ending soon' : 'Next page';
    final departure = current.add(
      firstPage ? const Duration(seconds: 3) : const Duration(minutes: 3),
    );
    return VisitorPage(
      data: [
        Visit.fromJson({
          ...visitJson,
          'visit_code': name,
          'visit_date': filters['visit_date'],
          'expected_arrival_at': current.toIso8601String(),
          'expected_departure_at': departure.toIso8601String(),
          'visitor': {'full_name': name},
        })
      ],
      page: 1,
      perPage: 1,
      total: firstPage ? 2 : 1,
    );
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

  test('visit parses uploaded media using file attachment fields', () {
    final visit = Visit.fromJson({
      ...visitJson,
      'visitor': {
        ...visitJson['visitor'] as Map<String, dynamic>,
        'photo': {
          'data': {
            'file_name': 'visitor-photo.png',
            'file_path': 'visitors/visitor-photo.png',
          },
        }
      },
    });

    expect(visit.attachments, hasLength(1));
    expect(visit.attachments.single.name, 'visitor-photo.png');
    expect(visit.attachments.single.url, 'visitors/visitor-photo.png');
  });

  test('visitor date-time query uses a local ISO timezone offset', () {
    final dateTime = DateTime(2026, 11, 13, 9);
    final offset = dateTime.timeZoneOffset;
    final sign = offset.isNegative ? '-' : '+';
    final minutes = offset.inMinutes.abs();
    final expectedOffset = '$sign${(minutes ~/ 60).toString().padLeft(2, '0')}:'
        '${(minutes % 60).toString().padLeft(2, '0')}';
    expect(visitorDateParameter(dateTime), '2026-11-13');
    expect(visitorDateTimeParameter(dateTime),
        '2026-11-13T09:00:00$expectedOffset');
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

  testWidgets('home visitor card shows today names and opens selected tab',
      (tester) async {
    final api = FakeVisitorApi();
    final bloc = VisitorBloc(api: api);
    addTearDown(bloc.close);
    final today = DateTime.now();
    final date =
        '${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    bloc.add(LoadTodayVisitorList(
        type: VisitorListType.invitations,
        date: date,
        homeSummary: true,
        reset: true));
    bloc.add(LoadTodayVisitorList(
        type: VisitorListType.monitoring,
        date: date,
        homeSummary: true,
        reset: true));

    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        GoRoute(
          path: '/home',
          builder: (_, __) => const Scaffold(body: VisitorTodayHomeCard()),
        ),
        GoRoute(
          path: '/visitor',
          name: 'visitor',
          builder: (_, state) => VisitorScreen(
            initialTab: state.extra == 1 ? 1 : 0,
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(BlocProvider.value(
      value: bloc,
      child: MaterialApp.router(routerConfig: router),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Visitor Today'), findsOneWidget);
    expect(find.text('Nama Tamu'), findsOneWidget);
    expect(find.text('Arrival 09:00'), findsOneWidget);
    await tester.tap(find.text('Monitoring'));
    await tester.pumpAndSettle();
    expect(find.text('Nama Host'), findsOneWidget);
    expect(find.text('Guest: Nama Tamu'), findsOneWidget);

    await tester.tap(find.text('See all'));
    await tester.pumpAndSettle();
    expect(api.calls, contains('monitoring:1'));
    expect(find.text('Visitor'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('home visitor tabs remain selectable when one list is empty',
      (tester) async {
    final bloc = VisitorBloc(api: MonitoringOnlyVisitorApi());
    addTearDown(bloc.close);
    final today = DateTime.now();
    final date =
        '${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    bloc.add(LoadTodayVisitorList(
        type: VisitorListType.invitations,
        date: date,
        homeSummary: true,
        reset: true));
    bloc.add(LoadTodayVisitorList(
        type: VisitorListType.monitoring,
        date: date,
        homeSummary: true,
        reset: true));
    await tester.pumpWidget(BlocProvider.value(
      value: bloc,
      child: const MaterialApp(
        home: Scaffold(body: VisitorTodayHomeCard()),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Nama Host'), findsOneWidget);

    await tester.tap(find.text('Invitations'));
    await tester.pumpAndSettle();
    expect(find.text('No invitations today'), findsOneWidget);
    expect(find.text('Visitor Today'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('home removes visits at departure and shows the next visit',
      (tester) async {
    var current = DateTime.now();
    final bloc = VisitorBloc(api: TimedVisitorApi(() => current));
    addTearDown(bloc.close);
    for (final type in VisitorListType.values) {
      bloc.add(LoadTodayVisitorList(
        type: type,
        date: visitorDateParameter(current),
        departureAfter: visitorDateTimeParameter(current),
        homeSummary: true,
        reset: true,
      ));
    }

    await tester.pumpWidget(BlocProvider.value(
      value: bloc,
      child: MaterialApp(
        home: Scaffold(body: VisitorTodayHomeCard(clock: () => current)),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Ending soon'), findsOneWidget);
    expect(find.text('Next visit'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Ending soon'), findsOneWidget);
    current = current.add(const Duration(seconds: 4));
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Ending soon'), findsNothing);
    expect(find.text('Next visit'), findsOneWidget);
    expect(find.text('Visitor Today'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('home requests the next page when its current visits expire',
      (tester) async {
    var current = DateTime.now();
    final api = PagedTimedVisitorApi(() => current);
    final bloc = VisitorBloc(api: api);
    addTearDown(bloc.close);
    for (final type in VisitorListType.values) {
      bloc.add(LoadTodayVisitorList(
        type: type,
        date: visitorDateParameter(current),
        departureAfter: visitorDateTimeParameter(current),
        homeSummary: true,
        reset: true,
      ));
    }
    await tester.pumpWidget(BlocProvider.value(
      value: bloc,
      child: MaterialApp(
        home: Scaffold(body: VisitorTodayHomeCard(clock: () => current)),
      ),
    ));
    await tester.pumpAndSettle();
    expect(api.invitationRequests, 1);
    expect(find.text('Ending soon'), findsOneWidget);

    current = current.add(const Duration(seconds: 4));
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    expect(api.invitationRequests, 2);
    expect(find.text('Ending soon'), findsNothing);
    expect(find.text('Next page'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('visitor screen opens directly on the requested tab',
      (tester) async {
    final api = FakeVisitorApi();
    await tester.pumpWidget(BlocProvider(
      create: (_) => VisitorBloc(api: api, getProfile: _fakeEmployeeProfile),
      child: const MaterialApp(home: VisitorScreen(initialTab: 1)),
    ));
    await tester.pumpAndSettle();
    expect(api.calls, contains('monitoring:1'));
    expect(api.calls, isNot(contains('invitations:1')));
  });

  testWidgets('home visitor card is hidden when both today lists are empty',
      (tester) async {
    final bloc = VisitorBloc(api: EmptyTodayVisitorApi());
    addTearDown(bloc.close);
    final today = DateTime.now();
    final date =
        '${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    bloc.add(LoadTodayVisitorList(
        type: VisitorListType.invitations,
        date: date,
        homeSummary: true,
        reset: true));
    bloc.add(LoadTodayVisitorList(
        type: VisitorListType.monitoring,
        date: date,
        homeSummary: true,
        reset: true));
    await tester.pumpWidget(BlocProvider.value(
      value: bloc,
      child: const MaterialApp(
        home: Scaffold(body: VisitorTodayHomeCard()),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Visitor Today'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('home visitor card exposes errors instead of hiding them',
      (tester) async {
    final bloc = VisitorBloc(api: FailedTodayVisitorApi());
    addTearDown(bloc.close);
    final today = DateTime.now();
    final date =
        '${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    bloc.add(LoadTodayVisitorList(
        type: VisitorListType.invitations,
        date: date,
        homeSummary: true,
        reset: true));
    bloc.add(LoadTodayVisitorList(
        type: VisitorListType.monitoring,
        date: date,
        homeSummary: true,
        reset: true));
    await tester.pumpWidget(BlocProvider.value(
      value: bloc,
      child: const MaterialApp(
        home: Scaffold(body: VisitorTodayHomeCard()),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Visitor Today'), findsOneWidget);
    expect(find.text('Unexpected response or error. Please try again.'),
        findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
    expect(tester.takeException(), isNull);
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
    final avatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar).first);
    expect(avatar.backgroundImage, isA<NetworkImage>());

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

  test('host response parses all provided employee details', () {
    final host = VisitorHost.fromJson({
      'id': 10,
      'name': 'Host Name',
      'branch': 'Head Office',
      'level': 'Senior',
      'position': 'Director',
      'organization': 'Operations',
      'avatar': 'https://example.test/storage/avatars/host.png',
    });

    expect(host.branch, 'Head Office');
    expect(host.level, 'Senior');
    expect(host.position, 'Director');
    expect(host.organization, 'Operations');
    expect(host.avatar, 'https://example.test/storage/avatars/host.png');
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

  test('visit API forwards name, exact-date, and date-range filters', () async {
    final requests = <RequestOptions>[];
    final dio = Dio();
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      requests.add(options);
      handler.resolve(Response(
        requestOptions: options,
        data: {
          'current_page': 1,
          'per_page': 20,
          'total': 0,
          'data': <dynamic>[],
        },
      ));
    }));
    final api = VisitorApi(client: () async => dio);

    await api.visits(
      'invitations',
      filters: {'query': 'angga', 'visit_date': '2026-11-13'},
    );
    await api.visits(
      'monitoring',
      filters: {'query': '0813', 'from': '2026-11-01', 'to': '2026-11-30'},
    );
    await api.visits(
      'invitations',
      filters: {
        'visit_date': '2026-11-13',
        'departure_after': '2026-11-13T09:00:00+07:00',
      },
    );

    expect(requests[0].queryParameters, {
      'page': 1,
      'per_page': 20,
      'query': 'angga',
      'visit_date': '2026-11-13',
    });
    expect(requests[1].queryParameters, {
      'page': 1,
      'per_page': 20,
      'query': '0813',
      'from': '2026-11-01',
      'to': '2026-11-30',
    });
    expect(requests[2].queryParameters['departure_after'],
        '2026-11-13T09:00:00+07:00');
    expect(requests[2].uri.query, contains('%2B07'));
    expect(requests[2].uri.query, isNot(contains('+07')));
  });

  test('today visitor BLoC forwards departure_after to the API', () async {
    final api = FakeVisitorApi();
    final bloc = VisitorBloc(api: api);
    addTearDown(bloc.close);

    bloc.add(const LoadTodayVisitorList(
      type: VisitorListType.invitations,
      date: '2026-11-13',
      departureAfter: '2026-11-13T09:00:00+07:00',
      homeSummary: true,
      reset: true,
    ));
    await Future<void>.delayed(Duration.zero);

    expect(api.visitFilterCalls.single, {
      'visit_date': '2026-11-13',
      'departure_after': '2026-11-13T09:00:00+07:00',
    });
    expect(bloc.state.todayInvitations.items, isEmpty);
    expect(bloc.state.homeTodayInvitations.items, hasLength(1));
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
    await tester.scrollUntilVisible(
      find.text('Attachments'),
      240,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('Attachments'), findsOneWidget);
    expect(find.text('visitor-photo.png'), findsWidgets);
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
    expect(api.attempts, 1);
    await tester.drag(find.byType(ListView).first, const Offset(0, -600));
    await tester.pumpAndSettle();
    expect(find.textContaining('Server unavailable'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('Visitor 1'), findsOneWidget);
    expect(find.text('20 January 2027'), findsOneWidget);
    expect(find.text('Arrival: 09:00  -  Departure: 10:00'), findsWidgets);
    await tester.drag(find.byType(ListView).first, const Offset(0, -900));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Load more'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView).first, const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.text('Visitor 2'), findsOneWidget);
    expect(find.text('Load more'), findsNothing);
  });

  testWidgets('invitation list separates today and searches by query',
      (tester) async {
    final api = FakeVisitorApi();
    await tester.pumpWidget(BlocProvider(
      create: (_) => VisitorBloc(api: api),
      child: const MaterialApp(home: VisitorScreen()),
    ));
    await tester.pumpAndSettle();

    expect(find.text("Today's invitations"), findsOneWidget);
    expect(find.text('All invitations'), findsOneWidget);
    expect(find.text('Filter by date'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'angga');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(
        api.visitFilterCalls.any(
          (filters) => filters.length == 1 && filters['query'] == 'angga',
        ),
        isTrue);
    expect(
      api.visitFilterCalls.any(
        (filters) =>
            filters['query'] == 'angga' && filters.containsKey('visit_date'),
      ),
      isTrue,
    );
    await tester.tap(find.text('Monitoring'));
    await tester.pumpAndSettle();
    expect(find.text("Today's monitoring"), findsOneWidget);
    expect(find.text('All monitoring'), findsOneWidget);
    expect(
        api.calls.any((call) => call.startsWith('today:monitoring:')), isTrue);
    await tester.enterText(find.byType(TextField).first, '0813');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(
      api.visitFilterCalls.any(
        (filters) =>
            filters['query'] == '0813' && filters.containsKey('visit_date'),
      ),
      isTrue,
    );
    expect(tester.takeException(), isNull);
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
    await tester.ensureVisible(find.byKey(const ValueKey('visitor-date')));
    final arrivalDateRect =
        tester.getRect(find.byKey(const ValueKey('visitor-date')));
    final arrivalTimeRect =
        tester.getRect(find.byKey(const ValueKey('visitor-arrival-time')));
    expect(arrivalDateRect.left, lessThan(arrivalTimeRect.left));
    expect(arrivalDateRect.top, arrivalTimeRect.top);
    expect(
      arrivalDateRect.width / (arrivalDateRect.width + arrivalTimeRect.width),
      closeTo(0.6, 0.02),
    );
    final departureDateRect =
        tester.getRect(find.byKey(const ValueKey('visitor-departure-date')));
    final departureTimeRect =
        tester.getRect(find.byKey(const ValueKey('visitor-departure-time')));
    expect(departureDateRect.left, lessThan(departureTimeRect.left));
    expect(departureDateRect.top, departureTimeRect.top);
    expect(
      departureDateRect.width /
          (departureDateRect.width + departureTimeRect.width),
      closeTo(0.6, 0.02),
    );
    expect(find.text('Add Attachment'), findsOneWidget);
    await tester.ensureVisible(find.byKey(const ValueKey('visitor-host')));
    await tester.pumpAndSettle();
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
    await tester.ensureVisible(find.byKey(const ValueKey('visitor-notes')));
    await tester.enterText(
        find.byKey(const ValueKey('visitor-notes')), 'Installation work');
    tester.testTextInput.hide();
    await tester.pumpAndSettle();
    await tester
        .ensureVisible(find.byKey(const ValueKey('visitor-arrival-time')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('visitor-arrival-time')));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.byKey(const ValueKey('visitor-time-input')), '09:00');
    await tester.tap(find.text('Set time'));
    await tester.pumpAndSettle();
    await tester
        .ensureVisible(find.byKey(const ValueKey('visitor-departure-time')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('visitor-departure-time')));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.byKey(const ValueKey('visitor-time-input')), '10:00');
    await tester.tap(find.text('Set time'));
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
    expect(api.submitted?['visit_date'], matches(r'^\d{4}-\d{2}-\d{2}$'));
    expect(api.submitted?['expected_arrival_time'], matches(r'^\d{2}:\d{2}$'));
    expect(api.submitted?['notes'], 'Installation work');
    expect(api.submitted, isNot(contains('expected_arrival_date')));
    expect(api.submitted, isNot(contains('expected_departure_date')));
    expect(api.submitted, isNot(contains('visitor_notes')));
    expect(find.text('Invitations'), findsOneWidget);
    expect(api.calls.where((call) => call == 'invitations:1').length, 2);
    expect(tester.takeException(), isNull);
  });

  testWidgets('time input dialog works in compact viewport', (tester) async {
    tester.view.physicalSize = const Size(800, 600);
    tester.view.devicePixelRatio = 1;
    tester.view.viewInsets = const FakeViewPadding(bottom: 420);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpWidget(BlocProvider(
      create: (_) =>
          VisitorBloc(api: FakeVisitorApi(), getProfile: _fakeEmployeeProfile),
      child: const MaterialApp(home: VisitorFormScreen()),
    ));
    await tester.pumpAndSettle();
    final timeField = find.byKey(const ValueKey('visitor-arrival-time'));
    await tester.ensureVisible(timeField);
    await tester.pumpAndSettle();
    await tester.tap(timeField);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('visitor-time-input')), findsOneWidget);
    await tester.enterText(
        find.byKey(const ValueKey('visitor-time-input')), '29:99');
    await tester.ensureVisible(find.text('Set time'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Set time'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a valid time in 24-hour format (HH:mm).'),
        findsOneWidget);
    await tester.enterText(
        find.byKey(const ValueKey('visitor-time-input')), '09:30');
    await tester.ensureVisible(find.text('Set time'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Set time'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('time input dialog accepts a valid 24-hour time', (tester) async {
    tester.view.physicalSize = const Size(800, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(BlocProvider(
      create: (_) =>
          VisitorBloc(api: FakeVisitorApi(), getProfile: _fakeEmployeeProfile),
      child: const MaterialApp(home: VisitorFormScreen()),
    ));
    await tester.pumpAndSettle();
    final timeField = find.byKey(const ValueKey('visitor-arrival-time'));
    await tester.ensureVisible(timeField);
    await tester.pumpAndSettle();
    await tester.tap(timeField);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('visitor-time-input')), findsOneWidget);
    await tester.enterText(
        find.byKey(const ValueKey('visitor-time-input')), '21:45');
    await tester.tap(find.text('Set time'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
