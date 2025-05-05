import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/pages/kpi/bloc/kpi_bloc.dart';
import 'package:fl_mhis_hr/widget/loading_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileWidget extends StatefulWidget {
  const ProfileWidget({super.key});

  @override
  State<ProfileWidget> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  @override
  void initState() {
    context.read<KpiBloc>().add(const OnGetEmployee());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return BlocBuilder<KpiBloc, KpiState>(
      builder: (context, state) {
        if (state.empLoading) {
          return const LoadingShimmer(height: 120);
        }
        if (state.empError) {
          return Center(child: Text(state.empErrorMessage ?? "Error"));
        }
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: size.width * 68 / 100,
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.employee?.person?.fullName ?? "Teacher's Name",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        state.employee?.person?.email ?? "Teacher's email",
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(state.employee?.employment?.jobPosition ?? "--"),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: size.width * 27 / 100,
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: CircleAvatar(
                    backgroundColor: const Color.fromARGB(255, 220, 220, 220),
                    minRadius: 45.0,
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                      backgroundImage: state.employee?.person?.avatar == ""
                          ? AssetImage(Common.imageProfile)
                          : NetworkImage(state.employee?.person?.avatar ?? ""),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
