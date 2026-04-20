// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'readings_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$filteredReadingsHash() => r'9cea9952a694953706e948a1dce4774a81b8c81f';

/// See also [filteredReadings].
@ProviderFor(filteredReadings)
final filteredReadingsProvider =
    AutoDisposeFutureProvider<List<BloodPressureReading>>.internal(
  filteredReadings,
  name: r'filteredReadingsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$filteredReadingsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef FilteredReadingsRef
    = AutoDisposeFutureProviderRef<List<BloodPressureReading>>;
String _$readingsControllerHash() =>
    r'0f03e657ff1a16149ba3201d1fa6753881017198';

/// See also [ReadingsController].
@ProviderFor(ReadingsController)
final readingsControllerProvider = AutoDisposeAsyncNotifierProvider<
    ReadingsController, List<BloodPressureReading>>.internal(
  ReadingsController.new,
  name: r'readingsControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$readingsControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ReadingsController
    = AutoDisposeAsyncNotifier<List<BloodPressureReading>>;
String _$filterPeriodControllerHash() =>
    r'51648338b0cf312982c5e2857fbe993c0c7ba807';

/// See also [FilterPeriodController].
@ProviderFor(FilterPeriodController)
final filterPeriodControllerProvider =
    AutoDisposeNotifierProvider<FilterPeriodController, FilterPeriod>.internal(
  FilterPeriodController.new,
  name: r'filterPeriodControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$filterPeriodControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$FilterPeriodController = AutoDisposeNotifier<FilterPeriod>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
