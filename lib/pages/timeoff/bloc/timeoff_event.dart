part of 'timeoff_bloc.dart';

abstract class TimeoffEvent extends Equatable {
  const TimeoffEvent();
}

class OnInit extends TimeoffEvent {
  const OnInit();
  @override
  List<Object?> get props => [];
}

class OnInitForm extends TimeoffEvent {
  const OnInitForm();
  @override
  List<Object?> get props => [];
}

class OnSubmitTimeoffForm extends TimeoffEvent {
  final int timeoffId;
  final Map<String, String> formData;
  final String note;
  final String? attachmentPath;

  const OnSubmitTimeoffForm({
    required this.timeoffId,
    required this.formData,
    required this.note,
    this.attachmentPath,
  });

  @override
  List<Object?> get props => [timeoffId, formData, note, attachmentPath];
}
