part of 'request_approval_bloc.dart';

abstract class RequestApprovalEvent extends Equatable {
  const RequestApprovalEvent();
}

class OnInitRequest extends RequestApprovalEvent {
  final Map<String, dynamic> map;
  const OnInitRequest(this.map);
  @override
  List<Object?> get props => [map];
}

class OnInitApproval extends RequestApprovalEvent {
  final Map<String, dynamic> map;
  const OnInitApproval(this.map);
  @override
  List<Object?> get props => [map];
}

class OnInitAllTimeoff extends RequestApprovalEvent {
  final Map<String, dynamic> map;
  const OnInitAllTimeoff(this.map);
  @override
  List<Object?> get props => [map];
}

class OnInitAllTimeoffFilters extends RequestApprovalEvent {
  const OnInitAllTimeoffFilters();

  @override
  List<Object?> get props => [];
}

class OnInitDetail extends RequestApprovalEvent {
  final int id;
  const OnInitDetail(this.id);
  @override
  List<Object?> get props => [id];
}

class PostAction extends RequestApprovalEvent {
  final Map<String, dynamic> map;
  const PostAction(this.map);
  @override
  List<Object?> get props => [map];
}

class PostCancelRequest extends RequestApprovalEvent {
  final int id;
  final Map<String, dynamic> map;
  const PostCancelRequest(this.id, this.map);
  @override
  List<Object?> get props => [id, map];
}

class OnGetBalance extends RequestApprovalEvent {
  const OnGetBalance();
  @override
  List<Object?> get props => [];
}
