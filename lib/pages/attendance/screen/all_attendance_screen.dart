import 'dart:async';

import 'package:fl_mhis_hr/library/app_colors.dart';
import 'package:fl_mhis_hr/models/v2/models.dart';
import 'package:fl_mhis_hr/pages/attendance/bloc/attendance_bloc.dart';
import 'package:fl_mhis_hr/service/api.dart';
import 'package:fl_mhis_hr/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

class AllAttendanceScreen extends StatefulWidget {
  const AllAttendanceScreen({super.key});

  @override
  State<AllAttendanceScreen> createState() => _AllAttendanceScreenState();
}

class _AllAttendanceScreenState extends State<AllAttendanceScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  DateTime _selectedDate = DateTime.now();
  String _searchQuery = '';
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    context.read<AttendanceBloc>().add(OnGetAll(_requestParams()));
    _scrollController.addListener(_onScroll);
    _searchController.addListener(() {
      final query = _searchController.text.trim().toLowerCase();
      setState(() => _searchQuery = query);
      _searchDebounce?.cancel();
      _searchDebounce = Timer(const Duration(milliseconds: 400), _reload);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final horizontalPadding = screenWidth < 380 ? 16.0 : 24.0;
    return Scaffold(
      backgroundColor: const Color(0xFFF3F0EE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3F0EE),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back, color: AppColors.lightblue),
        ),
        title: InkWell(
          onTap: _selectDate,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat('dd MMM yyyy').format(_selectedDate),
                  style: TextStyle(
                    color: Color(0xFF292B30),
                    fontSize: screenWidth < 600 ? 17 : 19,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(Icons.arrow_drop_down, color: Color(0xFF292B30)),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
                horizontalPadding, 4, horizontalPadding, 18),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search employee name or ID',
                hintStyle: TextStyle(
                  color: Color(0xFF87909D),
                  fontSize: screenWidth < 600 ? 14 : 16,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  size: screenWidth < 600 ? 26 : 30,
                  color: Color(0xFF738091),
                ),
                suffixIcon: _searchQuery.isEmpty
                    ? null
                    : IconButton(
                        onPressed: _searchController.clear,
                        icon: const Icon(Icons.close),
                      ),
                filled: true,
                fillColor: AppColors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(38),
                  borderSide: const BorderSide(color: Color(0xFFD5D5D5)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(38),
                  borderSide: const BorderSide(color: Color(0xFFD5D5D5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(38),
                  borderSide: const BorderSide(color: AppColors.lightblue),
                ),
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<AttendanceBloc, AttendanceState>(
              builder: (context, state) {
                if (state.historyLoading) return const LoadingWidget();
                if (state.isError) {
                  return _MessageState(
                    message: state.errorMessage ?? 'Unable to load attendance',
                    onRetry: _reload,
                  );
                }
                final records = _filteredRecords(
                  state.histories ?? _attendanceRecords(state),
                );
                if (records.isEmpty) {
                  return const _MessageState(message: 'No attendance found');
                }
                return RefreshIndicator(
                  onRefresh: () async => _reload(),
                  child: ListView.separated(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: records.length + (state.loadMore ? 1 : 0),
                    separatorBuilder: (_, __) => const Divider(
                      height: 1,
                      thickness: 1,
                      indent: 10,
                      endIndent: 10,
                      color: Color(0xFFD0D0D0),
                    ),
                    itemBuilder: (context, index) {
                      if (index == records.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      return _AttendanceTile(attendance: records[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Attendance> _filteredRecords(List<Attendance> records) {
    if (_searchQuery.isEmpty) return records;
    return records.where((attendance) {
      final employee = attendance.employee;
      final values = [
        attendance.fullname,
        attendance.employeeId?.toString(),
        employee?.idTalenta,
        employee?.personal?.fullname,
        employee?.employment?.jobPositionName,
      ];
      return values.any(
        (value) => value?.toLowerCase().contains(_searchQuery) ?? false,
      );
    }).toList();
  }

  List<Attendance> _attendanceRecords(AttendanceState state) {
    return (state.serverside?.data ?? [])
        .whereType<Map<String, dynamic>>()
        .map(Attendance.fromJson)
        .toList();
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date == null || !mounted) return;
    setState(() => _selectedDate = date);
    _reload();
  }

  void _reload() {
    context.read<AttendanceBloc>().add(OnGetAll(_requestParams()));
  }

  Map<String, dynamic> _requestParams({int? page}) {
    return {
      'date': DateFormat('yyyy-MM-dd').format(_selectedDate),
      if (_searchQuery.isNotEmpty) 'search': _searchQuery,
      if (page != null) 'page': page,
    };
  }

  void _onScroll() {
    if (!_scrollController.hasClients ||
        _scrollController.position.extentAfter > 300) {
      return;
    }

    final state = context.read<AttendanceBloc>().state;
    final nextPage = (state.serverside?.currentPage ?? 1) + 1;
    if (!state.loadMore && state.serverside?.nextPageUrl != null) {
      context
          .read<AttendanceBloc>()
          .add(OnLoadMore(_requestParams(page: nextPage)));
    }
  }
}

class _AttendanceTile extends StatefulWidget {
  const _AttendanceTile({required this.attendance});

  final Attendance attendance;

  @override
  State<_AttendanceTile> createState() => _AttendanceTileState();
}

class _AttendanceTileState extends State<_AttendanceTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isCompact = screenWidth < 600;
    final attendance = widget.attendance;
    final employee = attendance.employee;
    final name = attendance.fullname ?? employee?.personal?.fullname ?? '-';
    final employeeId =
        employee?.idTalenta ?? attendance.employeeId?.toString() ?? '-';
    final position = employee?.employment?.jobPositionName ?? '-';
    final hasAttendance =
        attendance.checkIn != null || attendance.checkOut != null;

    return Container(
      color: AppColors.white,
      padding: EdgeInsets.fromLTRB(isCompact ? 12 : 20, isCompact ? 8 : 12,
          isCompact ? 8 : 16, isCompact ? 8 : 12),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _Avatar(
                  url: employee?.personal?.avatar, radius: isCompact ? 22 : 26),
              SizedBox(width: isCompact ? 8 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 17, color: Color(0xFF292B30)),
                    ),
                    Text(
                      '$employeeId | $position',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 14, color: Color(0xFF737983)),
                    ),
                    if (hasAttendance)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            Expanded(
                              child: _TimeValue(
                                icon: Icons.access_time,
                                value: attendance.checkIn,
                                color: const Color(0xFF218D70),
                                compact: isCompact,
                              ),
                            ),
                            Expanded(
                              child: _TimeValue(
                                icon: Icons.access_time,
                                value: attendance.checkOut,
                                color: AppColors.lightblue,
                                compact: isCompact,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      const Padding(
                        padding: EdgeInsets.only(top: 3),
                        child: Text(
                          'No attendance yet',
                          style:
                              TextStyle(fontSize: 14, color: Color(0xFF737983)),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => setState(() => _isExpanded = !_isExpanded),
                icon: Icon(
                  _isExpanded
                      ? Icons.remove_circle_outline
                      : Icons.add_circle_outline,
                  size: isCompact ? 26 : 30,
                ),
                color: const Color(0xFF738091),
                tooltip: _isExpanded
                    ? 'Hide attendance details'
                    : 'Show attendance details',
              ),
            ],
          ),
          if (_isExpanded) _AttendanceDetails(attendance: attendance),
        ],
      ),
    );
  }
}

class _AttendanceDetails extends StatelessWidget {
  const _AttendanceDetails({required this.attendance});

  final Attendance attendance;

  @override
  Widget build(BuildContext context) {
    final schedule = attendance.shiftName == null ||
            attendance.shiftName!.isEmpty
        ? '-'
        : '${attendance.shiftName} (${attendance.scheduleIn ?? '-'} - ${attendance.scheduleOut ?? '-'})';

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 12, 4, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            schedule,
            style: const TextStyle(
              color: Color(0xFF303238),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          _AttendanceDetailRow(
            label: 'Clock in',
            value: attendance.checkIn,
            onTap: attendance.checkIn == null
                ? null
                : () => _showAttendanceLog(context, 'check_in'),
          ),
          _AttendanceDetailRow(
            label: 'Clock out',
            value: attendance.checkOut,
            onTap: attendance.checkOut == null
                ? null
                : () => _showAttendanceLog(context, 'check_out'),
          ),
          const SizedBox(height: 4),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'View all attendance data',
              style: TextStyle(
                color: AppColors.lightblue,
                fontSize: 14,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAttendanceLog(BuildContext context, String type) {
    final isClockIn = type == 'check_in';
    final log = AttendanceLog(
      type: type,
      fullname: attendance.fullname ?? attendance.employee?.personal?.fullname,
      shiftName: attendance.shiftName,
      photo: isClockIn ? attendance.checkInPhoto : attendance.checkOutPhoto,
      latitude:
          isClockIn ? attendance.checkInLatitude : attendance.checkOutLatitude,
      longitude: isClockIn
          ? attendance.checkInLongitude
          : attendance.checkOutLongitude,
      radius: isClockIn ? attendance.checkInRadius : attendance.checkOutRadius,
      clockDatetime: isClockIn ? attendance.checkIn : attendance.checkOut,
      clockDate: attendance.date,
      time: isClockIn ? attendance.checkIn : attendance.checkOut,
    );

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AttendanceLogSheet(
        log: log,
        scheduleIn: attendance.scheduleIn,
        scheduleOut: attendance.scheduleOut,
      ),
    );
  }
}

class _AttendanceDetailRow extends StatelessWidget {
  const _AttendanceDetailRow(
      {required this.label, required this.value, this.onTap});

  final String label;
  final String? value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 42,
        child: Row(
          children: [
            const Icon(Icons.location_on_outlined,
                color: Color(0xFF738091), size: 24),
            const SizedBox(width: 12),
            SizedBox(
              width: 64,
              child: Text(
                value ?? '-',
                style: const TextStyle(fontSize: 14, color: Color(0xFF454951)),
              ),
            ),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 14, color: Color(0xFF303238)),
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF738091), size: 28),
          ],
        ),
      ),
    );
  }
}

class _AttendanceLogSheet extends StatelessWidget {
  const _AttendanceLogSheet({
    required this.log,
    required this.scheduleIn,
    required this.scheduleOut,
  });

  final AttendanceLog log;
  final String? scheduleIn;
  final String? scheduleOut;

  @override
  Widget build(BuildContext context) {
    final target = log.latitude != null && log.longitude != null
        ? LatLng(log.latitude!, log.longitude!)
        : null;
    final title =
        log.type == 'check_in' ? 'Clock in details' : 'Clock out details';
    final schedule = log.shiftName == null || log.shiftName!.isEmpty
        ? '-'
        : '${log.shiftName}\n${scheduleIn ?? '-'} - ${scheduleOut ?? '-'}';

    return SafeArea(
      child: Container(
        constraints: const BoxConstraints(maxHeight: 700),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 72,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8793A2),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 18, 12, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(title,
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w700)),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close',
                          style: TextStyle(
                              color: AppColors.lightblue, fontSize: 16)),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 190,
                child: Row(
                  children: [
                    Expanded(child: _LogMap(target: target)),
                    Expanded(child: _LogPhoto(photo: log.photo)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 16, 22, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LogField(label: 'Shift', value: schedule),
                    _LogField(
                      label: log.type == 'check_in' ? 'Clock in' : 'Clock out',
                      value: _dateTimeLabel(log),
                    ),
                    _LogField(
                      label: 'Coordinate',
                      value: target == null
                          ? '-'
                          : '${target.latitude},${target.longitude}',
                    ),
                    _LogField(
                      label: 'Radius',
                      value: log.radius == null
                          ? '-'
                          : '${log.radius!.toStringAsFixed(2)} m',
                    ),
                    const _LogField(label: 'Notes', value: '-'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _dateTimeLabel(AttendanceLog value) {
    final raw = value.clockDatetime ?? value.time;
    if (raw == null || raw.isEmpty) return '-';
    try {
      return DateFormat('EEE, dd MMM yyyy HH:mm')
          .format(DateTime.parse(raw).toLocal());
    } catch (_) {
      return value.clockDate == null ? raw : '${value.clockDate} at $raw';
    }
  }
}

class _LogMap extends StatelessWidget {
  const _LogMap({required this.target});

  final LatLng? target;

  @override
  Widget build(BuildContext context) {
    if (target == null) {
      return const ColoredBox(
        color: Color(0xFFEFF2F5),
        child: Center(child: Icon(Icons.location_off_outlined, size: 36)),
      );
    }
    return GoogleMap(
      initialCameraPosition: CameraPosition(target: target!, zoom: 16),
      markers: {
        Marker(
            markerId: const MarkerId('attendance_detail'), position: target!),
      },
      zoomControlsEnabled: false,
      myLocationButtonEnabled: false,
    );
  }
}

class _LogPhoto extends StatelessWidget {
  const _LogPhoto({required this.photo});

  final String? photo;

  @override
  Widget build(BuildContext context) {
    if (photo == null || photo!.isEmpty) {
      return const ColoredBox(
        color: Color(0xFFEFF2F5),
        child: Center(child: Icon(Icons.person_outline, size: 36)),
      );
    }
    return Image.network(
      '${Api.url}/storage/$photo',
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const ColoredBox(
        color: Color(0xFFEFF2F5),
        child: Center(child: Icon(Icons.image_not_supported_outlined)),
      ),
    );
  }
}

class _LogField extends StatelessWidget {
  const _LogField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(color: Color(0xFF7A869A), fontSize: 13)),
          const SizedBox(height: 3),
          Text(value,
              style: const TextStyle(color: Color(0xFF303238), fontSize: 16)),
        ],
      ),
    );
  }
}

class _TimeValue extends StatelessWidget {
  const _TimeValue(
      {required this.icon,
      required this.value,
      required this.color,
      this.compact = false});

  final IconData icon;
  final String? value;
  final Color color;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: compact ? 18 : 22),
        SizedBox(width: compact ? 3 : 5),
        Text(
          value ?? '-',
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: value == null ? const Color(0xFF737983) : color,
            fontSize: compact ? 12 : 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({this.url, this.radius = 30});

  final String? url;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final imageUrl =
        url == null || url!.isEmpty ? null : '${Api.url}/storage/$url';
    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFFE9E9E9),
      backgroundImage: imageUrl == null ? null : NetworkImage(imageUrl),
      child: imageUrl == null
          ? Icon(Icons.person, size: radius, color: const Color(0xFF9AA0A8))
          : null,
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          if (onRetry != null) ...[
            const SizedBox(height: 12),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ],
      ),
    );
  }
}
