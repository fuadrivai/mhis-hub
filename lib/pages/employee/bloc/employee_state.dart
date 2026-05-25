part of 'employee_bloc.dart';

final class EmployeeState extends Equatable {
  final bool isLoading, isError, isSuccess, loadMore;
  final String? errorMessage;
  final ServerSideEmployee? serverside;
  final List<EmployeeV3>? employees;

  final Pagination? pagination;
  final List<Employee>? employees2;

  const EmployeeState({
    this.isLoading = false,
    this.isError = false,
    this.isSuccess = false,
    this.errorMessage,
    this.serverside,
    this.employees,
    this.loadMore = false,
    this.pagination,
    this.employees2,
  });
  EmployeeState copyWith({
    bool? isLoading,
    bool? isError,
    bool? isSuccess,
    bool? loadMore,
    String? errorMessage,
    ServerSideEmployee? serverside,
    List<EmployeeV3>? employees,
    Pagination? pagination,
    List<Employee>? employees2,
  }) {
    return EmployeeState(
      errorMessage: errorMessage ?? this.errorMessage,
      isError: isError ?? this.isError,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      employees: employees ?? this.employees,
      serverside: serverside ?? this.serverside,
      loadMore: loadMore ?? this.loadMore,
      pagination: pagination ?? this.pagination,
      employees2: employees2 ?? this.employees2,
    );
  }

  @override
  List<Object?> get props => [
        errorMessage,
        isLoading,
        isError,
        isSuccess,
        employees,
        serverside,
        loadMore,
        pagination,
        employees2,
      ];
}
