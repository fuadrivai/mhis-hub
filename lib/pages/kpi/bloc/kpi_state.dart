part of 'kpi_bloc.dart';

final class KpiState extends Equatable {
  final bool kpiLoading, kpiError, kpiSuccess;
  final bool empLoading, empError, empSuccess;
  final String? kpiErrorMessage;
  final String? empErrorMessage;
  final Kpi? kpi;
  final Employee? employee;
  const KpiState({
    this.kpiLoading = false,
    this.kpiError = false,
    this.kpiSuccess = false,
    this.kpiErrorMessage,
    this.empLoading = false,
    this.empError = false,
    this.empSuccess = false,
    this.empErrorMessage,
    this.kpi,
    this.employee,
  });
  KpiState copyWith({
    bool? kpiLoading,
    bool? kpiError,
    bool? kpiSuccess,
    String? kpiErrorMessage,
    bool? empLoading,
    bool? empError,
    bool? empSuccess,
    String? empErrorMessage,
    Kpi? kpi,
    Employee? employee,
  }) {
    return KpiState(
      kpiErrorMessage: kpiErrorMessage ?? this.kpiErrorMessage,
      kpiError: kpiError ?? this.kpiError,
      kpiLoading: kpiLoading ?? this.kpiLoading,
      kpiSuccess: kpiSuccess ?? this.kpiSuccess,
      empErrorMessage: empErrorMessage ?? this.empErrorMessage,
      empError: empError ?? this.empError,
      empLoading: empLoading ?? this.empLoading,
      empSuccess: empSuccess ?? this.empSuccess,
      kpi: kpi ?? this.kpi,
      employee: employee ?? this.employee,
    );
  }

  @override
  List<Object?> get props => [
        kpiErrorMessage,
        kpiLoading,
        kpiError,
        kpiSuccess,
        empErrorMessage,
        empLoading,
        empError,
        empSuccess,
        kpi,
        employee,
      ];
}
