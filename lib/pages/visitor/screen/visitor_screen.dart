import 'dart:async';

import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/models/v2/visitor.dart';
import 'package:fl_mhis_hr/pages/visitor/bloc/visitor_bloc.dart';
import 'package:fl_mhis_hr/pages/visitor/screen/visitor_detail_screen.dart';
import 'package:fl_mhis_hr/pages/visitor/screen/visitor_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class VisitorScreen extends StatefulWidget {
  const VisitorScreen({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  State<VisitorScreen> createState() => _VisitorScreenState();
}

class _VisitorScreenState extends State<VisitorScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(
    length: 2,
    initialIndex: widget.initialTab == 1 ? 1 : 0,
    vsync: this,
  );
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
  final _searchController = TextEditingController();
  Timer? _searchDebounce;
  DateTimeRange? _dateRange;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    reload();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  String _dateParam(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  Map<String, dynamic> _filters() {
    final filters = <String, dynamic>{};
    final query = _searchController.text.trim();
    if (query.isNotEmpty) filters['query'] = query;
    final range = _dateRange;
    if (range != null) {
      if (DateUtils.isSameDay(range.start, range.end)) {
        filters['visit_date'] = _dateParam(range.start);
      } else {
        filters['from'] = _dateParam(range.start);
        filters['to'] = _dateParam(range.end);
      }
    }
    return filters;
  }

  void _applyFilters() {
    final filters = _filters();
    context.read<VisitorBloc>().add(LoadVisitorList(
          widget.type,
          reset: true,
          filters: filters,
        ));
    context.read<VisitorBloc>().add(LoadTodayVisitorList(
          type: widget.type,
          date: _dateParam(DateTime.now()),
          query: _searchController.text.trim(),
          reset: true,
        ));
  }

  void _onSearchChanged(String _) {
    setState(() {});
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), _applyFilters);
  }

  Future<void> _selectDateRange() async {
    final selected = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2015),
      lastDate: DateTime(2100),
      initialDateRange: _dateRange,
      helpText: 'Filter visits by date',
    );
    if (selected == null || !mounted) return;
    setState(() => _dateRange = selected);
    _applyFilters();
  }

  bool _includesToday() {
    final range = _dateRange;
    if (range == null) return true;
    final today = DateTime.now();
    final date = DateTime(today.year, today.month, today.day);
    return !date.isBefore(DateTime(
          range.start.year,
          range.start.month,
          range.start.day,
        )) &&
        !date.isAfter(DateTime(
          range.end.year,
          range.end.month,
          range.end.day,
        ));
  }

  Future<void> reload() async {
    final completion = Completer<void>();
    context.read<VisitorBloc>().add(LoadVisitorList(
          widget.type,
          reset: true,
          filters: _filters(),
          completion: completion,
        ));
    context.read<VisitorBloc>().add(LoadTodayVisitorList(
          type: widget.type,
          date: _dateParam(DateTime.now()),
          query: _searchController.text.trim(),
          reset: true,
        ));
    await completion.future;
  }

  void _load() => context.read<VisitorBloc>().add(LoadVisitorList(widget.type));

  void _loadToday() => context.read<VisitorBloc>().add(LoadTodayVisitorList(
        type: widget.type,
        date: _dateParam(DateTime.now()),
      ));

  Widget _filtersBar() {
    final range = _dateRange;
    final rangeLabel = range == null
        ? 'Filter by date'
        : '${DateFormat('dd MMM yyyy').format(range.start)} - '
            '${DateFormat('dd MMM yyyy').format(range.end)}';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            onSubmitted: (_) {
              _searchDebounce?.cancel();
              _applyFilters();
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: 'Search visitor name or phone',
              prefixIcon: const Icon(Icons.search, color: AppColors.danger),
              suffixIcon: _searchController.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear search',
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                        _applyFilters();
                      },
                      icon: const Icon(Icons.close),
                    ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _selectDateRange,
                  icon: const Icon(Icons.calendar_month_outlined, size: 18),
                  label: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      rangeLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    alignment: Alignment.centerLeft,
                    side: BorderSide(
                        color: AppColors.danger.withValues(alpha: 0.18)),
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              if (range != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Clear date filter',
                  onPressed: () {
                    setState(() => _dateRange = null);
                    _applyFilters();
                  },
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.danger,
                    side: BorderSide(
                        color: AppColors.danger.withValues(alpha: 0.18)),
                  ),
                  icon: const Icon(Icons.close),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

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
        final showToday = _includesToday();
        final today = widget.type == VisitorListType.invitations
            ? state.todayInvitations
            : state.todayMonitoring;
        final todayIds =
            showToday ? today.items.map((visit) => visit.id).toSet() : <int>{};
        final visibleItems = showToday
            ? list.items.where((visit) => !todayIds.contains(visit.id)).toList()
            : list.items;
        return RefreshIndicator(
          onRefresh: reload,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            children: [
              _filtersBar(),
              if (showToday) ...[
                Row(
                  children: [
                    const Icon(Icons.today_rounded,
                        color: AppColors.danger, size: 19),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.type == VisitorListType.invitations
                            ? "Today's invitations"
                            : "Today's monitoring",
                        style: const TextStyle(
                          color: Color(0xFF252633),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (today.items.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.danger.withValues(alpha: 0.09),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          '${today.total ?? today.items.length}',
                          style: const TextStyle(
                            color: AppColors.danger,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 3, bottom: 10),
                  child: Text(
                    DateFormat('EEEE, dd MMMM yyyy', 'en')
                        .format(DateTime.now()),
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ),
                if (today.loading && today.items.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(18),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (today.error != null && today.items.isEmpty)
                  _VisitListMessage(
                    message: "Unable to load today's visits: ${today.error}",
                    actionLabel: 'Retry',
                    onPressed: _loadToday,
                  )
                else if (today.items.isEmpty)
                  const _TodayEmptyState()
                else ...[
                  for (final visit in today.items)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _VisitCard(
                        visit: visit,
                        highlight: true,
                        onTap: () => _open(visit),
                      ),
                    ),
                  if (today.loading)
                    const Center(child: CircularProgressIndicator())
                  else if (today.error != null)
                    _VisitListMessage(
                      message:
                          "Unable to load more of today's visits: ${today.error}",
                      actionLabel: 'Retry',
                      onPressed: _loadToday,
                    )
                  else if (today.hasMore)
                    Center(
                      child: TextButton(
                        onPressed: _loadToday,
                        child: const Text('Load more today'),
                      ),
                    ),
                ],
                const SizedBox(height: 8),
                const Divider(height: 1),
                const SizedBox(height: 14),
              ],
              _ListSectionHeader(
                title: widget.type == VisitorListType.invitations
                    ? 'All invitations'
                    : 'All monitoring',
              ),
              if (list.loading && list.items.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (list.error != null && list.items.isEmpty)
                _VisitListMessage(
                  message: 'Unable to load visits: ${list.error}',
                  actionLabel: 'Retry',
                  onPressed: _load,
                )
              else if (visibleItems.isEmpty && list.items.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(28),
                  child: Center(child: Text('No visits found')),
                )
              else if (visibleItems.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(18),
                  child: Center(
                    child: Text('Today’s visits are shown above.'),
                  ),
                ),
              for (final visit in visibleItems)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _VisitCard(
                    visit: visit,
                    onTap: () => _open(visit),
                  ),
                ),
              if (list.loading && list.items.isNotEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (list.error != null && list.items.isNotEmpty)
                _VisitListMessage(
                  message: 'Unable to load more visits: ${list.error}',
                  actionLabel: 'Retry',
                  onPressed: _load,
                )
              else if (list.hasMore && list.items.isNotEmpty)
                TextButton(onPressed: _load, child: const Text('Load more')),
            ],
          ),
        );
      },
    );
  }
}

class _VisitCard extends StatelessWidget {
  const _VisitCard({
    required this.visit,
    required this.onTap,
    this.highlight = false,
  });

  final Visit visit;
  final VoidCallback onTap;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(visit.status);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color:
                  highlight ? const Color(0xFFB7DDCF) : const Color(0xFFE9E9EF),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.035),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: (highlight
                              ? const Color(0xFF168A62)
                              : AppColors.danger)
                          .withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(
                      Icons.person_outline,
                      color: highlight
                          ? const Color(0xFF168A62)
                          : AppColors.danger,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          visit.visitor,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF252633),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          visit.code,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _VisitStatus(status: visit.status, color: statusColor),
                ],
              ),
              const SizedBox(height: 12),
              _VisitInfo(
                icon: Icons.calendar_today_outlined,
                text: _formatVisitDate(visit.date),
              ),
              const SizedBox(height: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                decoration: BoxDecoration(
                  color: highlight
                      ? const Color(0xFFF2F9F6)
                      : const Color(0xFFF7F7FA),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.schedule_rounded,
                        size: 17, color: AppColors.danger),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Arrival: ${_formatVisitTime(visit.arrival)}  -  '
                        'Departure: ${_formatVisitTime(visit.departure)}',
                        style: const TextStyle(
                          color: Color(0xFF30313D),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 13),
              Row(
                children: [
                  Expanded(
                    child: _VisitInfo(
                      icon: Icons.event_note_outlined,
                      text: '${visit.purpose} · ${visit.branch}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 7),
              Row(
                children: [
                  Expanded(
                    child: _VisitInfo(
                      icon: Icons.badge_outlined,
                      text: 'Host: ${visit.host}',
                    ),
                  ),
                  const Icon(Icons.chevron_right,
                      size: 20, color: Color(0xFF9A9AA5)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'expected':
        return const Color(0xFF2F6FED);
      case 'checked_in':
      case 'checked-in':
        return const Color(0xFF168A62);
      case 'completed':
      case 'checked_out':
      case 'checked-out':
        return const Color(0xFF55705F);
      case 'cancelled':
        return const Color(0xFFC63F4C);
      default:
        return const Color(0xFF99721B);
    }
  }
}

class _ListSectionHeader extends StatelessWidget {
  const _ListSectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF252633),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
}

class _TodayEmptyState extends StatelessWidget {
  const _TodayEmptyState();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F9F6),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFD9ECE4)),
        ),
        child: Row(
          children: [
            const Icon(Icons.event_available_rounded, color: Color(0xFF168A62)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'No visits scheduled for today.',
                style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
              ),
            ),
          ],
        ),
      );
}

class _VisitListMessage extends StatelessWidget {
  const _VisitListMessage({
    required this.message,
    required this.actionLabel,
    required this.onPressed,
  });

  final String message;
  final String actionLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          children: [
            Text(message, textAlign: TextAlign.center),
            TextButton(onPressed: onPressed, child: Text(actionLabel)),
          ],
        ),
      );
}

String _formatVisitDate(String value) {
  final date = DateTime.tryParse(value);
  if (date == null) return value;
  return DateFormat('dd MMMM yyyy', 'en').format(date);
}

String _formatVisitTime(String? value) {
  if (value == null || value.isEmpty) return '—';
  final time = RegExp(r'(?:T|\s)(\d{2}):(\d{2})').firstMatch(value);
  if (time != null) return '${time.group(1)}:${time.group(2)}';
  return value;
}

class _VisitInfo extends StatelessWidget {
  const _VisitInfo({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
          ),
        ),
      ],
    );
  }
}

class _VisitStatus extends StatelessWidget {
  const _VisitStatus({required this.status, required this.color});

  final String status;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final label = status
        .split(RegExp(r'[_\s-]+'))
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
