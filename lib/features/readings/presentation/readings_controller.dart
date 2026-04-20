import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/supabase_repository.dart';
import '../domain/blood_pressure_reading.dart';

part 'readings_controller.g.dart';

@riverpod
class ReadingsController extends _$ReadingsController {
  @override
  FutureOr<List<BloodPressureReading>> build() async {
    return _fetchReadings();
  }

  Future<List<BloodPressureReading>> _fetchReadings() async {
    final repository = ref.read(supabaseRepositoryProvider);
    return repository.getAllReadings();
  }

  Future<void> addReading(BloodPressureReading reading) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(supabaseRepositoryProvider);
      await repository.saveReading(reading);
      return _fetchReadings();
    });
  }

  Future<void> deleteReading(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(supabaseRepositoryProvider);
      await repository.deleteReading(id);
      return _fetchReadings();
    });
  }
}

enum FilterPeriod { sevenDays, thirtyDays, all }

@riverpod
class FilterPeriodController extends _$FilterPeriodController {
  @override
  FilterPeriod build() => FilterPeriod.thirtyDays;

  void changeFilter(FilterPeriod filter) {
    state = filter;
  }
}

@riverpod
FutureOr<List<BloodPressureReading>> filteredReadings(
  FilteredReadingsRef ref,
) async {
  final readings = await ref.watch(readingsControllerProvider.future);
  final filter = ref.watch(filterPeriodControllerProvider);

  if (filter == FilterPeriod.all) return readings;

  final today = DateTime.now();
  final filterDays = filter == FilterPeriod.sevenDays ? 7 : 30;
  final thresholdDate = today.subtract(Duration(days: filterDays));

  return readings.where((r) => r.measuredAt.isAfter(thresholdDate)).toList();
}
