import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../core/app_export.dart';
import '../../services/body_metrics_storage.dart';

class BodyMetricsScreen extends StatefulWidget {
  const BodyMetricsScreen({super.key});

  @override
  State<BodyMetricsScreen> createState() => _BodyMetricsScreenState();
}

class _BodyMetricsScreenState extends State<BodyMetricsScreen> {
  DateTime _selectedDate = DateTime.now();
  Map<String, dynamic> _metrics = {};
  List<(DateTime, Map<String, dynamic>)> _recent = const [];

  @override
  void initState() {
    super.initState();
    _load();
    // Handle route arguments (date, openEditor)
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map) {
        final dateArg = args['date'];
        if (dateArg is String) {
          try {
            final d = DateTime.parse(dateArg);
            setState(() => _selectedDate = DateTime(d.year, d.month, d.day));
            await _load();
          } catch (_) {}
        } else if (dateArg is DateTime) {
          setState(() => _selectedDate = DateTime(dateArg.year, dateArg.month, dateArg.day));
          await _load();
        }
        final openEditor = args['openEditor'] == true;
        if (openEditor) {
          _openEditor();
        }
      }
    });
  }

  Future<void> _load() async {
    final m = await BodyMetricsStorage.getForDate(_selectedDate);
    final r = await BodyMetricsStorage.getRecent(days: 30);
    if (!mounted) return;
    setState(() {
      _metrics = m;
      _recent = r;
    });
  }

  double? _bmi() {
    final w = (_metrics['weightKg'] as num?)?.toDouble();
    final hCm = (_metrics['heightCm'] as num?)?.toDouble();
    if (w == null || hCm == null || hCm <= 0) return null;
    final h = hCm / 100.0;
    return w / (h * h);
  }

  void _openEditor() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.secondaryBackgroundDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _BodyMetricsEditor(
        initial: _metrics,
        onSaved: (data) async {
          await BodyMetricsStorage.setForDate(_selectedDate, data);
          if (!mounted) return;
          Navigator.pop(ctx);
          await _load();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bmi = _bmi();
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Valores Corporais'),
        actions: [
          IconButton(
            tooltip: 'Registrar',
            onPressed: _openEditor,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top grid cards
            Row(
              children: [
                Expanded(child: _metricCard(
                  icon: MdiIcons.weightKilogram,
                  title: 'Peso',
                  value: (_metrics['weightKg'] as num?)?.toString() ?? '--',
                  unit: 'kg',
                  color: AppTheme.warningAmber,
                )),
                SizedBox(width: 3.w),
                Expanded(child: _metricCard(
                  icon: MdiIcons.humanMaleHeight,
                  title: 'Altura',
                  value: (_metrics['heightCm'] as num?)?.toString() ?? '--',
                  unit: 'cm',
                  color: AppTheme.successGreen,
                )),
              ],
            ),
            SizedBox(height: 1.2.h),
            Row(
              children: [
                Expanded(child: _metricCard(
                  icon: MdiIcons.human,
                  title: 'IMC',
                  value: bmi != null ? bmi.toStringAsFixed(1) : '--',
                  unit: '',
                  color: AppTheme.activeBlue,
                )),
                SizedBox(width: 3.w),
                Expanded(child: _metricCard(
                  icon: MdiIcons.heartPulse,
                  title: 'Gordura',
                  value: (_metrics['bodyFatPct'] as num?)?.toString() ?? '--',
                  unit: '%',
                  color: AppTheme.errorRed,
                )),
              ],
            ),

            SizedBox(height: 2.h),
            Text('Evolução do peso (30 dias)', style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: 1.h),
            Container(
              height: 22.h,
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
              ),
              padding: const EdgeInsets.all(12),
              child: _weightChart(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openEditor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _metricCard({required IconData icon, required String title, required String value, required String unit, required Color color}) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: color.withValues(alpha: 0.15),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                )),
                const SizedBox(height: 2),
                Text(
                  unit.isNotEmpty ? '$value $unit' : value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _weightChart() {
    final points = <FlSpot>[];
    double x = 0;
    for (final e in _recent) {
      final w = (e.$2['weightKg'] as num?)?.toDouble();
      if (w != null) {
        points.add(FlSpot(x, w));
        x += 1;
      }
    }
    if (points.isEmpty) {
      return Center(
        child: Text('Sem dados recentes', style: Theme.of(context).textTheme.bodySmall),
      );
    }
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: points,
            isCurved: true,
            color: AppTheme.activeBlue,
            barWidth: 2,
            dotData: const FlDotData(show: false),
          )
        ],
      ),
    );
  }
}

class _BodyMetricsEditor extends StatefulWidget {
  final Map<String, dynamic> initial;
  final void Function(Map<String, dynamic>) onSaved;
  const _BodyMetricsEditor({required this.initial, required this.onSaved});

  @override
  State<_BodyMetricsEditor> createState() => _BodyMetricsEditorState();
}

class _BodyMetricsEditorState extends State<_BodyMetricsEditor> {
  late TextEditingController weight;
  late TextEditingController height;
  late TextEditingController fat;
  late TextEditingController waist;
  late TextEditingController hip;
  late TextEditingController chest;

  @override
  void initState() {
    super.initState();
    weight = TextEditingController(text: _get(widget.initial['weightKg']));
    height = TextEditingController(text: _get(widget.initial['heightCm']));
    fat = TextEditingController(text: _get(widget.initial['bodyFatPct']));
    waist = TextEditingController(text: _get(widget.initial['waistCm']));
    hip = TextEditingController(text: _get(widget.initial['hipCm']));
    chest = TextEditingController(text: _get(widget.initial['chestCm']));
  }

  String _get(dynamic v) {
    if (v == null) return '';
    if (v is num) return v.toString();
    return v.toString();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 4.w,
          right: 4.w,
          top: 1.2.h,
          bottom: MediaQuery.of(context).viewInsets.bottom + 1.2.h,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.dividerGray, borderRadius: BorderRadius.circular(2))),
            SizedBox(height: 1.2.h),
            Row(
              children: [
                Expanded(child: _field('Peso (kg)', weight)),
                SizedBox(width: 3.w),
                Expanded(child: _field('Altura (cm)', height)),
              ],
            ),
            SizedBox(height: 0.8.h),
            Row(
              children: [
                Expanded(child: _field('% Gordura', fat)),
                SizedBox(width: 3.w),
                Expanded(child: _field('Cintura (cm)', waist)),
              ],
            ),
            SizedBox(height: 0.8.h),
            Row(
              children: [
                Expanded(child: _field('Quadril (cm)', hip)),
                SizedBox(width: 3.w),
                Expanded(child: _field('Peito (cm)', chest)),
              ],
            ),
            SizedBox(height: 1.2.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  final m = <String, dynamic>{};
                  double? n(String s) => s.trim().isEmpty ? null : double.tryParse(s.trim());
                  final w = n(weight.text);
                  final h = n(height.text);
                  if (w != null) m['weightKg'] = w;
                  if (h != null) m['heightCm'] = h;
                  final f = n(fat.text);
                  if (f != null) m['bodyFatPct'] = f;
                  final wc = n(waist.text);
                  if (wc != null) m['waistCm'] = wc;
                  final hc = n(hip.text);
                  if (hc != null) m['hipCm'] = hc;
                  final cc = n(chest.text);
                  if (cc != null) m['chestCm'] = cc;
                  widget.onSaved(m);
                },
                icon: const Icon(Icons.save),
                label: const Text('Salvar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.activeBlue,
                  foregroundColor: Colors.white,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctl) => TextField(
        controller: ctl,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(labelText: label, isDense: true),
      );
}
