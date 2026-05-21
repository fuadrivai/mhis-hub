part of 'request_approval_bloc.dart';

final class RequestApprovalState extends Equatable {
  final bool isLoading, isError, isSuccess, loadMore;
  final bool isFormLoading, isFormError, isFormSuccess;
  final String? errorMessage;
  final List<ApprovalRequest> requests;
  final ApprovalRequest? request;
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
    this.request,
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
    ApprovalRequest? request,
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
      ];
}
