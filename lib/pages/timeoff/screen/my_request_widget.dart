import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/pages/timeoff/repository/timeoff_api.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:jiffy/jiffy.dart';

class MyRequestWidget extends StatefulWidget {
  const MyRequestWidget({super.key});

  @override
  State<MyRequestWidget> createState() => _MyRequestWidgetState();
}

class _MyRequestWidgetState extends State<MyRequestWidget> {
  DateTime selectedDate = DateTime.now();
  String? strMonthYear;
  Map<String, dynamic> map = {};

  @override
  initState() {
    super.initState();
    strMonthYear =
        Jiffy.parseFromDateTime(selectedDate).format(pattern: "MMMM yyyy");
    String year = Jiffy.parseFromDateTime(selectedDate).format(pattern: "yyyy");
    String month = Jiffy.parseFromDateTime(selectedDate).format(pattern: "M");
    map = {"month": month, "year": year};
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BalanceCard(),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: TextEditingController(text: strMonthYear),
                  readOnly: true,
                  // enabled: false,
                  onTap: () {
                    showMonthPicker(
                      context: context,
                      initialDate: selectedDate,
                      monthPickerDialogSettings: Common.monthPickerDialog(),
                    ).then((date) async {
                      if (date != null) {
                        setState(() {
                          selectedDate = date;
                          strMonthYear = Jiffy.parseFromDateTime(selectedDate)
                              .format(pattern: "MMMM yyyy");
                          String year = Jiffy.parseFromDateTime(selectedDate)
                              .format(pattern: "yyyy");
                          String month = Jiffy.parseFromDateTime(selectedDate)
                              .format(pattern: "M");
                          map = {"month": month, "year": year};
                        });
                        var data = await TimeoffApi.getUserTimeoff();
                        print(data);
                      }
                    });
                  },
                  decoration: TextFormDecoration.box(
                    prefixIcon: const Icon(
                      Icons.calendar_month,
                    ),
                    suffixIcon: const Icon(
                      Icons.arrow_drop_down,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {},
                    child: const Padding(
                      padding: EdgeInsets.all(12),
                      child: FaIcon(
                        FontAwesomeIcons.sliders,
                        size: 20,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: 10,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                return _buildLeaveRequestItem(
                  type: "Annual Leave",
                  date: "May 10, 2026 - May 12, 2026",
                  reason: "Family vacation",
                  status: "Approved",
                  statusColor: Colors.green,
                );
              }),
        ],
      ),
    );
  }

  Widget _buildLeaveRequestItem({
    required String type,
    required String date,
    required String reason,
    required String status,
    required Color statusColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            type,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            date,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            reason,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            status,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }
}

class BalanceCard extends StatelessWidget {
  const BalanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.red.shade400,
        borderRadius: BorderRadius.circular(13),
      ),
      padding: const EdgeInsets.only(top: 10, bottom: 1, left: 1, right: 1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "My balance",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.whiteshade,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(
                  Icons.folder_outlined,
                  size: 48,
                  color: Colors.blue.shade300,
                ),
                const SizedBox(height: 16),
                const Text(
                  "No policy assigned",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Once your policy assigned, the policy will\nappear here.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
