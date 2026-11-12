import 'dart:async';

import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/models/v2/visitor.dart';
import 'package:fl_mhis_hr/pages/visitor/bloc/visitor_bloc.dart';
import 'package:fl_mhis_hr/pages/visitor/screen/visitor_detail_screen.dart';
import 'package:fl_mhis_hr/pages/visitor/screen/visitor_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class VisitorScreen extends StatefulWidget {
  const VisitorScreen({super.key});

  @override
  State<VisitorScreen> createState() => _VisitorScreenState();
}

class _VisitorScreenState extends State<VisitorScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 2, vsync: this);
  final _invitations = GlobalKey<_VisitListState>();
  final _monitoring = GlobalKey<_VisitListState>();

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  void _refreshLists() {
    _invitations.currentState?.reload();
    _monitoring.currentState?.reload();
  }

  Future<void> _create() async {
    final created = await Navigator.of(context).push<bool>(MaterialPageRoute(
      builder: (_) => const VisitorFormScreen(),
    ));
    if (created == true && mounted) _refreshLists();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FA),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _create,
        backgroundColor: AppColors.danger,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Invitation'),
      ),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.paddingOf(context).top + 220,
            child: DecoratedBox(
              decoration: BoxDecoration(gradient: Common.homeHeaderGradient),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 18),
                  child: Row(children: [
                    IconButton(
                      tooltip: 'Back',
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const SizedBox(width: 4),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Visitor',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700)),
                          SizedBox(height: 4),
                          Text('View invitations and monitoring',
                              style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  ]),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: AppColors.danger.withValues(alpha: 0.1)),
                  ),
                  child: TabBar(
                    controller: _tabs,
                    labelColor: Colors.white,
                    unselectedLabelColor: AppColors.danger,
                    labelStyle: const TextStyle(fontWeight: FontWeight.w700),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    indicator: BoxDecoration(
                      color: AppColors.danger,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    tabs: const [
                      Tab(text: 'Invitations'),
                      Tab(text: 'Monitoring'),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(controller: _tabs, children: [
                    _VisitList(
                        key: _invitations,
                        type: VisitorListType.invitations,
                        onChanged: _refreshLists),
                    _VisitList(
                        key: _monitoring,
                        type: VisitorListType.monitoring,
                        onChanged: _refreshLists),
                  ]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VisitList extends StatefulWidget {
  const _VisitList({
    super.key,
    required this.type,
    required this.onChanged,
  });
  final VisitorListType type;
  final VoidCallback onChanged;

  @override
  State<_VisitList> createState() => _VisitListState();
}

class _VisitListState extends State<_VisitList>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    reload();
  }

  Future<void> reload() async {
    final completion = Completer<void>();
    context
        .read<VisitorBloc>()
        .add(LoadVisitorList(widget.type, reset: true, completion: completion));
    await completion.future;
  }

  void _load() => context.read<VisitorBloc>().add(LoadVisitorList(widget.type));

  Future<void> _open(Visit visit) async {
    final changed = await Navigator.of(context).push<bool>(MaterialPageRoute(
      builder: (_) => VisitorDetailScreen(id: visit.id),
    ));
    if (changed == true && mounted) widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder<VisitorBloc, VisitorState>(
      builder: (context, state) {
        final list = state.list(widget.type);
        return RefreshIndicator(
          onRefresh: reload,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            children: [
              for (final visit in list.items)
                Card(
                  child: ListTile(
                    title: Text(visit.visitor,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text(
                        '${visit.code} • ${visit.status}\n${visit.date} • ${visit.purpose}\nHost: ${visit.host}'),
                    isThreeLine: true,
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _open(visit),
                  ),
                ),
              if (list.loading)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (list.error != null)
                Column(children: [
                  Text('Unable to load visits: ${list.error}',
                      textAlign: TextAlign.center),
                  TextButton(onPressed: _load, child: const Text('Retry')),
                ])
              else if (list.items.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: Text('No visits found')),
                )
              else if (list.hasMore)
                TextButton(onPressed: _load, child: const Text('Load more')),
            ],
          ),
        );
      },
    );
  }
}
