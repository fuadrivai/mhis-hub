import 'package:equatable/equatable.dart';
import 'package:fl_mhis_hr/models/model.dart';
import 'package:fl_mhis_hr/pages/employee/repository/employee_api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'employee_event.dart';
part 'employee_state.dart';

class EmployeeBloc extends Bloc<EmployeeEvent, EmployeeState> {
  EmployeeBloc() : super(const EmployeeState()) {
    on<OnInit>(_onInit);
    on<OnSearchChanged>(_onSearchChanged);
    on<OnLoadMore>(_onLoadMore);
  }

  void _onInit(OnInit event, Emitter<EmployeeState> emit) async {
    emit(state.copyWith(isLoading: true));
    ServerSideEmployee serverside =
        await EmployeeApi.getEmployee(params: {"limit": 30});
    List<EmployeeV3>? employees = serverside.employees ?? [];
    employees.removeWhere(
        (item) => item.email == "rollando.m@mutiaraharapan.sch.id");
    emit(state.copyWith(
      serverside: serverside,
      employees: employees,
      isLoading: false,
      isError: false,
      isSuccess: true,
    ));
  }

  void _onSearchChanged(
      OnSearchChanged event, Emitter<EmployeeState> emit) async {
    emit(state.copyWith(isLoading: true));
    ServerSideEmployee serverside = await EmployeeApi.getEmployee(
        params: {"limit": 30, "email": event.email});
    List<EmployeeV3>? employees = serverside.employees ?? [];
    employees.removeWhere(
        (item) => item.email == "rollando.m@mutiaraharapan.sch.id");
    emit(state.copyWith(
      serverside: serverside,
      employees: employees,
      isLoading: false,
      isError: false,
      isSuccess: true,
    ));
  }

  void _onLoadMore(OnLoadMore event, Emitter<EmployeeState> emit) async {
    emit(state.copyWith(loadMore: true));
    Map<String, dynamic> params = {};
    var url = Uri.parse(state.serverside!.pagination!.nextPageUrl!);
    List<String> listParam = url.query.split("&");
    for (var v in listParam) {
      params[v.split("=")[0]] = v.split("=")[1];
    }
    ServerSideEmployee serverside =
        await EmployeeApi.getEmployee(params: params);
    List<EmployeeV3> employees = state.employees ?? [];
    employees = employees + (serverside.employees ?? []);
    employees.removeWhere(
        (item) => item.email == "rollando.m@mutiaraharapan.sch.id");
    emit(state.copyWith(
      serverside: serverside,
      employees: employees,
      loadMore: false,
    ));
    emit(state.copyWith(
      serverside: serverside,
      employees: employees,
      isLoading: false,
      isError: false,
      isSuccess: true,
    ));
  }
}
