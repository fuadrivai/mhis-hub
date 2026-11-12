import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/pages/visitor/bloc/visitor_bloc.dart';
import 'package:fl_mhis_hr/widget/themed_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VisitorDetailScreen extends StatefulWidget {
  const VisitorDetailScreen({super.key, required this.id});
  final int id;

  @override
  State<VisitorDetailScreen> createState() => _VisitorDetailScreenState();
}

class _VisitorDetailScreenState extends State<VisitorDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<VisitorBloc>().add(LoadVisitorDetail(widget.id));
  }

  Future<void> _cancel() async {
    final form = GlobalKey<FormState>();
    var reasonText = '';
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel invitation'),
        content: Form(
          key: form,
          child: TextFormField(
            autofocus: true,
            maxLines: 3,
            onChanged: (value) => reasonText = value,
            decoration: const InputDecoration(labelText: 'Reason'),
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Enter a cancellation reason'
                : null,
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back')),
          TextButton(
            onPressed: () {
              if (form.currentState!.validate()) {
                Navigator.pop(context, reasonText.trim());
              }
            },
            child: const Text('Confirm cancellation'),
          ),
        ],
      ),
    );
    if (reason == null || !mounted) return;
    context.read<VisitorBloc>().add(CancelVisitorInvitation(widget.id, reason));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VisitorBloc, VisitorState>(
      listenWhen: (previous, current) => previous.detail != current.detail,
      listener: (context, state) async {
        final detail = state.detail;
        if (detail.cancelError != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Unable to cancel: ${detail.cancelError}')));
        } else if (detail.cancelled) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Invitation cancelled.')));
          await WidgetsBinding.instance.endOfFrame;
          if (context.mounted) Navigator.of(context).pop(true);
        }
      },
      builder: (context, state) {
        final detail = state.detail;
        return PopScope(
          canPop: !detail.cancelling,
          child: ThemedPage(
            title: 'Visit detail',
            subtitle: 'Visitor information',
            onBack:
                detail.cancelling ? () {} : () => Navigator.of(context).pop(),
            child: Builder(
              builder: (context) {
                if (detail.loading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (detail.error != null) {
                  return Center(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Text('Unable to load visit: ${detail.error}',
                          textAlign: TextAlign.center),
                      TextButton(
                        onPressed: () => context
                            .read<VisitorBloc>()
                            .add(LoadVisitorDetail(widget.id)),
                        child: const Text('Retry'),
                      ),
                    ]),
                  );
                }
                final visit = detail.visit;
                if (visit == null || visit.id != widget.id) {
                  return const Center(child: CircularProgressIndicator());
                }
                final fields = <String, String?>{
                  'Visit code': visit.code,
                  'Status': visit.status,
                  'Visitor': visit.visitor,
                  'Phone': visit.phone,
                  'Email': visit.email,
                  'Company': visit.company,
                  'Host': visit.host,
                  'Branch': visit.branch,
                  'Category': visit.category,
                  'Purpose': visit.purpose,
                  'Visit date': visit.date,
                  'Expected arrival': visit.arrival,
                  'Expected departure': visit.departure,
                  'Check in': visit.checkIn,
                  'Check out': visit.checkOut,
                  'Visit notes': visit.notes,
                  'Additional visitor information': visit.visitorNotes,
                  'Cancellation reason': visit.cancellationReason,
                  'Registration method': visit.registrationMethod,
                };
                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (final entry in fields.entries)
                              if (entry.value != null &&
                                  entry.value!.isNotEmpty)
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 6),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(entry.key,
                                          style: const TextStyle(
                                              color: Colors.grey)),
                                      const SizedBox(height: 2),
                                      Text(entry.value!),
                                    ],
                                  ),
                                ),
                          ],
                        ),
                      ),
                    ),
                    if (visit.canCancel)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                              backgroundColor: AppColors.danger),
                          onPressed: detail.cancelling ? null : _cancel,
                          child: Text(detail.cancelling
                              ? 'Cancelling...'
                              : 'Cancel invitation'),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}
