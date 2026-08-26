part of 'request_approval_bloc.dart';

final class RequestApprovalState extends Equatable {
  final bool isLoading, isError, isSuccess, loadMore;
  final bool isFormLoading, isFormError, isFormSuccess;
  final bool isBalanceLoading, isBalanceError, isBalanceSuccess, isBalanceEmpty;
  final String? errorMessage;
  final List<ApprovalRequest> requests;
  final List<ApprovalRequest> allTimeoffRequests;
  final List<Approval> approvals;
  final Pagination? allTimeoffPagination;
  final ApprovalRequest? request;
  final Approval? approval;
  final LeaveAllocation? leaveBalance;
  const RequestApprovalState({
    this.isLoading = false,
    this.isFormLoading = false,
    this.isError = false,
    this.isFormError = false,
    this.isSuccess = false,
    this.isFormSuccess = false,
    this.isBalanceLoading = false,
    this.isBalanceError = false,
    this.isBalanceSuccess = false,
    this.isBalanceEmpty = false,
    this.errorMessage,
    this.loadMore = false,
    this.requests = const [],
    this.allTimeoffRequests = const [],
    this.approvals = const [],
    this.allTimeoffPagination,
    this.request,
    this.approval,
    this.leaveBalance,
  });
  RequestApprovalState copyWith({
    bool? isLoading,
    bool? isError,
    bool? isSuccess,
    bool? loadMore,
    String? errorMessage,
    bool? isFormLoading,
    bool? isFormError,
    bool? isFormSuccess,
    bool? isBalanceLoading,
    bool? isBalanceError,
    bool? isBalanceSuccess,
    bool? isBalanceEmpty,
    List<ApprovalRequest>? requests,
    List<Approval>? approvals,
    ApprovalRequest? request,
    Approval? approval,
    LeaveAllocation? leaveBalance,
    List<ApprovalRequest>? allTimeoffRequests,
    Pagination? allTimeoffPagination,
  }) {
    return RequestApprovalState(
      errorMessage: errorMessage ?? this.errorMessage,
      isError: isError ?? this.isError,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      loadMore: loadMore ?? this.loadMore,
      isFormLoading: isFormLoading ?? this.isFormLoading,
      isFormError: isFormError ?? this.isFormError,
      isFormSuccess: isFormSuccess ?? this.isFormSuccess,
      isBalanceLoading: isBalanceLoading ?? this.isBalanceLoading,
      isBalanceError: isBalanceError ?? this.isBalanceError,
      isBalanceSuccess: isBalanceSuccess ?? this.isBalanceSuccess,
      isBalanceEmpty: isBalanceEmpty ?? this.isBalanceEmpty,
      requests: requests ?? this.requests,
      request: request ?? this.request,
      approvals: approvals ?? this.approvals,
      approval: approval ?? this.approval,
      leaveBalance: leaveBalance ?? this.leaveBalance,
      allTimeoffRequests: allTimeoffRequests ?? this.allTimeoffRequests,
      allTimeoffPagination: allTimeoffPagination ?? this.allTimeoffPagination,
    );
  }

  @override
  List<Object?> get props => [
        errorMessage,
        isLoading,
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
        allTimeoffRequests,
        allTimeoffPagination,
      ];
}
