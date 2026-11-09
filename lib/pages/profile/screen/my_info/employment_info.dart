import 'package:fl_mhis_hr/models/v2/models.dart';
import 'package:fl_mhis_hr/pages/profile/screen/my_info/info_details.dart';
import 'package:flutter/material.dart';

class EmplymentInfo extends StatelessWidget {
  final Employment? employment;
  const EmplymentInfo({super.key, this.employment});

  @override
  Widget build(BuildContext context) {
    return InfoDetails(
      title: 'Employment Info',
      fields: employment?.listForm() ?? [],
    );
  }
}
