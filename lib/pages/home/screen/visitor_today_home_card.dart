import 'dart:async';

import 'package:fl_mhis_hr/models/v2/visitor.dart';
import 'package:fl_mhis_hr/pages/visitor/bloc/visitor_bloc.dart';
import 'package:fl_mhis_hr/pages/visitor/library/visitor_date_time.dart';
import 'package:material_ui/material_ui.dart';
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
    _loadHome();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VisitorBloc, VisitorState>(
      builder: (context, state) {
        final home = state.visitorHome;
        final invitation = home.invitation;
        final monitoring = home.monitoring;
        final now = _now();
        _scheduleDepartureRefresh([invitation, monitoring], now);

        if (invitation == null && monitoring == null && home.error == null) {
          return const SizedBox.shrink();
        }

        final selectedTab = _selectedTab ??
            (invitation != null
                ? VisitorListType.invitations
                : monitoring != null
                    ? VisitorListType.monitoring
                    : VisitorListType.invitations);
        final visit = selectedTab == VisitorListType.invitations
            ? invitation
            : monitoring;
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
                        count: invitation == null ? 0 : 1,
                        selected: selectedTab == VisitorListType.invitations,
                        onTap: () => setState(
                            () => _selectedTab = VisitorListType.invitations),
                      ),
                      _VisitorTab(
                        label: 'Monitoring',
                        count: monitoring == null ? 0 : 1,
                        selected: selectedTab == VisitorListType.monitoring,
                        onTap: () => setState(
                            () => _selectedTab = VisitorListType.monitoring),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                if (home.loading && visit == null)
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (home.error != null && visit == null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            home.error!,
                            style: const TextStyle(
                              color: Color(0xFFB42318),
                              fontSize: 12,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: _loadHome,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                else if (visit == null)
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
                else
                  _VisitSummary(
                    visit: visit,
                    monitoring: selectedTab == VisitorListType.monitoring,
                  ),
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

  DateTime _now() => widget.clock?.call() ?? DateTime.now();

  void _loadHome() {
    if (!mounted) return;
    context.read<VisitorBloc>().add(const LoadVisitorHome());
  }

  void _scheduleDepartureRefresh(List<Visit?> visits, DateTime now) {
    DateTime? nextDeparture;
    for (final visit in visits.whereType<Visit>()) {
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
      _loadHome();
    });
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
                monitoring && visit.host.isNotEmpty
                    ? visit.host
                    : visit.visitor,
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
                        ? 'Arrival time TBD'
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
    final date = value == null ? null : visitorJakartaDateTime(value);
    if (date == null) return null;
    return '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
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
        Icon(icon, size: 14, color: const Color(0xFF777D8A)),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF777D8A)),
        ),
      ],
    );
  }
}
