import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PersonalInfo extends StatefulWidget {
  final List<dynamic>? listForm;
  final String title;
  const PersonalInfo({super.key, this.listForm, required this.title});

  @override
  State<PersonalInfo> createState() => _PersonalInfoState();
}

class _PersonalInfoState extends State<PersonalInfo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        backgroundColor: AppColors.whiteshade,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        title: widget.title,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
          color: AppColors.white,
          child: Column(
            children: (widget.listForm ?? []).map((val) {
              return textFormFiled(
                title: val['title'],
                value: val['value'] == "" ? "--" : val['value'],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget textFormFiled({required String title, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 3),
      child: TextFormField(
        readOnly: true,
        enabled: false,
        style: const TextStyle(color: AppColors.dark),
        controller: TextEditingController(text: value),
        decoration: InputDecoration(
          label: Text(title),
        ),
      ),
    );
  }
}
