import 'package:fl_mhis_hr/library/app_colors.dart';
import 'package:fl_mhis_hr/models/v2/visitor.dart';
import 'package:fl_mhis_hr/pages/visitor/bloc/visitor_bloc.dart';
import 'package:fl_mhis_hr/widget/themed_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class VisitorInvitationLinkDetailScreen extends StatefulWidget {
  const VisitorInvitationLinkDetailScreen({super.key, required this.batchId});

  final int batchId;

  @override
  State<VisitorInvitationLinkDetailScreen> createState() =>
      _VisitorInvitationLinkDetailScreenState();
}

class _VisitorInvitationLinkDetailScreenState
    extends State<VisitorInvitationLinkDetailScreen> {
  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() => context
      .read<VisitorBloc>()
      .add(LoadVisitorInvitationLinkBatchDetail(widget.batchId));

  Future<void> _copyLink(String url) async {
    await Clipboard.setData(ClipboardData(text: url));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invitation link copied.')),
      );
    }
  }

  String _dateLabel(String value, {String pattern = 'dd MMM yyyy'}) {
    final date = DateTime.tryParse(value);
    return date == null ? value : DateFormat(pattern).format(date);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VisitorBloc, VisitorState>(
      builder: (context, state) {
        final detail = state.invitationLinkBatchDetail;
        return ThemedPage(
          title: 'Invitation link batch',
          subtitle: 'View and copy guest registration links',
          child: detail.loading
              ? const Center(child: CircularProgressIndicator())
              : detail.error != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Unable to load batch: ${detail.error}',
                                textAlign: TextAlign.center),
                            TextButton(
                              onPressed: _load,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : detail.batch == null || detail.batch!.id != widget.batchId
                      ? const Center(child: CircularProgressIndicator())
                      : _content(detail.batch!),
        );
      },
    );
  }

  Widget _content(VisitorInvitationLinksResult batch) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
      children: [
        _section(batch.name, [
          _infoRow('Visit date', _dateLabel(batch.visitDate)),
          if (batch.expiresAt != null)
            _infoRow(
              'Expires',
              _dateLabel(batch.expiresAt!, pattern: 'dd MMM yyyy HH:mm'),
            ),
          _infoRow('Links', '${batch.linkCount ?? batch.links.length}'),
        ]),
        if (batch.emailFailures.isNotEmpty)
          _section('Email delivery issues', [
            for (final failure in batch.emailFailures)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading:
                    const Icon(Icons.error_outline, color: AppColors.danger),
                title: Text(failure),
              ),
          ]),
        if (batch.links.isEmpty)
          _section('No link details', [
            const Text('This batch did not return any registration links.'),
          ]),
        for (final link in batch.links)
          _section(link.recipientEmail ?? 'Manual link', [
            if (link.deliveryStatus != null)
              _infoRow('Delivery status', link.deliveryStatus!),
            const SizedBox(height: 8),
            SelectableText(
              link.url,
              style: const TextStyle(fontSize: 13),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _copyLink(link.url),
                icon: const Icon(Icons.copy),
                label: const Text('Copy link'),
              ),
            ),
          ]),
      ],
    );
  }

  Widget _section(String title, List<Widget> children) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE9E9EF)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            ...children,
          ],
        ),
      );

  Widget _infoRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Expanded(
                child: Text(label, style: TextStyle(color: Colors.grey[700]))),
            const SizedBox(width: 12),
            Flexible(
              child: Text(value,
                  textAlign: TextAlign.end,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      );
}
