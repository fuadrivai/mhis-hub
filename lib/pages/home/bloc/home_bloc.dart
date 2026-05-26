import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:fl_mhis_hr/models/v2/models.dart';
import 'package:fl_mhis_hr/pages/attendance/repository/attendance_api.dart';
import 'package:fl_mhis_hr/pages/home/repository/home_api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(const HomeState()) {
    on<OnInitCalendar>(_onInitCalendar);
    on<OnInitAttendance>(_onInitAttendance);
    on<OnGetNewsletter>(_onGetNewsletter);
  }

  void _onInitCalendar(OnInitCalendar event, Emitter<HomeState> emit) async {
    try {
      emit(state.copyWith(calendarLoading: true));
      List<SchoolCalendar> schoolCalendars = await HomeApi.getSchoolCalendar();
      emit(state.copyWith(
        calendarSchool: schoolCalendars,
        calendarLoading: false,
        calendarError: false,
      ));
    } catch (e) {
      String errorMessage = e.toString();
      if (e.runtimeType == DioException) {
        DioException err = e as DioException;
        errorMessage = err.response?.data?["message"] ?? err.message;
      }
      emit(state.copyWith(
        calendarLoading: false,
        calendarErrorMessage: errorMessage,
        calendarSchool: state.calendarSchool,
        calendarError: true,
      ));
    }
  }

  void _onInitAttendance(
      OnInitAttendance event, Emitter<HomeState> emit) async {
    try {
      emit(state.copyWith(attendanceLoading: true));
      Shift? shift = await AttendanceApi.getActiveShift();
      emit(state.copyWith(
        shift: shift,
        attendanceLoading: false,
        attendanceError: false,
      ));
    } catch (e) {
      String errorMessage = e.toString();
      if (e.runtimeType == DioException) {
        DioException err = e as DioException;
        errorMessage = err.response?.data?["message"] ?? err.message;
      }
      emit(state.copyWith(
        attendanceLoading: false,
        attendanceErrorMessage: errorMessage,
        attendanceError: true,
        shift: state.shift,
      ));
    }
  }

  void _onGetNewsletter(OnGetNewsletter event, Emitter<HomeState> emit) async {
    emit(state.copyWith(newsletterLoading: true));
    List<Newsletter> newsletters = await HomeApi.getNewsletter();
    emit(state.copyWith(newsletters: newsletters, newsletterLoading: false));
  }
}
