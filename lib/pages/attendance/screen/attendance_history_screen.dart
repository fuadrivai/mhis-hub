import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/models/model.dart';
import 'package:fl_mhis_hr/models/v2/models.dart';
import 'package:fl_mhis_hr/pages/attendance/bloc/attendance_bloc.dart';
import 'package:fl_mhis_hr/pages/pages.dart';
import 'package:fl_mhis_hr/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jiffy/jiffy.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() =>
      _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  DateTime? selectedDate;
  String? strMonthYear;
  Map<String, dynamic> map = {};

  final TextEditingController _monthController = TextEditingController();
  bool _cutoffInitialized = false;

  @override
  void initState() {
    super.initState();
    context.read<AttendanceBloc>().add(const OnGetCutoff());
  }

  @override
  void dispose() {
    _monthController.dispose();
    super.dispose();
  }

  void _initializeMonthFromCutoff(AttendanceState state) {
    final cutoffDay = state.cutoff?.cutoffDay;
    if (_cutoffInitialized || cutoffDay == null) {
      return;
    }

    final today = DateTime.now();
    final month = today.day > cutoffDay
        ? DateTime(today.year, today.month + 1, 1)
        : DateTime(today.year, today.month, 1);

    _cutoffInitialized = true;
    selectedDate = month;
    strMonthYear = Jiffy.parseFromDateTime(month).format(pattern: "MMMM yyyy");
    _monthController.text = strMonthYear!;
    map = {
      "year": month.year.toString(),
      "month": month.month.toString(),
    };
    context.read<AttendanceBloc>().add(OnGetHistory(map));
    context.read<AttendanceBloc>().add(OnGetAttendanceSummary(map));
  }

  void _selectMonth(DateTime date) {
    selectedDate = date;
    strMonthYear = Jiffy.parseFromDateTime(date).format(pattern: "MMMM yyyy");
    _monthController.text = strMonthYear!;
    map = {
      "year": date.year.toString(),
      "month": date.month.toString(),
    };
    context.read<AttendanceBloc>().add(OnGetHistory(map));
    context.read<AttendanceBloc>().add(OnGetAttendanceSummary(map));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FA),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.paddingOf(context).top + 220,
            child: DecoratedBox(
              decoration: BoxDecoration(gradient: Common.homeHeaderGradient),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 18),
                  child: Row(
                    children: [
                      IconButton(
                        tooltip: 'Back',
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      const SizedBox(width: 4),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Attendance log',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'View your attendance history',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    child: BlocListener<AttendanceBloc, AttendanceState>(
                      listener: (context, state) {
                        if (!state.cutoffError) {
                          _initializeMonthFromCutoff(state);
                        }
                      },
                      child: BlocBuilder<AttendanceBloc, AttendanceState>(
                        builder: (context, state) {
                          if (state.cutoffError) {
                            return Container(
                              height: 200,
                              decoration:
                                  const BoxDecoration(color: AppColors.white),
                              child: Center(
                                child: Text(state.errorMessage ??
                                    "Unable to load cutoff"),
                              ),
                            );
                          }
                          if (state.cutoffLoading || !_cutoffInitialized) {
                            return const LoadingWidget();
                          }
                          if (state.historyLoading) {
                            return const LoadingWidget();
                          }
                          if (state.isError) {
                            return Container(
                              height: 200,
                              decoration:
                                  const BoxDecoration(color: AppColors.white),
                              child: Center(
                                child: Text(state.errorMessage ?? "--"),
                              ),
                            );
                          }
                          return Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                      color: AppColors.danger
                                          .withValues(alpha: 0.1)),
                                ),
                                child: TextFormField(
                                  controller: _monthController,
                                  readOnly: true,
                                  onTap: () {
                                    showMonthPicker(
                                      context: context,
                                      initialDate: selectedDate,
                                      monthPickerDialogSettings:
                                          Common.monthPickerDialog(),
                                    ).then((date) {
                                      if (date != null && mounted) {
                                        setState(() => _selectMonth(date));
                                      }
                                    });
                                  },
                                  decoration: TextFormDecoration.box(
                                    prefixIcon: const Icon(
                                      Icons.calendar_month,
                                      color: AppColors.danger,
                                    ),
                                    suffixIcon: const Icon(
                                      Icons.arrow_drop_down,
                                      color: AppColors.danger,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              BlocBuilder<AttendanceBloc, AttendanceState>(
                                buildWhen: (previous, current) =>
                                    previous.summaryLoading !=
                                        current.summaryLoading ||
                                    previous.summaryError !=
                                        current.summaryError ||
                                    previous.attendanceSummary !=
                                        current.attendanceSummary,
                                builder: (context, state) {
                                  if (state.summaryLoading) {
                                    return const Card(
                                      child: SizedBox(
                                        height: 100,
                                        child: Center(
                                            child: LoadingShimmer(height: 100)),
                                      ),
                                    );
                                  }
                                  if (state.summaryError ||
                                      state.attendanceSummary == null) {
                                    return const SizedBox.shrink();
                                  }
                                  return AttendanceSummaryWidget(
                                    summary: state.attendanceSummary!,
                                  );
                                },
                              ),
                              const Padding(
                                padding: EdgeInsets.fromLTRB(2, 4, 2, 10),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Attendance history',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.dark,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                      color: AppColors.danger
                                          .withValues(alpha: 0.1)),
                                ),
                                child: (state.histories ?? []).isEmpty
                                    ? const Padding(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 24),
                                        child: Center(
                                          child: Text(
                                              'No attendance records found'),
                                        ),
                                      )
                                    : ListView.separated(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount:
                                            (state.histories ?? []).length,
                                        itemBuilder: (context, i) {
                                          Attendance history =
                                              (state.histories ?? [])[i];
                                          final historyDate =
                                              DateTime.tryParse(history.date!);
                                          final isDayOff =
                                              history.holiday == 1 ||
                                                  (historyDate != null &&
                                                      historyDate.weekday >= 6);
                                          Color color = isDayOff
                                              ? AppColors.danger
                                              : AppColors.blackshade;
                                          TextStyle style =
                                              TextStyle(color: color);
                                          return InkWell(
                                            onTap: () {
                                              showModalBottomSheet(
                                                context: context,
                                                backgroundColor:
                                                    Colors.transparent,
                                                builder: (context) => Container(
                                                  padding:
                                                      const EdgeInsets.all(20),
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: AppColors.white,
                                                    borderRadius:
                                                        BorderRadius.only(
                                                      topLeft:
                                                          Radius.circular(20),
                                                      topRight:
                                                          Radius.circular(20),
                                                    ),
                                                  ),
                                                  child: SingleChildScrollView(
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Expanded(
                                                              child: Text(
                                                                "${history.shiftName} (${history.scheduleIn}-${history.scheduleOut})",
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize: 18,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                              ),
                                                            ),
                                                            IconButton(
                                                              onPressed: () =>
                                                                  Navigator.pop(
                                                                      context),
                                                              icon: const Icon(
                                                                  Icons.close),
                                                              color: AppColors
                                                                  .danger,
                                                            ),
                                                          ],
                                                        ),
                                                        Text(Jiffy.parse(
                                                                history.date!)
                                                            .format(
                                                                pattern:
                                                                    "EEEE, dd MMMM yyyy")),
                                                        const Divider(),
                                                        const SizedBox(
                                                            height: 12),
                                                        ListView.builder(
                                                          physics:
                                                              const NeverScrollableScrollPhysics(),
                                                          shrinkWrap: true,
                                                          itemCount:
                                                              (history.logs ??
                                                                      [])
                                                                  .length,
                                                          itemBuilder:
                                                              (context, idx) {
                                                            AttendanceLog log =
                                                                (history.logs ??
                                                                    [])[idx];
                                                            return InkWell(
                                                              onTap: () {
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            AttendanceHistoryDetailScreen(
                                                                      log: log,
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                              child: Card(
                                                                color: const Color(
                                                                    0xFFF8F8FA),
                                                                elevation: 0,
                                                                child: Padding(
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          12.0,
                                                                      vertical:
                                                                          16),
                                                                  child: Row(
                                                                    children: [
                                                                      Expanded(
                                                                        child: Text(log.type ==
                                                                                "check_in"
                                                                            ? "Check In"
                                                                            : "Check Out"),
                                                                      ),
                                                                      Expanded(
                                                                        child: Text(log.time ??
                                                                            '--'),
                                                                      ),
                                                                      const Icon(
                                                                        Icons
                                                                            .arrow_forward_ios,
                                                                        color: AppColors
                                                                            .danger,
                                                                        size:
                                                                            16,
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                        const SizedBox(
                                                            height: 20),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  flex: 5,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Flexible(
                                                            child: Text(
                                                              Jiffy.parse(history
                                                                      .date!)
                                                                  .format(
                                                                      pattern:
                                                                          "EEE, dd MMM"),
                                                              style: style.copyWith(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700),
                                                            ),
                                                          ),
                                                          if (DateUtils.isSameDay(
                                                              historyDate ??
                                                                  DateTime(
                                                                      1900),
                                                              DateTime
                                                                  .now())) ...[
                                                            const SizedBox(
                                                                width: 6),
                                                            Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          6,
                                                                      vertical:
                                                                          2),
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: AppColors
                                                                    .danger,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                              ),
                                                              child: const Text(
                                                                  'Today',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          10,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700)),
                                                            ),
                                                          ],
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                          height: 12),
                                                      Text(
                                                        isDayOff
                                                            ? 'Day off'
                                                            : (history
                                                                    .shiftName ??
                                                                "--"),
                                                        style: style.copyWith(
                                                            fontSize: 13),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 5,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            child: Text(history
                                                                    .checkIn ??
                                                                "--"),
                                                          ),
                                                          Expanded(
                                                            child: Text(history
                                                                    .checkOut ??
                                                                "--"),
                                                          ),
                                                          const Align(
                                                            alignment: Alignment
                                                                .centerRight,
                                                            child: Icon(
                                                              Icons
                                                                  .arrow_forward_ios_rounded,
                                                              color: Color
                                                                  .fromARGB(
                                                                      255,
                                                                      101,
                                                                      101,
                                                                      101),
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
                                          );
                                        },
                                        separatorBuilder: (context, index) =>
                                            const Divider(),
                                      ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AttendanceSummaryWidget extends StatefulWidget {
  final AttendanceSummary summary;

  const AttendanceSummaryWidget({super.key, required this.summary});

  @override
  State<AttendanceSummaryWidget> createState() =>
      AttendanceSummaryWidgetState();
}

class AttendanceSummaryWidgetState extends State<AttendanceSummaryWidget> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final totals = widget.summary.totals;
    final period =
        '${Jiffy.parseFromDateTime(widget.summary.period.start).format(pattern: 'dd MMM yyyy')} - '
        '${Jiffy.parseFromDateTime(widget.summary.period.end).format(pattern: 'dd MMM yyyy')}';
    final items = <(String, int)>[
      ('Late clock-in', totals.lateClockin),
      ('Early clock-out', totals.earlyClockout),
      ('Absent', totals.absent),
      ('No clock-in', totals.noClockin),
      ('No clock-out', totals.noClockout),
      ('Day-off', totals.dayoff),
      ('On-time', totals.onTime),
      ('Time-off', totals.timeoff),
      ('Invalid', totals.invalid),
      ('Next workdays', totals.nextWorkdays),
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 4),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.danger.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(period,
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            _metricRow(items.sublist(0, 4)),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: _expanded
                  ? Column(
                      children: [
                        const Divider(height: 24),
                        _metricRow(items.sublist(4, 8)),
                        const Divider(height: 24),
                        _metricRow(items.sublist(8)),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
            if (_expanded) ...[
              const SizedBox(height: 4),
              Center(
                child: TextButton(
                  onPressed: () => setState(() => _expanded = false),
                  child: const Text('Show less',
                      style: TextStyle(
                          color: AppColors.danger,
                          fontWeight: FontWeight.w700)),
                ),
              ),
            ] else
              Center(
                child: TextButton(
                  onPressed: () => setState(() => _expanded = true),
                  child: const Text('Show more',
                      style: TextStyle(
                          color: AppColors.danger,
                          fontWeight: FontWeight.w700)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _metricRow(List<(String, int)> items) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map(
            (item) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.$1,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.$2.toString(),
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        color: item.$2 > 0 ? AppColors.danger : AppColors.dark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
