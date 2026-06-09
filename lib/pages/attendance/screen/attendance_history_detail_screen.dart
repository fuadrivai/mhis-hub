import 'package:fl_mhis_hr/library/app_colors.dart';
import 'package:fl_mhis_hr/library/sizes.dart';
import 'package:fl_mhis_hr/models/v2/attendance_log.dart';
import 'package:fl_mhis_hr/service/api.dart';
import 'package:fl_mhis_hr/widget/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

class AttendanceHistoryDetailScreen extends StatefulWidget {
  final AttendanceLog log;
  const AttendanceHistoryDetailScreen({super.key, required this.log});

  @override
  State<AttendanceHistoryDetailScreen> createState() =>
      _AttendanceHistoryDetailScreenState();
}

class _AttendanceHistoryDetailScreenState
    extends State<AttendanceHistoryDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final log = widget.log;
    final hasCoordinate = log.latitude != null && log.longitude != null;
    final latLng = hasCoordinate ? LatLng(log.latitude!, log.longitude!) : null;

    return Scaffold(
      appBar: CustomAppbar(
        backgroundColor: AppColors.white,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back, color: AppColors.dark),
        ),
        title: log.type == "check_in" ? "Check-In Detail" : "Check-Out Detail",
      ),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(Sizes.dimen_14),
          decoration: BoxDecoration(
            color: AppColors.white,
            boxShadow: const [
              BoxShadow(
                color: Color(0x11000000),
                blurRadius: 14,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                      child: _buildPhoto("${Api.url}/storage/${log.photo}")),
                  const SizedBox(width: Sizes.dimen_12),
                  Expanded(child: _buildMap(latLng)),
                ],
              ),
              const SizedBox(height: Sizes.dimen_16),
              _buildInfoRow("Fullname", _textOrDash(log.fullname)),
              _buildInfoRow("Type", _textOrDash(log.type)),
              _buildInfoRow("Shift Name", _textOrDash(log.shiftName)),
              _buildInfoRow(
                  "Clock Datetime", _formatDateTime(log.clockDatetime)),
              _buildInfoRow(
                "Latitude & Longitude",
                latLng == null
                    ? "-"
                    : "${latLng.latitude.toStringAsFixed(6)}, ${latLng.longitude.toStringAsFixed(6)}",
              ),
              _buildInfoRow(
                "Radius",
                log.radius == null
                    ? "-"
                    : "${log.radius!.toStringAsFixed(2)} m",
                isLast: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhoto(String? photoUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(Sizes.dimen_12),
      child: AspectRatio(
        aspectRatio: 1.111,
        child: photoUrl != null && photoUrl.isNotEmpty
            ? Image.network(
                photoUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    _mediaPlaceholder(Icons.image_not_supported_outlined),
              )
            : _mediaPlaceholder(Icons.person_outline),
      ),
    );
  }

  Widget _buildMap(LatLng? target) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(Sizes.dimen_12),
      child: AspectRatio(
        aspectRatio: 1.111,
        child: target == null
            ? _mediaPlaceholder(Icons.location_off_outlined)
            : GoogleMap(
                initialCameraPosition: CameraPosition(target: target, zoom: 16),
                markers: {
                  Marker(
                    markerId: const MarkerId("attendance_location"),
                    position: target,
                  ),
                },
                zoomControlsEnabled: false,
                myLocationButtonEnabled: false,
              ),
      ),
    );
  }

  Widget _mediaPlaceholder(IconData icon) {
    return Container(
      color: const Color(0xFFF1F4F8),
      alignment: Alignment.center,
      child: Icon(icon, size: Sizes.dimen_40, color: AppColors.grey),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: Sizes.dimen_10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isLast ? Colors.transparent : const Color(0xFFE8EBEF),
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: Sizes.dimen_14,
                color: Color(0xFF7A869A),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: Sizes.dimen_10),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: Sizes.dimen_14,
                color: AppColors.dark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _textOrDash(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "-";
    }
    return value;
  }

  String _formatDateTime(String? dateTime) {
    if (dateTime == null || dateTime.trim().isEmpty) {
      return "-";
    }

    try {
      final parsed = DateTime.parse(dateTime).toLocal();
      return DateFormat('dd MMM yyyy, HH:mm').format(parsed);
    } catch (_) {
      return dateTime;
    }
  }
}
