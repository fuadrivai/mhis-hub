import 'package:dio/dio.dart';
import 'package:fl_mhis_hr/injector/dio_interceptor.dart';
import 'package:fl_mhis_hr/models/v2/branch.dart';
import 'package:fl_mhis_hr/models/v2/employee.dart';
import 'package:fl_mhis_hr/models/v2/job_level.dart';
import 'package:fl_mhis_hr/models/v2/job_position.dart';
import 'package:fl_mhis_hr/models/v2/visitor.dart';
import 'package:fl_mhis_hr/pages/general_announcement/data/general_announcement_api.dart';
import 'package:fl_mhis_hr/pages/employee/repository/employee_api.dart';
import 'package:fl_mhis_hr/service/api.dart';

class VisitorApi {
  VisitorApi({
    Future<Dio> Function()? client,
    Future<VisitorHostFilters> Function()? getHostFilters,
    Future<List<Employee>> Function(Map<String, dynamic>)? getHostEmployees,
  })  : _client = client ??
            (() => Api.dioClient(
                  extra: {DioInterceptors.handleErrorsLocally: true},
                )),
        _getHostFilters = getHostFilters ?? _loadHostFilters,
        _getHostEmployees = getHostEmployees ?? _loadHostEmployees;

  final Future<Dio> Function() _client;
  final Future<VisitorHostFilters> Function() _getHostFilters;
  final Future<List<Employee>> Function(Map<String, dynamic>) _getHostEmployees;

  Future<VisitorPage<Visit>> visits(
    String endpoint, {
    int page = 1,
    Map<String, dynamic> filters = const {},
  }) async {
    final dio = await _client();
    final response = await dio.get<Map<String, dynamic>>(
      '${Api.baseUrl}visitor/$endpoint',
      queryParameters: {
        'page': page,
        'per_page': 20,
        ...filters,
      },
    );
    return _page(response.data!, Visit.fromJson);
  }

  Future<VisitorPage<VisitorHost>> hosts(String search,
      {int page = 1, Map<String, int?> filters = const {}}) async {
    final dio = await _client();
    final queryParameters = <String, dynamic>{
      'search': search,
      'page': page,
      'per_page': 20,
      for (final entry in filters.entries)
        if (entry.value != null) entry.key: entry.value,
    };
    final response = await dio.get<Map<String, dynamic>>(
      '${Api.baseUrl}visitor/hosts',
      queryParameters: queryParameters,
    );
    final hosts = _page(response.data!, VisitorHost.fromJson);
    if (hosts.data.isEmpty ||
        hosts.data.every((host) =>
            host.branch != null &&
            host.organization != null &&
            host.position != null &&
            host.level != null)) {
      return hosts;
    }

    final employees = await _getHostEmployees({
      'search': search,
      'page': page,
      'perpage': 20,
      'is_active': 1,
      for (final entry in filters.entries)
        if (entry.value != null) entry.key: entry.value,
    });
    final employeesById = {
      for (final employee in employees)
        if (employee.id != null) employee.id!: employee,
    };
    final employeesByName = {
      for (final employee in employees)
        if (_employeeName(employee).isNotEmpty)
          _employeeName(employee): employee,
    };
    return VisitorPage(
      data: hosts.data.map((host) {
        final employee = employeesById[host.id] ??
            employeesByName[host.name.trim().toLowerCase()];
        final employment = employee?.employment;
        return employee == null
            ? host
            : host.withEmployeeDetails(
                email: employee.personal?.email ?? employee.user?.email,
                phone: employee.personal?.mobilePhone,
                avatar:
                    employee.personal?.avatarLink ?? employee.personal?.avatar,
                branch: employment?.branch?.name ?? employment?.branchName,
                organization: employment?.organization?.name ??
                    employment?.organizationName,
                level: employment?.jobLevel?.name ?? employment?.jobLevelName,
                position: employment?.jobPosition?.name ??
                    employment?.jobPositionName,
              );
      }).toList(),
      page: hosts.page,
      perPage: hosts.perPage,
      total: hosts.total,
    );
  }

  static String _employeeName(Employee employee) =>
      (employee.personal?.fullname ?? employee.user?.name ?? '')
          .trim()
          .toLowerCase();

  Future<VisitorHostFilters> hostFilters() async {
    return _getHostFilters();
  }

  static Future<VisitorHostFilters> _loadHostFilters() async {
    final results = await Future.wait([
      GeneralAnnouncementApi.getBranch(handleErrorsLocally: true),
      GeneralAnnouncementApi.getJobLevel(handleErrorsLocally: true),
      GeneralAnnouncementApi.getJobPosition(handleErrorsLocally: true),
    ]);
    return VisitorHostFilters(
      branches: results[0] as List<Branch>,
      levels: results[1] as List<JobLevel>,
      positions: results[2] as List<JobPosition>,
    );
  }

  static Future<List<Employee>> _loadHostEmployees(
      Map<String, dynamic> params) async {
    final pagination = await EmployeeApi.getEmployees(params: params);
    return (pagination.data ?? [])
        .map(
            (item) => Employee.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  VisitorPage<T> _page<T>(
      Map<String, dynamic> json, T Function(Map<String, dynamic>) parse) {
    return VisitorPage(
      data: (json['data'] as List)
          .map((item) => parse(item as Map<String, dynamic>))
          .toList(),
      page: json['current_page'] as int,
      perPage: json['per_page'] as int,
      total: json['total'] as int,
    );
  }

  Future<VisitorFormOptions> formOptions() async {
    final dio = await _client();
    final response = await dio
        .get<Map<String, dynamic>>('${Api.baseUrl}visitor/form-options');
    return VisitorFormOptions.fromJson(
        response.data!['data'] as Map<String, dynamic>);
  }

  Future<Visit> detail(int id) async {
    final dio = await _client();
    final response = await dio
        .get<Map<String, dynamic>>('${Api.baseUrl}visitor/invitations/$id');
    return Visit.fromJson(response.data!['data'] as Map<String, dynamic>);
  }

  Future<void> create(
      Map<String, dynamic> fields, VisitorAttachment? photo) async {
    final dio = await _client();
    final data = FormData.fromMap({
      ...fields,
      if (photo != null)
        'photo': MultipartFile.fromBytes(photo.bytes, filename: photo.name),
    });
    await dio.post('${Api.baseUrl}visitor/invitations', data: data);
  }

  Future<void> cancel(int id, String reason) async {
    final dio = await _client();
    await dio.post('${Api.baseUrl}visitor/invitations/$id/cancel',
        data: {'reason': reason});
  }
}
