part of 'employee_bloc.dart';

final class EmployeeState extends Equatable {
  final bool isLoading, isError, isSuccess, loadMore;
  final String? errorMessage;
  final ServerSideEmployee? serverside;

  final Pagination? pagination;
  final List<Employee>? employees2;
  final List<Branch> branches;
  final List<Organization> organizations;
  final List<JobLevel> jobLevels;
  final List<JobPosition> jobPositions;

  const EmployeeState({
    this.isLoading = false,
    this.isError = false,
    this.isSuccess = false,
    this.errorMessage,
    this.serverside,
    this.loadMore = false,
    this.pagination,
    this.employees2,
    this.branches = const [],
    this.organizations = const [],
    this.jobLevels = const [],
    this.jobPositions = const [],
  });
  EmployeeState copyWith({
    bool? isLoading,
    bool? isError,
    bool? isSuccess,
    bool? loadMore,
    String? errorMessage,
    ServerSideEmployee? serverside,
    Pagination? pagination,
    List<Employee>? employees2,
    List<Branch>? branches,
    List<Organization>? organizations,
    List<JobLevel>? jobLevels,
    List<JobPosition>? jobPositions,
  }) {
    return EmployeeState(
      errorMessage: errorMessage ?? this.errorMessage,
      isError: isError ?? this.isError,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      serverside: serverside ?? this.serverside,
      loadMore: loadMore ?? this.loadMore,
      pagination: pagination ?? this.pagination,
      employees2: employees2 ?? this.employees2,
      branches: branches ?? this.branches,
      organizations: organizations ?? this.organizations,
      jobLevels: jobLevels ?? this.jobLevels,
      jobPositions: jobPositions ?? this.jobPositions,
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
        pagination,
        employees2,
        branches,
        organizations,
        jobLevels,
        jobPositions,
      ];
}
