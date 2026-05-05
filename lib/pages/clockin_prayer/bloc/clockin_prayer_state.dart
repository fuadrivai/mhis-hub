part of 'clockin_prayer_bloc.dart';

final class ClockinPrayerState extends Equatable {
  final bool isLoading, isError, isSuccess;
  final bool scheduleLoading, errorSchedule, successSchedule;
  final String? errorMessage;
  final String? errorMessageSchedule;
  final String? prayerName;
  final List<PostPrayer>? histories;
  final List<Placemark>? placemarks;
  final PrayerTimes? prayerTimes;
  final int? seconds;

  const ClockinPrayerState({
    this.isLoading = false,
    this.isError = false,
    this.isSuccess = false,
    this.scheduleLoading = false,
    this.errorSchedule = false,
    this.successSchedule = false,
    this.errorMessage,
    this.errorMessageSchedule,
    this.histories,
    this.prayerTimes,
    this.placemarks,
    this.prayerName,
    this.seconds,
  });

  ClockinPrayerState copyWith({
    bool? isLoading,
    bool? isError,
    bool? isSuccess,
    String? errorMessage,
    String? prayerName,
    bool? scheduleLoading,
    bool? errorSchedule,
    bool? successSchedule,
    int? seconds,
    String? errorMessageSchedule,
    List<PostPrayer>? histories,
    PrayerTimes? prayerTimes,
    List<Placemark>? placemarks,
  }) {
    return ClockinPrayerState(
      errorMessage: errorMessage ?? this.errorMessage,
      isError: isError ?? this.isError,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      histories: histories ?? this.histories,
      scheduleLoading: scheduleLoading ?? this.scheduleLoading,
      errorSchedule: errorSchedule ?? this.errorSchedule,
      successSchedule: successSchedule ?? this.successSchedule,
      errorMessageSchedule: errorMessageSchedule ?? this.errorMessageSchedule,
      prayerTimes: prayerTimes ?? this.prayerTimes,
      placemarks: placemarks ?? this.placemarks,
      prayerName: prayerName ?? this.prayerName,
      seconds: seconds ?? this.seconds,
    );
  }

  @override
  List<Object?> get props => [
        errorMessage,
        isLoading,
        isError,
        isSuccess,
        histories,
        scheduleLoading,
        errorSchedule,
        successSchedule,
        errorMessageSchedule,
        prayerTimes,
        placemarks,
        prayerName,
        seconds,
      ];
}
