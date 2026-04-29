import 'package:flutter/material.dart';

class DateTimeUtils {
  static DateTime utcToPST(DateTime utc) {
    return utc.subtract(const Duration(hours: 7));
  }

  static DateTime nowPST() => utcToPST(DateTime.now().toUtc());

  static DateTime pstToUTC(DateTime pst) {
    return DateTime.utc(
      pst.year,
      pst.month,
      pst.day,
      pst.hour,
      pst.minute,
      pst.second,
      pst.millisecond,
      pst.microsecond,
    ).add(const Duration(hours: 7));
  }

  static bool isDayPartiallyFull(DateTime day, List<DateTimeRange> unavailablePeriods) {
    final fullDay = _dateToRange(day);
    return unavailablePeriods.any((period) {
      return (period.start.isBefore(fullDay.start) && period.start.isAfter(fullDay.start)) ||
          (period.start.isAfter(fullDay.start) && period.end.isBefore(fullDay.end)) ||
          (period.start.isBefore(fullDay.end) && period.end.isAfter(fullDay.end)) && !fullDayOverlap(day, period);
    });
  }

  static bool fullDayOverlap(DateTime date, DateTimeRange range) {
    final dayRange = _dateToRange(date);
    return range.start.isBefore(dayRange.start) && range.end.isAfter(dayRange.end);
  }

  static bool isDayCompletelyFull(DateTime day, List<DateTimeRange> unavailablePeriods) {
    return unavailablePeriods.any((period) => fullDayOverlap(day, period));
  }

  static DateTimeRange _dateToRange(DateTime day) {
    final startOfDay = DateTime(day.year, day.month, day.day);
    final endOfDay = startOfDay.add(const Duration(days: 1)).subtract(const Duration(seconds: 1));
    return DateTimeRange(start: startOfDay, end: endOfDay);
  }
}
