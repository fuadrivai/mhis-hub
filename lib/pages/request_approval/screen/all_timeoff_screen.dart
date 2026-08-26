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

  @override
  void initState() {
    super.initState();
    context.read<RequestApprovalBloc>().add(
          const OnInitAllTimeoff({'page': 1, 'per_page': 20}),
        );
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    super.dispose();
  }

  void _searchRequests(String value) {
    _searchTimer?.cancel();
    _searchTimer = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      context.read<RequestApprovalBloc>().add(
            OnInitAllTimeoff({
              'page': 1,
              'per_page': 20,
              'requester_name': value.trim(),
            }),
          );
    });
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
                    onPressed: () {},
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
                    return Center(
                      child:
                          Text(state.errorMessage ?? 'Unable to load requests'),
                    );
                  }

                  final requests = state.allTimeoffRequests;

                  if (requests.isEmpty) {
                    return const Center(
                        child: Text('No time off requests found.'));
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
    final label = (status ?? 'pending').toLowerCase() == 'pending'
        ? 'Awaiting approval'
        : (status ?? '--').replaceAll('_', ' ');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.amber.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        label[0].toUpperCase() + label.substring(1).toLowerCase(),
        style: const TextStyle(color: Color(0xFF9A6728), fontSize: 12),
      ),
    );
  }
}
