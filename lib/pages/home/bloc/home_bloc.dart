import 'package:equatable/equatable.dart';
import 'package:fl_mhis_hr/models/model.dart';
import 'package:fl_mhis_hr/pages/home/repository/home_api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(const HomeState()) {
    on<OnGetSchoolCalendar>(_onGetSchoolCalendar);
    on<OnGetNewsletter>(_onGetNewsletter);
  }

  void _onGetSchoolCalendar(
      OnGetSchoolCalendar event, Emitter<HomeState> emit) async {
    emit(state.copyWith(scheduleLoading: true));
    String url =
        "https://script.google.com/a/macros/mutiaraharapan.sch.id/s/AKfycby3GpZVOQ9QBzpZm9jg27JXTntGCj5p8JhUPUdCvqiqb6MmbmXjiOrsadkKEhLNWxJP/exec?level=Preschool,Primary,Secondary";
    List<Schedule> schedules = await HomeApi.getSchoolCalendar(url);
    emit(state.copyWith(schedules: schedules, scheduleLoading: false));
  }

  void _onGetNewsletter(OnGetNewsletter event, Emitter<HomeState> emit) async {
    emit(state.copyWith(newsletterLoading: true));
    String url =
        "https://script.google.com/macros/s/AKfycby2pXoGdSuIRFbC1HZUGAV8NSJEwQcYIbuYEMnhdqo0bbmj9qMg3ZjWfJnQP5TdnyFp/exec?level=Preschool,Primary,Secondary";
    List<Newsletter> newsletters = await HomeApi.getNewsletter(url);
    emit(state.copyWith(newsletters: newsletters, newsletterLoading: false));
  }
}
