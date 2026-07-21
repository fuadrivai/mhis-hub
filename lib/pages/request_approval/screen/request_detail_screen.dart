// ignore_for_file: unused_element
import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/models/v2/models.dart';
import 'package:fl_mhis_hr/pages/request_approval/bloc/request_approval_bloc.dart';
import 'package:fl_mhis_hr/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:jiffy/jiffy.dart';

class RequestDetailScreen extends StatefulWidget {
  final int requestId;
  const RequestDetailScreen({super.key, required this.requestId});

  @override
  State<RequestDetailScreen> createState() => _RequestDetailScreenState();
}

class _RequestDetailScreenState extends State<RequestDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  int employeeId = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<RequestApprovalBloc>().add(OnInitDetail(widget.requestId));
    Session.get('employeeId').then((empId) {
      employeeId = int.tryParse(empId ?? '') ?? 0;
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteshade,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.dark,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text(
          'Timeoff Request Detail',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.dark,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.secondary,
          labelColor: AppColors.secondary,
          unselectedLabelColor: AppColors.blackshade,
          labelStyle:
              const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          unselectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          tabs: const [
            Tab(text: 'Detail'),
            Tab(text: 'Approval'),
          ],
        ),
      ),
      body: BlocBuilder<RequestApprovalBloc, RequestApprovalState>(
        builder: (context, state) {
          if (state.isFormLoading) {
            return const LoadingWidget();
          }

          if (state.isFormError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(state.errorMessage ?? 'An error occurred'),
              ),
            );
          }

          if (state.request == null) {
            return const Center(child: Text('Request detail not found'));
          }

          final ApprovalRequest request = state.request!;
          final Approval? approval = request.approvals?.firstWhere(
              (a) => a.approver?.id == employeeId,
              orElse: () => Approval());
          final bool canCancelRequest =
              request.requester?.id == employeeId && request.showCancel;

          return Column(
            children: [
              _buildHeader(request),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _DetailTab(
                      request: request,
                      approval: approval,
                      canCancelRequest: canCancelRequest,
                    ),
                    _ApprovalTab(request: request),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────────── header ────────────────────

  Widget _buildHeader(ApprovalRequest request) {
    final String requesterName = request.requester?.personal?.fullname ??
        request.requester?.user?.name ??
        'Unknown';
    final String position = request.requester?.employment?.jobPositionName ??
        request.requester?.employment?.jobPosition?.name ??
        '';
    final String? avatar = request.requester?.personal?.avatar;
    final String timeoffName = request.type?.name ?? '--';
    final String createdAt = Approval.formatDateTime(request.createdAt) ?? '--';
    final int totalSteps =
        request.approvalRule?.steps.length ?? (request.approvals?.length ?? 0);
    final String currentStep = totalSteps > 0
        ? 'Step ${request.currentStep ?? 1} of $totalSteps'
        : (request.currentStep?.toString() ?? '--');

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _Avatar(url: avatar, name: requesterName),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      requesterName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.dark,
                      ),
                    ),
                    if (position.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        position,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.blackshade,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Column(
            children: [
              _HeaderMetaRow(
                label: 'Timeoff Type',
                value: timeoffName,
              ),
              const SizedBox(height: 8),
              _HeaderMetaRow(
                label: 'Status',
                value: request.status ?? '--',
                valueColor: _headerStatusColor(request.status),
                badge: true,
              ),
              const SizedBox(height: 8),
              _HeaderMetaRow(
                label: 'Created At',
                value: createdAt,
              ),
              const SizedBox(height: 8),
              _HeaderMetaRow(
                label: 'Current Step',
                value: currentStep,
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Color _headerStatusColor(String? status) {
    switch ((status ?? '').toLowerCase()) {
      case 'approved':
        return const Color(0xFF0EA56A);
      case 'rejected':
        return const Color(0xFFD64545);
      case 'pending':
        return const Color(0xFFF2A93B);
      default:
        return AppColors.blackshade;
    }
  }
}

class _DetailTab extends StatelessWidget {
  final ApprovalRequest request;
  final Approval? approval;
  final bool canCancelRequest;
  const _DetailTab({
    required this.request,
    this.approval,
    this.canCancelRequest = false,
  });

  @override
  Widget build(BuildContext context) {
    final List<_FieldItem> fields = _buildFields();
    final List<_FieldItem> displayFields = fields;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SectionCard(
          title: 'Request Information',
          child: displayFields.isEmpty
              ? const _EmptyHint('No details available')
              : Column(
                  children: displayFields
                      .map((f) => _FieldRow(label: f.label, value: f.value))
                      .toList(),
                ),
        ),
        const SizedBox(height: 12),
        _SectionCard(
          title: 'Note',
          child: ((request.note ?? '').trim().isNotEmpty)
              ? Text(
                  request.note!.trim(),
                  style: const TextStyle(
                      fontSize: 14, height: 1.5, color: AppColors.dark),
                )
              : const _EmptyHint('No note available'),
        ),
        const SizedBox(height: 12),
        _SectionCard(
          title: 'Attachments',
          child: (request.attachments ?? []).isNotEmpty
              ? Column(
                  children: (request.attachments ?? [])
                      .map((a) => _AttachmentRow(attachment: a))
                      .toList(),
                )
              : const _EmptyHint('No attachments available'),
        ),
        if (approval?.showAction == true || canCancelRequest) ...[
          const SizedBox(height: 12),
          if (approval?.showAction == true)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _showActionReasonDialog(context, action: 'rejected')
                          .then((reason) {
                        if (reason == null || reason.trim().isEmpty) {
                          return;
                        }
                        if (!context.mounted) return;
                        Common.flushBar(
                          context,
                          title: 'Reject action clicked',
                          message: reason,
                        );
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.danger),
                      foregroundColor: AppColors.danger,
                    ),
                    child: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _showActionReasonDialog(context, action: 'approved')
                          .then((reason) {
                        if (reason == null || reason.trim().isEmpty) {
                          return;
                        }
                        if (!context.mounted) return;
                        Common.flushBar(
                          context,
                          title: 'Approve action clicked',
                          message: reason,
                        );
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.whiteshade,
                    ),
                    child: const Text('Approve'),
                  ),
                ),
              ],
            ),
          if (approval?.showAction == true && canCancelRequest)
            const SizedBox(height: 10),
          if (canCancelRequest)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  _showActionReasonDialog(context, action: 'cancelled')
                      .then((reason) {
                    if (reason == null || reason.trim().isEmpty) {
                      return;
                    }
                    if (!context.mounted) return;
                    Common.flushBar(
                      context,
                      title: 'Cancel action clicked',
                      message: reason,
                    );
                  });
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.danger),
                  foregroundColor: AppColors.danger,
                ),
                child: const Text('Cancel Request'),
              ),
            ),
        ],
        const SizedBox(height: 24),
      ],
    );
  }

  Future<String?> _showActionReasonDialog(
    BuildContext context, {
    required String action,
  }) {
    final TextEditingController controller = TextEditingController();
    String? errorText;

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text('$action Request'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Reason / Note',
                      hintText: 'Enter your reason',
                      errorText: errorText,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final String value = controller.text.trim();
                    Map<String, dynamic> map = {
                      "request_id": request.id,
                      "action": action.toLowerCase(),
                      "reason": value,
                    };
                    if (action.toLowerCase() == 'cancelled') {
                      context
                          .read<RequestApprovalBloc>()
                          .add(PostCancelRequest(request.id!, map));
                    } else {
                      context.read<RequestApprovalBloc>().add(PostAction(map));
                    }
                    Navigator.pop(dialogContext, value);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: action == 'Reject'
                        ? AppColors.danger
                        : AppColors.primary,
                    foregroundColor: AppColors.whiteshade,
                  ),
                  child: Text(action),
                ),
              ],
            );
          },
        );
      },
    );
  }

  List<_FieldItem> _buildFields() {
    final Map<String, dynamic> payload =
        request.data?.payload ?? <String, dynamic>{};
    final List<TimeoffSchema> schema =
        request.type?.schema ?? <TimeoffSchema>[];
    final List<_FieldItem> items = <_FieldItem>[];
    final Set<String> usedKeys = <String>{};

    for (final TimeoffSchema field in schema) {
      final String key = (field.name ?? '').trim();
      if (key.isEmpty || !payload.containsKey(key)) continue;
      items.add(_FieldItem(
        label: (field.label ?? key).trim(),
        value: _formatValue(payload[key], field: field),
      ));
      usedKeys.add(key);
    }

    for (final MapEntry<String, dynamic> entry in payload.entries) {
      if (usedKeys.contains(entry.key)) continue;
      items.add(_FieldItem(
        label: _beautifyKey(entry.key),
        value: _formatValue(entry.value, fieldName: entry.key),
      ));
    }

    return items;
  }

  static String _formatValue(dynamic value,
      {TimeoffSchema? field, String? fieldName}) {
    if (value == null) return '--';

    final bool isDateField = field != null
        ? ApprovalRequestData.looksLikeDateField(field)
        : ApprovalRequestData.looksLikeDateKey((fieldName ?? '').toLowerCase());

    final DateTime? parsed = ApprovalRequestData.parseDynamicDate(value);
    if (isDateField && parsed != null) {
      return Jiffy.parseFromDateTime(parsed).format(pattern: 'dd MMMM yyyy');
    }

    if (value is bool) return value ? 'Yes' : 'No';

    if (value is Map) {
      if (value.containsKey('label')) return _formatValue(value['label']);
      if (value.containsKey('name')) return _formatValue(value['name']);
      if (parsed != null) {
        return Jiffy.parseFromDateTime(parsed).format(pattern: 'dd MMMM yyyy');
      }
      return value.entries
          .map((e) =>
              '${_beautifyKey(e.key.toString())}: ${_formatValue(e.value)}')
          .join(', ');
    }

    if (value is Iterable) {
      final parts = value
          .map((item) => _formatValue(item))
          .where((s) => s.isNotEmpty && s != '--')
          .toList();
      return parts.isEmpty ? '--' : parts.join(', ');
    }

    final String text = value.toString().trim();
    return text.isEmpty ? '--' : text;
  }

  static String _beautifyKey(String key) {
    final parts = key
        .replaceAllMapped(
            RegExp(r'([a-z0-9])([A-Z])'), (m) => '${m[1]} ${m[2]}')
        .split(RegExp(r'[_\s]+'))
        .where((p) => p.isNotEmpty)
        .toList();
    return parts
        .map((p) => '${p[0].toUpperCase()}${p.substring(1).toLowerCase()}')
        .join(' ');
  }

  static String? _formatDateTime(String? value) {
    final DateTime? parsed = ApprovalRequestData.parseDynamicDate(value);
    if (parsed == null) {
      return null;
    }

    return Jiffy.parseFromDateTime(parsed).format(pattern: 'dd MMMM yyyy');
  }
}

class _ApprovalTab extends StatelessWidget {
  final ApprovalRequest request;
  const _ApprovalTab({required this.request});

  @override
  Widget build(BuildContext context) {
    final List<Approval> approvals = request.approvals ?? <Approval>[];
    final List<ApprovalHistory> histories = _sortedHistories(request.histories);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (approvals.isNotEmpty) ...[
          const SizedBox(height: 12),
          _SectionCard(
            title: 'Approvers',
            child: Column(
              children: approvals.asMap().entries.map((entry) {
                final int index = entry.key;
                final Approval ap = entry.value;
                final String name = ap.approver?.personal?.fullname ??
                    ap.approver?.user?.name ??
                    'Unknown';
                return _ApproverRow(
                  step: ap.stepOrder ?? (index + 1),
                  name: name,
                  status: ap.status,
                  note: ap.actionedDate != null
                      ? 'Actioned on ${Approval.formatDateTime(ap.actionedDate)}'
                      : null,
                  isLast: index == approvals.length - 1,
                );
              }).toList(),
            ),
          ),
        ],
        if (histories.isNotEmpty) ...[
          const SizedBox(height: 12),
          _SectionCard(
            title: 'History',
            child: Column(
              children: List.generate(
                histories.length,
                (i) => _HistoryRow(
                    history: histories[i], isLast: i == histories.length - 1),
              ),
            ),
          ),
        ],
        const SizedBox(height: 24),
      ],
    );
  }

  static List<ApprovalHistory> _sortedHistories(
      List<ApprovalHistory>? histories) {
    final List<ApprovalHistory> data =
        List<ApprovalHistory>.from(histories ?? []);
    data.sort((a, b) {
      final DateTime? dA =
          ApprovalRequestData.parseDynamicDate(a.createdAt ?? a.updatedAt);
      final DateTime? dB =
          ApprovalRequestData.parseDynamicDate(b.createdAt ?? b.updatedAt);
      if (dA == null && dB == null) return 0;
      if (dA == null) return 1;
      if (dB == null) return -1;
      return dB.compareTo(dA);
    });
    return data;
  }

  static String _capitalize(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1).toLowerCase()}';
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.blackshade,
                letterSpacing: 0.3,
              ),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _FieldRow extends StatelessWidget {
  final String label;
  final String value;
  const _FieldRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label,
                style:
                    const TextStyle(fontSize: 13, color: AppColors.blackshade)),
          ),
          const Text(':  ',
              style: TextStyle(fontSize: 13, color: AppColors.blackshade)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.dark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AttachmentRow extends StatelessWidget {
  final FileAttachment attachment;
  const _AttachmentRow({required this.attachment});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          const Icon(Icons.attach_file, size: 16, color: AppColors.blackshade),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: () {
                Common.launchExternalUrl(attachment.link);
              },
              child: Text(
                attachment.fileName,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.secondary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
          Text(
            _formatSize(attachment.fileSize),
            style: const TextStyle(fontSize: 12, color: AppColors.blackshade),
          ),
        ],
      ),
    );
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}

class _ApproverRow extends StatelessWidget {
  final int step;
  final String name;
  final String? status;
  final String? note;
  final bool isLast;
  const _ApproverRow({
    required this.step,
    required this.name,
    this.status,
    this.note,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = _statusColor(status);
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 1.5),
                ),
                child: Center(
                  child: Text(
                    '$step',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: color),
                  ),
                ),
              ),
              if (!isLast)
                Container(width: 1.5, height: 24, color: Colors.grey.shade200),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.dark),
                      ),
                    ),
                    if (status != null)
                      _StatusChip(status: status, small: true),
                  ],
                ),
                if ((note ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(note!.trim(),
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.blackshade)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Color _statusColor(String? status) {
    switch ((status ?? '').toLowerCase()) {
      case 'approved':
        return const Color(0xFF0EA56A);
      case 'rejected':
        return const Color(0xFFD64545);
      case 'pending':
        return const Color(0xFFF2A93B);
      default:
        return AppColors.blackshade;
    }
  }
}

class _HistoryRow extends StatelessWidget {
  final ApprovalHistory history;
  final bool isLast;
  const _HistoryRow({required this.history, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final String action = (history.action ?? '').toLowerCase();
    final bool isApproved = action.contains('approve');
    final bool isRejected = action.contains('reject');

    final Color dotColor = isApproved
        ? const Color(0xFF0EA56A)
        : isRejected
            ? const Color(0xFFD64545)
            : AppColors.secondary;

    final DateTime? date = ApprovalRequestData.parseDynamicDate(
        history.createdAt ?? history.updatedAt);
    final String formattedDate = date != null
        ? Jiffy.parseFromDateTime(date).format(pattern: 'dd MMM yyyy, HH:mm')
        : '--';

    final String actor = history.approver?.personal?.fullname ??
        history.approver?.user?.name ??
        'System';

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(top: 4),
                decoration:
                    BoxDecoration(color: dotColor, shape: BoxShape.circle),
              ),
              if (!isLast)
                Container(width: 1.5, height: 44, color: Colors.grey.shade200),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Timeoff request ${history.action ?? 'updated'}${actor != 'System' ? ' by $actor' : ''}",
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: dotColor),
                  ),
                  const SizedBox(height: 2),
                  Text(formattedDate,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.blackshade)),
                  if ((history.note ?? '').trim().isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      history.note!.trim(),
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.blackshade,
                          fontStyle: FontStyle.italic),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String? status;
  final bool small;
  const _StatusChip({this.status, this.small = false});

  @override
  Widget build(BuildContext context) {
    final Color color = _statusColor(status);
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: small ? 8 : 10, vertical: small ? 3 : 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        _capitalize(status ?? '--'),
        style: TextStyle(
            fontSize: small ? 11 : 12,
            fontWeight: FontWeight.w700,
            color: color),
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1).toLowerCase()}';

  static Color _statusColor(String? status) {
    switch ((status ?? '').toLowerCase()) {
      case 'approved':
        return const Color(0xFF0EA56A);
      case 'rejected':
        return const Color(0xFFD64545);
      case 'pending':
        return const Color(0xFFF2A93B);
      default:
        return AppColors.blackshade;
    }
  }
}

class _HeaderMetaRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool badge;

  const _HeaderMetaRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.badge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.blackshade,
            ),
          ),
        ),
        const Text(
          ': ',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.blackshade,
          ),
        ),
        Expanded(
          child: badge
              ? Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: (valueColor ?? AppColors.dark)
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(
                        color: (valueColor ?? AppColors.dark)
                            .withValues(alpha: 0.35),
                      ),
                    ),
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: valueColor ?? AppColors.dark,
                      ),
                    ),
                  ),
                )
              : Text(
                  value,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: valueColor ?? AppColors.dark,
                  ),
                ),
        ),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? url;
  final String name;
  const _Avatar({this.url, required this.name});

  @override
  Widget build(BuildContext context) {
    final String initials = _initials(name);
    final bool hasUrl = (url ?? '').trim().isNotEmpty;

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: hasUrl
            ? Image.network(url!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _initBox(initials))
            : _initBox(initials),
      ),
    );
  }

  Widget _initBox(String initials) => Container(
        alignment: Alignment.center,
        child: Text(
          initials,
          style: const TextStyle(
              color: AppColors.secondary,
              fontWeight: FontWeight.w700,
              fontSize: 16),
        ),
      );

  String _initials(String name) {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}

class _EmptyHint extends StatelessWidget {
  final String text;
  const _EmptyHint(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(text,
          style: const TextStyle(fontSize: 13, color: AppColors.blackshade)),
    );
  }
}

class _FieldItem {
  final String label;
  final String value;
  const _FieldItem({required this.label, required this.value});
}
