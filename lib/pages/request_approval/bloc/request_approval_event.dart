part of 'request_approval_bloc.dart';

abstract class RequestApprovalEvent extends Equatable {
  const RequestApprovalEvent();
}

class OnInit extends RequestApprovalEvent {
  final Map<String, dynamic> map;
  const OnInit(this.map);
  @override
  List<Object?> get props => [map];
}

class OnInitDetail extends RequestApprovalEvent {
  final int id;
  const OnInitDetail(this.id);
  @override
  List<Object?> get props => [id];
}
