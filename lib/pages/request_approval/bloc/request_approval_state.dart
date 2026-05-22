part of 'request_approval_bloc.dart';

final class RequestApprovalState extends Equatable {
  final bool isLoading, isError, isSuccess, loadMore;
  final bool isFormLoading, isFormError, isFormSuccess;
  final String? errorMessage;
  final List<ApprovalRequest> requests;
  final List<Approval> approvals;
  final ApprovalRequest? request;
  final Approval? approval;
  const RequestApprovalState({
    this.isLoading = false,
    this.isFormLoading = false,
    this.isError = false,
    this.isFormError = false,
    this.isSuccess = false,
    this.isFormSuccess = false,
    this.errorMessage,
    this.loadMore = false,
    this.requests = const [],
    this.approvals = const [],
    this.request,
    this.approval,
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
    List<ApprovalRequest>? requests,
    List<Approval>? approvals,
    ApprovalRequest? request,
    Approval? approval,
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
      requests: requests ?? this.requests,
      request: request ?? this.request,
      approvals: approvals ?? this.approvals,
      approval: approval ?? this.approval,
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
      ];
}
