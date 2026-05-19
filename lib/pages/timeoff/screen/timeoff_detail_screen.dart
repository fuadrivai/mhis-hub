import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class TimeoffDetailScreen extends StatefulWidget {
  const TimeoffDetailScreen({super.key});

  @override
  State<TimeoffDetailScreen> createState() => _TimeoffDetailScreenState();
}

class _TimeoffDetailScreenState extends State<TimeoffDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        backgroundColor: AppColors.whiteshade,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        actions: Padding(
          padding: const EdgeInsets.all(8.0),
          child: FaIcon(
            FontAwesomeIcons.clockRotateLeft,
            color: AppColors.secondary,
          ),
        ),
        title: "Timeoff Details",
      ),
    );
  }
}
