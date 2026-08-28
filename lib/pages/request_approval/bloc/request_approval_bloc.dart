import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/models/model.dart';
import 'package:fl_mhis_hr/models/v2/models.dart';
import 'package:fl_mhis_hr/pages/general_announcement/data/general_announcement_api.dart';
import 'package:fl_mhis_hr/pages/request_approval/repository/request_approval_api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'request_approval_event.dart';
part 'request_approval_state.dart';

class RequestApprovalBloc
    extends Bloc<RequestApprovalEvent, RequestApprovalState> {
  RequestApprovalBloc() : super(const RequestApprovalState()) {
    on<OnGetBalance>(_onGetBalance);
    on<OnInitRequest>(_onInitRequest);
    on<OnInitApproval>(_onInitApproval);
    on<OnInitAllTimeoff>(_onInitAllTimeoff);
    on<OnInitAllTimeoffFilters>(_onInitAllTimeoffFilters);
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

  void _onInitAllTimeoff(
      OnInitAllTimeoff event, Emitter<RequestApprovalState> emit) async {
    emit(state.copyWith(
      isLoading: true,
      isError: false,
      isSuccess: false,
      allTimeoffRequests: const [],
    ));

    try {
      final Pagination pagination =
          await RequestApprovalApi.getAllTimeoff(event.map);
      final requests = (pagination.data ?? [])
          .map((item) => ApprovalRequest.fromJson(item as Map<String, dynamic>))
          .toList();

      emit(state.copyWith(
        isLoading: false,
        isError: false,
        isSuccess: true,
        allTimeoffRequests: requests,
        allTimeoffPagination: pagination,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        isError: true,
        isSuccess: false,
        errorMessage: _extractErrorMessage(e),
      ));
    }
  }

  Future<void> _onInitAllTimeoffFilters(
      OnInitAllTimeoffFilters event, Emitter<RequestApprovalState> emit) async {
    if (state.isFilterLoading ||
        (state.branches.isNotEmpty &&
            state.organizations.isNotEmpty &&
            state.jobLevels.isNotEmpty &&
            state.jobPositions.isNotEmpty)) {
      return;
    }

    emit(state.copyWith(isFilterLoading: true, isFilterError: false));
    try {
      final catalogs = await Future.wait<dynamic>([
        GeneralAnnouncementApi.getBranch(),
        GeneralAnnouncementApi.getOrganization(),
        GeneralAnnouncementApi.getJobLevel(),
        GeneralAnnouncementApi.getJobPosition(),
        RequestApprovalApi.getTimeoffs(),
      ]);
      emit(state.copyWith(
        isFilterLoading: false,
        isFilterError: false,
        branches: catalogs[0] as List<Branch>,
        organizations: catalogs[1] as List<Organization>,
        jobLevels: catalogs[2] as List<JobLevel>,
        jobPositions: catalogs[3] as List<JobPosition>,
        timeoffs: catalogs[4] as List<Timeoff>,
      ));
    } catch (e) {
      emit(state.copyWith(isFilterLoading: false, isFilterError: true));
    }
  }

  void _onInitDetail(
      OnInitDetail event, Emitter<RequestApprovalState> emit) async {
    try {
      emit(state.copyWith(
        isFormLoading: true,
      ));

      ApprovalRequest? request =
          await RequestApprovalApi.getTimeoffDetail(event.id);
      emit(state.copyWith(
        isFormLoading: false,
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

  void _onGetBalance(
      OnGetBalance event, Emitter<RequestApprovalState> emit) async {
    try {
      emit(state.copyWith(
        isBalanceLoading: true,
        isBalanceError: false,
        isBalanceSuccess: false,
        isBalanceEmpty: true,
      ));

      String? employeeId = await Session.get('employeeId');

      LeaveAllocation? leaveBalance = await RequestApprovalApi.getLeaveBalance(
          int.parse(employeeId ?? '0'));

      bool isBalanceEmpty =
          leaveBalance.total == 0 || leaveBalance.total == null;

      emit(state.copyWith(
        isBalanceLoading: false,
        isBalanceError: false,
        isBalanceSuccess: true,
        isBalanceEmpty: isBalanceEmpty,
        leaveBalance: leaveBalance,
      ));
    } catch (e) {
      final errorMessage = _extractErrorMessage(e);
      emit(state.copyWith(
        isBalanceLoading: false,
        isBalanceError: true,
        isBalanceSuccess: false,
        errorMessage: errorMessage,
      ));
    }
  }
}
