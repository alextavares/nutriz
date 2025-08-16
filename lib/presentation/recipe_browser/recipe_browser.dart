import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
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
          "Salmão grelhado perfeitamente temperado com aspargos frescos."
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
          "Tacos deliciosos recheados com lentilhas temperadas e vegetais."
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
          "Lasanha saudável usando fatias de abobrinha no lugar da massa."
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeRecipes();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
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
              ? 'Receita adicionada aos favoritos'
              : 'Receita removida dos favoritos',
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onRecipeTap(Map<String, dynamic> recipe) {
    // Navigate to recipe detail (placeholder)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Abrindo receita: ${recipe['name']}'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onRecipeLongPress(Map<String, dynamic> recipe) {
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${recipe['name']} adicionada ao plano de refeições'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _shareRecipe(Map<String, dynamic> recipe) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Compartilhando receita: ${recipe['name']}'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _findSimilarRecipes(Map<String, dynamic> recipe) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Buscando receitas similares a: ${recipe['name']}'),
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
    return Scaffold(
      backgroundColor: AppTheme.primaryBackgroundDark,
      appBar: AppBar(
        title: Text(
          'Receitas',
          style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.primaryBackgroundDark,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              // Navigate to favorites or search history
            },
            icon: CustomIconWidget(
              iconName: 'favorite_border',
              color: AppTheme.textSecondary,
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

          // Recipe Grid
          Expanded(
            child: _filteredRecipes.isEmpty && !_isLoading
                ? EmptyStateWidget(
                    title: _hasActiveFilters || _searchQuery.isNotEmpty
                        ? 'Nenhuma receita encontrada'
                        : 'Carregando receitas...',
                    subtitle: _hasActiveFilters || _searchQuery.isNotEmpty
                        ? 'Tente ajustar seus filtros ou termo de busca'
                        : 'Aguarde enquanto carregamos as melhores receitas para você',
                    actionText: _hasActiveFilters || _searchQuery.isNotEmpty
                        ? 'Limpar Filtros'
                        : 'Atualizar',
                    onActionTap: _hasActiveFilters || _searchQuery.isNotEmpty
                        ? _clearAllFilters
                        : _onRefresh,
                    showClearFilters:
                        _hasActiveFilters || _searchQuery.isNotEmpty,
                  )
                : RefreshIndicator(
                    onRefresh: _onRefresh,
                    color: AppTheme.activeBlue,
                    backgroundColor: AppTheme.secondaryBackgroundDark,
                    child: RecipeGridWidget(
                      recipes: _filteredRecipes,
                      onRecipeTap: _onRecipeTap,
                      onFavoriteToggle: _toggleFavorite,
                      onRecipeLongPress: _onRecipeLongPress,
                      isLoading: _isLoading,
                      onLoadMore: _loadMoreRecipes,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
