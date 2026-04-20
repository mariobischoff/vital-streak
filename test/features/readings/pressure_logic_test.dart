import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pressao_arterial_historico/features/readings/domain/blood_pressure_logic.dart';

void main() {
  group('BloodPressureLogic - Classification (Spec 03)', () {
    test('should classify < 120/80 as Normal', () {
      expect(
        BloodPressureLogic.classify(115, 75),
        BloodPressureCategory.normal,
      );
      expect(
        BloodPressureLogic.classify(115, 75).color,
        Colors.green,
      );
    });

    test('should classify 120-129 / <80 as Elevated', () {
      expect(
        BloodPressureLogic.classify(125, 78),
        BloodPressureCategory.elevated,
      );
      expect(
        BloodPressureLogic.classify(125, 78).color,
        Colors.amber,
      );
    });

    test('should classify 130-139 OR 80-89 as Hypertension Stage 1', () {
      // High Systolic
      expect(
        BloodPressureLogic.classify(135, 75),
        BloodPressureCategory.hypertensionStage1,
      );
      // High Diastolic
      expect(
        BloodPressureLogic.classify(115, 85),
        BloodPressureCategory.hypertensionStage1,
      );
      expect(
        BloodPressureLogic.classify(135, 85).color,
        Colors.orange,
      );
    });

    test('should classify >= 140 OR >= 90 as Hypertension Stage 2+', () {
      // High Systolic
      expect(
        BloodPressureLogic.classify(145, 75),
        BloodPressureCategory.hypertensionStage2,
      );
      // High Diastolic
      expect(
        BloodPressureLogic.classify(115, 95),
        BloodPressureCategory.hypertensionStage2,
      );
      expect(
        BloodPressureLogic.classify(150, 100).color,
        Colors.red,
      );
    });

    test('should handle edge cases where Sys < Dia as Invalid', () {
      expect(
        BloodPressureLogic.classify(80, 120),
        BloodPressureCategory.invalid,
      );
    });
  });

  group('BloodPressureLogic - Validation (Spec 03)', () {
    test('should validate realistic values', () {
      expect(BloodPressureLogic.validate(120, 80), isTrue);
    });

    test('should reject Systolic <= Diastolic', () {
      expect(BloodPressureLogic.validate(100, 100), isFalse);
      expect(BloodPressureLogic.validate(80, 100), isFalse);
    });

    test('should reject out of range values', () {
      expect(BloodPressureLogic.validate(60, 50), isFalse); // Sys too low
      expect(BloodPressureLogic.validate(260, 80), isFalse); // Sys too high
      expect(BloodPressureLogic.validate(120, 30), isFalse); // Dia too low
      expect(BloodPressureLogic.validate(120, 150), isFalse); // Dia too high
    });
  });

  group('BloodPressureLogic - Habit & Trends', () {
    test('calculateCurrentStreak should detect a 3-day streak including today', () {
      final now = DateTime.now();
      final dates = [
        now,
        now.subtract(const Duration(days: 1)),
        now.subtract(const Duration(days: 2)),
      ];
      expect(BloodPressureLogic.calculateCurrentStreak(dates), 3);
    });

    test('calculateCurrentStreak should detect a streak ending yesterday', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final dates = [
        yesterday,
        yesterday.subtract(const Duration(days: 1)),
      ];
      expect(BloodPressureLogic.calculateCurrentStreak(dates), 2);
    });

    test('calculateCurrentStreak should return 0 if no reading today or yesterday', () {
      final oldDate = DateTime.now().subtract(const Duration(days: 5));
      final dates = [oldDate];
      expect(BloodPressureLogic.calculateCurrentStreak(dates), 0);
    });

    test('calculateStabilityStatus should detect Stable trend', () {
      final status = BloodPressureLogic.calculateStabilityStatus(
        [120, 122], // Avg 121
        [121, 119], // Avg 120 (diff < 5%)
      );
      expect(status, 'Stable');
    });

    test('calculateStabilityStatus should detect Improving trend', () {
      final status = BloodPressureLogic.calculateStabilityStatus(
        [115, 117], // Avg 116
        [130, 134], // Avg 132 (improving)
      );
      expect(status, 'Improving');
    });
  });
}
