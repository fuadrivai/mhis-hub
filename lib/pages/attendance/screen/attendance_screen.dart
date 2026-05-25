import 'dart:async';

import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/models/v2/models.dart';
import 'package:fl_mhis_hr/pages/attendance/bloc/attendance_bloc.dart';
import 'package:fl_mhis_hr/pages/pages.dart';
import 'package:fl_mhis_hr/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:jiffy/jiffy.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  late final Timer _clockTimer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    context.read<AttendanceBloc>().add(const OnInit());
    _loadHistoryPreview();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _now = DateTime.now());
    });
    super.initState();
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    super.dispose();
  }

  Future<void> _loadHistoryPreview() async {
    final userId = await Session.get("userIdTalenta");
    if (!mounted || userId == null) return;
    final now = DateTime.now();
    final map = {
      "user_id": int.parse(userId),
      "year": Jiffy.parseFromDateTime(now).format(pattern: "yyyy"),
      "month": Jiffy.parseFromDateTime(now).format(pattern: "M"),
    };
    context.read<AttendanceBloc>().add(OnGetHistory(map));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteshade,
      appBar: AppBar(
        backgroundColor: AppColors.danger,
        elevation: 0,
        centerTitle: true,
        foregroundColor: AppColors.white,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text(
          "Live Attendance",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.white,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<AttendanceBloc>().add(const OnInit());
          await _loadHistoryPreview();
        },
        child: BlocBuilder<AttendanceBloc, AttendanceState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const LoadingWidget();
            }
            final latestLog = _findLatestLog(state.histories);
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  _buildHeroSection(state.shift),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    child: _buildLogSection(context, latestLog),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeroSection(Shift? shift) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 0, 24, 35),
      decoration: const BoxDecoration(
        color: AppColors.danger,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -70,
            top: 10,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.white.withValues(alpha: 0.1),
              ),
            ),
          ),
          Column(
            children: [
              Align(
                child: Text(
                  Jiffy.parseFromDateTime(_now).format(pattern: "HH:mm:ss"),
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _buildScheduleCard(context, shift),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(
    BuildContext context,
    Shift? shift,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "Schedule: ${_scheduleDateLabel()}",
            style: const TextStyle(
              color: Color(0xFF808080),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            shift?.name ?? "-",
            style: const TextStyle(
              color: Color(0xFF222222),
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _scheduleTimeLabel(shift),
            style: const TextStyle(
              color: Color(0xFF222222),
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFE7F0FA),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.info,
                  color: Color(0xFF6B7280),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Selfie photo is required to Clock In/Out",
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  label: "Clock In",
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const ClockinClockoutScreen(type: "clock_in"))),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildActionButton(
                  label: "Clock Out",
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const ClockinClockoutScreen(type: "clock_out"))),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 58,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.blue,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        child: Text(label),
      ),
    );
  }

  Widget _buildLogSection(BuildContext context, AttendanceLog? latestLog) {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                "Attendance log",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF222222),
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AttendanceHistoryScreen())),
              child: const Text(
                "View Log",
                style: TextStyle(
                  color: Color(0xFF7A7A7A),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (latestLog != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 84,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        latestLog.time ?? "--:--",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF222222),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _logDateLabel(latestLog),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Text(
                    latestLog.type == "check_out" ? "Clock Out" : "Clock In",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF222222),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const AttendanceHistoryScreen())),
                  icon: const Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Text(
              "No attendance log available for this month yet.",
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 15,
              ),
            ),
          ),
      ],
    );
  }

  AttendanceLog? _findLatestLog(List<Attendance>? histories) {
    final logs = <AttendanceLog>[];
    for (final history in histories ?? <Attendance>[]) {
      logs.addAll(history.logs ?? const <AttendanceLog>[]);
    }
    if (logs.isEmpty) return null;
    logs.sort((a, b) => _logDateTime(b).compareTo(_logDateTime(a)));
    return logs.first;
  }

  DateTime _logDateTime(AttendanceLog log) {
    final fromDateTime = DateTime.tryParse(log.clockDatetime ?? "");
    if (fromDateTime != null) return fromDateTime;
    final rawDate = log.clockDate;
    final rawTime = log.time;
    if (rawDate != null && rawTime != null) {
      final combined =
          DateTime.tryParse("${rawDate}T${_normalizeTime(rawTime)}");
      if (combined != null) return combined;
    }
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  String _scheduleDateLabel() {
    return Jiffy.now().format(pattern: "dd MMM yyyy");
  }

  String _scheduleTimeLabel(Shift? shift) {
    final start = _formatShiftTime(shift?.scheduleIn);
    final end = _formatShiftTime(shift?.scheduleOut);
    return "$start - $end";
  }

  String _formatShiftTime(String? time) {
    if (time == null || time.isEmpty) return "--";
    try {
      return Jiffy.parse(time, pattern: "HH:mm:ss").format(pattern: "hh:mm a");
    } catch (_) {
      return time;
    }
  }

  String _logDateLabel(AttendanceLog log) {
    final rawDate = log.clockDate;
    if (rawDate == null || rawDate.isEmpty) return "--";
    try {
      return Jiffy.parse(rawDate).format(pattern: "dd MMM");
    } catch (_) {
      return rawDate;
    }
  }

  String _normalizeTime(String rawTime) {
    final hasAmPm = rawTime.toUpperCase().contains("AM") ||
        rawTime.toUpperCase().contains("PM");
    if (hasAmPm) {
      try {
        return Jiffy.parse(rawTime, pattern: "hh:mm A")
            .format(pattern: "HH:mm:ss");
      } catch (_) {
        return rawTime;
      }
    }
    return rawTime.length == 5 ? "$rawTime:00" : rawTime;
  }
}
