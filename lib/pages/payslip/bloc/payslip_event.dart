part of 'payslip_bloc.dart';

abstract class PayslipEvent extends Equatable {
  const PayslipEvent();
}

class OnInit extends PayslipEvent {
  const OnInit();
  @override
  List<Object?> get props => [];
}