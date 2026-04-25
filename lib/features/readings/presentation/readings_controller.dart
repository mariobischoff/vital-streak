import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/supabase_repository.dart';
import '../domain/blood_pressure_reading.dart';

part 'readings_controller.g.dart';

@riverpod
class ReadingsController extends _$ReadingsController {
  final int _pageSize = 20;
  bool _hasMore = true;

  @override
  FutureOr<List<BloodPressureReading>> build() async {
    _hasMore = true;
    return _fetchReadings(offset: 0, limit: 30); // Initial fetch 30 for chart
  }

  Future<List<BloodPressureReading>> _fetchReadings({required int offset, required int limit}) async {
    final repository = ref.read(supabaseRepositoryProvider);
    final readings = await repository.getAllReadings(limit: limit, offset: offset);
    if (readings.length < limit) {
      _hasMore = false;
    }
    return readings;
  }

  Future<void> loadMore() async {
    if (state.isLoading || !_hasMore) return;

    final currentReadings = state.value ?? [];

    
    // We don't want to set the whole state to loading because that would show a 
    // full-screen spinner. We want to append.
    // However, AsyncNotifier doesn't have a built-in "loading more" state easily.
    // We'll just fetch and update.
    
    try {
      final nextReadings = await _fetchReadings(
        offset: currentReadings.length, 
        limit: _pageSize
      );
      state = AsyncData([...currentReadings, ...nextReadings]);
    } catch (e, st) {
      // In a real app, we might want a separate error state for "load more"
      state = AsyncError(e, st);
    }
  }

  bool get hasMore => _hasMore;

  Future<void> addReading(BloodPressureReading reading) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(supabaseRepositoryProvider);
      await repository.saveReading(reading);
      _hasMore = true;
      return _fetchReadings(offset: 0, limit: 30);
    });
  }

  Future<void> deleteReading(String id) async {
    // We keep it simple: refetch everything if deleted to ensure consistency
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(supabaseRepositoryProvider);
      await repository.deleteReading(id);
      _hasMore = true;
      return _fetchReadings(offset: 0, limit: 30);
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
