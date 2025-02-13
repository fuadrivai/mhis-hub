import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/models/model.dart';
import 'package:fl_mhis_hr/pages/clockin_prayer/bloc/clockin_prayer_bloc.dart';
import 'package:fl_mhis_hr/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:jiffy/jiffy.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:timer_count_down/timer_controller.dart';
import 'package:timer_count_down/timer_count_down.dart';

class ClockInAsharScreen extends StatefulWidget {
  const ClockInAsharScreen({super.key});

  @override
  State<ClockInAsharScreen> createState() => _ClockInAsharScreenState();
}

class _ClockInAsharScreenState extends State<ClockInAsharScreen> {
  DateTime selectedDate = DateTime.now();
  Map<String, dynamic> map = {};
  String? monthYear;
  String strLocation = "Location is not detected";
  final CountdownController controller = CountdownController(autoStart: true);

  @override
  void initState() {
    monthYear =
        Jiffy.parseFromDateTime(selectedDate).format(pattern: "MMMM yyyy");
    String year = Jiffy.parseFromDateTime(selectedDate).format(pattern: "yyyy");
    String month = Jiffy.parseFromDateTime(selectedDate).format(pattern: "MM");
    map = {"year": int.parse(year), "month": month};
    context.read<ClockinPrayerBloc>().add(OnInit(map));
    context.read<ClockinPrayerBloc>().add(const GetPraySchedule());
    context.read<ClockinPrayerBloc>().add(const GetLocationName());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: CustomAppbar(
        backgroundColor: AppColors.whiteshade,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        title: "Clock In Ashar",
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<ClockinPrayerBloc>().add(OnInit(map));
          context.read<ClockinPrayerBloc>().add(const GetPraySchedule());
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 10,
                ),
                child: Container(
                  height: 220,
                  width: width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: AppColors.white,
                    gradient: Common.redGradient,
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const FaIcon(
                                FontAwesomeIcons.locationDot,
                                color: AppColors.white,
                              ),
                              const SizedBox(width: 10),
                              BlocListener<ClockinPrayerBloc,
                                  ClockinPrayerState>(
                                listener: (context, state) {
                                  if (!state.scheduleLoading) {
                                    if ((state.placemarks ?? []).isNotEmpty) {
                                      strLocation = state.placemarks![0]
                                              .subAdministrativeArea ??
                                          "Location is not detected";
                                      setState(() {});
                                    }
                                  }
                                },
                                child: Text(
                                  strLocation,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.whiteshade,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            Jiffy.now().format(pattern: "dd MMM yyyy"),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.whiteshade,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Center(
                        child:
                            BlocBuilder<ClockinPrayerBloc, ClockinPrayerState>(
                          builder: (context, state) {
                            if (state.scheduleLoading) {
                              return const SizedBox(
                                width: 100,
                                child: LoadingShimmer(height: 40),
                              );
                            }
                            // controller.start();
                            return Column(
                              children: [
                                Countdown(
                                  controller: controller,
                                  seconds: state.seconds ?? 0,
                                  build: (_, double time) {
                                    return Text(
                                      _formatTime(time.toInt()),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.whiteshade,
                                        fontSize: 25,
                                      ),
                                    );
                                  },
                                  interval: const Duration(milliseconds: 1),
                                  onFinished: () {},
                                ),
                                Text(
                                  "Next to ${state.prayerName}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.whiteshade,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      const Spacer(),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.white),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            ScheduleWidget(title: "Fajr"),
                            ScheduleWidget(title: "Dzuhur"),
                            ScheduleWidget(title: "Ashar"),
                            ScheduleWidget(title: "Maghrib"),
                            ScheduleWidget(title: "Isha"),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Container(
                        height: 45,
                        width: width,
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: IconButton(
                            onPressed: () => context.goNamed("tap-in-ashar"),
                            icon: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  FontAwesomeIcons.arrowRightToBracket,
                                  color: AppColors.blue,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  'Tap In',
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 10,
                ),
                child: TextFormField(
                  controller: TextEditingController(text: monthYear),
                  readOnly: true,
                  onTap: () {
                    showMonthPicker(
                      context: context,
                      initialDate: selectedDate,
                      monthPickerDialogSettings: Common.monthPickerDialog(),
                    ).then((date) {
                      if (date != null) {
                        setState(() {
                          selectedDate = date;
                          monthYear = Jiffy.parseFromDateTime(selectedDate)
                              .format(pattern: "MMMM yyyy");
                        });
                      }
                    });
                  },
                  decoration: TextFormDecoration.box(
                    prefixIcon: const Icon(FontAwesomeIcons.calendar),
                    suffixIcon: const Icon(Icons.arrow_drop_down),
                  ),
                ),
              ),
              BlocBuilder<ClockinPrayerBloc, ClockinPrayerState>(
                builder: (context, state) {
                  if (state.isLoading) {
                    return const LoadingWidget();
                  }
                  if ((state.histories ?? []).isEmpty) {
                    return EmptyWidget(
                      onTap: () {
                        context.read<ClockinPrayerBloc>().add(OnInit(map));
                        context
                            .read<ClockinPrayerBloc>()
                            .add(const GetPraySchedule());
                      },
                    );
                  }
                  return Container(
                    color: AppColors.white,
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const ScrollPhysics(),
                      itemCount: (state.histories ?? []).length,
                      itemBuilder: (context, i) {
                        PostPrayer e = (state.histories ?? [])[i];
                        return ListTile(
                          dense: true,
                          visualDensity: const VisualDensity(vertical: -2),
                          title: Text(
                            e.date(e.clockTime!),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Row(
                            children: [
                              const FaIcon(
                                FontAwesomeIcons.clock,
                                size: 12,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                e.hourMinute(e.clockTime!),
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                          leading: const FaIcon(
                            FontAwesomeIcons.mosque,
                            color: AppColors.blue,
                          ),
                        );
                      },
                      separatorBuilder: (context, index) => const Divider(),
                    ),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(int time) {
    int hours = (time ~/ 3600);
    int minutes = (time % 3600) ~/ 60;
    int seconds = time % 60;

    String hour = hours.toString().padLeft(2, "0");
    String minute = minutes.toString().padLeft(2, "0");
    String second = seconds.toString().padLeft(2, "0");

    return "$hour:$minute:$second";
  }
}

class ScheduleWidget extends StatelessWidget {
  final String title;
  const ScheduleWidget({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClockinPrayerBloc, ClockinPrayerState>(
      builder: (context, state) {
        if (state.scheduleLoading) {
          return const SizedBox(
            width: 50,
            child: LoadingShimmer(height: 20),
          );
        }
        String time = "";
        switch (title) {
          case "Fajr":
            time =
                "${state.prayerTimes?.fajr.hour}:${state.prayerTimes?.fajr.minute}";
            break;
          case "Dzuhur":
            time =
                "${state.prayerTimes?.dhuhr.hour}:${state.prayerTimes?.dhuhr.minute}";
            break;
          case "Ashar":
            time =
                "${state.prayerTimes?.asr.hour}:${state.prayerTimes?.asr.minute}";
            break;
          case "Maghrib":
            time =
                "${state.prayerTimes?.maghrib.hour}:${state.prayerTimes?.maghrib.minute}";
            break;
          case "Isha":
            time =
                "${state.prayerTimes?.isha.hour}:${state.prayerTimes?.isha.minute}";
            break;
          default:
            time = "--";
        }
        return Column(
          children: [
            Text(
              time,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.whiteshade,
                fontSize: 15,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.whiteshade,
                fontSize: 13,
              ),
            ),
          ],
        );
      },
    );
  }
}
