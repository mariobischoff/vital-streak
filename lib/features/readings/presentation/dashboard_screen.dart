import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/blood_pressure_reading.dart';
import '../domain/blood_pressure_logic.dart';
import 'readings_controller.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leiturasAsyncValue = ref.watch(filteredReadingsProvider);
    final filtroAtual = ref.watch(filterPeriodControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Blood Pressure Log'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildFilterBar(context, ref, filtroAtual),
          Expanded(
            child: leiturasAsyncValue.when(
              data: (leituras) {
                if (leituras.isEmpty) {
                  return _buildEmptyState(context);
                }

                // Computar estatísticas
                final double mediaSys =
                    leituras.map((l) => l.systolic).reduce((a, b) => a + b) /
                    leituras.length;
                final double mediaDia =
                    leituras.map((l) => l.diastolic).reduce((a, b) => a + b) /
                    leituras.length;
                final ultimaLeitura =
                    leituras.first; // lista já está ordenada desc

                String labelMedia = 'Overall Average';
                if (filtroAtual == FilterPeriod.sevenDays) {
                  labelMedia = 'Average (7 days)';
                } else if (filtroAtual == FilterPeriod.thirtyDays) {
                  labelMedia = 'Average (30 days)';
                }

                return Column(
                  children: [
                    _buildStatsHeader(
                      context,
                      ultimaLeitura,
                      mediaSys,
                      mediaDia,
                      labelMedia,
                    ),
                    _buildChartSection(context, leituras),
                    const Divider(height: 1),
                    Expanded(child: _buildHistoryList(context, ref, leituras)),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text(
                  'Error loading data:\n$error',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/scanner');
        },
        icon: const Icon(Icons.camera_alt),
        label: const Text('Scan Display'),
      ),
    );
  }

  Widget _buildFilterBar(
    BuildContext context,
    WidgetRef ref,
    FilterPeriod filtroAtual,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: SegmentedButton<FilterPeriod>(
        segments: const [
          ButtonSegment(value: FilterPeriod.sevenDays, label: Text('7 Days')),
          ButtonSegment(value: FilterPeriod.thirtyDays, label: Text('30 Days')),
          ButtonSegment(value: FilterPeriod.all, label: Text('All')),
        ],
        selected: {filtroAtual},
        onSelectionChanged: (Set<FilterPeriod> newSelection) {
          ref
              .read(filterPeriodControllerProvider.notifier)
              .changeFilter(newSelection.first);
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.monitor_heart_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No measurements recorded yet',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Use the camera to scan your monitor',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsHeader(
    BuildContext context,
    BloodPressureReading ultima,
    double mSys,
    double mDia,
    String labelMedia,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              label: 'Latest',
              value: '${ultima.systolic}/${ultima.diastolic}',
              color: BloodPressureLogic.classify(
                ultima.systolic,
                ultima.diastolic,
              ).color,
              icon: Icons.history,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              label: labelMedia,
              value: '${mSys.toInt()}/${mDia.toInt()}',
              color: Theme.of(context).colorScheme.secondary,
              icon: Icons.analytics_outlined,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection(
    BuildContext context,
    List<BloodPressureReading> leituras,
  ) {
    // Para o gráfico, é melhor ordenar cronologicamente (ascendente)
    final leiturasCronologicas = leituras.reversed.toList();

    return Container(
      height: 220,
      padding: const EdgeInsets.only(right: 24, left: 16, top: 24, bottom: 12),
      child: LineChart(
        LineChartData(
          minY: 40,
          maxY: 200,
          lineBarsData: [
            LineChartBarData(
              spots: leiturasCronologicas.asMap().entries.map((e) {
                return FlSpot(e.key.toDouble(), e.value.systolic.toDouble());
              }).toList(),
              isCurved: true,
              color: Colors.redAccent,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) =>
                    FlDotCirclePainter(
                      radius: 3,
                      color: Colors.redAccent,
                      strokeWidth: 1,
                      strokeColor: Colors.white,
                    ),
              ),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.redAccent.withValues(alpha: 0.1),
              ),
            ),
            LineChartBarData(
              spots: leiturasCronologicas.asMap().entries.map((e) {
                return FlSpot(e.key.toDouble(), e.value.diastolic.toDouble());
              }).toList(),
              isCurved: true,
              color: Colors.blueAccent,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) =>
                    FlDotCirclePainter(
                      radius: 3,
                      color: Colors.blueAccent,
                      strokeWidth: 1,
                      strokeColor: Colors.white,
                    ),
              ),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.blueAccent.withValues(alpha: 0.1),
              ),
            ),
          ],
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ), // Ocultar eixo X por ora
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: const Border(
              bottom: BorderSide(color: Colors.grey, width: 1),
              left: BorderSide(color: Colors.grey, width: 1),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 40,
            getDrawingHorizontalLine: (value) => const FlLine(
              color: Colors.black12,
              strokeWidth: 1,
              dashArray: [5, 5],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryList(
    BuildContext context,
    WidgetRef ref,
    List<BloodPressureReading> leituras,
  ) {
    return ListView.builder(
      itemCount: leituras.length,
      itemBuilder: (context, index) {
        final leitura = leituras[index];
        final corCard = _getPressureColor(leitura.systolic, leitura.diastolic);

        return Dismissible(
          key: Key(leitura.id.toString()),
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          direction: DismissDirection.endToStart,
          confirmDismiss: (direction) async {
            return await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Confirm"),
                  content: const Text(
                    "Do you really want to delete this reading?",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text(
                        "Delete",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                );
              },
            );
          },
          onDismissed: (direction) {
            if (leitura.id != null) {
              ref
                  .read(readingsControllerProvider.notifier)
                  .deleteReading(leitura.id!);
            }
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Reading deleted')));
          },
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: ListTile(
              leading: Container(
                width: 12,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: BloodPressureLogic.classify(
                    leitura.systolic,
                    leitura.diastolic,
                  ).color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              title: Text(
                '${leitura.systolic} / ${leitura.diastolic} mmHg',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              subtitle: Text(_formatDate(leitura.measuredAt)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.monitor_heart,
                    color: BloodPressureLogic.classify(
                      leitura.systolic,
                      leitura.diastolic,
                    ).color,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final h = date.hour.toString().padLeft(2, '0');
    final min = date.minute.toString().padLeft(2, '0');
    return '$d/$m/${date.year} at $h:$min';
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: color.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const Text(
            'mmHg',
            style: TextStyle(fontSize: 10, color: Colors.black38),
          ),
        ],
      ),
    );
  }
}
