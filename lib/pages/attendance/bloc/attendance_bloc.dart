import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/models/model.dart';
import 'package:fl_mhis_hr/pages/attendance/repositoty/attendance_api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

part 'attendance_event.dart';
part 'attendance_state.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  AttendanceBloc() : super(const AttendanceState()) {
    on<OnInit>(_onInit);
    on<OnGetHistory>(_onGetHistory);
  }

  void _onInit(OnInit event, Emitter<AttendanceState> emit) async {
    emit(state.copyWith(isLoading: true, isError: false, isSuccess: false));
    try {
      Position? position = await Common.determinePosition();
      String? userId = await Session.get("userIdTalenta");

      LiveAttendanceSchedule? schedule =
          await AttendanceApi.getLiveAttendanceSchedule(int.parse(userId!));
      emit(state.copyWith(
        isLoading: false,
        isError: false,
        isSuccess: true,
        position: position,
        schedule: schedule,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        isError: true,
        isSuccess: false,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onGetHistory(OnGetHistory event, Emitter<AttendanceState> emit) async {
    emit(state.copyWith(
      historyLoading: true,
      isError: false,
      isSuccess: false,
      history: [],
    ));
    try {
      List<AttendanceHistory> histories = [];
      histories = await AttendanceApi.getAttendanceHistory(event.map);
      emit(state.copyWith(
        historyLoading: false,
        isError: false,
        isSuccess: true,
        history: histories,
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
        history: state.history,
        errorMessage: errorMessage,
      ));
    }
  }
}
