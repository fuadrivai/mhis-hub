part of 'visitor_bloc.dart';

class VisitorListState<T> extends Equatable {
  const VisitorListState({
    this.items = const [],
    this.page = 0,
    this.hasMore = true,
    this.loading = false,
    this.error,
    this.query = '',
    this.filters = const {},
  });
  final List<T> items;
  final int page;
  final bool hasMore;
  final bool loading;
  final String? error;
  final String query;
  final Map<String, int?> filters;

  VisitorListState<T> copyWith({
    List<T>? items,
    int? page,
    bool? hasMore,
    bool? loading,
    String? error,
    String? query,
    Map<String, int?>? filters,
  }) =>
      VisitorListState(
        items: items ?? this.items,
        page: page ?? this.page,
        hasMore: hasMore ?? this.hasMore,
        loading: loading ?? this.loading,
        error: error,
        query: query ?? this.query,
        filters: filters ?? this.filters,
      );

  @override
  List<Object?> get props =>
      [items, page, hasMore, loading, error, query, filters];
}

class VisitorHostFilterStatus extends Equatable {
  const VisitorHostFilterStatus({
    this.loading = false,
    this.options,
    this.error,
  });

  final bool loading;
  final VisitorHostFilters? options;
  final String? error;

  @override
  List<Object?> get props => [loading, options, error];
}

class VisitorFormStatus extends Equatable {
  const VisitorFormStatus({
    this.loading = false,
    this.options,
    this.optionsError,
    this.submitting = false,
    this.submissionError,
    this.created = false,
  });
  final bool loading, submitting, created;
  final VisitorFormOptions? options;
  final String? optionsError, submissionError;

  @override
  List<Object?> get props =>
      [loading, options, optionsError, submitting, submissionError, created];
}

class VisitorDetailStatus extends Equatable {
  const VisitorDetailStatus({
    this.loading = false,
    this.visit,
    this.error,
    this.cancelling = false,
    this.cancelError,
    this.cancelled = false,
  });
  final bool loading, cancelling, cancelled;
  final Visit? visit;
  final String? error, cancelError;

  @override
  List<Object?> get props =>
      [loading, visit, error, cancelling, cancelError, cancelled];
}

class VisitorCurrentHostStatus extends Equatable {
  const VisitorCurrentHostStatus({this.loading = false, this.host, this.error});
  final bool loading;
  final VisitorOption? host;
  final String? error;

  @override
  List<Object?> get props => [loading, host, error];
}

class VisitorState extends Equatable {
  const VisitorState({
    this.invitations = const VisitorListState<Visit>(),
    this.monitoring = const VisitorListState<Visit>(),
    this.hosts = const VisitorListState<VisitorHost>(),
    this.hostFilters = const VisitorHostFilterStatus(),
    this.form = const VisitorFormStatus(),
    this.detail = const VisitorDetailStatus(),
    this.currentHost = const VisitorCurrentHostStatus(),
  });
  final VisitorListState<Visit> invitations, monitoring;
  final VisitorListState<VisitorHost> hosts;
  final VisitorHostFilterStatus hostFilters;
  final VisitorFormStatus form;
  final VisitorDetailStatus detail;
  final VisitorCurrentHostStatus currentHost;

  VisitorListState<Visit> list(VisitorListType type) =>
      type == VisitorListType.invitations ? invitations : monitoring;

  VisitorState copyWith({
    VisitorListState<Visit>? invitations,
    VisitorListState<Visit>? monitoring,
    VisitorListState<VisitorHost>? hosts,
    VisitorHostFilterStatus? hostFilters,
    VisitorFormStatus? form,
    VisitorDetailStatus? detail,
    VisitorCurrentHostStatus? currentHost,
  }) =>
      VisitorState(
        invitations: invitations ?? this.invitations,
        monitoring: monitoring ?? this.monitoring,
        hosts: hosts ?? this.hosts,
        hostFilters: hostFilters ?? this.hostFilters,
        form: form ?? this.form,
        detail: detail ?? this.detail,
        currentHost: currentHost ?? this.currentHost,
      );

  @override
  List<Object?> get props =>
      [invitations, monitoring, hosts, hostFilters, form, detail, currentHost];
}
