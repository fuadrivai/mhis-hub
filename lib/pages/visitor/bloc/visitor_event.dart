part of 'visitor_bloc.dart';

enum VisitorListType { invitations, monitoring }

abstract class VisitorEvent extends Equatable {
  const VisitorEvent();
}

class LoadVisitorList extends VisitorEvent {
  const LoadVisitorList(this.type, {this.reset = false, this.completion});
  final VisitorListType type;
  final bool reset;
  final Completer<void>? completion;

  @override
  List<Object?> get props => [type, reset, completion];
}

class LoadVisitorForm extends VisitorEvent {
  const LoadVisitorForm();

  @override
  List<Object?> get props => [];
}

class LoadVisitorCurrentHost extends VisitorEvent {
  const LoadVisitorCurrentHost();

  @override
  List<Object?> get props => [];
}

class SubmitVisitorInvitation extends VisitorEvent {
  const SubmitVisitorInvitation(this.fields, this.attachment);
  final Map<String, dynamic> fields;
  final VisitorAttachment? attachment;

  @override
  List<Object?> get props => [fields, attachment];
}

class SearchVisitorHosts extends VisitorEvent {
  const SearchVisitorHosts({
    this.query,
    this.filters,
    this.reset = false,
  });
  final String? query;
  final Map<String, int?>? filters;
  final bool reset;

  @override
  List<Object?> get props => [query, filters, reset];
}

class LoadVisitorHostFilters extends VisitorEvent {
  const LoadVisitorHostFilters();

  @override
  List<Object?> get props => [];
}

class LoadVisitorDetail extends VisitorEvent {
  const LoadVisitorDetail(this.id);
  final int id;

  @override
  List<Object?> get props => [id];
}

class CancelVisitorInvitation extends VisitorEvent {
  const CancelVisitorInvitation(this.id, this.reason);
  final int id;
  final String reason;

  @override
  List<Object?> get props => [id, reason];
}
