part of 'general_announcement_bloc.dart';

abstract class GeneralAnnouncementEvent extends Equatable {
  const GeneralAnnouncementEvent();
}

class OnInit extends GeneralAnnouncementEvent {
  const OnInit();
  @override
  List<Object?> get props => [];
}

class OnSubmit extends GeneralAnnouncementEvent {
  const OnSubmit();
  @override
  List<Object?> get props => [];
}

class OnInitForm extends GeneralAnnouncementEvent {
  const OnInitForm();
  @override
  List<Object?> get props => [];
}

class OnChangedCategory extends GeneralAnnouncementEvent {
  final AnnouncementCategory category;
  const OnChangedCategory(this.category);
  @override
  List<Object?> get props => [];
}

class OnChangedSubject extends GeneralAnnouncementEvent {
  final String val;
  const OnChangedSubject(this.val);
  @override
  List<Object?> get props => [];
}

class OnChangedContent extends GeneralAnnouncementEvent {
  final String val;
  const OnChangedContent(this.val);
  @override
  List<Object?> get props => [];
}

class OnChangedPostAllEmployee extends GeneralAnnouncementEvent {
  final bool val;
  const OnChangedPostAllEmployee(this.val);
  @override
  List<Object?> get props => [];
}

class OnChangedLink extends GeneralAnnouncementEvent {
  final String val;
  const OnChangedLink(this.val);
  @override
  List<Object?> get props => [];
}

class OnChangeBranches extends GeneralAnnouncementEvent {
  final Branch val;
  final bool value;
  const OnChangeBranches(this.val, this.value);
  @override
  List<Object?> get props => [];
}

class OnChangeOrganization extends GeneralAnnouncementEvent {
  final bool value;
  final Organization val;
  const OnChangeOrganization(this.val, this.value);
  @override
  List<Object?> get props => [];
}

class OnChangePosition extends GeneralAnnouncementEvent {
  final JobPosition val;
  final bool value;
  const OnChangePosition(this.val, this.value);
  @override
  List<Object?> get props => [];
}

class OnChangeLevel extends GeneralAnnouncementEvent {
  final JobLevel val;
  final bool value;
  const OnChangeLevel(this.val, this.value);
  @override
  List<Object?> get props => [];
}
