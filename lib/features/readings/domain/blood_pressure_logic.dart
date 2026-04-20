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
}
