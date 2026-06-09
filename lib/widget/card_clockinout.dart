import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/models/v2/models.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class CardClockInOut extends StatelessWidget {
  final Shift? shift;
  const CardClockInOut({super.key, required this.shift});

  String _greetingByTime() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 15) return 'Good Afternoon';
    if (hour < 18) return 'Good Evening';
    return 'Good Night';
  }

  double _greetingFontSize(double width) {
    if (width < 340) return 15;
    if (width < 420) return 16;
    return 14;
  }

  double _shiftTitleFontSize(double width) {
    if (width < 340) return 15;
    if (width < 420) return 16;
    return 17;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    final String fullname = shift?.fullname?.trim().isNotEmpty == true
        ? shift!.fullname!.trim()
        : 'Employee';
    final String greeting = '${_greetingByTime()}, $fullname';

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 8.0,
        vertical: 10,
      ),
      child: Container(
        height: 170,
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
              greeting,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
                fontSize: _greetingFontSize(width),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Schedule: ${shift?.name ?? 'WS'}",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.grayshade,
                fontWeight: FontWeight.w700,
                fontSize: _shiftTitleFontSize(width),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const FaIcon(
                  FontAwesomeIcons.clock,
                  color: AppColors.white,
                ),
                const SizedBox(width: 10),
                if (shift != null)
                  Expanded(
                    child: Text(
                      shift!.fullScheduleTime(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
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
                          FaIcon(
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
                      icon: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FaIcon(
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
