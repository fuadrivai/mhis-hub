import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/models/v2/models.dart';
import 'package:fl_mhis_hr/pages/request_approval/bloc/request_approval_bloc.dart';
import 'package:fl_mhis_hr/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    context.read<RequestApprovalBloc>().add(OnInitRequest(map));
    context.read<RequestApprovalBloc>().add(OnGetBalance());
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<RequestApprovalBloc>().add(OnInitRequest(map));
      },
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
              child: BlocBuilder<RequestApprovalBloc, RequestApprovalState>(
                builder: (context, state) {
                  if (state.isBalanceLoading) {
                    return const LoadingShimmer(height: 150);
                  }
                  if (state.isBalanceError) {
                    return const Text(
                      "Failed to load balance",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    );
                  }
                  if (state.isBalanceEmpty == true) {
                    return const BalanceCard();
                  }
                  LeaveAllocation? leaveBalance = state.leaveBalance;
                  return BalanceCardWidget(leaveBalance: leaveBalance);
                },
              ),
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
                                  .add(OnInitRequest(map));
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
                  FilterIconWidget(onTap: () {}),
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
                  return const Column(
                    children: [
                      LoadingShimmer(height: 105),
                      LoadingShimmer(height: 105),
                      LoadingShimmer(height: 105),
                    ],
                  );
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
                      statusColor: Common.statusColor(request.status),
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

class BalanceCardWidget extends StatelessWidget {
  final LeaveAllocation? leaveBalance;

  const BalanceCardWidget({super.key, this.leaveBalance});

  @override
  Widget build(BuildContext context) {
    final int total = leaveBalance?.total ?? 0;
    final int used = leaveBalance?.used ?? 0;
    final int remaining = leaveBalance?.remaining ?? 0;
    final double progress = total > 0 ? (used / total).clamp(0.0, 1.0) : 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 10, bottom: 1, left: 1, right: 1),
      decoration: BoxDecoration(
        color: AppColors.danger,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'My balance',
            style: TextStyle(
              color: AppColors.whiteshade,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$remaining',
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 6, bottom: 5),
                      child: Text(
                        'days remaining',
                        style: TextStyle(color: Colors.black54, fontSize: 13),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 7,
                    backgroundColor: AppColors.danger.withValues(alpha: 0.15),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.danger,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                        child: _BalanceMetric(label: 'Total', value: total)),
                    Expanded(child: _BalanceMetric(label: 'Used', value: used)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BalanceMetric extends StatelessWidget {
  final String label;
  final int value;

  const _BalanceMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$value days',
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
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
