import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:fl_mhis_hr/models/v2/models.dart';
import 'package:fl_mhis_hr/pages/request_approval/repository/request_approval_api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'request_approval_event.dart';
part 'request_approval_state.dart';

class RequestApprovalBloc
    extends Bloc<RequestApprovalEvent, RequestApprovalState> {
  RequestApprovalBloc() : super(const RequestApprovalState()) {
    on<OnInitRequest>(_onInitRequest);
    on<OnInitApproval>(_onInitApproval);
    on<OnInitDetail>(_onInitDetail);
    on<PostAction>(_onPostAction);
    on<PostCancelRequest>(_onPostCancelRequest);
  }

  String _extractErrorMessage(Object e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        return (data['message'] ?? e.message ?? 'Unknown error').toString();
      }
      if (data is String && data.isNotEmpty) {
        return data;
      }
      return e.message ?? 'Unknown error';
    }
    return e.toString();
  }

  void _onInitRequest(
      OnInitRequest event, Emitter<RequestApprovalState> emit) async {
    try {
      emit(state.copyWith(
        isLoading: true,
        isError: false,
        isSuccess: false,
      ));

      Map<String, dynamic> map = event.map;

      List<ApprovalRequest> requests =
          await RequestApprovalApi.getUserTimeoff(map);
      emit(state.copyWith(
        isLoading: false,
        isError: false,
        isSuccess: true,
        requests: requests,
      ));
    } catch (e) {
      final errorMessage = _extractErrorMessage(e);
      emit(state.copyWith(
        isLoading: false,
        isError: true,
        isSuccess: false,
        loadMore: false,
        errorMessage: errorMessage,
      ));
    }
  }

  void _onInitApproval(
      OnInitApproval event, Emitter<RequestApprovalState> emit) async {
    try {
      emit(state.copyWith(
        isLoading: true,
        isError: false,
        isSuccess: false,
      ));

      Map<String, dynamic> map = event.map;

      List<Approval> approvals = await RequestApprovalApi.getUserApproval(map);
      emit(state.copyWith(
        isLoading: false,
        isError: false,
        isSuccess: true,
        approvals: approvals,
      ));
    } catch (e) {
      final errorMessage = _extractErrorMessage(e);
      emit(state.copyWith(
        isLoading: false,
        isError: true,
        isSuccess: false,
        loadMore: false,
        errorMessage: errorMessage,
      ));
    }
  }

  void _onInitDetail(
      OnInitDetail event, Emitter<RequestApprovalState> emit) async {
    try {
      emit(state.copyWith(
        isFormLoading: true,
        isFormError: false,
        isFormSuccess: false,
      ));

      ApprovalRequest? request =
          await RequestApprovalApi.getTimeoffDetail(event.id);
      emit(state.copyWith(
        isFormLoading: false,
        isFormError: false,
        isFormSuccess: true,
        request: request,
      ));
    } catch (e) {
      final errorMessage = _extractErrorMessage(e);
      emit(state.copyWith(
        isFormLoading: false,
        isFormError: true,
        isFormSuccess: false,
        errorMessage: errorMessage,
      ));
    }
  }

  void _onPostAction(
      PostAction event, Emitter<RequestApprovalState> emit) async {
    try {
      emit(state.copyWith(
        isFormLoading: true,
        isFormError: false,
        isFormSuccess: false,
      ));

      Map<String, dynamic> map = event.map;

      await RequestApprovalApi.postAction(map);
      emit(state.copyWith(
        isFormLoading: false,
        isFormError: false,
        isFormSuccess: true,
      ));
    } catch (e) {
      final errorMessage = _extractErrorMessage(e);
      emit(state.copyWith(
        isFormLoading: false,
        isFormError: true,
        isFormSuccess: false,
        errorMessage: errorMessage,
      ));
    }
  }

  void _onPostCancelRequest(
      PostCancelRequest event, Emitter<RequestApprovalState> emit) async {
    try {
      emit(state.copyWith(
        isFormLoading: true,
        isFormError: false,
        isFormSuccess: false,
      ));

      await RequestApprovalApi.postCancelRequest(event.id, event.map);
      emit(state.copyWith(
        isFormLoading: false,
        isFormError: false,
        isFormSuccess: true,
      ));
    } catch (e) {
      final errorMessage = _extractErrorMessage(e);
      emit(state.copyWith(
        isFormLoading: false,
        isFormError: true,
        isFormSuccess: false,
        errorMessage: errorMessage,
      ));
    }
  }
}
