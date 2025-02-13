part of 'clockin_prayer_bloc.dart';

abstract class ClockinPrayerEvent extends Equatable {
  const ClockinPrayerEvent();
}

class OnInit extends ClockinPrayerEvent {
  final Map<String, dynamic> map;
  const OnInit(this.map);
  @override
  List<Object?> get props => [];
}

class GetPraySchedule extends ClockinPrayerEvent {
  const GetPraySchedule();
  @override
  List<Object?> get props => [];
}

class GetLocationName extends ClockinPrayerEvent {
  const GetLocationName();
  @override
  List<Object?> get props => [];
}
