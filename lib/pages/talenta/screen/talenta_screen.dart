import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/widget/widget.dart';
import 'package:flutter/material.dart';

class TalentaScreen extends StatefulWidget {
  const TalentaScreen({super.key});

  @override
  State<TalentaScreen> createState() => _TalentaScreenState();
}

class _TalentaScreenState extends State<TalentaScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: CustomAppbar(
        backgroundColor: AppColors.whiteshade,
        leading: Container(
          padding: const EdgeInsets.only(left: 10),
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Image.asset(Common.imageLogo),
        ),
        title: "Talenta",
      ),
      body: const SingleChildScrollView(),
    );
  }
}
