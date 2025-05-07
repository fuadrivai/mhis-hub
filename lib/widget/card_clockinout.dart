import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/models/model.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class CardClockInOut extends StatelessWidget {
  final LiveAttendanceSchedule? schedule;
  const CardClockInOut({super.key, required this.schedule});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 8.0,
        vertical: 10,
      ),
      child: Container(
        height: 150,
        width: width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: Common.redGradient,
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              schedule?.currentShiftName ?? "WS",
              style: const TextStyle(
                color: AppColors.grayshade,
                fontWeight: FontWeight.w700,
                fontSize: 17,
              ),
            ),
            const Spacer(),
            Row(
              children: [
                const FaIcon(
                  FontAwesomeIcons.clock,
                  color: AppColors.white,
                ),
                const SizedBox(width: 10),
                if (schedule != null)
                  Text(
                    schedule?.fullDateTime ?? "--",
                    style: const TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
              ],
            ),
            const Spacer(),
            Container(
              height: 50,
              width: width,
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: IconButton(
                      onPressed: () => context.goNamed("clockin"),
                      icon: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            FontAwesomeIcons.arrowRightToBracket,
                            color: AppColors.blue,
                          ),
                          SizedBox(width: 5),
                          Text(
                            'Clock In',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  const VerticalDivider(
                    color: AppColors.grey,
                    width: 1,
                  ),
                  Expanded(
                    child: IconButton(
                      onPressed: () => context.goNamed("clockout"),
                      icon: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            FontAwesomeIcons.arrowRightFromBracket,
                            color: AppColors.blue,
                          ),
                          SizedBox(width: 5),
                          Text(
                            'Clock Out',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
