import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/user_preferences.dart';

class ProSubscriptionScreen extends StatefulWidget {
  const ProSubscriptionScreen({super.key});

  @override
  State<ProSubscriptionScreen> createState() => _ProSubscriptionScreenState();
}

class _ProSubscriptionScreenState extends State<ProSubscriptionScreen> {
  final List<_ProPlanOption> _plans = const [
    _ProPlanOption(
      id: '12m',
      title: '12 meses',
      monthlyPrice: 'R\$ 14,99/mês',
      totalPrice: 'R\$ 179,90',
      oldPrice: 'R\$ 359,90',
      badge: 'Mais popular',
      description: 'Economia de 50% no plano anual',
    ),
    _ProPlanOption(
      id: '3m',
      title: '3 meses',
      monthlyPrice: 'R\$ 30,00/mês',
      totalPrice: 'R\$ 89,99',
      description: 'Flexibilidade com economia trimestral',
    ),
    _ProPlanOption(
      id: '1m',
      title: '1 mês',
      monthlyPrice: 'R\$ 39,90/mês',
      totalPrice: 'Cobrança mensal',
      description: 'Ideal para experimentar todos os recursos',
    ),
  ];

  final List<_ProFeature> _features = const [
    _ProFeature(
      icon: Icons.restaurant_menu,
      title: 'Planos personalizados',
      subtitle: 'Cardápios e ciclos de jejum ajustados às suas metas.',
    ),
    _ProFeature(
      icon: Icons.qr_code_scanner,
      title: 'Scanner inteligente',
      subtitle: 'Barcode + OCR para lançar refeições em segundos.',
    ),
    _ProFeature(
      icon: Icons.auto_graph_outlined,
      title: 'Insights avançados',
      subtitle: 'Relatórios preditivos e ajustes automáticos de meta.',
    ),
    _ProFeature(
      icon: Icons.menu_book_outlined,
      title: 'Receitas exclusivas',
      subtitle: 'Coleção PRO com macros calculados e filtros avançados.',
    ),
  ];

  final List<_ProGuarantee> _guarantees = const [
    _ProGuarantee(
      icon: Icons.calendar_month_outlined,
      label: 'Cancele quando quiser',
    ),
    _ProGuarantee(
      icon: Icons.verified_outlined,
      label: '7 dias de garantia',
    ),
    _ProGuarantee(
      icon: Icons.star_rate_outlined,
      label: 'Avaliação média 4,8/5',
    ),
  ];

  int _selectedPlan = 0;
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  Text(
                    'NutriTracker PRO',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  const SizedBox(width: 48), // balance icon button width
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeroHeader(context),
                    SizedBox(height: 2.5.h),
                    Text(
                      'Escolha seu plano PRO',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    SizedBox(height: 1.2.h),
                    ..._plans.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final plan = entry.value;
                      final bool selected = _selectedPlan == idx;
                      return Padding(
                        padding: EdgeInsets.only(bottom: 1.4.h),
                        child: _ProPlanCard(
                          plan: plan,
                          selected: selected,
                          onTap: () => setState(() => _selectedPlan = idx),
                        ),
                      );
                    }).toList(),
                    SizedBox(height: 2.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: _guarantees
                          .map((g) => _GuaranteeChip(data: g))
                          .toList(),
                    ),
                    SizedBox(height: 2.4.h),
                    Text(
                      'Tudo o que você desbloqueia',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    SizedBox(height: 1.2.h),
                    ..._features.map((feature) => Padding(
                          padding: EdgeInsets.symmetric(vertical: 0.8.h),
                          child: _FeatureTile(data: feature),
                        )),
                    SizedBox(height: 2.4.h),
                    Container(
                      padding: EdgeInsets.all(3.6.w),
                      decoration: BoxDecoration(
                        color: AppTheme.activeBlue.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppTheme.activeBlue.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nosso compromisso',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.activeBlue,
                                ),
                          ),
                          SizedBox(height: 0.8.h),
                          Text(
                            'Se o plano não fizer sentido para a sua rotina, basta cancelar diretamente pelo app. Nenhuma taxa escondida.',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      'Ao continuar, você concorda com os termos de uso. A assinatura se renova automaticamente até que seja cancelada.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    SizedBox(height: 18.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 2.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Cancele quando quiser',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            SizedBox(height: 1.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _activateSelectedPlan,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 1.8.h),
                  backgroundColor: AppTheme.activeBlue,
                  foregroundColor: AppTheme.textPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isProcessing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : Text('Continuar com ${_plans[_selectedPlan].title}'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.5.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Theme.of(context)
              .colorScheme
              .outlineVariant
              .withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 18.w,
            height: 18.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppTheme.activeBlue,
                  AppTheme.premiumGold.withValues(alpha: 0.9),
                ],
              ),
            ),
            child: const Icon(Icons.local_fire_department,
                color: Colors.white, size: 36),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chegou a hora de acelerar seus resultados',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                SizedBox(height: 0.8.h),
                Text(
                  'Desbloqueie planos guiados, relatórios avançados e suporte dedicado para atingir suas metas com confiança.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _activateSelectedPlan() async {
    setState(() => _isProcessing = true);
    await UserPreferences.setPremiumStatus(true,
        planId: _plans[_selectedPlan].id, purchaseDate: DateTime.now());
    if (!mounted) return;
    setState(() => _isProcessing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Assinatura ${_plans[_selectedPlan].title} ativada!'),
        backgroundColor: AppTheme.successGreen,
      ),
    );
    Navigator.pop(context, true);
  }
}

class _ProPlanOption {
  final String id;
  final String title;
  final String monthlyPrice;
  final String totalPrice;
  final String? oldPrice;
  final String? badge;
  final String description;

  const _ProPlanOption({
    required this.id,
    required this.title,
    required this.monthlyPrice,
    required this.totalPrice,
    this.oldPrice,
    this.badge,
    required this.description,
  });
}

class _ProFeature {
  final IconData icon;
  final String title;
  final String subtitle;

  const _ProFeature({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}

class _ProGuarantee {
  final IconData icon;
  final String label;

  const _ProGuarantee({required this.icon, required this.label});
}

class _ProPlanCard extends StatelessWidget {
  final _ProPlanOption plan;
  final bool selected;
  final VoidCallback onTap;

  const _ProPlanCard({
    required this.plan,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color highlight = AppTheme.activeBlue;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: selected
              ? highlight.withValues(alpha: 0.12)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? highlight
                : Theme.of(context)
                    .colorScheme
                    .outlineVariant
                    .withValues(alpha: 0.2),
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            plan.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          if (plan.badge != null) ...[
                            SizedBox(width: 2.w),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: highlight,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                plan.badge!,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 0.6.h),
                      Text(
                        plan.monthlyPrice,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: highlight,
                            ),
                      ),
                      SizedBox(height: 0.4.h),
                      Text(
                        plan.totalPrice,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Radio<int>(
                  value: 1,
                  groupValue: selected ? 1 : 0,
                  activeColor: highlight,
                  onChanged: (_) => onTap(),
                ),
              ],
            ),
            if (plan.oldPrice != null) ...[
              SizedBox(height: 0.4.h),
              Text(
                plan.oldPrice!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      decoration: TextDecoration.lineThrough,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
            SizedBox(height: 1.h),
            Text(
              plan.description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final _ProFeature data;

  const _FeatureTile({required this.data});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 12.w,
          height: 12.w,
          decoration: BoxDecoration(
            color: AppTheme.premiumGold.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(data.icon, color: AppTheme.premiumGold),
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              SizedBox(height: 0.4.h),
              Text(
                data.subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GuaranteeChip extends StatelessWidget {
  final _ProGuarantee data;

  const _GuaranteeChip({required this.data});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.4.h),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context)
                .colorScheme
                .outlineVariant
                .withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(data.icon, color: AppTheme.activeBlue),
            SizedBox(height: 0.6.h),
            Text(
              data.label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
