import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MapScreen extends StatefulWidget {
  final String type;
  const MapScreen({super.key, required this.type});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        backgroundColor: AppColors.whiteshade,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        title: widget.type.toUpperCase(),
      ),
      body: MapWidget(
        onTap: () {
          if (widget.type == "checkin") {
            context.goNamed('clockin');
          } else {
            context.goNamed('clockout');
          }
        },
      ),
    );
  }
}
