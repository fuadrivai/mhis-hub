import 'dart:io';

import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/models/v2/models.dart';
import 'package:fl_mhis_hr/pages/timeoff/repository/timeoff_api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'timeoff_event.dart';
part 'timeoff_state.dart';

class TimeoffBloc extends Bloc<TimeoffEvent, TimeoffState> {
  TimeoffBloc() : super(const TimeoffState()) {
    on<OnInit>(_onInit);
    on<OnInitForm>(_onInitForm);
    on<OnSubmitTimeoffForm>(_onSubmitTimeoffForm);
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

  void _onInit(OnInit event, Emitter<TimeoffState> emit) async {
    try {
      emit(state.copyWith(
        isLoading: true,
        isError: false,
        isSuccess: false,
      ));

      List<Timeoff> timeoffs = await TimeoffApi.get();

      emit(state.copyWith(
        isLoading: false,
        isError: false,
        timeoffs: timeoffs,
      ));
    } catch (e) {
      final errorMessage = _extractErrorMessage(e);
      emit(state.copyWith(
        isLoading: false,
        timeoffs: state.timeoffs,
        isError: true,
        loadMore: false,
        errorMessage: errorMessage,
      ));
    }
  }

  void _onInitForm(OnInitForm event, Emitter<TimeoffState> emit) async {
    try {
      emit(state.copyWith(
        isFormLoading: true,
        isFormError: false,
        isFormSuccess: false,
      ));

      String? userId = await Session.get('userId');

      Employee employee = await TimeoffApi.getEmployeeById(int.parse(userId!));

      emit(state.copyWith(
        isFormLoading: false,
        isFormError: false,
        isFormSuccess: true,
        employee: employee,
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

  void _onSubmitTimeoffForm(
      OnSubmitTimeoffForm event, Emitter<TimeoffState> emit) async {
    try {
      emit(state.copyWith(
        isFormLoading: true,
        isFormError: false,
        isFormSuccess: false,
      ));

      // Build attachments list if file path provided
      List<FileAttachment>? attachments;
      if (event.attachmentPath != null && event.attachmentPath!.isNotEmpty) {
        final file = File(event.attachmentPath!);
        final fileName = file.path.split('/').last;
        attachments = [
          FileAttachment(
            fileName: fileName,
            filePath: event.attachmentPath!,
            fileSize: file.lengthSync(),
            file: file,
          ),
        ];
      }

      // Create approval request with multipart data
      final approvalRequest = Request(
        requesterEmployeeId: state.employee?.id ?? 0,
        timeoffId: event.timeoffId,
        note: event.note,
        dynamicFields: event.formData.isNotEmpty ? event.formData : null,
        attachments: attachments,
      );

      await TimeoffApi.postTimeoff(approvalRequest);

      emit(state.copyWith(
          isFormLoading: false,
          isFormError: false,
          isFormSuccess: true,
          errorMessage: null,
          isSuccess: true));
    } catch (e) {
      final errorMessage = _extractErrorMessage(e);
      emit(state.copyWith(
        isFormLoading: false,
        isFormError: true,
        isFormSuccess: false,
        errorMessage: errorMessage,
        isSuccess: false,
      ));
    }
  }
}
