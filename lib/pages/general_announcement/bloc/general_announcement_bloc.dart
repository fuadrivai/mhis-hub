import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:fl_mhis_hr/models/job_postion.dart';
import 'package:fl_mhis_hr/models/model.dart';
import 'package:fl_mhis_hr/pages/general_announcement/data/general_announcement_api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jiffy/jiffy.dart';

part 'general_announcement_event.dart';
part 'general_announcement_state.dart';

class GeneralAnnouncementBloc
    extends Bloc<GeneralAnnouncementEvent, GeneralAnnouncementState> {
  GeneralAnnouncementBloc() : super(const GeneralAnnouncementState()) {
    on<OnInit>(_onInit);
    on<OnSubmit>(_onSubmit);
    on<OnInitForm>(_onInitForm);
    on<OnChangedCategory>(_onChangedCategory);
    on<OnChangedSubject>(_onChangedSubject);
    on<OnChangedContent>(_onChangedContent);
    on<OnChangedLink>(_onChangedLink);
    on<OnChangedPostAllEmployee>(_onChangedPostAllEmployee);
    on<OnChangeBranches>(_onChangeBranch);
    on<OnChangeLevel>(_onChangeLevel);
    on<OnChangeOrganization>(_onChangOrganization);
    on<OnChangePosition>(_onChangePosition);
  }

  void _onChangeLevel(
      OnChangeLevel event, Emitter<GeneralAnnouncementState> emit) {
    Announcement announcement = state.announcement ?? Announcement();
    List<JobLevel> levels = announcement.levels ?? [];
    if (event.value) {
      levels.add(event.val);
    } else {
      levels.removeWhere((data) => data.id == event.val.id);
    }
    announcement.levels = levels;
    emit(state.copyWith(announcement: announcement));
  }

  void _onChangePosition(
      OnChangePosition event, Emitter<GeneralAnnouncementState> emit) {
    Announcement announcement = state.announcement ?? Announcement();
    List<JobPosition> positions = announcement.positions ?? [];
    if (event.value) {
      positions.add(event.val);
    } else {
      positions.removeWhere((data) => data.id == event.val.id);
    }
    announcement.positions = positions;
    emit(state.copyWith(announcement: announcement));
  }

  void _onChangOrganization(
      OnChangeOrganization event, Emitter<GeneralAnnouncementState> emit) {
    Announcement announcement = state.announcement ?? Announcement();
    List<Organization> organizations = announcement.organizations ?? [];
    if (event.value) {
      organizations.add(event.val);
    } else {
      organizations.removeWhere((data) => data.id == event.val.id);
    }
    announcement.organizations = organizations;
    emit(state.copyWith(announcement: announcement));
  }

  void _onChangeBranch(
      OnChangeBranches event, Emitter<GeneralAnnouncementState> emit) {
    Announcement announcement = state.announcement ?? Announcement();
    List<Branch> branches = announcement.branches ?? [];
    if (event.value) {
      branches.add(event.val);
    } else {
      branches.removeWhere((data) => data.id == event.val.id);
    }
    announcement.branches = branches;
    emit(state.copyWith(announcement: announcement));
  }

  void _onInit(OnInit event, Emitter<GeneralAnnouncementState> emit) async {
    emit(state.copyWith(isLoading: true));
    List<Announcement> announcements =
        await GeneralAnnouncementApi.getAnnouncement();
    emit(state.copyWith(
      isLoading: false,
      isError: false,
      isSuccess: true,
      announcements: announcements,
    ));
  }

  void _onChangedCategory(
      OnChangedCategory event, Emitter<GeneralAnnouncementState> emit) {
    Announcement announcement = state.announcement ?? Announcement();
    announcement.category = event.category;
    emit(state.copyWith(announcement: announcement));
  }

  void _onChangedSubject(
      OnChangedSubject event, Emitter<GeneralAnnouncementState> emit) {
    Announcement announcement = state.announcement ?? Announcement();
    announcement.subject = event.val;
    emit(state.copyWith(announcement: announcement));
  }

  void _onChangedContent(
      OnChangedContent event, Emitter<GeneralAnnouncementState> emit) {
    Announcement announcement = state.announcement ?? Announcement();
    announcement.content = event.val;
    emit(state.copyWith(announcement: announcement));
  }

  void _onChangedLink(
      OnChangedLink event, Emitter<GeneralAnnouncementState> emit) {
    Announcement announcement = state.announcement ?? Announcement();
    announcement.link = event.val;
    emit(state.copyWith(announcement: announcement));
  }

  void _onChangedPostAllEmployee(OnChangedPostAllEmployee event,
      Emitter<GeneralAnnouncementState> emit) async {
    try {
      Announcement announcement = state.announcement ?? Announcement();
      List<Branch> branches = [];
      List<Organization> organizations = [];
      List<JobLevel> levels = [];
      List<JobPosition> positions = [];
      announcement.allEmployees = event.val;
      if (!event.val) {
        await Future.wait([
          GeneralAnnouncementApi.getBranch().then((val) => branches = val),
          GeneralAnnouncementApi.getJobPosition()
              .then((val) => positions = val),
          GeneralAnnouncementApi.getOrganization()
              .then((val) => organizations = val),
          GeneralAnnouncementApi.getJobLevel().then((val) => levels = val),
        ]);
        announcement.allEmployees = event.val;
        emit(state.copyWith(
          announcement: announcement,
          levels: levels,
          branches: branches,
          organizations: organizations,
          positions: positions,
        ));
      } else {
        announcement.allEmployees = event.val;
        announcement.branches = [];
        announcement.organizations = [];
        announcement.levels = [];
        announcement.positions = [];
        emit(state.copyWith(
          announcement: announcement,
          levels: levels,
          branches: branches,
          organizations: organizations,
          positions: positions,
        ));
      }
    } catch (e) {
      String errorMessage = e.toString();
      if (e.runtimeType == DioException) {
        DioException err = e as DioException;
        errorMessage = err.response?.data?["message"] ?? err.message;
      }
      emit(state.copyWith(
        loadingButton: false,
        buttonErrorMessage: errorMessage,
        announcement: state.announcement,
        errorButton: true,
      ));
    }
  }

  void _onSubmit(OnSubmit event, Emitter<GeneralAnnouncementState> emit) async {
    emit(state.copyWith(loadingButton: true));
    try {
      Announcement announcement = state.announcement ?? Announcement();
      announcement.date = Jiffy.now().format(pattern: "yyyy-MM-dd");
      await GeneralAnnouncementApi.post(announcement);
      emit(state.copyWith(
        loadingButton: false,
        errorButton: false,
        announcement: announcement,
        successButton: true,
      ));
    } catch (e) {
      String errorMessage = e.toString();
      if (e.runtimeType == DioException) {
        DioException err = e as DioException;
        errorMessage = err.response?.data?["message"] ?? err.message;
      }
      emit(state.copyWith(
        loadingButton: false,
        buttonErrorMessage: errorMessage,
        announcement: state.announcement,
        errorButton: true,
      ));
    }
  }

  void _onInitForm(
      OnInitForm event, Emitter<GeneralAnnouncementState> emit) async {
    try {
      emit(state.copyWith(loadingForm: true, announcement: Announcement()));
      List<AnnouncementCategory> categories = [];
      categories.add(
        AnnouncementCategory(description: null, id: 0, name: "Uncategorized"),
      );
      List<AnnouncementCategory> realCategories =
          await GeneralAnnouncementApi.getCategory();
      categories = categories + realCategories;
      Announcement announcement = state.announcement ?? Announcement();
      announcement.category = categories[0];
      announcement.allEmployees = true;

      emit(state.copyWith(
        loadingForm: false,
        errorForm: false,
        successForm: true,
        categories: categories,
        announcement: announcement,
      ));
    } catch (e) {
      String errorMessage = e.toString();
      if (e.runtimeType == DioException) {
        DioException err = e as DioException;
        errorMessage = err.response?.data?["message"] ?? err.message;
      }
      emit(state.copyWith(
        loadingForm: false,
        formErrorMessage: errorMessage,
        categories: state.categories,
        errorForm: true,
      ));
    }
  }
}
