import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:fl_mhis_hr/models/v2/models.dart';
import 'package:fl_mhis_hr/pages/attendance/repository/attendance_api.dart';
import 'package:fl_mhis_hr/pages/general_announcement/data/general_announcement_api.dart';
import 'package:fl_mhis_hr/pages/home/repository/home_api.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({Future<List<Announcement>> Function()? getAnnouncements})
      : _getAnnouncements = getAnnouncements ??
            (() => GeneralAnnouncementApi.getAnnouncement(
                handleForbiddenLocally: true, handleErrorsLocally: true)),
        super(const HomeState()) {
    on<OnInitCalendar>(_onInitCalendar);
    on<OnInitAttendance>(_onInitAttendance);
    on<OnGetNewsletter>(_onGetNewsletter);
    on<OnGetSop>(_onGetSop);
    on<OnInitAnnouncement>(_onInitAnnouncement);
  }

  final Future<List<Announcement>> Function() _getAnnouncements;

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
    emit(state.copyWith(newsletterLoading: true, newsletterError: false));
    try {
      final newsletters = await HomeApi.getNewsletter();
      emit(state.copyWith(
        newsletters: newsletters,
        newsletterLoading: false,
        newsletterError: false,
      ));
    } catch (e) {
      String errorMessage = e.toString();
      if (e is DioException) {
        errorMessage =
            e.response?.data?["message"] ?? e.message ?? errorMessage;
      }
      emit(state.copyWith(
        newsletterLoading: false,
        newsletterError: true,
        newsletterErrorMessage: errorMessage,
      ));
    }
  }

  void _onGetSop(OnGetSop event, Emitter<HomeState> emit) async {
    emit(state.copyWith(sopLoading: true, sopError: false));
    try {
      final List<Sop> sops = await HomeApi.getSop();
      emit(state.copyWith(
        sops: sops.where((sop) => sop.isActive == true).toList(),
        sopLoading: false,
        sopError: false,
      ));
    } catch (e) {
      String errorMessage = e.toString();
      if (e is DioException) {
        errorMessage =
            e.response?.data?["message"] ?? e.message ?? errorMessage;
      }
      emit(state.copyWith(
        sopLoading: false,
        sopError: true,
        sopErrorMessage: errorMessage,
        sops: state.sops,
      ));
    }
  }

  void _onInitAnnouncement(
      OnInitAnnouncement event, Emitter<HomeState> emit) async {
    try {
      emit(state.copyWith(announcementLoading: true, announcementError: false));
      final announcements = await _getAnnouncements();
      emit(state.copyWith(
        announcements: announcements,
        announcementLoading: false,
        announcementError: false,
      ));
    } catch (e) {
      String errorMessage = e.toString();
      if (e is FormatException ||
          (e is DioException && e.error is FormatException)) {
        final formatError = e is FormatException
            ? e
            : (e as DioException).error as FormatException;
        debugPrint(
            'Announcement response JSON decoding failed at offset ${formatError.offset}.');
        errorMessage =
            'The server returned an invalid announcement response. Please try again.';
      } else if (e is DioException) {
        final data = e.response?.data;
        final message = data is Map ? data['message'] : null;
        errorMessage =
            message is String ? message : (e.message ?? errorMessage);
      }
      emit(state.copyWith(
        announcementLoading: false,
        announcementErrorMessage: errorMessage,
        announcementError: true,
        announcements: state.announcements,
      ));
    }
  }
}
