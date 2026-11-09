import 'package:fl_mhis_hr/pages/kpi/screen/my_kpi_widget.dart';
import 'package:fl_mhis_hr/pages/kpi/screen/profile_widget.dart';
import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/widget/themed_page.dart';
import 'package:flutter/material.dart';

class KpiScreen extends StatefulWidget {
  const KpiScreen({super.key});

  @override
  State<KpiScreen> createState() => _KpiScreenState();
}

class _KpiScreenState extends State<KpiScreen> {
  @override
  Widget build(BuildContext context) {
    return ThemedPage(
      title: 'KPI Score',
      subtitle: 'View your performance summary',
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border:
                    Border.all(color: AppColors.danger.withValues(alpha: 0.1)),
              ),
              child: const ProfileWidget(),
            ),
            const SizedBox(height: 12),
            const MyKpiWidget(),
          ],
        ),
      ),
    );
  }
}
