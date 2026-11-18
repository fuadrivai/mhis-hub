import 'dart:async';

import 'package:fl_mhis_hr/library/app_colors.dart';
import 'package:fl_mhis_hr/models/v2/visitor.dart';
import 'package:fl_mhis_hr/pages/visitor/bloc/visitor_bloc.dart';
import 'package:fl_mhis_hr/pages/visitor/library/visitor_date_time.dart';
import 'package:fl_mhis_hr/pages/visitor/screen/visitor_detail_screen.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class VisitorApprovalListScreen extends StatefulWidget {
  const VisitorApprovalListScreen({super.key});

  @override
  VisitorApprovalListScreenState createState() =>
      VisitorApprovalListScreenState();
}

class VisitorApprovalListScreenState extends State<VisitorApprovalListScreen> {
  @override
  void initState() {
    super.initState();
    reload();
  }

  Future<void> reload() async {
    final completion = Completer<void>();
    context
        .read<VisitorBloc>()
        .add(LoadVisitorApprovals(reset: true, completion: completion));
    await completion.future;
  }

  void _loadMore() {
    context.read<VisitorBloc>().add(const LoadVisitorApprovals());
  }

  Future<void> _decide(Visit visit, String decision) async {
    final formKey = GlobalKey<FormState>();
    var notes = '';
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(decision == 'approve' ? 'Approve visit?' : 'Reject visit?'),
        content: Form(
          key: formKey,
          child: TextFormField(
            key: const ValueKey('visitor-approval-notes'),
            autofocus: true,
            maxLines: 3,
            onTapOutside: (_) => FocusScope.of(context).unfocus(),
            onChanged: (value) => notes = value,
            decoration: InputDecoration(
              labelText: decision == 'reject' ? 'Rejection note' : 'Notes',
            ),
            validator: decision == 'reject'
                ? (value) => value == null || value.trim().isEmpty
                    ? 'Enter a rejection note.'
                    : null
                : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: const ValueKey('visitor-approval-confirm'),
            style: FilledButton.styleFrom(
              backgroundColor: decision == 'approve'
                  ? Colors.green.shade700
                  : Colors.red.shade700,
            ),
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(dialogContext, notes.trim());
              }
            },
            child: Text(decision == 'approve' ? 'Approve' : 'Reject'),
          ),
        ],
      ),
    );
    if (result == null || !mounted) return;
    context.read<VisitorBloc>().add(DecideVisitorApproval(
          id: visit.id,
          decision: decision,
          notes: result,
        ));
  }

  Future<void> _openDetail(Visit visit) async {
    await Navigator.of(context).push<bool>(MaterialPageRoute(
      builder: (_) => VisitorDetailScreen(id: visit.id),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VisitorBloc, VisitorState>(
      listenWhen: (previous, current) =>
          previous.approvalAction != current.approvalAction,
      listener: (context, state) {
        final action = state.approvalAction;
        if (action.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Unable to update approval: ${action.error}')),
          );
        } else if (action.completedId != null) {
          final message = action.decision == 'approve'
              ? 'Visitor invitation approved.'
              : 'Visitor invitation rejected.';
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(message)));
          reload();
        }
      },
      builder: (context, state) {
        final list = state.approvals;
        return RefreshIndicator(
          onRefresh: reload,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Pending confirmation',
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                    ),
                  ),
                  if (list.total != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.danger.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        '${list.total}',
                        style: const TextStyle(
                          color: AppColors.danger,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (list.loading && list.items.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (list.error != null && list.items.isEmpty)
                _ApprovalMessage(
                  message: 'Unable to load approvals: ${list.error}',
                  actionLabel: 'Retry',
                  onPressed: reload,
                )
              else if (list.items.isEmpty)
                const _ApprovalMessage(
                  message: 'There are no visits waiting for approval.',
                )
              else ...[
                for (final visit in list.items)
                  _ApprovalCard(
                    visit: visit,
                    busy: state.approvalAction.submittingId == visit.id,
                    disabled: state.approvalAction.submittingId != null,
                    onTap: () => _openDetail(visit),
                    onApprove: () => _decide(visit, 'approve'),
                    onReject: () => _decide(visit, 'reject'),
                  ),
                if (list.loading)
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (list.error != null)
                  _ApprovalMessage(
                    message: 'Unable to load more approvals: ${list.error}',
                    actionLabel: 'Retry',
                    onPressed: _loadMore,
                  )
                else if (list.hasMore)
                  Center(
                    child: TextButton(
                      onPressed: _loadMore,
                      child: const Text('Load more'),
                    ),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _ApprovalCard extends StatelessWidget {
  const _ApprovalCard({
    required this.visit,
    required this.busy,
    required this.disabled,
    required this.onTap,
    required this.onApprove,
    required this.onReject,
  });

  final Visit visit;
  final bool busy, disabled;
  final VoidCallback onTap, onApprove, onReject;

  String _date(String value) {
    final date = DateTime.tryParse(value);
    return date == null ? value : DateFormat('dd MMM yyyy', 'en').format(date);
  }

  String _time(String? value) {
    final date = value == null ? null : visitorJakartaDateTime(value);
    return date == null ? 'Not specified' : DateFormat('HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: onTap,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          visit.visitor,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        visit.code,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('${_date(visit.date)} · ${_time(visit.arrival)}'),
                  const SizedBox(height: 4),
                  Text('Host: ${visit.host} · ${visit.branch}'),
                  if (visit.notes?.trim().isNotEmpty == true) ...[
                    const SizedBox(height: 6),
                    Text(
                      visit.notes!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: disabled ? null : onReject,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red.shade700,
                    ),
                    child: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: disabled ? null : onApprove,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                    ),
                    child: busy
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Approve'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ApprovalMessage extends StatelessWidget {
  const _ApprovalMessage({
    required this.message,
    this.actionLabel,
    this.onPressed,
  });

  final String message;
  final String? actionLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Text(message, textAlign: TextAlign.center),
          if (actionLabel != null && onPressed != null)
            TextButton(onPressed: onPressed, child: Text(actionLabel!)),
        ],
      ),
    );
  }
}
