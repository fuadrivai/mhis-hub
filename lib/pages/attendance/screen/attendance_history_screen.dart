import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/models/model.dart';
import 'package:fl_mhis_hr/pages/attendance/bloc/attendance_bloc.dart';
import 'package:fl_mhis_hr/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:jiffy/jiffy.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() =>
      _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  DateTime selectedDate = DateTime.now();
  String? strMonthYear;
  Map<String, dynamic> map = {};
  String? userId;
  @override
  void initState() {
    Session.get("userIdTalenta").then((val) {
      userId = val;
      strMonthYear =
          Jiffy.parseFromDateTime(selectedDate).format(pattern: "MMMM yyyy");
      String year =
          Jiffy.parseFromDateTime(selectedDate).format(pattern: "yyyy");
      String month = Jiffy.parseFromDateTime(selectedDate).format(pattern: "M");
      map = {"user_id": int.parse(userId!), "year": year, "month": month};
      setState(() {});
      if (!mounted) return;
      context.read<AttendanceBloc>().add(OnGetHistory(map));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: CustomAppbar(
        backgroundColor: AppColors.whiteshade,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        title: "Attendance",
      ),
      body: BlocBuilder<AttendanceBloc, AttendanceState>(
        builder: (context, state) {
          if (state.historyLoading) {
            return const LoadingWidget();
          }
          if (state.isError) {
            return Container(
              height: 200,
              decoration: const BoxDecoration(color: AppColors.white),
              child: Center(
                child: Text(state.errorMessage ?? "--"),
              ),
            );
          }
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 10,
                ),
                child: TextFormField(
                  controller: TextEditingController(text: strMonthYear),
                  readOnly: true,
                  // enabled: false,
                  onTap: () {
                    showMonthPicker(
                      context: context,
                      initialDate: selectedDate,
                      monthPickerDialogSettings: MonthPickerDialogSettings(
                        headerSettings: const PickerHeaderSettings(
                          headerCurrentPageTextStyle: TextStyle(fontSize: 14),
                          headerSelectedIntervalTextStyle:
                              TextStyle(fontSize: 16),
                        ),
                        dialogSettings: PickerDialogSettings(
                          locale: const Locale('en'),
                          dialogRoundedCornersRadius: 20,
                          dialogBackgroundColor: Colors.blueGrey[50],
                        ),
                        buttonsSettings: const PickerButtonsSettings(
                          buttonBorder: RoundedRectangleBorder(),
                          selectedMonthBackgroundColor: AppColors.primary,
                          selectedMonthTextColor: Colors.white,
                          unselectedMonthsTextColor: AppColors.blackshade,
                          currentMonthTextColor: Colors.green,
                          yearTextStyle: TextStyle(
                            fontSize: 10,
                          ),
                          monthTextStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ).then((date) {
                      if (date != null) {
                        setState(() {
                          selectedDate = date;
                          strMonthYear = Jiffy.parseFromDateTime(selectedDate)
                              .format(pattern: "MMMM yyyy");
                          String year =
                              Jiffy.parseFromDateTime(selectedDate).format(
                            pattern: "yyyy",
                          );
                          String month =
                              Jiffy.parseFromDateTime(selectedDate).format(
                            pattern: "M",
                          );
                          map = {
                            "user_id": int.parse(userId!),
                            "year": year,
                            "month": month
                          };
                          setState(() {});
                          context.read<AttendanceBloc>().add(OnGetHistory(map));
                        });
                      }
                    });
                  },
                  decoration: TextFormDecoration.box(
                    prefixIcon: const Icon(
                      FontAwesomeIcons.calendar,
                    ),
                    suffixIcon: const Icon(
                      Icons.arrow_drop_down,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(color: AppColors.white),
                  child: ListView.separated(
                    itemCount: (state.history ?? []).length,
                    itemBuilder: (context, i) {
                      AttendanceHistory history = (state.history ?? [])[i];
                      Color color = (history.dayoff ?? false)
                          ? AppColors.danger
                          : AppColors.blackshade;
                      TextStyle style = TextStyle(color: color);
                      String dateMOnth =
                          Jiffy.parse(history.date!).format(pattern: "dd MMM");
                      return SizedBox(
                        height: 45,
                        child: Row(
                          children: [
                            SizedBox(
                              width: size.width * 30 / 100,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(dateMOnth, style: style),
                                  Text(
                                    history.shift ?? "--",
                                    style: style.copyWith(fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(history.checkin ?? "--"),
                                      ),
                                      Expanded(
                                        child: Text(history.checkout ?? "--"),
                                      ),
                                      const Align(
                                        alignment: Alignment.centerRight,
                                        child: Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          color: Color.fromARGB(
                                              255, 101, 101, 101),
                                          size: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Visibility(
                                    visible: history.timeoffName != "",
                                    child: Expanded(
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 2, horizontal: 8),
                                          decoration: BoxDecoration(
                                            color: AppColors.blue,
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            history.timeoffName ?? "--",
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: AppColors.white,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (context, index) => const Divider(),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
