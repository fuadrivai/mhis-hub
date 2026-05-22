// ignore_for_file: deprecated_member_use

import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/models/v2/models.dart';
import 'package:fl_mhis_hr/pages/request_approval/bloc/request_approval_bloc.dart';
import 'package:fl_mhis_hr/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:jiffy/jiffy.dart';

class MyApprovalWidget extends StatefulWidget {
  const MyApprovalWidget({super.key});

  @override
  State<MyApprovalWidget> createState() => _MyApprovalWidgetState();
}

class _MyApprovalWidgetState extends State<MyApprovalWidget> {
  DateTime selectedDate = DateTime.now();
  String? strMonthYear;
  String selectedStatus = 'All';
  String searchQuery = '';
  Map<String, dynamic> map = {};

  final List<String> statuses = const [
    'All',
    'Pending',
    'Approved',
    'Rejected',
    'Skipped',
  ];

  @override
  void initState() {
    super.initState();
    _syncPeriodAndLoad();
  }

  void _syncPeriodAndLoad() {
    strMonthYear =
        Jiffy.parseFromDateTime(selectedDate).format(pattern: 'MMMM yyyy');
    final String year =
        Jiffy.parseFromDateTime(selectedDate).format(pattern: 'yyyy');
    final String month =
        Jiffy.parseFromDateTime(selectedDate).format(pattern: 'M');
    map = {'month': month, 'year': year};
    context.read<RequestApprovalBloc>().add(OnInitApproval(map));
  }

  List<Approval> _filteredApprovals(List<Approval> approvals) {
    return approvals.where((approval) {
      final String query = searchQuery.trim().toLowerCase();
      final String status = (approval.status ?? '').toLowerCase();

      bool statusMatches = true;
      if (selectedStatus != 'All') {
        final String selected = selectedStatus.toLowerCase();
        if (selected == 'rejected') {
          statusMatches = status == 'rejected' || status == 'reject';
        } else {
          statusMatches = status == selected;
        }
      }

      if (!statusMatches) {
        return false;
      }

      if (query.isEmpty) {
        return true;
      }

      final String requesterName =
          (approval.approvalRequest?.requester?.personal?.fullname ?? '')
              .toLowerCase();
      final String timeoffName =
          (approval.approvalRequest?.type?.name ?? '').toLowerCase();

      return requesterName.contains(query) || timeoffName.contains(query);
    }).toList();
  }

  String _emptyApprovalMessage() {
    if (searchQuery.trim().isNotEmpty) {
      return 'No approval data matching "$searchQuery" for the selected filters.';
    }

    if (selectedStatus != 'All') {
      return 'No approval data with status $selectedStatus for the selected month.';
    }

    return 'There is no approval data for the selected month.';
  }

  int _countStatus(List<Approval> approvals, String status) {
    final String target = status.toLowerCase();
    return approvals.where((approval) {
      final String current = (approval.status ?? '').toLowerCase();
      if (target == 'rejected') {
        return current == 'rejected' || current == 'reject';
      }
      return current == target;
    }).length;
  }

  String _displayStatus(String? status) {
    final String text = (status ?? '--').trim();
    if (text.isEmpty) {
      return '--';
    }
    if (text.toLowerCase() == 'reject') {
      return 'Rejected';
    }
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  Future<void> _showStatusFilterDialog() async {
    final String? selected = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Filter by status'),
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: statuses.map((status) {
              return RadioListTile<String>(
                value: status,
                groupValue: selectedStatus,
                title: Text(status),
                dense: true,
                onChanged: (value) {
                  Navigator.pop(dialogContext, value);
                },
              );
            }).toList(),
          ),
        );
      },
    );

    if (selected == null || selected == selectedStatus) {
      return;
    }

    setState(() {
      selectedStatus = selected;
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<RequestApprovalBloc>().add(OnInitApproval(map));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: BlocBuilder<RequestApprovalBloc, RequestApprovalState>(
          builder: (context, state) {
            final List<Approval> approvals = state.approvals;
            final List<Approval> filteredApprovals =
                _filteredApprovals(approvals);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  color: AppColors.whiteshade,
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
                  child: AppBar(
                    automaticallyImplyLeading: false,
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    surfaceTintColor: Colors.transparent,
                    titleSpacing: 0,
                    toolbarHeight: 52,
                    title: TextFormField(
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                      decoration: TextFormDecoration.box(
                        hintText: 'Search requester or timeoff name',
                        prefixIcon: const Icon(Icons.search),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: _SummarySection(
                    pendingCount: _countStatus(approvals, 'pending'),
                    approvedCount: _countStatus(approvals, 'approved'),
                    rejectedCount: _countStatus(approvals, 'rejected'),
                    skippedCount: _countStatus(approvals, 'skipped'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: TextEditingController(text: strMonthYear),
                          readOnly: true,
                          onTap: () {
                            showMonthPicker(
                              context: context,
                              initialDate: selectedDate,
                              monthPickerDialogSettings:
                                  Common.monthPickerDialog(),
                            ).then((date) {
                              if (date == null) {
                                return;
                              }
                              setState(() {
                                selectedDate = date;
                                _syncPeriodAndLoad();
                              });
                            });
                          },
                          decoration: TextFormDecoration.box(
                            prefixIcon: const Icon(Icons.calendar_month),
                            suffixIcon: const Icon(Icons.arrow_drop_down),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      FilterIconWidget(onTap: _showStatusFilterDialog),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: state.isLoading
                      ? const LoadingWidget()
                      : filteredApprovals.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 28,
                                horizontal: 12,
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.approval_outlined,
                                    size: 44,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'No approvals found',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _emptyApprovalMessage(),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.separated(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: filteredApprovals.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final Approval approval =
                                    filteredApprovals[index];
                                final String status =
                                    _displayStatus(approval.status);
                                return _ApprovalCard(
                                    title:
                                        approval
                                                .approvalRequest?.type?.name ??
                                            '--',
                                    subtitle:
                                        ApprovalRequestData.formatRequestDate(
                                            approval.approvalRequest ??
                                                ApprovalRequest()),
                                    requesterName: approval.approvalRequest
                                            ?.requester?.personal?.fullname ??
                                        '--',
                                    note:
                                        approval.approvalRequest?.note ?? '--',
                                    status: status,
                                    statusColor:
                                        Common.statusColor(approval.status),
                                    onTap: () {
                                      context.pushNamed(
                                        "timeoff-detail",
                                        extra: {
                                          "requestId":
                                              approval.approvalRequest?.id,
                                        },
                                      );
                                    });
                              },
                            ),
                ),
                const SizedBox(height: 14),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SummarySection extends StatelessWidget {
  final int pendingCount;
  final int approvedCount;
  final int rejectedCount;
  final int skippedCount;

  const _SummarySection({
    required this.pendingCount,
    required this.approvedCount,
    required this.rejectedCount,
    required this.skippedCount,
  });

  @override
  Widget build(BuildContext context) {
    final List<_SummaryItem> items = [
      const _SummaryItem(
        title: 'Pending',
        color: AppColors.amber,
      ),
      const _SummaryItem(
        title: 'Approved',
        color: AppColors.primary,
      ),
      const _SummaryItem(
        title: 'Rejected',
        color: AppColors.danger,
      ),
      const _SummaryItem(
        title: 'Skipped',
        color: AppColors.grey,
      ),
    ];
    final List<int> counts = [
      pendingCount,
      approvedCount,
      rejectedCount,
      skippedCount,
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.whiteshade,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Wrap(
        spacing: 5,
        runSpacing: 5,
        children: List.generate(items.length, (index) {
          return SizedBox(
            width: (MediaQuery.of(context).size.width - 58) / 2,
            child: _SummaryTile(
              title: items[index].title,
              count: counts[index],
              color: items[index].color,
            ),
          );
        }),
      ),
    );
  }
}

class _SummaryItem {
  final String title;
  final Color color;

  const _SummaryItem({required this.title, required this.color});
}

class _SummaryTile extends StatelessWidget {
  final String title;
  final int count;
  final Color color;

  const _SummaryTile({
    required this.title,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      // decoration: BoxDecoration(
      //   color: color.withValues(alpha: 0.10),
      //   borderRadius: BorderRadius.circular(10),
      // ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          Text(
            '$count',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class _ApprovalCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String requesterName;
  final String note;
  final String status;
  final Color statusColor;
  final GestureTapCallback onTap;

  const _ApprovalCard({
    required this.title,
    required this.subtitle,
    required this.requesterName,
    required this.note,
    required this.status,
    required this.statusColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Requester: $requesterName',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Note: $note',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
