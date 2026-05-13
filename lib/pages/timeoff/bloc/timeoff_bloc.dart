import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/models/v2/models.dart';
import 'package:fl_mhis_hr/pages/timeoff/repository/timeoff_api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'timeoff_event.dart';
part 'timeoff_state.dart';

class TimeoffBloc extends Bloc<TimeoffEvent, TimeoffState> {
  TimeoffBloc() : super(const TimeoffState()) {
    on<OnInit>(_onInit);
    on<OnInitForm>(_onInitForm);
  }

  void _onInit(OnInit event, Emitter<TimeoffState> emit) async {
    try {
      emit(state.copyWith(
        isLoading: true,
        isError: false,
        isSuccess: false,
      ));

      List<Timeoff> timeoffs = await TimeoffApi.get();

      emit(state.copyWith(
        isLoading: false,
        isError: false,
        timeoffs: timeoffs,
      ));
    } catch (e) {
      String errorMessage = e.toString();
      if (e.runtimeType == DioException) {
        DioException err = e as DioException;
        errorMessage = err.response?.data?["message"] ?? err.message;
      }
      emit(state.copyWith(
        isLoading: false,
        timeoffs: state.timeoffs,
        isError: true,
        loadMore: false,
        errorMessage: errorMessage,
      ));
    }
  }

  void _onInitForm(OnInitForm event, Emitter<TimeoffState> emit) async {
    try {
      emit(state.copyWith(
        isFormLoading: true,
        isFormError: false,
        isFormSuccess: false,
      ));

      String? employeeId = await Session.get('employeeId');

      Employee employee =
          await TimeoffApi.getEmployeeById(int.parse(employeeId!));

      emit(state.copyWith(
        isFormLoading: false,
        isFormError: false,
        isFormSuccess: true,
        employee: employee,
      ));
    } catch (e) {
      String errorMessage = e.toString();
      if (e.runtimeType == DioException) {
        DioException err = e as DioException;
        errorMessage = err.response?.data?["message"] ?? err.message;
      }
      emit(state.copyWith(
        isFormLoading: false,
        isFormError: true,
        isFormSuccess: false,
        errorMessage: errorMessage,
      ));
    }
  }
}
