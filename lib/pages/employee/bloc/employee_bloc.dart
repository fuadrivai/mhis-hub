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
  EmployeeBloc() : super(const EmployeeState()) {
    on<OnInit>(_onInit);
    on<OnInitV2>(_onInitV2);
    on<OnSearchChanged>(_onSearchChanged);
    on<OnLoadMore>(_onLoadMore);
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
    emit(state.copyWith(isLoading: true));
    Map<String, dynamic> params = event.map;
    params['perpage'] = perpage;
    params['is_active'] = 1;
    Pagination serverside = await EmployeeApi.getEmployees(params: params);
    List<Employee>? employees =
        serverside.data?.map((e) => Employee.fromJson(e)).toList() ?? [];
    emit(state.copyWith(
      pagination: serverside,
      employees2: employees,
      isLoading: false,
      isError: false,
      isSuccess: true,
    ));
  }

  void _onLoadMore(OnLoadMore event, Emitter<EmployeeState> emit) async {
    if (state.loadMore) {
      return;
    }

    final String? nextPageUrl = state.pagination?.nextPageUrl;
    if (nextPageUrl == null || nextPageUrl.isEmpty) {
      return;
    }

    emit(state.copyWith(loadMore: true));

    try {
      final Uri? url = Uri.tryParse(nextPageUrl);
      if (url == null) {
        emit(state.copyWith(loadMore: false));
        return;
      }

      final Map<String, dynamic> params = Map<String, dynamic>.from(event.map);
      params.addAll(url.queryParameters);
      params['perpage'] = perpage;
      params['is_active'] = 1;

      final Pagination serverside =
          await EmployeeApi.getEmployees(params: params);
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
    } catch (_) {
      emit(state.copyWith(
        loadMore: false,
        isError: true,
        isSuccess: false,
      ));
    }
  }

  void _onInitV2(OnInitV2 event, Emitter<EmployeeState> emit) async {
    emit(state.copyWith(isLoading: true));
    Map<String, dynamic> params = event.map;
    params['perpage'] = perpage;
    params['is_active'] = 1;
    Pagination pagination = await EmployeeApi.getEmployees(params: params);
    List<Branch> branches = await GeneralAnnouncementApi.getBranch();
    List<Organization> organizations =
        await GeneralAnnouncementApi.getOrganization();
    List<JobLevel> jobLevels = await GeneralAnnouncementApi.getJobLevel();
    List<JobPosition> jobPositions =
        await GeneralAnnouncementApi.getJobPosition();
    List<Employee>? employees =
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
  }
}
