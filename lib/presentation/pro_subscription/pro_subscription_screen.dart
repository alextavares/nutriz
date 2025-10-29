import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../core/app_export.dart';
import '../../services/user_preferences.dart';
import '../../services/purchase_service.dart';

class ProSubscriptionScreen extends StatefulWidget {
  const ProSubscriptionScreen({super.key});

  @override
  State<ProSubscriptionScreen> createState() => _ProSubscriptionScreenState();
}

class _ProSubscriptionScreenState extends State<ProSubscriptionScreen> {
  // Will be populated from RevenueCat offerings
  List<Package> _packages = [];
  bool _isLoading = true;
  String? _errorMessage;

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
  void initState() {
    super.initState();
    _loadOfferings();
  }

  Future<void> _loadOfferings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final packages = await PurchaseService.getOfferings();

      if (!mounted) return;

      if (packages.isEmpty) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Nenhum plano disponível no momento.\nTente novamente mais tarde.';
        });
        return;
      }

      setState(() {
        _packages = packages;
        _isLoading = false;
        // Select first package by default (usually the best value)
        _selectedPlan = 0;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = 'Erro ao carregar planos.\nVerifique sua conexão.';
      });
    }
  }

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
                    if (_isLoading) ...[
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ] else if (_errorMessage != null) ...[
                      Container(
                        padding: EdgeInsets.all(4.w),
                        margin: EdgeInsets.symmetric(vertical: 2.h),
                        decoration: BoxDecoration(
                          color: AppTheme.errorRed.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.errorRed.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.error_outline, size: 48, color: AppTheme.errorRed),
                            SizedBox(height: 2.h),
                            Text(
                              _errorMessage!,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            SizedBox(height: 2.h),
                            ElevatedButton.icon(
                              onPressed: _loadOfferings,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Tentar novamente'),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      ..._packages.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final package = entry.value;
                        final bool selected = _selectedPlan == idx;
                        return Padding(
                          padding: EdgeInsets.only(bottom: 1.4.h),
                          child: _ProPackageCard(
                            package: package,
                            selected: selected,
                            onTap: () => setState(() => _selectedPlan = idx),
                          ),
                        );
                      }).toList(),
                    ],
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
                    : Text(_packages.isNotEmpty
                        ? 'Continuar com ${_getPackageTitle(_packages[_selectedPlan])}'
                        : 'Continuar'),
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
    if (_packages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Nenhum plano selecionado'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final result = await PurchaseService.purchasePackage(_packages[_selectedPlan]);

      if (!mounted) return;

      setState(() => _isProcessing = false);

      if (result.success && result.isPremium) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: AppTheme.successGreen,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() => _isProcessing = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro inesperado: $e'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  String _getPackageTitle(Package package) {
    // Extract readable title from package identifier
    // You can customize this based on your RevenueCat package identifiers
    switch (package.packageType) {
      case PackageType.annual:
        return '12 meses';
      case PackageType.threeMonth:
        return '3 meses';
      case PackageType.monthly:
        return '1 mês';
      case PackageType.sixMonth:
        return '6 meses';
      case PackageType.weekly:
        return '1 semana';
      default:
        return package.storeProduct.title;
    }
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

// New widget that uses RevenueCat Package data
class _ProPackageCard extends StatelessWidget {
  final Package package;
  final bool selected;
  final VoidCallback onTap;

  const _ProPackageCard({
    required this.package,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color highlight = AppTheme.activeBlue;
    final product = package.storeProduct;

    // Determine if this is the best value package (typically annual)
    final isBestValue = package.packageType == PackageType.annual;

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
                            _getPackageTitle(package.packageType),
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          if (isBestValue) ...[
                            SizedBox(width: 2.w),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: highlight,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Mais popular',
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
                        product.priceString,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: highlight,
                            ),
                      ),
                      SizedBox(height: 0.4.h),
                      Text(
                        _getPackageDescription(package.packageType),
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
          ],
        ),
      ),
    );
  }

  String _getPackageTitle(PackageType type) {
    switch (type) {
      case PackageType.annual:
        return '12 meses';
      case PackageType.threeMonth:
        return '3 meses';
      case PackageType.monthly:
        return '1 mês';
      case PackageType.sixMonth:
        return '6 meses';
      case PackageType.weekly:
        return '1 semana';
      default:
        return 'Plano';
    }
  }

  String _getPackageDescription(PackageType type) {
    switch (type) {
      case PackageType.annual:
        return 'Melhor custo-benefício';
      case PackageType.threeMonth:
        return 'Flexibilidade trimestral';
      case PackageType.monthly:
        return 'Ideal para experimentar';
      case PackageType.sixMonth:
        return 'Plano semestral';
      case PackageType.weekly:
        return 'Teste por 1 semana';
      default:
        return 'Plano de assinatura';
    }
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
