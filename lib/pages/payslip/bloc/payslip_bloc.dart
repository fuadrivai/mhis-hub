import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/models/model.dart';
import 'package:fl_mhis_hr/pages/payslip/repository/payslip_api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'payslip_event.dart';
part 'payslip_state.dart';

class PayslipBloc extends Bloc<PayslipEvent, PayslipState> {
  PayslipBloc() : super(const PayslipState()) {
    on<OnInit>(_onInit);
  }

  void _onInit(OnInit event, Emitter<PayslipState> emit) async {
    try {
      emit(state.copyWith(
        isLoading: true,
        isError: false,
        isSuccess: false,
      ));
      String? email = await Session.get("email");
      Pagination paginate =
          await PayslipApi.getPaySlipData(params: {"email": email});
      List<Payslip> payslips = [];
      for (var pay in (paginate.data ?? [])) {
        payslips.add(Payslip.fromJson(pay));
      }
      emit(state.copyWith(
        isLoading: false,
        isError: false,
        payslips: payslips,
        serverside: paginate,
      ));
    } catch (e) {
      String errorMessage = e.toString();
      if (e.runtimeType == DioException) {
        DioException err = e as DioException;
        errorMessage = err.response?.data?["message"] ?? err.message;
      }
      emit(state.copyWith(
        isLoading: false,
        serverside: state.serverside,
        payslips: state.payslips,
        isError: true,
        loadMore: false,
        errorMessage: errorMessage,
      ));
    }
  }
}
