import 'package:fl_mhis_hr/pages/profile/screen/my_info/info_details.dart';
import 'package:material_ui/material_ui.dart';

class PersonalInfo extends StatelessWidget {
  final List<dynamic>? listForm;
  final String title;
  const PersonalInfo({super.key, this.listForm, required this.title});

  @override
  Widget build(BuildContext context) {
    return InfoDetails(title: title, fields: listForm ?? []);
  }
}
