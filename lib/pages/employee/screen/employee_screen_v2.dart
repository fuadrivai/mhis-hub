import 'package:fl_mhis_hr/widget/widget.dart';
import 'package:flutter/material.dart';

class EmployeeScreenV2 extends StatefulWidget {
  const EmployeeScreenV2({super.key});

  @override
  State<EmployeeScreenV2> createState() => _EmployeeScreenV2State();
}

class _EmployeeScreenV2State extends State<EmployeeScreenV2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const EmployeeWidget(),
    );
  }
}
