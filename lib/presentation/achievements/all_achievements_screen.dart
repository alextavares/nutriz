import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../services/achievement_service.dart';
import '../../services/user_preferences.dart';
import '../../core/app_export.dart';
import 'package:nutritracker/l10n/generated/app_localizations.dart';

class AllAchievementsScreen extends StatefulWidget {
  const AllAchievementsScreen({super.key});

  @override
  State<AllAchievementsScreen> createState() => _AllAchievementsScreenState();
}

class _AllAchievementsScreenState extends State<AllAchievementsScreen> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _all = [];
  String _filterType = 'all'; // all|success|flame|diamond|star
  String _filterMeta = 'all'; // all|water|fasting|calories|protein|test
  String _sort = 'recent'; // recent|oldest|type
  late TabController _tab;
  Set<String> _favorites = <String>{};
  bool _grid = false;
  int _newMinutes = 5;

  @override
  void initState() {
    super.initState();
    // Tabs: Todas, Água, Jejum, Calorias, Proteína, Alimentos, Teste, Favoritos
    _tab = TabController(length: 8, vsync: this);
    _tab.addListener(() {
      if (_tab.indexIsChanging) return;
      setState(() {
        // Map first 7 tabs to meta filters; last tab (index 7) is Favorites
        if (_tab.index <= 6) {
          _filterMeta = const ['all', 'water', 'fasting', 'calories', 'protein', 'food_log', 'test'][_tab.index];
        } else {
          _filterMeta = 'all';
        }
      });
    });
    _load();
    // Load UI prefs for "new" highlight
    UserPreferences.getNewBadgeMinutes().then((m) {
      if (mounted) setState(() => _newMinutes = m);
    });
  }

  Future<void> _load() async {
    final items = await AchievementService.listAll();
    final favs = await AchievementService.getFavorites();
    setState(() {
      _all = items;
      _favorites = favs;
    });
  }

  List<Map<String, dynamic>> get _filtered {
    final list = List<Map<String, dynamic>>.from(_all);
    list.removeWhere((a) {
      final t = (a['type'] as String?) ?? '';
      final m = (a['metaKey'] as String?) ?? '';
      if (_filterType != 'all' && t != _filterType) return true;
      // Tab index 6 => favorites
      if (_tab.index == 6) {
        final id = (a['id']?.toString() ?? '');
        if (!_favorites.contains(id)) return true;
      } else {
        if (_filterMeta != 'all' && m != _filterMeta) return true;
      }
      return false;
    });
    switch (_sort) {
      case 'recent':
        list.sort((a, b) => (b['dateIso'] as String?)?.compareTo(a['dateIso'] as String? ?? '') ?? 0);
        break;
      case 'oldest':
        list.sort((a, b) => (a['dateIso'] as String?)?.compareTo(b['dateIso'] as String? ?? '') ?? 0);
        break;
      case 'type':
        list.sort((a, b) => ((a['type'] as String?) ?? '').compareTo((b['type'] as String?) ?? ''));
        break;
    }
    return list;
  }

  bool _isNew(Map<String, dynamic> a) {
    final iso = (a['dateIso'] as String?) ?? '';
    DateTime? d;
    try { d = DateTime.parse(iso); } catch (_) {}
    if (d == null) return false;
    final age = DateTime.now().difference(d).inMinutes;
    return age >= 0 && age <= _newMinutes;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppTheme.primaryBackgroundDark,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryBackgroundDark,
        title: Text(AppLocalizations.of(context)?.achievementsTitle ?? 'Achievements'),
        bottom: TabBar(
          controller: _tab,
          tabs: [
            Tab(text: AppLocalizations.of(context)?.achievementsTabAll ?? 'All'),
            Tab(text: AppLocalizations.of(context)?.achievementsTabWater ?? 'Water'),
            Tab(text: AppLocalizations.of(context)?.achievementsTabFasting ?? 'Fasting'),
            Tab(text: AppLocalizations.of(context)?.achievementsTabCalories ?? 'Calories'),
            Tab(text: AppLocalizations.of(context)?.achievementsTabProtein ?? 'Protein'),
            Tab(text: AppLocalizations.of(context)?.achievementsTabFood ?? 'Food'),
            Tab(text: AppLocalizations.of(context)?.achievementsTabTest ?? 'Test'),
            Tab(text: AppLocalizations.of(context)?.achievementsTabFavorites ?? 'Favorites'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: _grid ? (AppLocalizations.of(context)?.achievementsListView ?? 'List view') : (AppLocalizations.of(context)?.achievementsGridView ?? 'Grid view'),
            onPressed: () => setState(() => _grid = !_grid),
            icon: Icon(_grid ? Icons.view_list : Icons.grid_view),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          children: [
            Row(children: [
              Expanded(child: _buildTypeFilter(theme)),
              SizedBox(width: 2.w),
              // meta filter covered by tabs now; keep space symmetrical
              const SizedBox.shrink(),
              SizedBox(width: 2.w),
              Expanded(child: _buildSort(theme)),
              SizedBox(width: 2.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.6.h),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryBackgroundDark,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.dividerGray.withValues(alpha: 0.25)),
                ),
                child: Text((AppLocalizations.of(context)?.achievementsTotal(_filtered.length) ?? 'Total: ${_filtered.length}'), style: theme.textTheme.labelSmall?.copyWith(color: AppTheme.textSecondary)),
              ),
            ]),
            SizedBox(height: 2.h),
            Expanded(
              child: _filtered.isEmpty
                  ? Center(
                      child: Text(AppLocalizations.of(context)?.achievementsEmpty ?? 'No achievements yet',
                          style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary)),
                    )
                  : (_grid
                      ? GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.9,
                          ),
                          itemCount: _filtered.length,
                          itemBuilder: (_, i) {
                            final a = _filtered[i];
                            final id = (a['id']?.toString() ?? '');
                            final isFav = _favorites.contains(id);
                            final isNew = _isNew(a);
                            return Stack(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(3.w),
                                  decoration: BoxDecoration(
                                    color: AppTheme.secondaryBackgroundDark,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppTheme.dividerGray.withValues(alpha: 0.25)),
                                  ),
                                  child: Row(
                                    children: [
                                      CustomIconWidget(
                                        iconName: _iconForType((a['type'] as String?) ?? 'star'),
                                        color: _colorForType((a['type'] as String?) ?? 'star'),
                                        size: 20,
                                      ),
                                      SizedBox(width: 3.w),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(a['title'] as String? ?? (AppLocalizations.of(context)?.achievementsDefaultTitle ?? 'Achievement'),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: theme.textTheme.bodyMedium?.copyWith(
                                                    color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
                                            SizedBox(height: 0.2.h),
                                            Text(
                                              (a['dateIso'] as String?) ?? '',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: theme.textTheme.labelSmall?.copyWith(color: AppTheme.textSecondary),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        tooltip: isFav ? (AppLocalizations.of(context)?.achievementsRemoveFavorite ?? 'Remove favorite') : (AppLocalizations.of(context)?.achievementsFavorite ?? 'Favorite'),
                                        onPressed: () async {
                                          await AchievementService.toggleFavorite(id);
                                          final favs = await AchievementService.getFavorites();
                                          if (!mounted) return;
                                          setState(() => _favorites = favs);
                                        },
                                        icon: Icon(isFav ? Icons.star : Icons.star_border,
                                            color: isFav ? AppTheme.premiumGold : AppTheme.textSecondary),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isNew)
                                  Positioned(
                                    left: 8,
                                    top: 6,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppTheme.successGreen.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: AppTheme.successGreen.withValues(alpha: 0.4)),
                                      ),
                                      child: Text(AppLocalizations.of(context)?.achievementsNewBadge ?? 'New', style: theme.textTheme.labelSmall?.copyWith(color: AppTheme.successGreen)),
                                    ),
                                  ),
                              ],
                            );
                          },
                        )
                      : ListView.separated(
                          itemCount: _filtered.length,
                          separatorBuilder: (_, __) => SizedBox(height: 1.h),
                          itemBuilder: (_, i) {
                            final a = _filtered[i];
                            final id = (a['id']?.toString() ?? '');
                            final isFav = _favorites.contains(id);
                            final isNew = _isNew(a);
                            return Stack(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(3.w),
                                  decoration: BoxDecoration(
                                    color: AppTheme.secondaryBackgroundDark,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppTheme.dividerGray.withValues(alpha: 0.25)),
                                  ),
                                  child: Row(
                                    children: [
                                      CustomIconWidget(
                                        iconName: _iconForType((a['type'] as String?) ?? 'star'),
                                        color: _colorForType((a['type'] as String?) ?? 'star'),
                                        size: 20,
                                      ),
                                      SizedBox(width: 3.w),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(a['title'] as String? ?? (AppLocalizations.of(context)?.achievementsDefaultTitle ?? 'Achievement'),
                                                style: theme.textTheme.bodyLarge?.copyWith(
                                                    color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
                                            SizedBox(height: 0.4.h),
                                            Text('${AppLocalizations.of(context)?.achievementsType ?? 'Type'}: ${(a['type'] as String?) ?? '-'}  •  ${AppLocalizations.of(context)?.achievementsGoal ?? 'Goal'}: ${(a['metaKey'] as String?) ?? '-'}',
                                                style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary)),
                                            SizedBox(height: 0.2.h),
                                            Text((a['dateIso'] as String?) ?? '',
                                                style: theme.textTheme.labelSmall?.copyWith(color: AppTheme.textSecondary)),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        tooltip: isFav ? (AppLocalizations.of(context)?.achievementsRemoveFavorite ?? 'Remove favorite') : (AppLocalizations.of(context)?.achievementsFavorite ?? 'Favorite'),
                                        onPressed: () async {
                                          await AchievementService.toggleFavorite(id);
                                          final favs = await AchievementService.getFavorites();
                                          if (!mounted) return;
                                          setState(() => _favorites = favs);
                                        },
                                        icon: Icon(isFav ? Icons.star : Icons.star_border,
                                            color: isFav ? AppTheme.premiumGold : AppTheme.textSecondary),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isNew)
                                  Positioned(
                                    left: 8,
                                    top: 6,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppTheme.successGreen.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: AppTheme.successGreen.withValues(alpha: 0.4)),
                                      ),
                                      child: Text(AppLocalizations.of(context)?.achievementsNewBadge ?? 'New', style: theme.textTheme.labelSmall?.copyWith(color: AppTheme.successGreen)),
                                    ),
                                  ),
                              ],
                            );
                          },
                        )),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTypeFilter(ThemeData theme) {
    final t = AppLocalizations.of(context);
    return _labeledDropdown(theme, t?.filterTypeLabel ?? 'Type', _filterType, [
      DropdownMenuItem(value: 'all', child: Text(t?.filterTypeAll ?? 'All')),
      DropdownMenuItem(value: 'success', child: Text(t?.filterTypeSuccess ?? 'Success')),
      DropdownMenuItem(value: 'flame', child: Text(t?.filterTypeStreak ?? 'Streak')),
      DropdownMenuItem(value: 'diamond', child: Text(t?.filterTypePremium ?? 'Premium')),
      DropdownMenuItem(value: 'star', child: Text(t?.filterTypeGeneral ?? 'General')),
    ], (v) => setState(() => _filterType = v ?? 'all'));
  }

  Widget _buildSort(ThemeData theme) {
    final t = AppLocalizations.of(context);
    return _labeledDropdown(theme, t?.filterSortLabel ?? 'Sort', _sort, [
      DropdownMenuItem(value: 'recent', child: Text(t?.sortRecent ?? 'Recent')),
      DropdownMenuItem(value: 'oldest', child: Text(t?.sortOldest ?? 'Oldest')),
      DropdownMenuItem(value: 'type', child: Text(t?.sortType ?? 'Type')),
    ], (v) => setState(() => _sort = v ?? 'recent'));
  }

  Widget _labeledDropdown(ThemeData theme, String label, String value,
      List<DropdownMenuItem<String>> items, void Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: theme.textTheme.labelSmall
                ?.copyWith(color: AppTheme.textSecondary)),
        SizedBox(height: 0.4.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 3.w),
          decoration: BoxDecoration(
            color: AppTheme.secondaryBackgroundDark,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.dividerGray.withValues(alpha: 0.25)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              items: items,
              onChanged: onChanged,
            ),
          ),
        )
      ],
    );
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'diamond':
        return AppTheme.premiumGold;
      case 'flame':
        return AppTheme.warningAmber;
      case 'success':
        return AppTheme.successGreen;
      default:
        return AppTheme.activeBlue;
    }
  }

  String _iconForType(String type) {
    switch (type) {
      case 'diamond':
        return 'diamond';
      case 'flame':
        return 'local_fire_department';
      case 'success':
        return 'check_circle';
      default:
        return 'star';
    }
  }
}

