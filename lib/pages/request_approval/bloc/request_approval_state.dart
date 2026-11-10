part of 'request_approval_bloc.dart';

final class RequestApprovalState extends Equatable {
  final bool isLoading, isError, isSuccess, loadMore;
  final bool isRequestLoading, isApprovalLoading;
  final bool isRequestRefreshing, isApprovalRefreshing;
  final bool isFormLoading, isFormError, isFormSuccess;
  final bool isBalanceLoading, isBalanceError, isBalanceSuccess, isBalanceEmpty;
  final bool isFilterLoading, isFilterError;
  final bool isNextLoading, isNextError, isNextEmpty;
  final Approval? nextApproval;
  final String? errorMessage;
  final String? requestRefreshError, approvalRefreshError;
  final List<ApprovalRequest> requests;
  final List<ApprovalRequest> allTimeoffRequests;
  final List<Approval> approvals;
  final Pagination? allTimeoffPagination;
  final ApprovalRequest? request;
  final Approval? approval;
  final LeaveAllocation? leaveBalance;
  final List<Branch> branches;
  final List<Organization> organizations;
  final List<JobLevel> jobLevels;
  final List<JobPosition> jobPositions;
  final List<Timeoff> timeoffs;
  const RequestApprovalState({
    this.isLoading = false,
    this.isRequestLoading = false,
    this.isApprovalLoading = false,
    this.isRequestRefreshing = false,
    this.isApprovalRefreshing = false,
    this.isFormLoading = false,
    this.isError = false,
    this.isFormError = false,
    this.isSuccess = false,
    this.isFormSuccess = false,
    this.isBalanceLoading = false,
    this.isBalanceError = false,
    this.isBalanceSuccess = false,
    this.isBalanceEmpty = false,
    this.isFilterLoading = false,
    this.isFilterError = false,
    this.isNextLoading = false,
    this.isNextError = false,
    this.isNextEmpty = false,
    this.nextApproval,
    this.errorMessage,
    this.requestRefreshError,
    this.approvalRefreshError,
    this.loadMore = false,
    this.requests = const [],
    this.allTimeoffRequests = const [],
    this.approvals = const [],
    this.allTimeoffPagination,
    this.request,
    this.approval,
    this.leaveBalance,
    this.branches = const [],
    this.organizations = const [],
    this.jobLevels = const [],
    this.jobPositions = const [],
    this.timeoffs = const [],
  });
  RequestApprovalState copyWith({
    bool? isLoading,
    bool? isRequestLoading,
    bool? isApprovalLoading,
    bool? isRequestRefreshing,
    bool? isApprovalRefreshing,
    bool? isError,
    bool? isSuccess,
    bool? loadMore,
    String? errorMessage,
    String? requestRefreshError,
    String? approvalRefreshError,
    bool clearRequestRefreshError = false,
    bool clearApprovalRefreshError = false,
    bool? isFormLoading,
    bool? isFormError,
    bool? isFormSuccess,
    bool? isBalanceLoading,
    bool? isBalanceError,
    bool? isBalanceSuccess,
    bool? isBalanceEmpty,
    bool? isFilterLoading,
    bool? isFilterError,
    bool? isNextLoading,
    bool? isNextError,
    bool? isNextEmpty,
    Approval? nextApproval,
    List<ApprovalRequest>? requests,
    List<Approval>? approvals,
    ApprovalRequest? request,
    Approval? approval,
    LeaveAllocation? leaveBalance,
    List<ApprovalRequest>? allTimeoffRequests,
    Pagination? allTimeoffPagination,
    List<Branch>? branches,
    List<Organization>? organizations,
    List<JobLevel>? jobLevels,
    List<JobPosition>? jobPositions,
    List<Timeoff>? timeoffs,
  }) {
    return RequestApprovalState(
      errorMessage: errorMessage ?? this.errorMessage,
      requestRefreshError: clearRequestRefreshError
          ? null
          : requestRefreshError ?? this.requestRefreshError,
      approvalRefreshError: clearApprovalRefreshError
          ? null
          : approvalRefreshError ?? this.approvalRefreshError,
      isError: isError ?? this.isError,
      isLoading: isLoading ?? this.isLoading,
      isRequestLoading: isRequestLoading ?? this.isRequestLoading,
      isApprovalLoading: isApprovalLoading ?? this.isApprovalLoading,
      isRequestRefreshing: isRequestRefreshing ?? this.isRequestRefreshing,
      isApprovalRefreshing: isApprovalRefreshing ?? this.isApprovalRefreshing,
      isSuccess: isSuccess ?? this.isSuccess,
      loadMore: loadMore ?? this.loadMore,
      isFormLoading: isFormLoading ?? this.isFormLoading,
      isFormError: isFormError ?? this.isFormError,
      isFormSuccess: isFormSuccess ?? this.isFormSuccess,
      isBalanceLoading: isBalanceLoading ?? this.isBalanceLoading,
      isBalanceError: isBalanceError ?? this.isBalanceError,
      isBalanceSuccess: isBalanceSuccess ?? this.isBalanceSuccess,
      isBalanceEmpty: isBalanceEmpty ?? this.isBalanceEmpty,
      isFilterLoading: isFilterLoading ?? this.isFilterLoading,
      isFilterError: isFilterError ?? this.isFilterError,
      isNextLoading: isNextLoading ?? this.isNextLoading,
      isNextError: isNextError ?? this.isNextError,
      isNextEmpty: isNextEmpty ?? this.isNextEmpty,
      nextApproval: nextApproval ?? this.nextApproval,
      requests: requests ?? this.requests,
      request: request ?? this.request,
      approvals: approvals ?? this.approvals,
      approval: approval ?? this.approval,
      leaveBalance: leaveBalance ?? this.leaveBalance,
      allTimeoffRequests: allTimeoffRequests ?? this.allTimeoffRequests,
      allTimeoffPagination: allTimeoffPagination ?? this.allTimeoffPagination,
      branches: branches ?? this.branches,
      organizations: organizations ?? this.organizations,
      jobLevels: jobLevels ?? this.jobLevels,
      jobPositions: jobPositions ?? this.jobPositions,
      timeoffs: timeoffs ?? this.timeoffs,
    );
  }

  @override
  List<Object?> get props => [
        errorMessage,
        requestRefreshError,
        approvalRefreshError,
        isLoading,
        isRequestLoading,
        isApprovalLoading,
        isRequestRefreshing,
        isApprovalRefreshing,
        isError,
        isSuccess,
        loadMore,
        isFormLoading,
        isFormError,
        isFormSuccess,
        requests,
        request,
        approvals,
        approval,
        leaveBalance,
        isBalanceLoading,
        isBalanceError,
        isBalanceSuccess,
        isBalanceEmpty,
        isFilterLoading,
        isFilterError,
        isNextLoading,
        isNextError,
        isNextEmpty,
        nextApproval,
        allTimeoffPagination,
        branches,
        organizations,
        jobLevels,
        jobPositions,
        timeoffs,
      ];
}
