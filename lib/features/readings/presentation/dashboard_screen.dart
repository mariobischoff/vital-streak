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

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _isExporting = false;

  @override
  Widget build(BuildContext context) {
    final leiturasAsyncValue = ref.watch(filteredReadingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Blood Pressure Log'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Export PDF',
            onPressed: () => _generateAndShareReport(),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'My Profile',
            onPressed: () => context.push('/profile'),
          ),
          IconButton(
            icon: const Icon(Icons.add_box_outlined),
            tooltip: 'Manual Entry',
            onPressed: () => context.push('/manual'),
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
          String stability = 'Calculating...';
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
                  child: _buildRangeBarChart(context, leituras),
                ),
              ),

              // 4. History Header
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 24, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'RECENT ACTIVITY',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          letterSpacing: 1.1,
                        ),
                      ),
                      Divider(height: 16),
                    ],
                  ),
                ),
              ),

              // 5. History List
              SliverPadding(
                padding: const EdgeInsets.only(bottom: 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return _buildHistoryItem(context, ref, leituras[index]);
                  }, childCount: leituras.length),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      // Overlay de carregamento
      floatingActionButton: _isExporting 
        ? null 
        : FloatingActionButton.extended(
            onPressed: () => context.push('/scanner'),
            icon: const Icon(Icons.camera_alt),
            label: const Text('Scan Now'),
          ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.monitor_heart_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            'No records found.',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Text('Take your first reading to start your streak!'),
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
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'YOUR STREAK',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.local_fire_department,
                    color: Colors.orangeAccent,
                    size: 28,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$streak Days',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Trend: $stability',
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'AVG',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              Text(
                '${mSys.toInt()}/${mDia.toInt()}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const Text(
                'mmHg',
                style: TextStyle(color: Colors.white60, fontSize: 10),
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
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Text(
            'LAST 30 DAYS CONSTANCY',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            // Cálculo responsivo: tentamos preencher a largura de forma equilibrada.
            // Consideramos 6-8 semanas para os últimos 30 dias + labels laterais.
            final availableWidth = constraints.maxWidth - 80; 
            final cellSize = (availableWidth / 7.5).clamp(18.0, 30.0);
            final spacing = cellSize / 4;

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: HeatMap(
                  datasets: dataset,
                  colorMode: ColorMode.opacity,
                  showText: true,
                  scrollable: false,
                  size: cellSize,
                  blockSpacing: spacing,
                  showColorTip: false,
                  startDate: DateTime.now().subtract(const Duration(days: 30)),
                  endDate: DateTime.now(),
                  colorsets: {1: Theme.of(context).colorScheme.primary},
                  onClick: (value) {},
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRangeBarChart(
    BuildContext context,
    List<BloodPressureReading> leituras,
  ) {
    if (leituras.isEmpty) return const SizedBox.shrink();

    // Pegamos as últimas 7 ou 10 leituras para não poluir muito a horizontal
    final recentLeituras = leituras.take(10).toList().reversed.toList();

    return Container(
      height: 240,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: BarChart(
        BarChartData(
          minY: 40,
          maxY: 180,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => Theme.of(context).colorScheme.primaryContainer,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final reading = recentLeituras[group.x.toInt()];
                return BarTooltipItem(
                  '${reading.systolic}/${reading.diastolic}\n',
                  TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(
                      text: _formatDate(reading.measuredAt),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 40,
            getDrawingHorizontalLine: (v) => FlLine(
              color: Colors.grey.withValues(alpha: 0.1),
              strokeWidth: 1,
            ),
          ),
          extraLinesData: ExtraLinesData(
            horizontalLines: [
              HorizontalLine(
                y: 110, // Centro da zona normal (80-140 aprox combinando sys/dia)
                color: Colors.green.withValues(alpha: 0.05),
                strokeWidth: 60,
                label: HorizontalLineLabel(
                  show: true,
                  alignment: Alignment.topRight,
                  labelResolver: (line) => 'NORMAL ZONE',
                  style: const TextStyle(fontSize: 9, color: Colors.green),
                ),
              ),
            ],
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= recentLeituras.length) return const SizedBox.shrink();
                  final date = recentLeituras[value.toInt()].measuredAt;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      '${date.day}/${date.month}',
                      style: const TextStyle(fontSize: 9, color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40, // Aumentado de 30 para 40
                interval: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: recentLeituras.asMap().entries.map((e) {
            final idx = e.key;
            final leitura = e.value;
            final cat = BloodPressureLogic.classify(leitura.systolic, leitura.diastolic);

            return BarChartGroupData(
              x: idx,
              barRods: [
                BarChartRodData(
                  fromY: leitura.diastolic.toDouble(),
                  toY: leitura.systolic.toDouble(),
                  color: cat.color,
                  width: 12,
                  borderRadius: BorderRadius.circular(6),
                ),
              ],
            );
          }).toList(),
        ),
      ),
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

    return Dismissible(
      key: Key(leitura.id ?? leitura.measuredAt.toIso8601String()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.redAccent,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        if (leitura.id != null) {
          ref
              .read(readingsControllerProvider.notifier)
              .deleteReading(leitura.id!);
        }
      },
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: cat.color.withValues(alpha: 0.1),
          child: Icon(Icons.favorite, color: cat.color, size: 20),
        ),
        title: Text(
          '${leitura.systolic}/${leitura.diastolic}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(_formatDate(leitura.measuredAt)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              cat.label,
              style: TextStyle(
                color: cat.color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
          ],
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No entries to export')),
        );
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating report: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }
}
