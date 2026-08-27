import 'dart:async';

import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/models/v2/models.dart';
import 'package:fl_mhis_hr/pages/request_approval/bloc/request_approval_bloc.dart';
import 'package:fl_mhis_hr/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:jiffy/jiffy.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AllTimeoffScreen extends StatefulWidget {
  const AllTimeoffScreen({super.key});

  @override
  State<AllTimeoffScreen> createState() => _AllTimeoffScreenState();
}

class _AllTimeoffScreenState extends State<AllTimeoffScreen> {
  Timer? _searchTimer;
  final _searchController = TextEditingController();
  String _status = 'pending';
  List<int> _branchIds = [];
  List<int> _organizationIds = [];
  List<int> _levelIds = [];
  List<int> _positionIds = [];
  String _currentStep = 'all';
  int? _typeId;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    context.read<RequestApprovalBloc>().add(
          const OnInitAllTimeoff({'page': 1, 'per_page': 20}),
        );
    context.read<RequestApprovalBloc>().add(const OnInitAllTimeoffFilters());
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _searchRequests(String value) {
    _searchTimer?.cancel();
    _searchTimer = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      _loadRequests(value.trim());
    });
  }

  void _loadRequests(String requesterName) {
    context.read<RequestApprovalBloc>().add(OnInitAllTimeoff({
          'page': 1,
          'per_page': 20,
          'status': _status,
          if (requesterName.isNotEmpty) 'requester_name': requesterName,
          if (_branchIds.isNotEmpty) 'branch': _branchIds,
          if (_organizationIds.isNotEmpty) 'organization': _organizationIds,
          if (_levelIds.isNotEmpty) 'level': _levelIds,
          if (_positionIds.isNotEmpty) 'position': _positionIds,
          if (_currentStep != 'all') 'current_step': _currentStep,
          if (_typeId != null) 'type': _typeId,
          if (_startDate != null) 'start_date': _dateValue(_startDate!),
          if (_endDate != null) 'end_date': _dateValue(_endDate!),
        }));
  }

  String _dateValue(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  Future<void> _showFilterDialog() async {
    var status = _status;
    var branchIds = List<int>.from(_branchIds);
    var organizationIds = List<int>.from(_organizationIds);
    var levelIds = List<int>.from(_levelIds);
    var positionIds = List<int>.from(_positionIds);
    var currentStep = _currentStep;
    var typeId = _typeId;
    var startDate = _startDate;
    var endDate = _endDate;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) =>
          BlocBuilder<RequestApprovalBloc, RequestApprovalState>(
        builder: (context, state) {
          if (state.isFilterLoading) {
            return const AlertDialog(
              content: SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator()),
              ),
            );
          }
          if (state.isFilterError) {
            return AlertDialog(
              title: const Text('Filter requests'),
              content: const Text('Unable to load filter options.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Close'),
                ),
              ],
            );
          }

          return AlertDialog(
            title: const Text('Filter requests'),
            content: StatefulBuilder(
              builder: (context, setDialogState) => SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: status,
                      decoration: const InputDecoration(labelText: 'Status'),
                      items: const [
                        DropdownMenuItem(
                            value: 'all', child: Text('All statuses')),
                        DropdownMenuItem(
                            value: 'pending', child: Text('Pending')),
                        DropdownMenuItem(
                            value: 'approved', child: Text('Approved')),
                        DropdownMenuItem(
                            value: 'rejected', child: Text('Rejected')),
                      ],
                      onChanged: (value) =>
                          setDialogState(() => status = value ?? 'all'),
                    ),
                    _multiSelectField(
                        'Branch',
                        state.branches,
                        branchIds,
                        (item) => item.name ?? '--',
                        (item) => item.id,
                        (value) => setDialogState(() => branchIds = value)),
                    _multiSelectField(
                        'Organization',
                        state.organizations,
                        organizationIds,
                        (item) => item.name ?? '--',
                        (item) => item.id,
                        (value) =>
                            setDialogState(() => organizationIds = value)),
                    _multiSelectField(
                        'Level',
                        state.jobLevels,
                        levelIds,
                        (item) => item.name ?? '--',
                        (item) => item.id,
                        (value) => setDialogState(() => levelIds = value)),
                    _multiSelectField(
                        'Position',
                        state.jobPositions,
                        positionIds,
                        (item) => item.name ?? '--',
                        (item) => item.id,
                        (value) => setDialogState(() => positionIds = value)),
                    DropdownButtonFormField<int?>(
                      initialValue: typeId,
                      decoration:
                          const InputDecoration(labelText: 'Time-off type'),
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text('All time-off types'),
                        ),
                        ...state.timeoffs.map(
                          (timeoff) => DropdownMenuItem<int?>(
                            value: timeoff.id,
                            child: Text(timeoff.name ?? '--'),
                          ),
                        ),
                      ],
                      onChanged: (value) =>
                          setDialogState(() => typeId = value),
                    ),
                    _dateField(
                      context,
                      'Start date',
                      startDate,
                      (date) => setDialogState(() => startDate = date),
                    ),
                    _dateField(
                      context,
                      'End date',
                      endDate,
                      (date) => setDialogState(() => endDate = date),
                    ),
                    DropdownButtonFormField<String>(
                      initialValue: currentStep,
                      decoration:
                          const InputDecoration(labelText: 'Current step'),
                      items: const [
                        DropdownMenuItem(
                            value: 'all', child: Text('All steps')),
                        DropdownMenuItem(value: '1', child: Text('Step 1')),
                        DropdownMenuItem(value: '2', child: Text('Step 2')),
                        DropdownMenuItem(value: '3', child: Text('Step 3')),
                      ],
                      onChanged: (value) =>
                          setDialogState(() => currentStep = value ?? 'all'),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _status = 'all';
                    _branchIds = [];
                    _organizationIds = [];
                    _levelIds = [];
                    _positionIds = [];
                    _currentStep = 'all';
                    _typeId = null;
                    _startDate = null;
                    _endDate = null;
                  });
                  Navigator.pop(dialogContext);
                  _loadRequests(_searchController.text.trim());
                },
                child: const Text('Clear'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _status = status;
                    _branchIds = branchIds;
                    _organizationIds = organizationIds;
                    _levelIds = levelIds;
                    _positionIds = positionIds;
                    _currentStep = currentStep;
                    _typeId = typeId;
                    _startDate = startDate;
                    _endDate = endDate;
                  });
                  Navigator.pop(dialogContext);
                  _loadRequests(_searchController.text.trim());
                },
                child: const Text('Apply'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _dateField(
    BuildContext context,
    String label,
    DateTime? value,
    ValueChanged<DateTime?> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: TextFormField(
        readOnly: true,
        controller: TextEditingController(
          text: value == null ? '' : _dateValue(value),
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: 'Select $label'.toLowerCase(),
          suffixIcon: value == null
              ? const Icon(Icons.calendar_today_outlined)
              : IconButton(
                  tooltip: 'Clear $label',
                  onPressed: () => onChanged(null),
                  icon: const Icon(Icons.clear),
                ),
        ),
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: value ?? DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );
          if (date != null) onChanged(date);
        },
      ),
    );
  }

  Widget _multiSelectField<T>(
    String label,
    List<T> items,
    List<int> selectedIds,
    String Function(T) getName,
    int? Function(T) getId,
    ValueChanged<List<int>> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: InkWell(
          onTap: () async {
            final selected = Set<int>.from(selectedIds);
            final result = await showDialog<Set<int>>(
              context: context,
              builder: (context) => StatefulBuilder(
                builder: (context, setState) => AlertDialog(
                  title: Text('Select $label'),
                  content: SizedBox(
                    width: double.maxFinite,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: items.map((item) {
                          final id = getId(item);
                          return CheckboxListTile(
                            value: id != null && selected.contains(id),
                            title: Text(getName(item)),
                            onChanged: id == null
                                ? null
                                : (value) => setState(() {
                                      if (value == true) {
                                        selected.add(id);
                                      } else {
                                        selected.remove(id);
                                      }
                                    }),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => setState(selected.clear),
                      child: const Text('All'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, selected),
                      child: const Text('Done'),
                    ),
                  ],
                ),
              ),
            );
            if (result != null) onChanged(result.toList());
          },
          child: Row(
            children: [
              Expanded(
                child: Text(selectedIds.isEmpty
                    ? 'All ${label.toLowerCase()}'
                    : '${selectedIds.length} selected'),
              ),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteshade,
      appBar: AppBar(
        backgroundColor: AppColors.whiteshade,
        foregroundColor: AppColors.dark,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text(
          'Time off requests',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.pushNamed('timeoff'),
        backgroundColor: AppColors.dark,
        icon: const FaIcon(FontAwesomeIcons.plus, color: Colors.white),
        label: const Text('Request',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: _searchRequests,
                      decoration: InputDecoration(
                        hintText: 'Search employee name or ID',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(28),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(28),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Filter',
                    onPressed: _showFilterDialog,
                    icon: const Icon(Icons.filter_alt_outlined, size: 28),
                    color: AppColors.blackshade,
                  ),
                ],
              ),
            ),
            BlocBuilder<RequestApprovalBloc, RequestApprovalState>(
              builder: (context, state) {
                final total = state.allTimeoffPagination?.total ?? 0;
                return Container(
                  margin: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF4DC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_rounded,
                          color: Color(0xFFE87518)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'There are $total requests awaiting approval.',
                          style: const TextStyle(
                              fontSize: 14, color: AppColors.dark),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            Expanded(
              child: BlocBuilder<RequestApprovalBloc, RequestApprovalState>(
                builder: (context, state) {
                  if (state.isLoading) return const LoadingWidget();
                  if (state.isError) {
                    return MessageState(
                      message: state.errorMessage ?? 'Failed to load requests.',
                      onRetry: () =>
                          _loadRequests(_searchController.text.trim()),
                    );
                  }

                  final requests = state.allTimeoffRequests;

                  if (requests.isEmpty) {
                    return const MessageState(
                        message: 'No time off requests found.');
                  }

                  final groups = <String, List<ApprovalRequest>>{};
                  for (final request in requests) {
                    final date = ApprovalRequestData.parseDynamicDate(
                      ApprovalRequestData.resolveRequestDateValue(request),
                    );
                    final key = date == null
                        ? 'Unknown date'
                        : Jiffy.parseFromDateTime(date)
                            .format(pattern: 'MMM yyyy');
                    groups.putIfAbsent(key, () => []).add(request);
                  }

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    children: groups.entries
                        .expand((entry) => [
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 12, bottom: 8),
                                child: Text(
                                  entry.key,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.blackshade,
                                  ),
                                ),
                              ),
                              ...entry.value.map(
                                (request) => _RequestTile(request: request),
                              ),
                            ])
                        .toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RequestTile extends StatelessWidget {
  final ApprovalRequest request;
  const _RequestTile({required this.request});

  @override
  Widget build(BuildContext context) {
    final name = request.requester?.personal?.fullname ??
        request.requester?.user?.name ??
        'Unknown employee';
    final employeeId = request.requester?.idTalenta ??
        request.requester?.id?.toString() ??
        '--';
    final date = ApprovalRequestData.parseDynamicDate(
      ApprovalRequestData.resolveRequestDateValue(request),
    );
    final dateText = date == null
        ? '--'
        : Jiffy.parseFromDateTime(date).format(pattern: 'EEE, dd MMM yyyy');

    return InkWell(
      onTap: request.id == null
          ? null
          : () => context.pushNamed(
                'timeoff-detail',
                extra: {'requestId': request.id},
              ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Avatar(name: name, url: request.requester?.personal?.avatar),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$name ($employeeId)',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 5),
                  Text('Time off request for ${request.type?.name ?? '--'}',
                      style: const TextStyle(color: AppColors.blackshade)),
                  const SizedBox(height: 5),
                  Text('• $dateText',
                      style: const TextStyle(color: AppColors.blackshade)),
                  Text(
                    '• Reason: ${request.note?.trim().isNotEmpty == true ? request.note : '--'}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.blackshade),
                  ),
                  const SizedBox(height: 7),
                  _StatusChip(status: request.status),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String name;
  final String? url;
  const _Avatar({required this.name, this.url});

  @override
  Widget build(BuildContext context) {
    final initials = name.trim().isEmpty ? 'U' : name.trim()[0].toUpperCase();
    return CircleAvatar(
      radius: 23,
      backgroundColor: AppColors.secondary.withValues(alpha: 0.12),
      backgroundImage: (url ?? '').isEmpty ? null : NetworkImage(url!),
      child: (url ?? '').isEmpty
          ? Text(initials,
              style: const TextStyle(
                  color: AppColors.secondary, fontWeight: FontWeight.w700))
          : null,
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String? status;
  const _StatusChip({this.status});

  @override
  Widget build(BuildContext context) {
    final color = Common.statusColor(status);
    final label = (status ?? 'pending').toLowerCase() == 'pending'
        ? 'Awaiting approval'
        : (status ?? '--').replaceAll('_', ' ');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        label[0].toUpperCase() + label.substring(1).toLowerCase(),
        style: TextStyle(color: color, fontSize: 12),
      ),
    );
  }
}
