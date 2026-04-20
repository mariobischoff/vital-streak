import 'package:flutter/material.dart';

enum BloodPressureCategory {
  normal('Normal', Colors.green),
  elevated('Elevated', Colors.amber),
  hypertensionStage1('Hypertension Stage 1', Colors.orange),
  hypertensionStage2('Hypertension Stage 2+', Colors.red),
  invalid('Invalid', Colors.grey);

  final String label;
  final Color color;

  const BloodPressureCategory(this.label, this.color);
}

class BloodPressureLogic {
  /// Classifies a reading based on Spec 03 rules.
  static BloodPressureCategory classify(int systolic, int diastolic) {
    if (!validate(systolic, diastolic)) {
      return BloodPressureCategory.invalid;
    }

    // Hypertension Stage 2+ (highest severity)
    if (systolic >= 140 || diastolic >= 90) {
      return BloodPressureCategory.hypertensionStage2;
    }

    // Hypertension Stage 1
    if (systolic >= 130 || diastolic >= 80) {
      return BloodPressureCategory.hypertensionStage1;
    }

    // Elevated
    if (systolic >= 120 && diastolic < 80) {
      return BloodPressureCategory.elevated;
    }

    // Normal
    if (systolic < 120 && diastolic < 80) {
      return BloodPressureCategory.normal;
    }

    // Fallback (e.g. 115/85 - would capture as Stage 1 due to Diastolic)
    return BloodPressureCategory.normal;
  }

  /// Validates if the numbers make medical and logical sense according to Spec 03.
  static bool validate(int systolic, int diastolic) {
    if (systolic <= diastolic) return false;
    if (systolic < 70 || systolic > 250) return false;
    if (diastolic < 40 || diastolic > 140) return false;
    return true;
  }

  /// Calculates the number of consecutive days with at least one reading.
  static int calculateCurrentStreak(List<DateTime> dates) {
    if (dates.isEmpty) return 0;

    // Normalize and remove duplicates (only care about the date)
    final uniqueDates =
        dates
            .map((d) => DateTime(d.year, d.month, d.day))
            .toSet()
            .toList()
          ..sort((a, b) => b.compareTo(a)); // Newest first

    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);
    final normalizedYesterday = normalizedToday.subtract(const Duration(days: 1));

    // If the latest reading is not today or yesterday, streak is broken
    if (uniqueDates.first.isBefore(normalizedYesterday)) {
      return 0;
    }

    int streak = 0;
    DateTime currentCheck = uniqueDates.first;

    for (final date in uniqueDates) {
      if (date == currentCheck) {
        streak++;
        currentCheck = currentCheck.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  /// Categorizes the stability of the pressure based on recent volatility.
  static String calculateStabilityStatus(
    List<int> currentSys,
    List<int> previousSys,
  ) {
    if (currentSys.isEmpty || previousSys.isEmpty) return 'Initial Phase';

    final avgCurrent = currentSys.reduce((a, b) => a + b) / currentSys.length;
    final avgPrevious = previousSys.reduce((a, b) => a + b) / previousSys.length;

    final diff = (avgCurrent - avgPrevious).abs();
    final percentChange = diff / avgPrevious;

    if (percentChange < 0.05) return 'Stable';
    if (avgCurrent < avgPrevious) return 'Improving';
    return 'Varying';
  }
}
