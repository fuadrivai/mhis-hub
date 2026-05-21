import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/models/v2/models.dart';
import 'package:fl_mhis_hr/pages/request_approval/bloc/request_approval_bloc.dart';
import 'package:fl_mhis_hr/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
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
    context.read<RequestApprovalBloc>().add(OnInit(map));
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<RequestApprovalBloc>().add(OnInit(map));
      },
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
              child: BalanceCard(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
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
                        ).then((date) {
                          if (date != null) {
                            setState(() {
                              selectedDate = date;
                              strMonthYear =
                                  Jiffy.parseFromDateTime(selectedDate)
                                      .format(pattern: "MMMM yyyy");
                              String year =
                                  Jiffy.parseFromDateTime(selectedDate)
                                      .format(pattern: "yyyy");
                              String month =
                                  Jiffy.parseFromDateTime(selectedDate)
                                      .format(pattern: "M");
                              map = {"month": month, "year": year};
                              context
                                  .read<RequestApprovalBloc>()
                                  .add(OnInit(map));
                            });
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
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(14),
              child: BlocBuilder<RequestApprovalBloc, RequestApprovalState>(
                  builder: (context, state) {
                if (state.isLoading) {
                  return LoadingWidget();
                }
                if (state.requests.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 28,
                      horizontal: 12,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.inbox_rounded,
                          size: 44,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "No requests found",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "There is no request data for the selected month.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: state.requests.length,
                  separatorBuilder: (context, i) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    ApprovalRequest request = state.requests[i];
                    return _buildLeaveRequestItem(
                      type: request.type?.name ?? "--",
                      date: ApprovalRequestData.formatRequestDate(request),
                      reason: request.note ?? "--",
                      status: request.status ?? "--",
                      statusColor: request.status == "Approved"
                          ? Colors.green
                          : request.status == "Rejected"
                              ? Colors.red
                              : Colors.orange,
                      onTap: () {
                        context.pushNamed(
                          "timeoff-detail",
                          extra: {
                            "requestId": request.id,
                          },
                        );
                      },
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaveRequestItem(
      {required String type,
      required String date,
      required String reason,
      required String status,
      required Color statusColor,
      required GestureTapCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
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
        color: AppColors.danger,
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
