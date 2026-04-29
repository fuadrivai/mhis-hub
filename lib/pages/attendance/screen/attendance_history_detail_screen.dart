import 'package:fl_mhis_hr/library/app_colors.dart';
import 'package:fl_mhis_hr/library/sizes.dart';
import 'package:fl_mhis_hr/models/v2/attendance_log.dart';
import 'package:fl_mhis_hr/widget/custom_appbar.dart';
import 'package:flutter/material.dart';
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
    return Scaffold(
      appBar: CustomAppbar(
        backgroundColor: AppColors.primary,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
        ),
        title: "Attendance Detail",
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(Sizes.dimen_16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Sizes.dimen_12),
                ),
                child: Container(
                  padding: const EdgeInsets.all(Sizes.dimen_16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.1),
                        AppColors.primary2.withValues(alpha: 0.1)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(Sizes.dimen_12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        log.type == "check_in" ? Icons.login : Icons.logout,
                        size: Sizes.dimen_40,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: Sizes.dimen_16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              log.type == "check_in" ? "Check In" : "Check Out",
                              style: TextStyle(
                                fontSize: Sizes.dimen_20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            Text(
                              log.time ?? "--:--",
                              style: TextStyle(
                                fontSize: Sizes.dimen_16,
                                color: AppColors.blackshade,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: Sizes.dimen_20),

              // Details Section
              Text(
                "Details",
                style: TextStyle(
                  fontSize: Sizes.dimen_18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.blackshade,
                ),
              ),
              const SizedBox(height: Sizes.dimen_12),

              // Date
              _buildDetailRow("Date", log.clockDate ?? "--"),

              // Time
              _buildDetailRow("Time", log.time ?? "--:--"),

              // Employee
              _buildDetailRow("Employee",
                  log.fullname ?? log.employee?.personal?.fullname ?? "--"),

              // Shift
              _buildDetailRow("Shift", log.shiftName ?? "--"),

              // Location
              if (log.latitude != null && log.longitude != null)
                _buildDetailRow(
                    "Coordinates", "${log.latitude}, ${log.longitude}"),

              // Radius
              if (log.radius != null)
                _buildDetailRow("Radius", "${log.radius} meters"),

              // Photo
              if (log.photo != null && log.photo!.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: Sizes.dimen_16),
                    Text(
                      "Photo",
                      style: TextStyle(
                        fontSize: Sizes.dimen_16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.blackshade,
                      ),
                    ),
                    const SizedBox(height: Sizes.dimen_8),
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Sizes.dimen_12),
                        image: DecorationImage(
                          image: NetworkImage(log.photo!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),

              // Clock DateTime
              if (log.clockDatetime != null)
                _buildDetailRow("Clock DateTime", log.clockDatetime!),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Sizes.dimen_8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              "$label:",
              style: TextStyle(
                fontSize: Sizes.dimen_14,
                fontWeight: FontWeight.w600,
                color: AppColors.blackshade,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: Sizes.dimen_14,
                color: AppColors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
