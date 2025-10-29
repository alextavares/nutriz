import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../theme/design_tokens.dart';
import '../../services/user_preferences.dart';
import 'package:nutriz/l10n/generated/app_localizations.dart';
import './widgets/empty_state_widget.dart';
import './widgets/filter_bottom_sheet_widget.dart';
import './widgets/filter_chip_widget.dart';
import './widgets/quick_actions_bottom_sheet_widget.dart';
import './widgets/recipe_grid_widget.dart';
import './widgets/search_bar_widget.dart';

class RecipeBrowser extends StatefulWidget {
  const RecipeBrowser({Key? key}) : super(key: key);

  @override
  State<RecipeBrowser> createState() => _RecipeBrowserState();
}

class _RecipeBrowserState extends State<RecipeBrowser>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> _allRecipes = [];
  List<Map<String, dynamic>> _filteredRecipes = [];
  Map<String, dynamic> _activeFilters = {};
  bool _isLoading = false;
  // removed unused: _isRefreshing
  String _searchQuery = '';
  bool _isPremiumUser = false;
  late final VoidCallback _prefsListener;

  // Mock recipe data
  final List<Map<String, dynamic>> _mockRecipes = [
    {
      "id": 1,
      "name": "Salada de Quinoa com Abacate",
      "imageUrl":
          "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=500&h=400&fit=crop",
      "prepTime": 15,
      "calories": 320,
      "isFavorite": false,
      "mealTypes": ["Almoço"],
      "dietaryRestrictions": ["Vegetariano", "Sem Glúten"],
      "prepTimeCategory": "< 15 min",
      "calorieCategory": "200-400 cal",
      "description":
          "Uma salada nutritiva e saborosa com quinoa, abacate e vegetais frescos."
    },
    {
      "id": 2,
      "name": "Salmão Grelhado com Aspargos",
      "imageUrl":
          "https://images.unsplash.com/photo-1467003909585-2f8a72700288?w=500&h=400&fit=crop",
      "prepTime": 25,
      "calories": 450,
      "isFavorite": true,
      "mealTypes": ["Jantar"],
      "dietaryRestrictions": ["Low-Carb", "Keto"],
      "prepTimeCategory": "15-30 min",
      "calorieCategory": "400-600 cal",
      "description":
          "Salmão grelhado perfeitamente temperado com aspargos frescos.",
      "isPremium": true,
    },
    {
      "id": 3,
      "name": "Smoothie Bowl de Açaí",
      "imageUrl":
          "https://images.unsplash.com/photo-1511690743698-d9d85f2fbf38?w=500&h=400&fit=crop",
      "prepTime": 10,
      "calories": 280,
      "isFavorite": false,
      "mealTypes": ["Café da Manhã", "Lanche"],
      "dietaryRestrictions": ["Vegetariano", "Vegano"],
      "prepTimeCategory": "< 15 min",
      "calorieCategory": "200-400 cal",
      "description":
          "Bowl cremoso de açaí com frutas frescas e granola caseira."
    },
    {
      "id": 4,
      "name": "Frango Teriyaki com Brócolis",
      "imageUrl":
          "https://images.unsplash.com/photo-1432139555190-58524dae6a55?w=500&h=400&fit=crop",
      "prepTime": 30,
      "calories": 380,
      "isFavorite": false,
      "mealTypes": ["Almoço", "Jantar"],
      "dietaryRestrictions": ["Sem Glúten"],
      "prepTimeCategory": "15-30 min",
      "calorieCategory": "200-400 cal",
      "description": "Frango suculento com molho teriyaki e brócolis no vapor."
    },
    {
      "id": 5,
      "name": "Tacos Veganos de Lentilha",
      "imageUrl":
          "https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=500&h=400&fit=crop",
      "prepTime": 20,
      "calories": 340,
      "isFavorite": true,
      "mealTypes": ["Almoço", "Jantar"],
      "dietaryRestrictions": ["Vegetariano", "Vegano"],
      "prepTimeCategory": "15-30 min",
      "calorieCategory": "200-400 cal",
      "description":
          "Tacos deliciosos recheados com lentilhas temperadas e vegetais.",
      "isPremium": true,
    },
    {
      "id": 6,
      "name": "Omelete de Espinafre e Queijo",
      "imageUrl":
          "https://images.unsplash.com/photo-1506084868230-bb9d95c24759?w=500&h=400&fit=crop",
      "prepTime": 12,
      "calories": 250,
      "isFavorite": false,
      "mealTypes": ["Café da Manhã"],
      "dietaryRestrictions": ["Vegetariano", "Low-Carb"],
      "prepTimeCategory": "< 15 min",
      "calorieCategory": "< 200 cal",
      "description": "Omelete fluffy com espinafre fresco e queijo derretido."
    },
    {
      "id": 7,
      "name": "Bowl de Buddha Colorido",
      "imageUrl":
          "https://images.unsplash.com/photo-1540420773420-3366772f4999?w=500&h=400&fit=crop",
      "prepTime": 35,
      "calories": 420,
      "isFavorite": false,
      "mealTypes": ["Almoço"],
      "dietaryRestrictions": ["Vegetariano", "Vegano"],
      "prepTimeCategory": "30-60 min",
      "calorieCategory": "400-600 cal",
      "description":
          "Bowl nutritivo com grãos, vegetais assados e molho tahine."
    },
    {
      "id": 8,
      "name": "Lasanha de Abobrinha Low-Carb",
      "imageUrl":
          "https://images.unsplash.com/photo-1574894709920-11b28e7367e3?w=500&h=400&fit=crop",
      "prepTime": 45,
      "calories": 320,
      "isFavorite": true,
      "mealTypes": ["Jantar"],
      "dietaryRestrictions": ["Low-Carb", "Sem Glúten"],
      "prepTimeCategory": "30-60 min",
      "calorieCategory": "200-400 cal",
      "description":
          "Lasanha saudável usando fatias de abobrinha no lugar da massa.",
      "isPremium": true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeRecipes();
    _searchController.addListener(_onSearchChanged);
    _prefsListener = () => _loadPremiumStatus();
    UserPreferences.changes.addListener(_prefsListener);
    _loadPremiumStatus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    UserPreferences.changes.removeListener(_prefsListener);
    super.dispose();
  }

  Future<void> _loadPremiumStatus() async {
    final status = await UserPreferences.getPremiumStatus();
    if (!mounted) return;
    if (status != _isPremiumUser) {
      setState(() => _isPremiumUser = status);
      // Re-sort recipes so itens PRO aparecem ao final quando bloqueados
      _applyFilters();
    }
  }

  void _initializeRecipes() {
    setState(() {
      _allRecipes = List<Map<String, dynamic>>.from(_mockRecipes);
      _filteredRecipes = List<Map<String, dynamic>>.from(_allRecipes);
    });
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      _applyFilters();
    });
  }

  void _applyFilters() {
    List<Map<String, dynamic>> filtered =
        List<Map<String, dynamic>>.from(_allRecipes);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((recipe) {
        final name = (recipe['name'] as String).toLowerCase();
        final description = (recipe['description'] as String).toLowerCase();
        return name.contains(_searchQuery) ||
            description.contains(_searchQuery);
      }).toList();
    }

    // Apply category filters
    _activeFilters.forEach((key, value) {
      if (value is List<String> && value.isNotEmpty) {
        filtered = filtered.where((recipe) {
          final recipeValues = recipe[key] as List<dynamic>?;
          if (recipeValues == null) return false;
          return value.any((filterValue) => recipeValues.contains(filterValue));
        }).toList();
      }
    });

    filtered.sort((a, b) {
      final bool aLocked = _isRecipeLocked(a);
      final bool bLocked = _isRecipeLocked(b);
      if (aLocked == bLocked) return 0;
      return aLocked ? 1 : -1;
    });

    setState(() {
      _filteredRecipes = filtered;
    });
  }

  void _onFiltersChanged(Map<String, dynamic> filters) {
    setState(() {
      _activeFilters = filters;
      _applyFilters();
    });
  }

  void _clearAllFilters() {
    setState(() {
      _activeFilters.clear();
      _searchController.clear();
      _searchQuery = '';
      _applyFilters();
    });
  }

  void _removeFilter(String filterKey, String filterValue) {
    setState(() {
      final currentList = (_activeFilters[filterKey] as List<String>?) ?? [];
      currentList.remove(filterValue);
      if (currentList.isEmpty) {
        _activeFilters.remove(filterKey);
      } else {
        _activeFilters[filterKey] = currentList;
      }
      _applyFilters();
    });
  }

  void _toggleFavorite(Map<String, dynamic> recipe) {
    if (_isRecipeLocked(recipe)) {
      _showProUpgradeMessage('Favoritar receitas exclusivas');
      return;
    }
    setState(() {
      recipe['isFavorite'] = !(recipe['isFavorite'] as bool);
    });

    // Haptic feedback
    HapticFeedback.lightImpact();

    // Show toast message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          recipe['isFavorite']
              ? AppLocalizations.of(context)?.recipeAddedToFavorites ??
                  'Recipe added to favorites'
              : AppLocalizations.of(context)?.recipeRemovedFromFavorites ??
                  'Recipe removed from favorites',
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onRecipeTap(Map<String, dynamic> recipe) {
    if (_isRecipeLocked(recipe)) {
      _showProUpgradeMessage('Receitas exclusivas');
      return;
    }
    // Navigate to recipe detail (placeholder)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)
                ?.openingRecipe(recipe['name'] as String) ??
            'Opening recipe: ${recipe['name']}'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onRecipeLongPress(Map<String, dynamic> recipe) {
    if (_isRecipeLocked(recipe)) {
      _showProUpgradeMessage('Receitas exclusivas');
      return;
    }
    if (!_ensurePremiumAccess('Ações rápidas de receita')) {
      return;
    }
    HapticFeedback.mediumImpact();
    _showQuickActionsBottomSheet(recipe);
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheetWidget(
        currentFilters: _activeFilters,
        onFiltersChanged: _onFiltersChanged,
      ),
    );
  }

  void _showQuickActionsBottomSheet(Map<String, dynamic> recipe) {
    if (!_ensurePremiumAccess('Ações rápidas de receita')) {
      return;
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => QuickActionsBottomSheetWidget(
        recipe: recipe,
        onAddToMealPlan: () => _addToMealPlan(recipe),
        onShareRecipe: () => _shareRecipe(recipe),
        onSimilarRecipes: () => _findSimilarRecipes(recipe),
      ),
    );
  }

  void _addToMealPlan(Map<String, dynamic> recipe) {
    if (!_ensurePremiumAccess('Planejamento de refeições inteligente')) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text((AppLocalizations.of(context)
                ?.addedToMealPlan(recipe['name'] as String) ??
            '${recipe['name']} added to meal plan')),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _shareRecipe(Map<String, dynamic> recipe) {
    if (!_ensurePremiumAccess('Compartilhar receitas exclusivas')) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text((AppLocalizations.of(context)
                ?.sharingRecipe(recipe['name'] as String) ??
            'Sharing recipe: ${recipe['name']}')),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _findSimilarRecipes(Map<String, dynamic> recipe) {
    if (!_ensurePremiumAccess('Sugestões avançadas')) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text((AppLocalizations.of(context)
                ?.findingSimilar(recipe['name'] as String) ??
            'Finding recipes similar to: ${recipe['name']}')),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _onRefresh() async {
    // no-op visual refresh indicator already handled by RefreshIndicator

    // Simulate network refresh
    await Future.delayed(const Duration(seconds: 1));

    // In real app, this would fetch new recipes from API
  }

  void _loadMoreRecipes() {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    // Simulate loading more recipes
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
          // In real app, this would load more recipes from API
        });
      }
    });
  }

  bool _isRecipePremium(Map<String, dynamic> recipe) =>
      (recipe['isPremium'] as bool?) ?? false;

  bool _isRecipeLocked(Map<String, dynamic> recipe) =>
      _isRecipePremium(recipe) && !_isPremiumUser;

  void _openProPlans() {
    Navigator.pushNamed(context, AppRoutes.proSubscription);
  }

  void _showProUpgradeMessage(String feature) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text('$feature está disponível no NutriTracker PRO'),
        action: SnackBarAction(
          label: 'Ver planos',
          onPressed: _openProPlans,
        ),
      ),
    );
  }

  bool _ensurePremiumAccess(String feature) {
    if (_isPremiumUser) {
      return true;
    }
    _showProUpgradeMessage(feature);
    return false;
  }

  Widget _buildProUpsellCard() {
    final colors = context.colors;
    final semantics = context.semanticColors;
    final textStyles = context.textStyles;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.2.w, vertical: 1.6.h),
      decoration: BoxDecoration(
        color: semantics.premiumContainer,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: semantics.premium.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.workspace_premium_outlined,
                  color: semantics.premium),
              SizedBox(width: 2.w),
              Text(
                'Receitas PRO liberam mais opções',
                style: textStyles.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: semantics.premium,
                ),
              ),
            ],
          ),
          SizedBox(height: 0.8.h),
          Text(
            'Acesse coleções exclusivas, filtros avançados e sugestões automáticas de refeições completas.',
            style: textStyles.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 1.2.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _openProPlans,
              style: ElevatedButton.styleFrom(
                backgroundColor: semantics.premium,
                foregroundColor: semantics.onPremium,
                padding: EdgeInsets.symmetric(vertical: 1.2.h),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Ver benefícios PRO'),
            ),
          ),
        ],
      ),
    );
  }

  bool get _hasActiveFilters {
    return _activeFilters.values.any((value) {
      if (value is List) return value.isNotEmpty;
      return value != null;
    });
  }

  List<Widget> _buildActiveFilterChips() {
    List<Widget> chips = [];

    _activeFilters.forEach((key, value) {
      if (value is List<String> && value.isNotEmpty) {
        for (String filterValue in value) {
          chips.add(
            FilterChipWidget(
              label: filterValue,
              count: 0,
              onRemove: () => _removeFilter(key, filterValue),
            ),
          );
        }
      }
    });

    return chips;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)?.recipesTitle ?? 'Recipes',
          style: textStyles.titleLarge?.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: colors.surface,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              // Navigate to favorites or search history
            },
            icon: CustomIconWidget(
              iconName: 'favorite_border',
              color: colors.onSurfaceVariant,
              size: 6.w,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          SearchBarWidget(
            controller: _searchController,
            onChanged: (value) {
              // Search is handled by listener
            },
            onFilterTap: _showFilterBottomSheet,
            hasActiveFilters: _hasActiveFilters,
          ),

          // Active Filter Chips
          if (_hasActiveFilters) ...[
            Container(
              height: 6.h,
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: _buildActiveFilterChips(),
              ),
            ),
          ],

          if (!_isPremiumUser)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.2.h),
              child: _buildProUpsellCard(),
            ),

          // Recipe Grid
          Expanded(
            child: _filteredRecipes.isEmpty && !_isLoading
                ? EmptyStateWidget(
                    title: _hasActiveFilters || _searchQuery.isNotEmpty
                        ? (AppLocalizations.of(context)?.recipesEmptyFiltered ??
                            'No recipes found')
                        : (AppLocalizations.of(context)?.recipesLoadingTitle ??
                            'Loading recipes...'),
                    subtitle: _hasActiveFilters || _searchQuery.isNotEmpty
                        ? (AppLocalizations.of(context)?.recipesEmptySubtitle ??
                            'Try adjusting your filters or search term')
                        : (AppLocalizations.of(context)
                                ?.recipesLoadingSubtitle ??
                            'Please wait while we load the best recipes for you'),
                    actionText: _hasActiveFilters || _searchQuery.isNotEmpty
                        ? (AppLocalizations.of(context)?.clearFilters ??
                            'Clear filters')
                        : (AppLocalizations.of(context)?.refresh ?? 'Refresh'),
                    onActionTap: _hasActiveFilters || _searchQuery.isNotEmpty
                        ? _clearAllFilters
                        : _onRefresh,
                    showClearFilters:
                        _hasActiveFilters || _searchQuery.isNotEmpty,
                  )
                : RefreshIndicator(
                    onRefresh: _onRefresh,
                    color: colors.primary,
                    backgroundColor: colors.surfaceContainer,
                    child: RecipeGridWidget(
                      recipes: _filteredRecipes,
                      onRecipeTap: _onRecipeTap,
                      onFavoriteToggle: _toggleFavorite,
                      onRecipeLongPress: _onRecipeLongPress,
                      isLoading: _isLoading,
                      onLoadMore: _loadMoreRecipes,
                      isPremiumUser: _isPremiumUser,
                      onUnlockPro: () =>
                          _showProUpgradeMessage('Receitas exclusivas'),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}


