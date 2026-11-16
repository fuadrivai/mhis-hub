part of 'visitor_bloc.dart';

class VisitorListState<T> extends Equatable {
  const VisitorListState({
    this.items = const [],
    this.page = 0,
    this.total,
    this.hasMore = true,
    this.loading = false,
    this.error,
    this.query = '',
    this.filters = const {},
  });
  final List<T> items;
  final int page;
  final int? total;
  final bool hasMore;
  final bool loading;
  final String? error;
  final String query;
  final Map<String, dynamic> filters;

  VisitorListState<T> copyWith({
    List<T>? items,
    int? page,
    int? total,
    bool? hasMore,
    bool? loading,
    String? error,
    String? query,
    Map<String, dynamic>? filters,
  }) =>
      VisitorListState(
        items: items ?? this.items,
        page: page ?? this.page,
        total: total ?? this.total,
        hasMore: hasMore ?? this.hasMore,
        loading: loading ?? this.loading,
        error: error,
        query: query ?? this.query,
        filters: filters ?? this.filters,
      );

  @override
  List<Object?> get props =>
      [items, page, total, hasMore, loading, error, query, filters];
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

class VisitorInvitationLinksStatus extends Equatable {
  const VisitorInvitationLinksStatus({
    this.submitting = false,
    this.result,
    this.error,
  });

  final bool submitting;
  final VisitorInvitationLinksResult? result;
  final String? error;

  @override
  List<Object?> get props => [submitting, result, error];
}

class VisitorInvitationLinkBatchDetailStatus extends Equatable {
  const VisitorInvitationLinkBatchDetailStatus({
    this.loading = false,
    this.batch,
    this.error,
  });

  final bool loading;
  final VisitorInvitationLinksResult? batch;
  final String? error;

  @override
  List<Object?> get props => [loading, batch, error];
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
    this.todayInvitations = const VisitorListState<Visit>(),
    this.todayMonitoring = const VisitorListState<Visit>(),
    this.homeTodayInvitations = const VisitorListState<Visit>(),
    this.homeTodayMonitoring = const VisitorListState<Visit>(),
    this.hosts = const VisitorListState<VisitorHost>(),
    this.hostFilters = const VisitorHostFilterStatus(),
    this.form = const VisitorFormStatus(),
    this.detail = const VisitorDetailStatus(),
    this.invitationLinks = const VisitorInvitationLinksStatus(),
    this.invitationLinkBatches =
        const VisitorListState<VisitorInvitationLinksResult>(),
    this.invitationLinkBatchDetail =
        const VisitorInvitationLinkBatchDetailStatus(),
    this.currentHost = const VisitorCurrentHostStatus(),
  });
  final VisitorListState<Visit> invitations,
      monitoring,
      todayInvitations,
      todayMonitoring,
      homeTodayInvitations,
      homeTodayMonitoring;
  final VisitorListState<VisitorHost> hosts;
  final VisitorHostFilterStatus hostFilters;
  final VisitorFormStatus form;
  final VisitorDetailStatus detail;
  final VisitorInvitationLinksStatus invitationLinks;
  final VisitorListState<VisitorInvitationLinksResult> invitationLinkBatches;
  final VisitorInvitationLinkBatchDetailStatus invitationLinkBatchDetail;
  final VisitorCurrentHostStatus currentHost;

  VisitorListState<Visit> list(VisitorListType type) =>
      type == VisitorListType.invitations ? invitations : monitoring;

  VisitorState copyWith({
    VisitorListState<Visit>? invitations,
    VisitorListState<Visit>? monitoring,
    VisitorListState<Visit>? todayInvitations,
    VisitorListState<Visit>? todayMonitoring,
    VisitorListState<Visit>? homeTodayInvitations,
    VisitorListState<Visit>? homeTodayMonitoring,
    VisitorListState<VisitorHost>? hosts,
    VisitorHostFilterStatus? hostFilters,
    VisitorFormStatus? form,
    VisitorDetailStatus? detail,
    VisitorInvitationLinksStatus? invitationLinks,
    VisitorListState<VisitorInvitationLinksResult>? invitationLinkBatches,
    VisitorInvitationLinkBatchDetailStatus? invitationLinkBatchDetail,
    VisitorCurrentHostStatus? currentHost,
  }) =>
      VisitorState(
        invitations: invitations ?? this.invitations,
        monitoring: monitoring ?? this.monitoring,
        todayInvitations: todayInvitations ?? this.todayInvitations,
        todayMonitoring: todayMonitoring ?? this.todayMonitoring,
        homeTodayInvitations: homeTodayInvitations ?? this.homeTodayInvitations,
        homeTodayMonitoring: homeTodayMonitoring ?? this.homeTodayMonitoring,
        hosts: hosts ?? this.hosts,
        hostFilters: hostFilters ?? this.hostFilters,
        form: form ?? this.form,
        detail: detail ?? this.detail,
        invitationLinks: invitationLinks ?? this.invitationLinks,
        invitationLinkBatches:
            invitationLinkBatches ?? this.invitationLinkBatches,
        invitationLinkBatchDetail:
            invitationLinkBatchDetail ?? this.invitationLinkBatchDetail,
        currentHost: currentHost ?? this.currentHost,
      );

  @override
  List<Object?> get props => [
        invitations,
        monitoring,
        todayInvitations,
        todayMonitoring,
        homeTodayInvitations,
        homeTodayMonitoring,
        hosts,
        hostFilters,
        form,
        detail,
        invitationLinks,
        invitationLinkBatches,
        invitationLinkBatchDetail,
        currentHost,
      ];
}
