import 'dart:async';

import 'package:fl_mhis_hr/models/v2/visitor.dart';
import 'package:fl_mhis_hr/pages/visitor/bloc/visitor_bloc.dart';
import 'package:fl_mhis_hr/pages/visitor/library/visitor_date_time.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class VisitorTodayHomeCard extends StatefulWidget {
  const VisitorTodayHomeCard({super.key, this.clock});

  final DateTime Function()? clock;

  @override
  State<VisitorTodayHomeCard> createState() => _VisitorTodayHomeCardState();
}

class _VisitorTodayHomeCardState extends State<VisitorTodayHomeCard>
    with WidgetsBindingObserver {
  VisitorListType? _selectedTab;
  Timer? _departureTimer;
  DateTime? _scheduledDeparture;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _departureTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    _departureTimer?.cancel();
    _scheduledDeparture = null;
    _reloadExpiredPages(_now());
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VisitorBloc, VisitorState>(
      builder: (context, state) {
        final invitations = state.homeTodayInvitations;
        final monitoring = state.homeTodayMonitoring;
        final now = _now();
        final invitationVisits = _visitsNotDeparted(invitations.items, now);
        final monitoringVisits = _visitsNotDeparted(monitoring.items, now);
        _scheduleDepartureRefresh(
          [...invitations.items, ...monitoring.items],
          now,
        );
        final hasError = invitations.error != null || monitoring.error != null;
        if (invitationVisits.isEmpty && monitoringVisits.isEmpty && !hasError) {
          return const SizedBox.shrink();
        }

        final selectedTab = _selectedTab ??
            (invitationVisits.isNotEmpty
                ? VisitorListType.invitations
                : monitoringVisits.isNotEmpty
                    ? VisitorListType.monitoring
                    : invitations.error != null
                        ? VisitorListType.invitations
                        : VisitorListType.monitoring);
        final list = selectedTab == VisitorListType.invitations
            ? invitations
            : monitoring;
        final visits = selectedTab == VisitorListType.invitations
            ? invitationVisits
            : monitoringVisits;
        final count = _remainingCount(list, visits);
        final visibleVisits = visits.take(2).toList();
        final colorScheme = Theme.of(context).colorScheme;

        return Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE9EAF0)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0C182230),
                  blurRadius: 16,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Icon(Icons.badge_outlined,
                          color: colorScheme.primary),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Visitor Today',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF20232B),
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Today\'s visits at a glance',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF777D8A),
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => _openVisitor(context, selectedTab),
                      child: const Text('See all'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F7),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Row(
                    children: [
                      _VisitorTab(
                        label: 'Invitations',
                        count: _remainingCount(invitations, invitationVisits),
                        selected: selectedTab == VisitorListType.invitations,
                        onTap: () => setState(
                            () => _selectedTab = VisitorListType.invitations),
                      ),
                      _VisitorTab(
                        label: 'Monitoring',
                        count: _remainingCount(monitoring, monitoringVisits),
                        selected: selectedTab == VisitorListType.monitoring,
                        onTap: () => setState(
                            () => _selectedTab = VisitorListType.monitoring),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                if (visibleVisits.isEmpty && list.error != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            list.error!,
                            style: const TextStyle(
                              color: Color(0xFFB42318),
                              fontSize: 12,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => _retryToday(context, selectedTab),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                else if (visibleVisits.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Center(
                      child: Text(
                        selectedTab == VisitorListType.invitations
                            ? 'No invitations today'
                            : 'No monitoring visits today',
                        style: const TextStyle(
                          color: Color(0xFF777D8A),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  )
                else ...[
                  for (var index = 0;
                      index < visibleVisits.length;
                      index++) ...[
                    if (index > 0) const Divider(height: 20),
                    _VisitSummary(
                      visit: visibleVisits[index],
                      monitoring: selectedTab == VisitorListType.monitoring,
                    ),
                  ],
                  if (count > visibleVisits.length) ...[
                    const Divider(height: 20),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => _openVisitor(context, selectedTab),
                        child: Text(
                            '+${count - visibleVisits.length} more visits'),
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _openVisitor(BuildContext context, VisitorListType type) {
    context.pushNamed(
      'visitor',
      extra: type == VisitorListType.monitoring ? 1 : 0,
    );
  }

  void _retryToday(BuildContext context, VisitorListType type) {
    _loadHomeToday(type, _now());
  }

  DateTime _now() => widget.clock?.call() ?? DateTime.now();

  List<Visit> _visitsNotDeparted(List<Visit> visits, DateTime now) {
    return visits.where((visit) {
      if (visit.status.toLowerCase() == 'cancelled' || visit.checkOut != null) {
        return false;
      }
      final departure =
          visit.departure == null ? null : DateTime.tryParse(visit.departure!);
      return departure != null && departure.isAfter(now);
    }).toList();
  }

  int _remainingCount(VisitorListState<Visit> list, List<Visit> visits) {
    final expiredLoadedItems = list.items.length - visits.length;
    final count = (list.total ?? list.items.length) - expiredLoadedItems;
    return count < 0 ? 0 : count;
  }

  void _scheduleDepartureRefresh(List<Visit> visits, DateTime now) {
    DateTime? nextDeparture;
    for (final visit in visits) {
      if (visit.status.toLowerCase() == 'cancelled' || visit.checkOut != null) {
        continue;
      }
      final departure =
          visit.departure == null ? null : DateTime.tryParse(visit.departure!);
      if (departure != null &&
          departure.isAfter(now) &&
          (nextDeparture == null || departure.isBefore(nextDeparture))) {
        nextDeparture = departure;
      }
    }

    if (nextDeparture == _scheduledDeparture) return;
    _departureTimer?.cancel();
    _scheduledDeparture = nextDeparture;
    if (nextDeparture == null) return;

    _departureTimer = Timer(nextDeparture.difference(now), () {
      _scheduledDeparture = null;
      if (!mounted) return;
      _reloadExpiredPages(_now());
      setState(() {});
    });
  }

  void _reloadExpiredPages(DateTime now) {
    final state = context.read<VisitorBloc>().state;
    final invitations = state.homeTodayInvitations;
    if (!invitations.loading &&
        invitations.total != null &&
        invitations.hasMore &&
        _visitsNotDeparted(invitations.items, now).isEmpty) {
      _loadHomeToday(VisitorListType.invitations, now);
    }
    final monitoring = state.homeTodayMonitoring;
    if (!monitoring.loading &&
        monitoring.total != null &&
        monitoring.hasMore &&
        _visitsNotDeparted(monitoring.items, now).isEmpty) {
      _loadHomeToday(VisitorListType.monitoring, now);
    }
  }

  void _loadHomeToday(VisitorListType type, DateTime now) {
    context.read<VisitorBloc>().add(LoadTodayVisitorList(
          type: type,
          date: visitorDateParameter(now),
          departureAfter: visitorDateTimeParameter(now),
          homeSummary: true,
          reset: true,
        ));
  }
}

class _VisitorTab extends StatelessWidget {
  const _VisitorTab({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            decoration: BoxDecoration(
              color: selected ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              boxShadow: selected
                  ? const [
                      BoxShadow(
                        color: Color(0x10182030),
                        blurRadius: 7,
                        offset: Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected
                          ? const Color(0xFF20232B)
                          : const Color(0xFF777D8A),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: selected
                        ? Theme.of(context).colorScheme.primary.withValues(
                              alpha: 0.1,
                            )
                        : const Color(0xFFE5E7EC),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: selected
                          ? Theme.of(context).colorScheme.primary
                          : const Color(0xFF777D8A),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _VisitSummary extends StatelessWidget {
  const _VisitSummary({required this.visit, required this.monitoring});

  final Visit visit;
  final bool monitoring;

  @override
  Widget build(BuildContext context) {
    final arrival = _arrivalTime(visit.arrival);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: const Color(0xFFF2F3F7),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(
            monitoring
                ? Icons.person_outline
                : Icons.person_pin_circle_outlined,
            size: 19,
            color: const Color(0xFF626A79),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                monitoring ? visit.host : visit.visitor,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF252833),
                ),
              ),
              const SizedBox(height: 5),
              Wrap(
                spacing: 12,
                runSpacing: 4,
                children: [
                  if (monitoring)
                    _VisitMeta(
                      icon: Icons.groups_2_outlined,
                      label: 'Guest: ${visit.visitor}',
                    ),
                  _VisitMeta(
                    icon: Icons.schedule,
                    label: arrival == null
                        ? 'Arrival time unavailable'
                        : 'Arrival $arrival',
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  String? _arrivalTime(String? value) {
    if (value == null || value.isEmpty) return null;
    final match = RegExp(r'T(\d{2}:\d{2})').firstMatch(value);
    if (match != null) return match.group(1);
    return value;
  }
}

class _VisitMeta extends StatelessWidget {
  const _VisitMeta({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: const Color(0xFF818796)),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF777D8A),
            ),
          ),
        ),
      ],
    );
  }
}
