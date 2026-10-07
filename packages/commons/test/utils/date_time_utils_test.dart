import 'package:commons/utils/date_time_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('utcToPST / pstToUTC', () {
    test('utcToPST subtracts seven hours', () {
      final utc = DateTime.utc(2026, 8, 13, 12);

      expect(DateTimeUtils.utcToPST(utc), DateTime.utc(2026, 8, 13, 5));
    });

    test('pstToUTC adds seven hours', () {
      final pst = DateTime(2026, 8, 13, 5);

      expect(DateTimeUtils.pstToUTC(pst), DateTime.utc(2026, 8, 13, 12));
    });

    test('pstToUTC then utcToPST round trips', () {
      final pst = DateTime(2026, 8, 13, 9, 30);

      expect(DateTimeUtils.utcToPST(DateTimeUtils.pstToUTC(pst)),
          DateTime.utc(2026, 8, 13, 9, 30));
    });
  });

  group('fullDayOverlap', () {
    test('is true when the period strictly contains the whole day', () {
      final day = DateTime(2026, 8, 13);
      final range = DateTimeRange(
        start: DateTime(2026, 8, 12),
        end: DateTime(2026, 8, 14),
      );

      expect(DateTimeUtils.fullDayOverlap(day, range), isTrue);
    });

    test('is false when the period only covers part of the day', () {
      final day = DateTime(2026, 8, 13);
      final range = DateTimeRange(
        start: DateTime(2026, 8, 13, 9),
        end: DateTime(2026, 8, 13, 11),
      );

      expect(DateTimeUtils.fullDayOverlap(day, range), isFalse);
    });
  });

  group('isDayCompletelyFull', () {
    test('is true when some period covers the whole day', () {
      final day = DateTime(2026, 8, 13);

      expect(
        DateTimeUtils.isDayCompletelyFull(day, [
          DateTimeRange(start: DateTime(2026, 8, 1), end: DateTime(2026, 8, 2)),
          DateTimeRange(start: DateTime(2026, 8, 12), end: DateTime(2026, 8, 14)),
        ]),
        isTrue,
      );
    });

    test('is false for an empty period list', () {
      expect(DateTimeUtils.isDayCompletelyFull(DateTime(2026, 8, 13), const []),
          isFalse);
    });
  });

  group('isDayPartiallyFull', () {
    test('is true when a period falls entirely inside the day', () {
      final day = DateTime(2026, 8, 13);

      expect(
        DateTimeUtils.isDayPartiallyFull(day, [
          DateTimeRange(
            start: DateTime(2026, 8, 13, 9),
            end: DateTime(2026, 8, 13, 11),
          ),
        ]),
        isTrue,
      );
    });

    test('is true when a period starts inside the day and runs past its end', () {
      final day = DateTime(2026, 8, 13);

      expect(
        DateTimeUtils.isDayPartiallyFull(day, [
          DateTimeRange(
            start: DateTime(2026, 8, 13, 22),
            end: DateTime(2026, 8, 14, 3),
          ),
        ]),
        isTrue,
      );
    });

    test('is true when a period starts before the day and ends inside it', () {
      final day = DateTime(2026, 8, 13);

      expect(
        DateTimeUtils.isDayPartiallyFull(day, [
          DateTimeRange(
            start: DateTime(2026, 8, 12, 22),
            end: DateTime(2026, 8, 13, 3),
          ),
        ]),
        isTrue,
      );
    });

    test('is false when a period covers the whole day, that is completely full', () {
      final day = DateTime(2026, 8, 13);

      expect(
        DateTimeUtils.isDayPartiallyFull(day, [
          DateTimeRange(start: DateTime(2026, 8, 12), end: DateTime(2026, 8, 14)),
        ]),
        isFalse,
      );
    });

    test('is false when the period does not touch the day at all', () {
      final day = DateTime(2026, 8, 13);

      expect(
        DateTimeUtils.isDayPartiallyFull(day, [
          DateTimeRange(start: DateTime(2026, 8, 1), end: DateTime(2026, 8, 2)),
        ]),
        isFalse,
      );
    });

    test('is false for an empty period list', () {
      expect(DateTimeUtils.isDayPartiallyFull(DateTime(2026, 8, 13), const []),
          isFalse);
    });
  });
}
