import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/pages/kpi/screen/my_kpi_widget.dart';
import 'package:fl_mhis_hr/pages/kpi/screen/profile_widget.dart';
import 'package:fl_mhis_hr/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class KpiScreen extends StatefulWidget {
  const KpiScreen({super.key});

  @override
  State<KpiScreen> createState() => _KpiScreenState();
}

class _KpiScreenState extends State<KpiScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        backgroundColor: AppColors.whiteshade,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        title: "KPI Score",
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ProfileWidget(),
            Divider(
              color: Colors.grey,
              height: 20,
              thickness: 1,
              indent: 8,
              endIndent: 8,
            ),
            MyKpiWidget(),
          ],
        ),
      ),
    );
  }
}
