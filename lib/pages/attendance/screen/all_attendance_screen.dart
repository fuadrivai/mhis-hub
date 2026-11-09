import 'dart:async';

import 'package:fl_mhis_hr/library/app_colors.dart';
import 'package:fl_mhis_hr/models/v2/models.dart';
import 'package:fl_mhis_hr/pages/attendance/bloc/attendance_bloc.dart';
import 'package:fl_mhis_hr/service/api.dart';
import 'package:fl_mhis_hr/widget/themed_page.dart';
import 'package:fl_mhis_hr/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

class AllAttendanceScreen extends StatefulWidget {
  const AllAttendanceScreen({super.key});

  @override
  State<AllAttendanceScreen> createState() => _AllAttendanceScreenState();
}

class _AllAttendanceScreenState extends State<AllAttendanceScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<AttendanceBloc>().add(OnGetAll(_requestParams()));
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ThemedPage(
      title: 'All Attendance',
      subtitle: 'View employee attendance',
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                onTap: _selectDate,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: AppColors.danger.withValues(alpha: 0.1)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          size: 20, color: AppColors.danger),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          DateFormat('dd MMM yyyy').format(_selectedDate),
                          style: const TextStyle(
                            color: AppColors.dark,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down,
                          color: AppColors.danger),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search employee name or ID',
                hintStyle:
                    const TextStyle(color: Color(0xFF87909D), fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: AppColors.danger),
                suffixIcon: _searchQuery.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                          _reload();
                        },
                        icon: const Icon(Icons.close, color: AppColors.danger),
                        tooltip: 'Clear search',
                      ),
                filled: true,
                fillColor: AppColors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                      color: AppColors.danger.withValues(alpha: 0.1)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                      color: AppColors.danger.withValues(alpha: 0.1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.danger),
                ),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value.trim().toLowerCase());
                _reload();
              },
            ),
          ),
          Expanded(
            child: BlocBuilder<AttendanceBloc, AttendanceState>(
              builder: (context, state) {
                if (state.historyLoading) return const LoadingWidget();
                if (state.isError) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    children: [
                      ThemedMessageCard(
                        message: 'Unable to load attendance',
                        details: state.errorMessage,
                        onRetry: _reload,
                      ),
                    ],
                  );
                }
                final records = _filteredRecords(
                  state.histories ?? _attendanceRecords(state),
                );
                if (records.isEmpty) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    children: [
                      ThemedMessageCard(
                        message: 'No attendance found',
                        onRetry: _reload,
                      ),
                    ],
                  );
                }
                return RefreshIndicator(
                  color: AppColors.danger,
                  onRefresh: () async => _reload(),
                  child: ListView.separated(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: records.length + (state.loadMore ? 1 : 0),
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
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
        employee?.employment?.jobPosition?.name,
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
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.danger,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: AppColors.dark,
          ),
        ),
        child: child!,
      ),
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
    final position = employee?.employment?.jobPosition?.name ?? '-';
    final hasAttendance =
        attendance.checkIn != null || attendance.checkOut != null;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.1)),
      ),
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
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.dark,
                      ),
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
                                color: AppColors.danger,
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
                color: AppColors.danger,
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
                color: AppColors.danger, size: 24),
            const SizedBox(width: 12),
            SizedBox(
              width: 64,
              child: Text(
                value ?? '-',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14, color: Color(0xFF454951)),
              ),
            ),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 14, color: Color(0xFF303238)),
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.danger, size: 28),
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
                    color: AppColors.danger.withValues(alpha: 0.25),
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
                          style:
                              TextStyle(color: AppColors.danger, fontSize: 16)),
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

    final imageUrl = '${Api.url}/storage/$photo';

    return GestureDetector(
      onTap: () => _openFullScreenPhoto(context, imageUrl),
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const ColoredBox(
          color: Color(0xFFEFF2F5),
          child: Center(child: Icon(Icons.image_not_supported_outlined)),
        ),
      ),
    );
  }

  void _openFullScreenPhoto(BuildContext context, String imageUrl) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, __, ___) => _FullScreenPhotoViewer(imageUrl: imageUrl),
      ),
    );
  }
}

class _FullScreenPhotoViewer extends StatelessWidget {
  const _FullScreenPhotoViewer({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: Colors.white),
            tooltip: 'Close photo',
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 1,
          maxScale: 4,
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Center(
              child:
                  Icon(Icons.image_not_supported_outlined, color: Colors.white),
            ),
          ),
        ),
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
        Flexible(
          child: Text(
            value ?? '-',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: value == null ? const Color(0xFF737983) : color,
              fontSize: compact ? 12 : 14,
              fontWeight: FontWeight.w600,
            ),
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
      backgroundColor: AppColors.danger.withValues(alpha: 0.1),
      backgroundImage: imageUrl == null ? null : NetworkImage(imageUrl),
      child: imageUrl == null
          ? Icon(Icons.person, size: radius, color: AppColors.danger)
          : null,
    );
  }
}
