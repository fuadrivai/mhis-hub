import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/models/model.dart';
import 'package:fl_mhis_hr/pages/attendance/repositoty/attendance_api.dart';
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
      String? userId = await Session.get("userIdTalenta");
      LiveAttendanceSchedule? schedule =
          await AttendanceApi.getLiveAttendanceSchedule(int.parse(userId!));
      emit(state.copyWith(
        attendaceSchedule: schedule,
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
        attendaceSchedule: state.attendaceSchedule,
        attendanceError: true,
      ));
    }
  }

  void _onGetNewsletter(OnGetNewsletter event, Emitter<HomeState> emit) async {
    emit(state.copyWith(newsletterLoading: true));
    List<Newsletter> newsletters = await HomeApi.getNewsletter();
    emit(state.copyWith(newsletters: newsletters, newsletterLoading: false));
  }
}
