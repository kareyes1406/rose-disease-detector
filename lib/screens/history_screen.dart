import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';
import '../models/diagnosis_result.dart';
import '../services/history_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final history = HistoryService().history;
    final counts = HistoryService().counts;
    final total = history.length;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('📊 Historial y Gráficas'),
        actions: [
          if (history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _confirmClear(context),
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primary,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textSecondary,
          tabs: const [
            Tab(text: 'Gráficas'),
            Tab(text: 'Registros'),
          ],
        ),
      ),
      body: history.isEmpty
          ? _buildEmpty()
          : TabBarView(
              controller: _tabController,
              children: [
                _buildCharts(counts, total),
                _buildList(history),
              ],
            ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('📋', style: TextStyle(fontSize: 64)),
          SizedBox(height: 16),
          Text(
            'Sin diagnósticos aún',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Ve a Diagnóstico y analiza\nuna hoja de rosa',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildCharts(Map<String, int> counts, int total) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Summary cards
          Row(
            children: [
              _summaryCard('Total', total.toString(), Icons.analytics, AppTheme.primary),
              const SizedBox(width: 12),
              _summaryCard(
                'Enfermas',
                ((counts['Black Spot']! + counts['Downy Mildew']!)).toString(),
                Icons.warning_amber_outlined,
                Colors.orange,
              ),
              const SizedBox(width: 12),
              _summaryCard(
                'Sanas',
                counts['Fresh Leaf']!.toString(),
                Icons.check_circle_outline,
                AppTheme.primary,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Bar chart
          _chartCard(
            title: 'Diagnósticos por tipo',
            child: SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: (counts.values.reduce((a, b) => a > b ? a : b) + 1).toDouble(),
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        getTitlesWidget: (val, _) => Text(
                          val.toInt().toString(),
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (val, _) {
                          const labels = ['Mancha\nNegra', 'Mildiu\nVelloso', 'Hoja\nSana'];
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              labels[val.toInt()],
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 10,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(
                    show: true,
                    getDrawingHorizontalLine: (_) => const FlLine(
                      color: AppTheme.surfaceLight,
                      strokeWidth: 1,
                    ),
                    drawVerticalLine: false,
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    _bar(0, counts['Black Spot']!.toDouble(), const Color(0xFF8B0000)),
                    _bar(1, counts['Downy Mildew']!.toDouble(), const Color(0xFF4A708B)),
                    _bar(2, counts['Fresh Leaf']!.toDouble(), AppTheme.primary),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Pie chart
          if (total > 0)
            _chartCard(
              title: 'Distribución porcentual',
              child: SizedBox(
                height: 220,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 3,
                    centerSpaceRadius: 40,
                    sections: [
                      if (counts['Black Spot']! > 0)
                        PieChartSectionData(
                          color: const Color(0xFF8B0000),
                          value: counts['Black Spot']!.toDouble(),
                          title: '${(counts['Black Spot']! / total * 100).toStringAsFixed(0)}%',
                          radius: 80,
                          titleStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      if (counts['Downy Mildew']! > 0)
                        PieChartSectionData(
                          color: const Color(0xFF4A708B),
                          value: counts['Downy Mildew']!.toDouble(),
                          title: '${(counts['Downy Mildew']! / total * 100).toStringAsFixed(0)}%',
                          radius: 80,
                          titleStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      if (counts['Fresh Leaf']! > 0)
                        PieChartSectionData(
                          color: AppTheme.primary,
                          value: counts['Fresh Leaf']!.toDouble(),
                          title: '${(counts['Fresh Leaf']! / total * 100).toStringAsFixed(0)}%',
                          radius: 80,
                          titleStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 16),

          // Legend
          _buildLegend(),
        ],
      ),
    );
  }

  BarChartGroupData _bar(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 36,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
        ),
      ],
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendDot(const Color(0xFF8B0000), 'Mancha Negra'),
        const SizedBox(width: 16),
        _legendDot(const Color(0xFF4A708B), 'Mildiu Velloso'),
        const SizedBox(width: 16),
        _legendDot(AppTheme.primary, 'Hoja Sana'),
      ],
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
      ],
    );
  }

  Widget _buildList(List<DiagnosisResult> history) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: history.length,
      itemBuilder: (_, i) {
        final item = history[history.length - 1 - i]; // newest first
        final color = Color(DiagnosisResult.diseaseInfo[item.label]!['color']);
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Text(item.emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.nombre,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      '${item.fecha.day}/${item.fecha.month}/${item.fecha.year} ${item.fecha.hour}:${item.fecha.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color.withOpacity(0.4)),
                ),
                child: Text(
                  '${item.confianza}%',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _summaryCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chartCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  void _confirmClear(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('¿Limpiar historial?',
            style: TextStyle(color: AppTheme.textPrimary)),
        content: const Text(
          'Se eliminarán todos los diagnósticos guardados.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar',
                style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              await HistoryService().clear();
              if (context.mounted) {
                Navigator.pop(context);
                setState(() {});
              }
            },
            child: const Text('Limpiar',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
