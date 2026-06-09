import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/models/model.dart';
import 'package:fl_mhis_hr/models/v2/models.dart';
import 'package:fl_mhis_hr/pages/attendance/repository/attendance_api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

part 'attendance_event.dart';
part 'attendance_state.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  AttendanceBloc() : super(const AttendanceState()) {
    on<OnInit>(_onInit);
    on<OnGetHistory>(_onGetHistory);
    on<OnGetCurrentLog>(_onGetCurrentLog);
  }

  void _onInit(OnInit event, Emitter<AttendanceState> emit) async {
    emit(state.copyWith(isLoading: true, isError: false, isSuccess: false));
    try {
      Position? position = await Common.determinePosition();
      List<AttendanceLog> logs = await AttendanceApi.getCurrentAttendance();
      Shift shift = await AttendanceApi.getActiveShift();
      emit(state.copyWith(
        isLoading: false,
        isError: false,
        isSuccess: true,
        position: position,
        shift: shift,
        logs: logs,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        isError: true,
        isSuccess: false,
        errorMessage: e.toString(),
        logs: state.logs,
      ));
    }
  }

  void _onGetHistory(OnGetHistory event, Emitter<AttendanceState> emit) async {
    emit(state.copyWith(
      historyLoading: true,
      isError: false,
      isSuccess: false,
      histories: [],
    ));
    try {
      List<Attendance> histories =
          await AttendanceApi.getAttendaceHistories(event.map);
      emit(state.copyWith(
        historyLoading: false,
        isError: false,
        isSuccess: true,
        histories: histories,
      ));
    } catch (e) {
      String errorMessage = e.toString();
      if (e.runtimeType == DioException) {
        DioException err = e as DioException;
        errorMessage = err.response?.data?["message"] ?? err.message;
      }
      emit(state.copyWith(
        historyLoading: false,
        isError: true,
        isSuccess: false,
        histories: state.histories,
        errorMessage: errorMessage,
      ));
    }
  }

  void _onGetCurrentLog(
      OnGetCurrentLog event, Emitter<AttendanceState> emit) async {
    emit(state.copyWith(
      historyLoading: true,
      isError: false,
      isSuccess: false,
      logs: [],
    ));
    try {
      List<AttendanceLog> logs = await AttendanceApi.getCurrentAttendance();
      emit(state.copyWith(
        historyLoading: false,
        isError: false,
        isSuccess: true,
        logs: logs,
      ));
    } catch (e) {
      String errorMessage = e.toString();
      if (e.runtimeType == DioException) {
        DioException err = e as DioException;
        errorMessage = err.response?.data?["message"] ?? err.message;
      }
      emit(state.copyWith(
        historyLoading: false,
        isError: true,
        isSuccess: false,
        logs: state.logs,
        errorMessage: errorMessage,
      ));
    }
  }
}
