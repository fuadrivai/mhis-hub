import 'dart:async';

import 'package:fl_mhis_hr/library/app_colors.dart';
import 'package:fl_mhis_hr/models/v2/visitor.dart';
import 'package:fl_mhis_hr/pages/visitor/bloc/visitor_bloc.dart';
import 'package:fl_mhis_hr/pages/visitor/screen/visitor_invitation_link_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class VisitorInvitationLinkListScreen extends StatefulWidget {
  const VisitorInvitationLinkListScreen({super.key});

  @override
  VisitorInvitationLinkListScreenState createState() =>
      VisitorInvitationLinkListScreenState();
}

class VisitorInvitationLinkListScreenState
    extends State<VisitorInvitationLinkListScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final completion = Completer<void>();
    context.read<VisitorBloc>().add(LoadVisitorInvitationLinkBatches(
          reset: true,
          completion: completion,
        ));
    await completion.future;
  }

  Future<void> reload() => _reload();

  void _loadMore(VisitorListState<VisitorInvitationLinksResult> list) {
    if (!list.loading && list.hasMore) {
      context.read<VisitorBloc>().add(const LoadVisitorInvitationLinkBatches());
    }
  }

  Future<void> _open(VisitorInvitationLinksResult batch) async {
    await Navigator.of(context).push<void>(MaterialPageRoute(
      builder: (_) => VisitorInvitationLinkDetailScreen(batchId: batch.id),
    ));
  }

  String _dateLabel(String value) {
    final date = DateTime.tryParse(value);
    return date == null ? value : DateFormat('dd MMM yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder<VisitorBloc, VisitorState>(
      builder: (context, state) {
        final list = state.invitationLinkBatches;
        if (list.loading && list.items.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (list.error != null && list.items.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Unable to load invitation links: ${list.error}',
                      textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _reload,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: _reload,
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification.metrics.axis == Axis.vertical &&
                  notification.metrics.extentAfter < 300) {
                _loadMore(list);
              }
              return false;
            },
            child: ListView(
              key: const ValueKey('visitor-invitation-link-list'),
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              children: [
                if (list.items.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 80),
                    child: Center(
                      child: Text('No invitation link batches yet.'),
                    ),
                  )
                else
                  for (final batch in list.items)
                    _BatchCard(
                      batch: batch,
                      dateLabel: _dateLabel(batch.visitDate),
                      onTap: () => _open(batch),
                    ),
                if (list.loading && list.items.isNotEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                if (list.error != null && list.items.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: TextButton(
                      onPressed: _reload,
                      child: Text('Unable to load more: ${list.error}'),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BatchCard extends StatelessWidget {
  const _BatchCard({
    required this.batch,
    required this.dateLabel,
    required this.onTap,
  });

  final VisitorInvitationLinksResult batch;
  final String dateLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final count = batch.linkCount ?? batch.links.length;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE9E9EF)),
      ),
      child: ListTile(
        key: ValueKey('visitor-link-batch-${batch.id}'),
        onTap: onTap,
        contentPadding: const EdgeInsets.fromLTRB(16, 8, 12, 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.danger.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Icon(Icons.link_rounded, color: AppColors.danger),
        ),
        title: Text(batch.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text('$dateLabel  ·  $count ${count == 1 ? 'link' : 'links'}'),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.black45),
      ),
    );
  }
}
