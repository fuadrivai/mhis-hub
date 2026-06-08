import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/models/v2/models.dart';
import 'package:fl_mhis_hr/pages/attendance/bloc/attendance_bloc.dart';
import 'package:fl_mhis_hr/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  @override
  void initState() {
    strMonthYear =
        Jiffy.parseFromDateTime(selectedDate).format(pattern: "MMMM yyyy");
    String year = Jiffy.parseFromDateTime(selectedDate).format(pattern: "yyyy");
    String month = Jiffy.parseFromDateTime(selectedDate).format(pattern: "M");
    map = {"year": year, "month": month};
    context.read<AttendanceBloc>().add(OnGetHistory(map));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: CustomAppbar(
        backgroundColor: AppColors.whiteshade,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
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
                      monthPickerDialogSettings: Common.monthPickerDialog(),
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
                          map = {"year": year, "month": month};
                          setState(() {});
                          context.read<AttendanceBloc>().add(OnGetHistory(map));
                        });
                      }
                    });
                  },
                  decoration: TextFormDecoration.box(
                    prefixIcon: const Icon(
                      Icons.calendar_month,
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
                    itemCount: (state.histories ?? []).length,
                    itemBuilder: (context, i) {
                      Attendance history = (state.histories ?? [])[i];
                      Color color = (history.holiday == 1)
                          ? AppColors.danger
                          : AppColors.blackshade;
                      TextStyle style = TextStyle(color: color);
                      String dateMOnth =
                          Jiffy.parse(history.date!).format(pattern: "dd MMM");
                      return InkWell(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) => Container(
                              padding: const EdgeInsets.all(20),
                              decoration: const BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                ),
                              ),
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "${history.shiftName} (${history.scheduleIn}-${history.scheduleOut})",
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () => context.pop(),
                                          icon: const Icon(Icons.close),
                                        ),
                                      ],
                                    ),
                                    Text(Jiffy.parse(history.date!)
                                        .format(pattern: "EEEE, dd MMMM yyyy")),
                                    const Divider(),
                                    const SizedBox(height: 12),
                                    ListView.builder(
                                      physics: ScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: (history.logs ?? []).length,
                                      itemBuilder: (context, idx) {
                                        AttendanceLog log =
                                            (history.logs ?? [])[idx];
                                        return Card(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                      log.type == "check_in"
                                                          ? "Check In"
                                                          : "Check Out"),
                                                ),
                                                Expanded(
                                                  child: Text(log.time ?? '--'),
                                                ),
                                                IconButton(
                                                  icon: Icon(
                                                      Icons.arrow_forward_ios),
                                                  onPressed: () {
                                                    context.pushNamed(
                                                      'attendance-history-detail',
                                                      extra: {'log': log},
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 20),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        child: SizedBox(
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
                                      history.shiftName ?? "--",
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
                                          child: Text(history.checkIn ?? "--"),
                                        ),
                                        Expanded(
                                          child: Text(history.checkOut ?? "--"),
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
                                  ],
                                ),
                              )
                            ],
                          ),
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
