part of 'payslip_bloc.dart';

final class PayslipState extends Equatable {
  final bool isLoading, isError, isSuccess, loadMore;
  final String? errorMessage;
  final Pagination? serverside;
  final List<Payslip>? payslips;
  const PayslipState({
    this.isLoading = false,
    this.isError = false,
    this.isSuccess = false,
    this.errorMessage,
    this.serverside,
    this.payslips,
    this.loadMore = false,
  });
  PayslipState copyWith({
    bool? isLoading,
    bool? isError,
    bool? isSuccess,
    bool? loadMore,
    String? errorMessage,
    Pagination? serverside,
    List<Payslip>? payslips,
  }) {
    return PayslipState(
      errorMessage: errorMessage ?? this.errorMessage,
      isError: isError ?? this.isError,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      serverside: serverside ?? this.serverside,
      loadMore: loadMore ?? this.loadMore,
      payslips: payslips ?? this.payslips,
    );
  }

  @override
  List<Object?> get props => [
        errorMessage,
        isLoading,
        isError,
        isSuccess,
        serverside,
        loadMore,
        payslips,
      ];
}
