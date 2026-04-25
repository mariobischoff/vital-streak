import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:heatmap_calendar_plus/heatmap_calendar_plus.dart';
import 'package:screenshot/screenshot.dart';

import '../domain/blood_pressure_logic.dart';
import '../domain/blood_pressure_reading.dart';
import '../../reports/application/export_service.dart';
import 'readings_controller.dart';
import '../../../core/design_system/app_colors.dart';
import '../../../core/design_system/app_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_button.dart';
import 'package:pressao_arterial_historico/l10n/app_localizations.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();
  final ScrollController _scrollController = ScrollController();
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Detect when user is near bottom
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(readingsControllerProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final leiturasAsyncValue = ref.watch(filteredReadingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/images/logo.png', height: 32),
            const SizedBox(width: 8),
            Text(
              'Vital Streak',
              style: AppTypography.textTheme.displaySmall?.copyWith(fontSize: 20),
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: AppColors.background,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: AppColors.textPrimary),
            tooltip: 'Export PDF',
            onPressed: () => _generateAndShareReport(),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: AppColors.textPrimary),
            tooltip: 'My Profile',
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: leiturasAsyncValue.when(
        data: (leituras) {
          if (leituras.isEmpty) {
            return _buildEmptyState(context);
          }

          // Computar Métricas (Streak & Stability)
          final streak = BloodPressureLogic.calculateCurrentStreak(
            leituras.map((l) => l.measuredAt).toList(),
          );

          // Estabilidade: Comparamos os últimos 5 registros com os 5 anteriores (se existirem)
          String stability = AppLocalizations.of(context)!.dashboardCalculating;
          if (leituras.length >= 4) {
            final mid = leituras.length ~/ 2;
            stability = BloodPressureLogic.calculateStabilityStatus(
              leituras.take(mid).map((l) => l.systolic).toList(),
              leituras.skip(mid).map((l) => l.systolic).toList(),
            );
          }

          final mSys =
              leituras.map((l) => l.systolic).reduce((a, b) => a + b) /
              leituras.length;
          final mDia =
              leituras.map((l) => l.diastolic).reduce((a, b) => a + b) /
              leituras.length;

          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              // 1. Streak & Status Header
              SliverToBoxAdapter(
                child: _buildStreakHeader(
                  context,
                  streak,
                  stability,
                  mSys,
                  mDia,
                ),
              ),

              // 2. Consistency Grid (30 Days)
              SliverToBoxAdapter(
                child: _buildConsistencySection(context, leituras),
              ),

              // 3. Trends Zoned Chart
              // 3. Trends Range Bar Chart
              SliverToBoxAdapter(
                child: Screenshot(
                  controller: _screenshotController,
                  child: _buildTrendChart(context, leituras),
                ),
              ),

              // 4. History Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 32, 20, 8),
                  child: Text(
                    AppLocalizations.of(context)!.dashboardRecentActivity,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),

              // 5. History List
              SliverPadding(
                padding: const EdgeInsets.only(bottom: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return _buildHistoryItem(context, ref, leituras[index]);
                  }, childCount: leituras.length),
                ),
              ),

              // 6. Loading More Indicator
              if (ref.read(readingsControllerProvider.notifier).hasMore)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
                ),

              const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _isExporting
          ? null
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: AppButton(
                text: AppLocalizations.of(context)!.dashboardScanNow,
                leading: const Icon(Icons.camera_alt_outlined),
                onPressed: () => context.push('/scanner'),
              ),
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.monitor_heart_outlined, size: 80, color: AppColors.primary.withValues(alpha: 0.1)),
          const SizedBox(height: 24),
          Text(
            AppLocalizations.of(context)!.dashboardEmptyTitle,
            style: AppTypography.textTheme.displaySmall,
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.dashboardEmptySubtitle,
            style: AppTypography.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakHeader(
    BuildContext context,
    int streak,
    String stability,
    double mSys,
    double mDia,
  ) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Primary Card: Challenge/Streak
          AppCard(
            color: null, // We'll use decoration for gradient
            padding: EdgeInsets.zero,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, Color(0xFFFF8E8E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.dashboardChallengeStarted,
                          style: AppTypography.textTheme.labelLarge?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$streak ${AppLocalizations.of(context)!.dashboardDays}',
                          style: AppTypography.textTheme.displayLarge?.copyWith(
                            color: Colors.white,
                            fontSize: 36,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.local_fire_department,
                    color: Colors.orangeAccent,
                    size: 48,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Average Card
          Row(
            children: [
              Expanded(
                child: AppCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.dashboardAvgBP,
                        style: AppTypography.textTheme.labelLarge?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '${mSys.toInt()}/${mDia.toInt()}',
                              style: AppTypography.textTheme.displaySmall?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: ' mmHg',
                              style: AppTypography.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.dashboardStatus,
                        style: AppTypography.textTheme.labelLarge?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        stability.toUpperCase(),
                        style: AppTypography.textTheme.titleLarge?.copyWith(
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConsistencySection(
    BuildContext context,
    List<BloodPressureReading> leituras,
  ) {
    // Preparar dados para o HeatMap
    final Map<DateTime, int> dataset = {};
    for (var reading in leituras) {
      final date = DateTime(
        reading.measuredAt.year,
        reading.measuredAt.month,
        reading.measuredAt.day,
      );
      dataset[date] = (dataset[date] ?? 0) + 1;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Text(
            AppLocalizations.of(context)!.dashboardConstancy,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
              letterSpacing: 1.2,
            ),
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            final availableWidth = constraints.maxWidth - 80;
            final cellSize = (availableWidth / 7.5).clamp(18.0, 30.0);
            final spacing = cellSize / 4;

            return AppCard(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: HeatMap(
                  datasets: dataset,
                  colorMode: ColorMode.opacity,
                  showText: false,
                  scrollable: false,
                  size: cellSize,
                  blockSpacing: spacing,
                  showColorTip: false,
                  startDate: DateTime.now().subtract(const Duration(days: 30)),
                  endDate: DateTime.now(),
                  colorsets: {1: AppColors.primary},
                  borderRadius: 8, // Close to squircular for small cells
                  onClick: (value) {},
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTrendChart(
    BuildContext context,
    List<BloodPressureReading> leituras,
  ) {
    if (leituras.isEmpty) return const SizedBox.shrink();

    final recentLeituras = leituras.take(30).toList().reversed.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
          child: Text(
            AppLocalizations.of(context)!.dashboardTrend,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
              letterSpacing: 1.2,
            ),
          ),
        ),
        AppCard(
          padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
          margin: const EdgeInsets.all(16),
          child: SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTitlesWidget: (value, meta) {
                        return Text('', style: AppTypography.textTheme.bodySmall);
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 40,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: AppTypography.textTheme.bodySmall,
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minY: 40,
                maxY: 180,
                barGroups: recentLeituras.asMap().entries.map((e) {
                  return BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        fromY: e.value.diastolic.toDouble(),
                        toY: e.value.systolic.toDouble(),
                        color: AppColors.primary,
                        width: 12,
                        borderRadius: BorderRadius.circular(4),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: 180,
                          color: AppColors.primary.withValues(alpha: 0.05),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryItem(
    BuildContext context,
    WidgetRef ref,
    BloodPressureReading leitura,
  ) {
    final cat = BloodPressureLogic.classify(
      leitura.systolic,
      leitura.diastolic,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Dismissible(
        key: Key(leitura.id ?? leitura.measuredAt.toIso8601String()),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: Colors.redAccent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        onDismissed: (_) {
          if (leitura.id != null) {
            ref.read(readingsControllerProvider.notifier).deleteReading(leitura.id!);
          }
        },
        child: AppCard(
          padding: EdgeInsets.zero,
          cornerRadius: 16,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: cat.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.favorite, color: cat.color, size: 24),
            ),
            title: Text(
              '${leitura.systolic}/${leitura.diastolic}',
              style: AppTypography.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            subtitle: Text(
              _formatDate(leitura.measuredAt),
              style: AppTypography.textTheme.bodySmall,
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  cat.label.toUpperCase(),
                  style: TextStyle(
                    color: cat.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                const Icon(Icons.chevron_right, size: 16, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final localDate = date.toLocal();
    final d = localDate.day.toString().padLeft(2, '0');
    final m = localDate.month.toString().padLeft(2, '0');
    final h = localDate.hour.toString().padLeft(2, '0');
    final min = localDate.minute.toString().padLeft(2, '0');
    return '$d/$m at $h:$min';
  }

  Future<void> _generateAndShareReport() async {
    final leituras = ref.read(filteredReadingsProvider).value;
    if (leituras == null || leituras.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No entries to export')));
      }
      return;
    }

    setState(() => _isExporting = true);

    try {
      // 1. Capturar o gráfico
      final chartBytes = await _screenshotController.capture(
        pixelRatio: 2.0, // Alta qualidade
      );

      // 2. Calcular médias para o relatório
      final mSys =
          leituras.map((l) => l.systolic).reduce((a, b) => a + b) /
          leituras.length;
      final mDia =
          leituras.map((l) => l.diastolic).reduce((a, b) => a + b) /
          leituras.length;

      // 3. Gerar e compartilhar
      await ExportService.generateAndShare(
        readings: leituras,
        chartImage: chartBytes,
        avgSys: mSys,
        avgDia: mDia,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error generating report: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }
}
