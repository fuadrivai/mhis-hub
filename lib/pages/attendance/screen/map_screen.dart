import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/widget/map_widget.dart';
import 'package:fl_mhis_hr/widget/themed_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MapScreen extends StatefulWidget {
  final String type;
  const MapScreen({super.key, required this.type});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  String base64 = "";
  @override
  Widget build(BuildContext context) {
    return ThemedPage(
      title: widget.type.toUpperCase(),
      subtitle: 'Confirm your attendance location',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: MapWidget(
            buttonColor: AppColors.danger,
            centerButton: true,
            onTap: () async {
              if (widget.type == "checkin") {
                context.goNamed('clockin');
              } else {
                context.goNamed('clockout');
              }
            },
          ),
        ),
      ),
    );
  }
}
