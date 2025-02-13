import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/models/model.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:jiffy/jiffy.dart';

class AttendanceResponseScreen extends StatefulWidget {
  final AttendanceResponse? data;
  const AttendanceResponseScreen({super.key, this.data});

  @override
  State<AttendanceResponseScreen> createState() =>
      _AttendanceResponseScreenState();
}

class _AttendanceResponseScreenState extends State<AttendanceResponseScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(FontAwesomeIcons.xmark),
        ),
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: IntrinsicHeight(
          child: Column(
            children: [
              const FaIcon(
                FontAwesomeIcons.circleCheck,
                color: Color.fromARGB(255, 0, 249, 33),
                size: 100,
              ),
              Text(
                Common.capitalizeFirst(
                    widget.data?.data?.attributes?.approvalStatus ?? ""),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 30,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                Common.capitalizeEvery(widget.data?.message ?? ""),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                Jiffy.parse(widget.data!.data!.attributes!.clockTime!)
                    .format(pattern: "dd MMMM yyyy"),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                "Time : ${Jiffy.parse(widget.data!.data!.attributes!.clockTime!).format(pattern: "HH:mm")}",
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(Common.capitalizeFirst(
                  widget.data?.data?.attributes?.locationName ?? "")),
            ],
          ),
        ),
      ),
    );
  }
}
