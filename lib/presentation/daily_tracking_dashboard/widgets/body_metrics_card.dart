import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class BodyMetricsCard extends StatelessWidget {
  final VoidCallback onAddMetrics;
  final double? currentWeight;
  final double? goalWeight;
  final double? lastWeight;
  final String weightUnit;
  final bool hasEntry;
  final List<double>? weeklyWeights; // ordered oldest -> newest
  final double? weeklyChange; // last - first over the week
  final void Function(double delta)? onAdjustWeight;

  const BodyMetricsCard({
    super.key,
    required this.onAddMetrics,
    this.currentWeight,
    this.goalWeight,
    this.lastWeight,
    this.weightUnit = 'kg',
    this.hasEntry = false,
    this.weeklyWeights,
    this.weeklyChange,
    this.onAdjustWeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Body Metrics',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1A1A),
                      ),
                ),
                TextButton(
                  onPressed: onAddMetrics,
                  child: const Text(
                    'More',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF5B7FFF),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Card principal (gradiente escuro)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF4A5568), Color(0xFF2D3748)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: hasEntry ? _buildWeightTracker(context) : _buildEmptyState(context),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightTracker(BuildContext context) {
    final change = weeklyChange;
    final isDown = (change ?? 0) < 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Weight',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        if (goalWeight != null)
          Text(
            'Goal: ${goalWeight!.toStringAsFixed(1)} $weightUnit',
            style: const TextStyle(fontSize: 13, color: Color(0xFFB8C5D6)),
          ),
        const SizedBox(height: 16),

        if (weeklyWeights != null && weeklyWeights!.isNotEmpty)
          SizedBox(
            height: 40,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: weeklyWeights!
                        .asMap()
                        .entries
                        .map((e) => FlSpot(e.key.toDouble(), e.value))
                        .toList(),
                    isCurved: true,
                    color: Colors.white70,
                    barWidth: 2,
                    dotData: const FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 12),

        if (lastWeight != null)
          Column(
            children: [
              Text(
                'Último: ${lastWeight!.toStringAsFixed(1)} $weightUnit (Ontem)',
                style: const TextStyle(fontSize: 13, color: Color(0xFFB8C5D6)),
              ),
              if (change != null) ...[
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(isDown ? Icons.arrow_downward : Icons.arrow_upward,
                        size: 16,
                        color: isDown
                            ? const Color(0xFF4CAF50)
                            : const Color(0xFFFF9800)),
                    const SizedBox(width: 4),
                    Text(
                      '${change.abs().toStringAsFixed(1)} $weightUnit esta semana',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDown
                            ? const Color(0xFF4CAF50)
                            : const Color(0xFFFF9800),
                      ),
                    ),
                    if (isDown) const Text(' 💪', style: TextStyle(fontSize: 13)),
                  ],
                ),
              ],
            ],
          ),

        const SizedBox(height: 16),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildControlButton(
              icon: Icons.remove,
              onPressed: () => onAdjustWeight?.call(-0.1),
            ),
            const SizedBox(width: 24),
            Text(
              '${(currentWeight ?? 0).toStringAsFixed(1)} $weightUnit',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 24),
            _buildControlButton(
              icon: Icons.add,
              onPressed: () => onAdjustWeight?.call(0.1),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Column(
      children: [
        if (weeklyWeights != null && weeklyWeights!.isNotEmpty) ...[
          SizedBox(
            height: 40,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: weeklyWeights!
                        .asMap()
                        .entries
                        .map((e) => FlSpot(e.key.toDouble(), e.value))
                        .toList(),
                    isCurved: true,
                    color: Colors.white70,
                    barWidth: 2,
                    dotData: const FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.monitor_weight_outlined,
            size: 32,
            color: Colors.white70,
          ),
        ),

        const SizedBox(height: 16),
        const Text(
          'Como está seu progresso hoje?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'Registrar agora ajuda você a\nmanter o foco ✨',
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFFB8C5D6),
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: onAddMetrics,
          icon: const Icon(Icons.straighten, size: 20),
          label: const Text(
            'Registrar Peso',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF5B7FFF),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _buildControlButton({required IconData icon, required VoidCallback onPressed}) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
      ),
    );
  }
}
