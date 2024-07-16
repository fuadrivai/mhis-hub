import 'package:fl_mhis_hr/pages/academy/bloc/academy_bloc.dart';
import 'package:fl_mhis_hr/pages/home/bloc/home_bloc.dart';
import 'package:fl_mhis_hr/pages/login/bloc/login_bloc.dart';
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
    ];
  }
}
