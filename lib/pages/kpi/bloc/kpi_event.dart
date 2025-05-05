part of 'kpi_bloc.dart';

abstract class KpiEvent extends Equatable {
  const KpiEvent();
}

class OnGetKpi extends KpiEvent {
  const OnGetKpi();
  @override
  List<Object?> get props => [];
}

class OnGetEmployee extends KpiEvent {
  const OnGetEmployee();
  @override
  List<Object?> get props => [];
}
