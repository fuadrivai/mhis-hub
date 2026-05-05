part of 'general_announcement_bloc.dart';

final class GeneralAnnouncementState extends Equatable {
  final bool isLoading,
      isError,
      isSuccess,
      loadingForm,
      errorForm,
      successForm,
      loadingButton,
      errorButton,
      successButton;
  final String? errorMessage;
  final String? buttonErrorMessage;
  final String? formErrorMessage;
  final Announcement? announcement;
  final List<Announcement>? announcements;
  final List<AnnouncementCategory>? categories;
  final List<Branch>? branches;
  final List<Organization>? organizations;
  final List<JobLevel>? levels;
  final List<JobPosition>? positions;

  const GeneralAnnouncementState({
    this.isLoading = false,
    this.loadingForm = false,
    this.isError = false,
    this.errorForm = false,
    this.isSuccess = false,
    this.successForm = false,
    this.loadingButton = false,
    this.errorButton = false,
    this.successButton = false,
    this.errorMessage,
    this.formErrorMessage,
    this.announcements,
    this.announcement,
    this.categories,
    this.buttonErrorMessage,
    this.branches,
    this.levels,
    this.organizations,
    this.positions,
  });
  GeneralAnnouncementState copyWith({
    bool? isLoading,
    bool? isError,
    bool? isSuccess,
    bool? successForm,
    bool? errorForm,
    bool? loadingForm,
    bool? loadingButton,
    bool? errorButton,
    bool? successButton,
    String? errorMessage,
    String? formErrorMessage,
    String? buttonErrorMessage,
    List<Announcement>? announcements,
    List<AnnouncementCategory>? categories,
    Announcement? announcement,
    List<Branch>? branches,
    List<Organization>? organizations,
    List<JobLevel>? levels,
    List<JobPosition>? positions,
  }) {
    return GeneralAnnouncementState(
      errorMessage: errorMessage ?? this.errorMessage,
      isError: isError ?? this.isError,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      successForm: successForm ?? this.successForm,
      errorForm: errorForm ?? this.errorForm,
      loadingForm: loadingForm ?? this.loadingForm,
      formErrorMessage: formErrorMessage ?? this.formErrorMessage,
      announcements: announcements ?? this.announcements,
      categories: categories ?? this.categories,
      announcement: announcement ?? this.announcement,
      loadingButton: loadingButton ?? this.loadingButton,
      errorButton: errorButton ?? this.errorButton,
      successButton: successButton ?? this.successButton,
      buttonErrorMessage: buttonErrorMessage ?? this.buttonErrorMessage,
      branches: branches ?? this.branches,
      organizations: organizations ?? this.organizations,
      levels: levels ?? this.levels,
      positions: positions ?? this.positions,
    );
  }

  @override
  List<Object?> get props => [
        errorMessage,
        isLoading,
        isError,
        isSuccess,
        loadingForm,
        formErrorMessage,
        errorForm,
        successForm,
        announcements,
        categories,
        announcement,
        loadingButton,
        errorButton,
        successButton,
        buttonErrorMessage,
        positions,
        branches,
        levels,
        organizations,
      ];
}
