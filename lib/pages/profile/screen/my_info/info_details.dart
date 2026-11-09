import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/widget/themed_page.dart';
import 'package:flutter/material.dart';

class InfoDetails extends StatelessWidget {
  const InfoDetails({super.key, required this.title, required this.fields});

  final String title;
  final List<dynamic> fields;

  @override
  Widget build(BuildContext context) {
    return ThemedPage(
      title: title,
      subtitle: 'View your information',
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.danger.withValues(alpha: 0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var index = 0; index < fields.length; index++) ...[
                if (index > 0) const Divider(height: 24),
                Text(
                  fields[index]['title'].toString(),
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  fields[index]['value'] == null ||
                          fields[index]['value'].toString().isEmpty
                      ? '--'
                      : fields[index]['value'].toString(),
                  style: const TextStyle(
                    color: AppColors.dark,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
