import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:fl_mhis_hr/models/model.dart';
import 'package:fl_mhis_hr/models/v2/models.dart';
import 'package:fl_mhis_hr/pages/employee/repository/employee_api.dart';
import 'package:fl_mhis_hr/pages/general_announcement/data/general_announcement_api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'employee_event.dart';
part 'employee_state.dart';

class EmployeeBloc extends Bloc<EmployeeEvent, EmployeeState> {
  int perpage = 20;
  EmployeeBloc(
      {Future<Pagination> Function(Map<String, dynamic>)? getEmployees})
      : _getEmployees = getEmployees ??
            ((params) => EmployeeApi.getEmployees(params: params)),
        super(const EmployeeState()) {
    on<OnInit>(_onInit);
    on<OnInitV2>(_onInitV2);
    on<OnSearchChanged>(_onSearchChanged);
    on<OnLoadMore>(_onLoadMore);
  }

  final Future<Pagination> Function(Map<String, dynamic>) _getEmployees;
  int _requestVersion = 0;

  String _errorMessage(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map && data['message'] is String) {
        return data['message'] as String;
      }
    }
    return 'Unable to load employees. Please try again.';
  }

  void _onInit(OnInit event, Emitter<EmployeeState> emit) async {
    emit(state.copyWith(isLoading: true));
    ServerSideEmployee serverside = ServerSideEmployee();
    emit(state.copyWith(
      serverside: serverside,
      isLoading: false,
      isError: false,
      isSuccess: true,
    ));
  }

  void _onSearchChanged(
      OnSearchChanged event, Emitter<EmployeeState> emit) async {
    final requestVersion = ++_requestVersion;
    emit(state.copyWith(
        isLoading: true,
        isError: false,
        loadMore: false,
        loadMoreError: false));
    try {
      final params = Map<String, dynamic>.from(event.map);
      params['perpage'] = perpage;
      params['is_active'] = 1;
      final serverside = await _getEmployees(params);
      if (requestVersion != _requestVersion) return;
      final employees =
          serverside.data?.map((e) => Employee.fromJson(e)).toList() ?? [];
      emit(state.copyWith(
        pagination: serverside,
        employees2: employees,
        isLoading: false,
        isError: false,
        isSuccess: true,
      ));
    } catch (e) {
      if (requestVersion != _requestVersion) return;
      emit(state.copyWith(
        isLoading: false,
        isError: true,
        isSuccess: false,
        errorMessage: _errorMessage(e),
      ));
    }
  }

  void _onLoadMore(OnLoadMore event, Emitter<EmployeeState> emit) async {
    if (state.loadMore || state.isLoading || state.isError) {
      return;
    }

    final String? nextPageUrl = state.pagination?.nextPageUrl;
    if (nextPageUrl == null || nextPageUrl.isEmpty) {
      return;
    }

    emit(state.copyWith(loadMore: true, loadMoreError: false, isError: false));
    final requestVersion = _requestVersion;

    try {
      final Uri? url = Uri.tryParse(nextPageUrl);
      if (url == null) {
        emit(state.copyWith(
          loadMore: false,
          loadMoreError: true,
          errorMessage: 'Unable to load more employees. Please try again.',
        ));
        return;
      }

      final Map<String, dynamic> params = Map<String, dynamic>.from(event.map);
      params.addAll(url.queryParameters);
      params['perpage'] = perpage;
      params['is_active'] = 1;

      final Pagination serverside = await _getEmployees(params);
      if (requestVersion != _requestVersion) return;
      final List<Employee> currentEmployees =
          List<Employee>.from(state.employees2 ?? const <Employee>[]);
      final List<Employee> nextEmployees =
          (serverside.data ?? []).map((e) => Employee.fromJson(e)).toList();

      emit(state.copyWith(
        pagination: serverside,
        employees2: currentEmployees + nextEmployees,
        loadMore: false,
        isLoading: false,
        isError: false,
        isSuccess: true,
      ));
    } catch (e) {
      if (requestVersion != _requestVersion) return;
      emit(state.copyWith(
        loadMore: false,
        loadMoreError: true,
        errorMessage: _errorMessage(e),
      ));
    }
  }

  void _onInitV2(OnInitV2 event, Emitter<EmployeeState> emit) async {
    final requestVersion = ++_requestVersion;
    emit(state.copyWith(
        isLoading: true,
        isError: false,
        loadMore: false,
        loadMoreError: false));
    try {
      final params = Map<String, dynamic>.from(event.map);
      params['perpage'] = perpage;
      params['is_active'] = 1;
      final pagination = await _getEmployees(params);
      if (requestVersion != _requestVersion) return;
      final branches =
          await GeneralAnnouncementApi.getBranch(handleErrorsLocally: true);
      if (requestVersion != _requestVersion) return;
      final organizations = await GeneralAnnouncementApi.getOrganization(
          handleErrorsLocally: true);
      if (requestVersion != _requestVersion) return;
      final jobLevels =
          await GeneralAnnouncementApi.getJobLevel(handleErrorsLocally: true);
      if (requestVersion != _requestVersion) return;
      final jobPositions = await GeneralAnnouncementApi.getJobPosition(
          handleErrorsLocally: true);
      if (requestVersion != _requestVersion) return;
      final employees =
          (pagination.data ?? []).map((e) => Employee.fromJson(e)).toList();
      emit(state.copyWith(
        pagination: pagination,
        employees2: employees,
        isLoading: false,
        isError: false,
        isSuccess: true,
        branches: branches,
        organizations: organizations,
        jobLevels: jobLevels,
        jobPositions: jobPositions,
      ));
    } catch (e) {
      if (requestVersion != _requestVersion) return;
      emit(state.copyWith(
        isLoading: false,
        isError: true,
        isSuccess: false,
        errorMessage: _errorMessage(e),
      ));
    }
  }
}
