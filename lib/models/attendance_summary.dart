class AttendanceSummary {
  final AttendancePeriod period;
  final AttendanceTotals totals;

  AttendanceSummary({
    required this.period,
    required this.totals,
  });

  factory AttendanceSummary.fromJson(Map<String, dynamic> json) {
    return AttendanceSummary(
      period: AttendancePeriod.fromJson(
        json['period'] as Map<String, dynamic>,
      ),
      totals: AttendanceTotals.fromJson(
        json['totals'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'period': period.toJson(),
      'totals': totals.toJson(),
    };
  }
}

class AttendancePeriod {
  final DateTime start;
  final DateTime end;
  final int? cutoffDay;

  AttendancePeriod({
    required this.start,
    required this.end,
    required this.cutoffDay,
  });

  factory AttendancePeriod.fromJson(Map<String, dynamic> json) {
    return AttendancePeriod(
      start: DateTime.parse(json['start']),
      end: DateTime.parse(json['end']),
      cutoffDay: json['cutoff_day'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'start': start.toIso8601String().split('T').first,
      'end': end.toIso8601String().split('T').first,
      'cutoff_day': cutoffDay,
    };
  }
}

class AttendanceTotals {
  final int lateClockin;
  final int earlyClockout;
  final int absent;
  final int noClockin;
  final int noClockout;
  final int dayoff;
  final int onTime;
  final int timeoff;
  final int invalid;
  final int nextWorkdays;

  AttendanceTotals({
    required this.lateClockin,
    required this.earlyClockout,
    required this.absent,
    required this.noClockin,
    required this.noClockout,
    required this.dayoff,
    required this.onTime,
    required this.timeoff,
    required this.invalid,
    required this.nextWorkdays,
  });

  factory AttendanceTotals.fromJson(Map<String, dynamic> json) {
    return AttendanceTotals(
      lateClockin: json['late_clockin'] ?? 0,
      earlyClockout: json['early_clockout'] ?? 0,
      absent: json['absent'] ?? 0,
      noClockin: json['no_clockin'] ?? 0,
      noClockout: json['no_clockout'] ?? 0,
      dayoff: json['dayoff'] ?? 0,
      onTime: json['on_time'] ?? 0,
      timeoff: json['timeoff'] ?? 0,
      invalid: json['invalid'] ?? 0,
      nextWorkdays: json['next_workdays'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'late_clockin': lateClockin,
      'early_clockout': earlyClockout,
      'absent': absent,
      'no_clockin': noClockin,
      'no_clockout': noClockout,
      'dayoff': dayoff,
      'on_time': onTime,
      'timeoff': timeoff,
      'invalid': invalid,
      'next_workdays': nextWorkdays,
    };
  }
}
