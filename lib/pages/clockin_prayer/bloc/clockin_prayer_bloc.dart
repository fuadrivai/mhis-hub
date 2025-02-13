import 'package:adhan/adhan.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/models/model.dart';
import 'package:fl_mhis_hr/pages/clockin_prayer/data/clock_in_prayer_api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

part 'clockin_prayer_event.dart';
part 'clockin_prayer_state.dart';

class ClockinPrayerBloc extends Bloc<ClockinPrayerEvent, ClockinPrayerState> {
  ClockinPrayerBloc() : super(const ClockinPrayerState()) {
    on<OnInit>(_onInit);
    on<GetPraySchedule>(_getPrayerSchedule);
    on<GetLocationName>(_getLocationName);
  }

  void _onInit(OnInit event, Emitter<ClockinPrayerState> emit) async {
    try {
      emit(state.copyWith(isLoading: true));
      List<PostPrayer> history = await ClockInPrayerApi.get(event.map);
      emit(state.copyWith(
        isLoading: false,
        histories: history,
        isError: false,
        isSuccess: true,
      ));
    } catch (e) {
      String errorMessage = e.toString();
      if (e.runtimeType == DioException) {
        DioException err = e as DioException;
        errorMessage = err.response?.data?["message"] ?? err.message;
      }
      emit(state.copyWith(
        isLoading: false,
        isError: true,
        isSuccess: false,
        histories: state.histories,
        errorMessage: errorMessage,
      ));
    }
  }

  void _getPrayerSchedule(
      GetPraySchedule event, Emitter<ClockinPrayerState> emit) async {
    try {
      emit(state.copyWith(scheduleLoading: true));
      Position position = await Common.determinePosition();
      final coordinate = Coordinates(
        position.latitude,
        position.longitude,
        validate: true,
      );
      final params = CalculationMethod.muslim_world_league.getParameters();
      params.madhab = Madhab.shafi;
      final times = PrayerTimes.today(coordinate, params);

      DateTime now = DateTime.now();
      String prayerName = "Fajr";
      int seconds = 0;
      bool isBefore = false;
      for (var i = 0; i <= 5; i++) {
        if (!isBefore) {
          if (i == 0) {
            seconds =
                times.fajr.millisecondsSinceEpoch - now.millisecondsSinceEpoch;
            prayerName = "Fajr";
            isBefore = now.isBefore(times.fajr);
          } else if (i == 1) {
            seconds =
                times.dhuhr.millisecondsSinceEpoch - now.millisecondsSinceEpoch;
            prayerName = "Dzuhur";
            isBefore = now.isBefore(times.dhuhr);
          } else if (i == 2) {
            seconds =
                times.asr.millisecondsSinceEpoch - now.millisecondsSinceEpoch;
            prayerName = "Ashar";
            isBefore = now.isBefore(times.asr);
          } else if (i == 3) {
            seconds = times.maghrib.millisecondsSinceEpoch -
                now.millisecondsSinceEpoch;
            prayerName = "Maghrib";
            isBefore = now.isBefore(times.maghrib);
          } else if (i == 4) {
            seconds =
                times.isha.millisecondsSinceEpoch - now.millisecondsSinceEpoch;
            prayerName = "Isha";
            isBefore = now.isBefore(times.isha);
          } else {
            DateTime nextDay = now.add(const Duration(days: 1));
            PrayerTimes pr =
                PrayerTimes(coordinate, DateComponents.from(nextDay), params);
            seconds =
                pr.fajr.millisecondsSinceEpoch - now.millisecondsSinceEpoch;
            prayerName =
                "Fajr (${nextDay.month}/${nextDay.day}/${nextDay.year})";
            isBefore = now.isBefore(pr.fajr);
          }
        }
      }
      seconds = seconds ~/ 1000;
      emit(state.copyWith(
        scheduleLoading: false,
        errorSchedule: false,
        successSchedule: true,
        prayerTimes: times,
        prayerName: prayerName,
        seconds: seconds,
      ));
    } catch (e) {
      String errorMessage = e.toString();
      if (e.runtimeType == DioException) {
        DioException err = e as DioException;
        errorMessage = err.response?.data?["message"] ?? err.message;
      }
      emit(state.copyWith(
        scheduleLoading: false,
        errorSchedule: true,
        successSchedule: false,
        prayerTimes: state.prayerTimes,
        placemarks: state.placemarks,
        errorMessageSchedule: errorMessage,
      ));
    }
  }

  void _getLocationName(
      GetLocationName event, Emitter<ClockinPrayerState> emit) async {
    try {
      Position position = await Common.determinePosition();
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      emit(state.copyWith(placemarks: placemarks));
    } catch (e) {
      String errorMessage = e.toString();
      if (e.runtimeType == DioException) {
        DioException err = e as DioException;
        errorMessage = err.response?.data?["message"] ?? err.message;
      }
      emit(state.copyWith(errorMessage: errorMessage));
    }
  }
}
