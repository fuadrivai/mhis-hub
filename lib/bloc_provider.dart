import 'package:fl_mhis_hr/pages/academy/bloc/academy_bloc.dart';
import 'package:fl_mhis_hr/pages/attendance/bloc/attendance_bloc.dart';
import 'package:fl_mhis_hr/pages/clockin_prayer/bloc/clockin_prayer_bloc.dart';
import 'package:fl_mhis_hr/pages/employee/bloc/employee_bloc.dart';
import 'package:fl_mhis_hr/pages/general_announcement/bloc/general_announcement_bloc.dart';
import 'package:fl_mhis_hr/pages/home/bloc/home_bloc.dart';
import 'package:fl_mhis_hr/pages/login/bloc/login_bloc.dart';
import 'package:fl_mhis_hr/pages/payslip/bloc/payslip_bloc.dart';
import 'package:fl_mhis_hr/pages/profile/bloc/profile_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProviderBloc {
  ProviderBloc._();
  List<BlocProvider>? provider;

  static List<BlocProvider> get() {
    return [
      BlocProvider<HomeBloc>(create: (__) => HomeBloc()),
      BlocProvider<ProfileBloc>(create: (__) => ProfileBloc()),
      BlocProvider<LoginBloc>(create: (__) => LoginBloc()),
      BlocProvider<AcademyBloc>(create: (__) => AcademyBloc()),
      BlocProvider<AttendanceBloc>(create: (__) => AttendanceBloc()),
      BlocProvider<EmployeeBloc>(create: (__) => EmployeeBloc()),
      BlocProvider<PayslipBloc>(create: (__) => PayslipBloc()),
      BlocProvider<ClockinPrayerBloc>(create: (__) => ClockinPrayerBloc()),
      BlocProvider<GeneralAnnouncementBloc>(
          create: (__) => GeneralAnnouncementBloc()),
    ];
  }
}
