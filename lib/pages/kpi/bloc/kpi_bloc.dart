import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/models/model.dart';
import 'package:fl_mhis_hr/pages/kpi/repository/kpi_api.dart';
import 'package:fl_mhis_hr/pages/profile/repository/profile_api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'kpi_event.dart';
part 'kpi_state.dart';

class KpiBloc extends Bloc<KpiEvent, KpiState> {
  KpiBloc() : super(KpiState()) {
    on<OnGetKpi>(_onGetKpi);
    on<OnGetEmployee>(_onGetEmployee);
  }

  void _onGetKpi(OnGetKpi event, Emitter<KpiState> emit) async {
    try {
      emit(state.copyWith(
        kpiLoading: true,
        kpiError: false,
        kpiSuccess: false,
      ));

      Kpi kpi = await KpiApi.get();

      emit(state.copyWith(
        kpiLoading: false,
        kpiError: false,
        kpi: kpi,
      ));
    } catch (e) {
      String kpiErrorMessage = e.toString();
      if (e.runtimeType == DioException) {
        DioException err = e as DioException;
        kpiErrorMessage = err.response?.data?["message"] ?? err.message;
      }
      emit(state.copyWith(
        kpiLoading: false,
        kpiError: true,
        kpiErrorMessage: kpiErrorMessage,
      ));
    }
  }

  void _onGetEmployee(OnGetEmployee event, Emitter<KpiState> emit) async {
    try {
      emit(state.copyWith(
        empLoading: true,
        empError: false,
        empSuccess: false,
      ));

      String? id = await Session.get("userIdTalenta");
      int employeeId = int.parse(id!);
      Employee employee = await ProfileApi.getEmployeeById(employeeId);

      emit(state.copyWith(
        empLoading: false,
        empError: false,
        employee: employee,
      ));
    } catch (e) {
      String empErrorMessage = e.toString();
      if (e.runtimeType == DioException) {
        DioException err = e as DioException;
        empErrorMessage = err.response?.data?["message"] ?? err.message;
      }
      emit(state.copyWith(
        empLoading: false,
        empError: true,
        empErrorMessage: empErrorMessage,
      ));
    }
  }
}
