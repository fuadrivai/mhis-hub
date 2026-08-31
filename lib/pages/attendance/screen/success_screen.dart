import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/models/v2/models.dart';
import 'package:fl_mhis_hr/pages/bottom_menu.dart';
import 'package:fl_mhis_hr/pages/pages.dart';
import 'package:fl_mhis_hr/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';

class AttendanceResponseScreen extends StatefulWidget {
  final AttendanceLog? attendance;
  const AttendanceResponseScreen({super.key, required this.attendance});

  @override
  State<AttendanceResponseScreen> createState() =>
      _AttendanceResponseScreenState();
}

class _AttendanceResponseScreenState extends State<AttendanceResponseScreen> {
  @override
  Widget build(BuildContext context) {
    final isCheckIn = widget.attendance?.type == "check_in";

    return Scaffold(
      appBar: CustomAppbar(
        title: isCheckIn ? "Check-In" : "Check-Out",
        leading: IconButton(
          onPressed: () => _goHome(),
          icon: const Icon(Icons.close, color: AppColors.dark),
        ),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        child: SafeArea(
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(isCheckIn),
                    const SizedBox(height: 32),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth > 700) {
                          return _buildDesktopLayout(
                            widget.attendance?.photo,
                            widget.attendance?.time,
                          );
                        } else {
                          return _buildMobileLayout(
                            widget.attendance?.photo,
                            widget.attendance?.time,
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isCheckIn) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_circle_rounded,
            size: 48,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "Success",
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          Jiffy.parse(widget.attendance?.clockDatetime ?? "")
              .format(pattern: "EEEE, dd MMMM yyyy HH:mm"),
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
        const SizedBox(height: 8),
        Text(
          isCheckIn ? "Your attendance has been recorded" : "See you tomorrow!",
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      ],
    );
  }

  void _goHome() {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => const BottomMenu(child: HomeScreen())),
        (route) => false);
  }

  void _goToAttendanceHistory() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => const AttendanceHistoryScreen()));
  }

  Widget _buildDesktopLayout(String? photoUrl, String? time) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPhotoSection(photoUrl),
              const SizedBox(height: 16),
              _buildAttendanceHistoryButton(),
            ],
          ),
        ),
        const SizedBox(width: 32),
        Expanded(child: _buildDetailSection(time)),
      ],
    );
  }

  Widget _buildMobileLayout(String? photoUrl, String? time) {
    return Column(
      children: [
        SizedBox(width: 250, child: _buildPhotoSection(photoUrl)),
        const SizedBox(height: 16),
        _buildAttendanceHistoryButton(),
        const SizedBox(height: 24),
        _buildDetailSection(time),
      ],
    );
  }

  Widget _buildAttendanceHistoryButton() {
    return SizedBox(
      width: 170,
      child: ElevatedButton.icon(
        onPressed: _goToAttendanceHistory,
        icon: const Icon(Icons.history),
        label: Center(child: const Text('Attendance History')),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        ),
      ),
    );
  }

  Widget _buildPhotoSection(String? photoUrl) {
    final int? warningMinutes = lateMinutes ?? earlyClockoutMinutes;

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey[100],
            ),
            child: photoUrl != null
                ? Image.network(
                    photoUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildPhotoPlaceholder(),
                  )
                : _buildPhotoPlaceholder(),
          ),
        ),
        if (warningMinutes != null) ...[
          const SizedBox(height: 12),
          _buildAttendanceWarning(warningMinutes),
        ],
      ],
    );
  }

  Widget _buildPhotoPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.photo_camera, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 8),
          Text(
            'photo not available',
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String? time) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Employee Information",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoItem(
            icon: Icons.person_outline,
            label: "Name",
            value: widget.attendance?.employee?.personal?.fullname ?? "-",
          ),
          _buildInfoItem(
            icon: Icons.business_outlined,
            label: "Organization",
            value:
                widget.attendance?.employee?.employment?.organization?.name ??
                    "-",
          ),
          _buildInfoItem(
            icon: Icons.work_outline,
            label: "Position",
            value: widget.attendance?.employee?.employment?.jobPosition?.name ??
                "-",
          ),
        ],
      ),
    );
  }

  int? get lateMinutes {
    if (widget.attendance?.type != 'check_in') return null;

    final DateTime? clockedAt = _clockedAt;
    final String? scheduleIn = widget.attendance?.attendance?.scheduleIn;
    if (clockedAt == null || scheduleIn == null || scheduleIn.isEmpty) {
      return null;
    }

    final List<String> parts = scheduleIn.split(':');
    if (parts.length < 2) return null;
    final int? hour = int.tryParse(parts[0]);
    final int? minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;

    final DateTime scheduledAt = DateTime(
      clockedAt.year,
      clockedAt.month,
      clockedAt.day,
      hour,
      minute,
    );
    final int difference = clockedAt.difference(scheduledAt).inMinutes;
    return difference > 0 ? difference : null;
  }

  int? get earlyClockoutMinutes {
    if (widget.attendance?.type != 'check_out') return null;

    final DateTime? clockedAt = _clockedAt;
    final String? scheduleOut = widget.attendance?.attendance?.scheduleOut;
    if (clockedAt == null || scheduleOut == null || scheduleOut.isEmpty) {
      return null;
    }

    final List<String> parts = scheduleOut.split(':');
    if (parts.length < 2) return null;
    final int? hour = int.tryParse(parts[0]);
    final int? minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;

    final DateTime scheduledAt = DateTime(
      clockedAt.year,
      clockedAt.month,
      clockedAt.day,
      hour,
      minute,
    );
    final int difference = scheduledAt.difference(clockedAt).inMinutes;
    return difference > 0 ? difference : null;
  }

  DateTime? get _clockedAt {
    final String? clockDatetime = widget.attendance?.clockDatetime;
    if (clockDatetime != null && clockDatetime.isNotEmpty) {
      return DateTime.tryParse(clockDatetime);
    }

    final String? clockDate = widget.attendance?.clockDate;
    final String? time = widget.attendance?.time;
    if (clockDate == null || time == null) return null;
    return DateTime.tryParse('$clockDate ${time.trim()}');
  }

  Widget _buildAttendanceWarning(int minutes) {
    final bool isEarlyClockout = earlyClockoutMinutes != null;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          const Icon(Icons.schedule_rounded, color: Colors.orange),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isEarlyClockout
                  ? 'You clocked out $minutes ${minutes == 1 ? 'minute' : 'minutes'} early'
                  : 'You arrived $minutes ${minutes == 1 ? 'minute' : 'minutes'} late',
              style: const TextStyle(
                color: Color(0xff9a5b00),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    bool isHighlighted = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(right: 12, top: 2),
            child: Icon(
              icon,
              size: 20,
              color: isHighlighted ? Colors.green : Colors.grey[600],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: isHighlighted ? Colors.green : Colors.grey[800],
                    fontWeight:
                        isHighlighted ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
