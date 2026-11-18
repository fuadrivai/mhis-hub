import 'package:fl_mhis_hr/library/constant.dart';
import 'package:material_ui/material_ui.dart';

class CustomHeader extends StatelessWidget {
  final String text;
  const CustomHeader({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16, left: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            text,
            style: KTextStyle.headerTextStyle,
          )
        ],
      ),
    );
  }
}
