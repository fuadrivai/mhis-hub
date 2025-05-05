import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/pages/kpi/bloc/kpi_bloc.dart';
import 'package:fl_mhis_hr/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MyKpiWidget extends StatefulWidget {
  const MyKpiWidget({super.key});

  @override
  State<MyKpiWidget> createState() => _MyKpiWidgetState();
}

class _MyKpiWidgetState extends State<MyKpiWidget> {
  @override
  void initState() {
    context.read<KpiBloc>().add(const OnGetKpi());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<KpiBloc, KpiState>(
      builder: (context, state) {
        if (state.kpiLoading) {
          return LoadingWidget();
        }
        if (state.kpiError) {
          return EmptyWidget(
            onTap: () {
              context.read<KpiBloc>().add(const OnGetKpi());
            },
          );
        }
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Container(
            color: AppColors.whiteshade,
            child: Column(
              children: [
                _kpiName(
                  name: "SKL",
                  value: "${state.kpi?.sKL ?? "-"}",
                ),
                _kpiName(
                  name: "IMTAQ",
                  value: "${state.kpi?.iMTAQ ?? "-"}",
                ),
                _kpiName(
                  name: "ISI",
                  value: "${state.kpi?.iSI ?? "-"}",
                ),
                _kpiName(
                  name: "PROCESS",
                  value: "${state.kpi?.pROCESS ?? "-"}",
                ),
                _kpiName(
                  name: "SPTK",
                  value: "${state.kpi?.sPTK ?? "-"}",
                ),
                _kpiName(
                  name: "PENILAIAN",
                  value: "${state.kpi?.pENILAIAN ?? "-"}",
                ),
                _kpiName(
                  name: "TAL",
                  value: "${state.kpi?.tAL ?? "-"}",
                ),
                _kpiName(
                  name: "PERFORMANCE",
                  value: "${state.kpi?.teachersPerformance ?? "-"}",
                ),
                Padding(
                  padding: EdgeInsets.all(15),
                  child: Column(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(50)),
                          color: AppColors.danger,
                        ),
                        child: Center(
                          child: Text(
                            "${state.kpi?.kPIScoreAutomate ?? "-"}",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 30,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        "KPI SCORE",
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 25,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _kpiName({required String name, required String value}) {
    return Column(
      children: [
        ListTile(
          dense: false,
          visualDensity: VisualDensity(vertical: -1),
          title: Text(
            name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          leading: Icon(
            FontAwesomeIcons.circleDot,
            color: AppColors.primary,
            size: 25,
          ),
          trailing: Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              color: AppColors.danger,
            ),
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: AppColors.white,
              ),
            ),
          ),
        ),
        Divider(height: 0.8),
      ],
    );
  }
}
