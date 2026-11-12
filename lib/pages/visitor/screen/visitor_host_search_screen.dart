import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/models/v2/branch.dart';
import 'package:fl_mhis_hr/models/v2/job_level.dart';
import 'package:fl_mhis_hr/models/v2/job_position.dart';
import 'package:fl_mhis_hr/models/v2/visitor.dart';
import 'package:fl_mhis_hr/pages/visitor/bloc/visitor_bloc.dart';
import 'package:fl_mhis_hr/widget/themed_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VisitorHostSearchScreen extends StatefulWidget {
  const VisitorHostSearchScreen({super.key});

  @override
  State<VisitorHostSearchScreen> createState() =>
      _VisitorHostSearchScreenState();
}

class _VisitorHostSearchScreenState extends State<VisitorHostSearchScreen> {
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<VisitorBloc>()
      ..add(const LoadVisitorHostFilters())
      ..add(const SearchVisitorHosts(query: '', reset: true));
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _searchHosts() => context.read<VisitorBloc>().add(SearchVisitorHosts(
        query: _search.text.trim(),
        reset: true,
      ));

  void _load() => context.read<VisitorBloc>().add(const SearchVisitorHosts());

  Future<void> _showFilters() async {
    final bloc = context.read<VisitorBloc>();
    final activeFilters = bloc.state.hosts.filters;
    int? branch = activeFilters['branch'];
    int? level = activeFilters['level'];
    int? position = activeFilters['position'];

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Filter employees'),
          content: SizedBox(
            width: 360,
            child: BlocBuilder<VisitorBloc, VisitorState>(
              builder: (context, state) {
                final options = state.hostFilters.options;
                if (state.hostFilters.loading && options == null) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (state.hostFilters.error != null && options == null) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Unable to load filter options: ${state.hostFilters.error}',
                        textAlign: TextAlign.center,
                      ),
                      TextButton(
                        onPressed: () =>
                            bloc.add(const LoadVisitorHostFilters()),
                        child: const Text('Retry'),
                      ),
                    ],
                  );
                }
                if (options == null) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _filterDropdown<Branch>(
                        label: 'Branch',
                        options: options.branches,
                        selectedId: branch,
                        idOf: (item) => item.id,
                        nameOf: (item) => item.name,
                        onChanged: (id) => setDialogState(() => branch = id),
                      ),
                      const SizedBox(height: 12),
                      _filterDropdown<JobPosition>(
                        label: 'Position',
                        options: options.positions,
                        selectedId: position,
                        idOf: (item) => item.id,
                        nameOf: (item) => item.name,
                        onChanged: (id) => setDialogState(() => position = id),
                      ),
                      const SizedBox(height: 12),
                      _filterDropdown<JobLevel>(
                        label: 'Level',
                        options: options.levels,
                        selectedId: level,
                        idOf: (item) => item.id,
                        nameOf: (item) => item.name,
                        onChanged: (id) => setDialogState(() => level = id),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => setDialogState(() {
                branch = null;
                position = null;
                level = null;
              }),
              child: const Text('Clear'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                bloc.add(SearchVisitorHosts(
                  query: _search.text.trim(),
                  filters: {
                    if (branch != null) 'branch': branch,
                    if (position != null) 'position': position,
                    if (level != null) 'level': level,
                  },
                  reset: true,
                ));
              },
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterDropdown<T>({
    required String label,
    required List<T> options,
    required int? selectedId,
    required int? Function(T) idOf,
    required String? Function(T) nameOf,
    required ValueChanged<int?> onChanged,
  }) {
    return DropdownButtonFormField<int?>(
      initialValue: selectedId,
      isExpanded: true,
      decoration: InputDecoration(labelText: label),
      items: [
        DropdownMenuItem<int?>(
          value: null,
          child: Text('All ${_pluralLabel(label)}'),
        ),
        ...options.map(
          (item) => DropdownMenuItem<int?>(
            value: idOf(item),
            child: Text(nameOf(item) ?? '--'),
          ),
        ),
      ],
      onChanged: onChanged,
    );
  }

  String _pluralLabel(String label) =>
      {
        'Branch': 'branches',
        'Position': 'positions',
        'Level': 'levels'
      }[label] ??
      label.toLowerCase();

  @override
  Widget build(BuildContext context) {
    return ThemedPage(
      title: 'Select employee',
      subtitle: 'Find the host for this visit',
      onBack: () => Navigator.of(context).pop(),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _search,
                    onSubmitted: (_) => _searchHosts(),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      labelText: 'Employee name',
                      suffixIcon: IconButton(
                        tooltip: 'Search hosts',
                        onPressed: _searchHosts,
                        icon: const Icon(Icons.search),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  height: 56,
                  width: 52,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.danger.withValues(alpha: 0.2)),
                  ),
                  child: IconButton(
                    tooltip: 'Filter employees',
                    onPressed: _showFilters,
                    icon:
                        const Icon(Icons.filter_list, color: AppColors.danger),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<VisitorBloc, VisitorState>(
              builder: (context, state) {
                final hosts = state.hosts;
                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: [
                    if (hosts.filters.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: hosts.filters.entries
                              .map((entry) => Chip(
                                    label: Text(
                                        '${_filterName(entry.key)}: ${_optionName(state.hostFilters.options, entry.key, entry.value)}'),
                                    onDeleted: () {
                                      final filters =
                                          Map<String, int?>.from(hosts.filters)
                                            ..remove(entry.key);
                                      context.read<VisitorBloc>().add(
                                            SearchVisitorHosts(
                                              query: hosts.query,
                                              filters: filters,
                                              reset: true,
                                            ),
                                          );
                                    },
                                  ))
                              .toList(),
                        ),
                      ),
                    if (hosts.loading && hosts.items.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (hosts.error != null && hosts.items.isEmpty)
                      _HostMessage(
                        message: 'Unable to load hosts: ${hosts.error}',
                        actionLabel: 'Retry',
                        onAction: _load,
                      )
                    else if (hosts.items.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 56),
                        child: Center(child: Text('No employees found')),
                      )
                    else ...[
                      for (final host in hosts.items)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _HostCard(
                            host: host,
                            onTap: () => Navigator.of(context).pop(host),
                          ),
                        ),
                      if (hosts.loading)
                        const Center(child: CircularProgressIndicator())
                      else if (hosts.error != null)
                        _HostMessage(
                          message: 'Unable to load more hosts: ${hosts.error}',
                          actionLabel: 'Retry',
                          onAction: _load,
                        )
                      else if (hosts.hasMore)
                        Center(
                          child: TextButton(
                            onPressed: _load,
                            child: const Text('Load more'),
                          ),
                        ),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _filterName(String key) =>
      {'branch': 'Branch', 'position': 'Position', 'level': 'Level'}[key] ??
      key;

  String _optionName(VisitorHostFilters? options, String key, int? id) {
    if (options == null || id == null) return '$id';
    final List<(int?, String?)> items = switch (key) {
      'branch' => options.branches.map((item) => (item.id, item.name)).toList(),
      'position' =>
        options.positions.map((item) => (item.id, item.name)).toList(),
      'level' => options.levels.map((item) => (item.id, item.name)).toList(),
      _ => const <(int?, String?)>[],
    };
    for (final item in items) {
      if (item.$1 == id) return item.$2 ?? '$id';
    }
    return '$id';
  }
}

class _HostCard extends StatelessWidget {
  const _HostCard({required this.host, required this.onTap});

  final VisitorHost host;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final details = <(String, String)>[
      ('Branch', host.branch ?? '-'),
      ('Level', host.level ?? '-'),
      ('Organization', host.organization ?? '-'),
      ('Position', host.position ?? '-'),
    ];
    final avatar = host.avatar;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.danger.withValues(alpha: 0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: avatar != null && avatar.isNotEmpty
                        ? NetworkImage(avatar)
                        : null,
                    onBackgroundImageError:
                        avatar == null || avatar.isEmpty ? null : (_, __) {},
                    child: avatar == null || avatar.isEmpty
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          host.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                        if (host.email?.isNotEmpty == true)
                          _ContactLine(
                              icon: Icons.email_outlined, value: host.email!),
                        if (host.phone?.isNotEmpty == true)
                          _ContactLine(
                              icon: Icons.phone_outlined, value: host.phone!),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.black45),
                ],
              ),
              if (details.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: details
                      .map((detail) =>
                          _HostBadge(label: detail.$1, value: detail.$2))
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactLine extends StatelessWidget {
  const _ContactLine({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        children: [
          Icon(icon, size: 13, color: Colors.grey.shade600),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _HostBadge extends StatelessWidget {
  const _HostBadge({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$label: $value',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Colors.grey.shade800, fontSize: 11),
      ),
    );
  }
}

class _HostMessage extends StatelessWidget {
  const _HostMessage({
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Text(message, textAlign: TextAlign.center),
          TextButton(onPressed: onAction, child: Text(actionLabel)),
        ],
      ),
    );
  }
}
