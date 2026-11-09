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
              Expanded(
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.employee?.personal?.fullname ?? "Teacher's Name",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        state.employee?.personal?.email ?? "Teacher's email",
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(state.employee?.employment?.jobPosition?.name ??
                          "--"),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 80,
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: CircleAvatar(
                    backgroundColor: const Color.fromARGB(255, 220, 220, 220),
                    radius: 40,
                    child: CircleAvatar(
                      radius: 36,
                      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                      backgroundImage:
                          (state.employee?.personal?.avatar ?? '').isEmpty
                              ? AssetImage(Common.imageProfile)
                              : NetworkImage(
                                  state.employee?.personal?.avatarLink ?? ""),
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
