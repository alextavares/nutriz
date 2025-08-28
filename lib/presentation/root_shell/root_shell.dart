import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../services/nutrition_storage.dart';
import '../daily_tracking_dashboard/daily_tracking_dashboard.dart';
import '../enhanced_dashboard_screen/enhanced_dashboard_screen.dart';
import '../food_logging_screen/food_logging_screen.dart';
import '../progress_overview/progress_overview.dart';
import '../profile_screen/profile_screen.dart';

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _currentIndex = 0;
  final ValueNotifier<DateTime> _selectedDate =
      ValueNotifier<DateTime>(DateTime.now());
  bool _handledInitialArgs = false;
  bool _useEnhancedDashboard = false;

  List<Widget> _buildPages() => [
        _useEnhancedDashboard
            ? const EnhancedDashboardScreen()
            : const DailyTrackingDashboard(),
        const FoodLoggingScreen(),
        const SizedBox.shrink(), // slot central para ação de adicionar
        const ProgressOverviewScreen(),
        const ProfileScreen(),
      ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_handledInitialArgs) return;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      // Accept 'date' as ISO string or DateTime
      final dateArg = args['date'];
      DateTime? d;
      if (dateArg is String) {
        d = DateTime.tryParse(dateArg);
      } else if (dateArg is DateTime) {
        d = dateArg;
      }
      if (d != null) {
        _selectedDate.value = DateTime(d.year, d.month, d.day);
      }
      // Optional tab targeting
      final tab = (args['tab'] as String?)?.toLowerCase();
      if (tab != null) {
        switch (tab) {
          case 'diary':
          case 'home':
            _currentIndex = 0;
            break;
          case 'search':
            _currentIndex = 1;
            break;
          case 'progress':
          case 'analytics':
            _currentIndex = 3;
            break;
          case 'profile':
            _currentIndex = 4;
            break;
        }
        setState(() {});
      }
    }
    _handledInitialArgs = true;
  }

  void _onItemTapped(int index) async {
    if (index == 2) {
      // Ação central: abrir bottom sheet de adicionar
      _showAddSheet();
      return;
    }
    setState(() => _currentIndex = index);
  }

  void _showAddSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.secondaryBackgroundDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.search),
                  title: const Text('Adicionar alimento'),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    setState(() => _currentIndex = 0); // ir para Diário
                    Navigator.of(context).pushNamed(AppRoutes.addFoodEntry);
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.free_breakfast_outlined),
                  title: const Text('Adicionar ao Café da manhã'),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    // Garanta que, ao voltar, o tab visível não seja o slot vazio (index 2)
                    setState(() => _currentIndex = 0); // Diário
                    Navigator.of(context).pushNamed(
                      AppRoutes.addFoodEntry,
                      arguments: {
                        'mealKey': 'breakfast',
                        'targetDate': _selectedDate.value.toIso8601String(),
                      },
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.lunch_dining_outlined),
                  title: const Text('Adicionar ao Almoço'),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    setState(() => _currentIndex = 0);
                    Navigator.of(context).pushNamed(
                      AppRoutes.addFoodEntry,
                      arguments: {
                        'mealKey': 'lunch',
                        'targetDate': _selectedDate.value.toIso8601String(),
                      },
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.dinner_dining_outlined),
                  title: const Text('Adicionar ao Jantar'),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    setState(() => _currentIndex = 0);
                    Navigator.of(context).pushNamed(
                      AppRoutes.addFoodEntry,
                      arguments: {
                        'mealKey': 'dinner',
                        'targetDate': _selectedDate.value.toIso8601String(),
                      },
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.emoji_food_beverage_outlined),
                  title: const Text('Adicionar aos Lanches'),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    setState(() => _currentIndex = 0);
                    Navigator.of(context).pushNamed(
                      AppRoutes.addFoodEntry,
                      arguments: {
                        'mealKey': 'snack',
                        'targetDate': _selectedDate.value.toIso8601String(),
                      },
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.local_drink_outlined),
                  title: const Text('Adicionar água (+250 ml)'),
                  onTap: () async {
                    Navigator.of(ctx).pop();
                    await NutritionStorage.addWaterMl(_selectedDate.value, 250);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Adicionado 250 ml de água'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    setState(() {});
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.local_drink),
                  title: const Text('Adicionar água (+500 ml)'),
                  onTap: () async {
                    Navigator.of(ctx).pop();
                    await NutritionStorage.addWaterMl(_selectedDate.value, 500);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Adicionado 500 ml de água'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    setState(() {});
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.qr_code_scanner),
                  title: const Text('Scanner/AI de alimento'),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    setState(() => _currentIndex = 0);
                    Navigator.of(context).pushNamed(AppRoutes.aiFoodDetection);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.menu_book_outlined),
                  title: const Text('Explorar receitas'),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    setState(() => _currentIndex = 0);
                    Navigator.of(context).pushNamed(AppRoutes.recipeBrowser);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.timer_outlined),
                  title: const Text('Jejum intermitente'),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    setState(() => _currentIndex = 0);
                    Navigator.of(context)
                        .pushNamed(AppRoutes.intermittentFastingTracker);
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final titles = ['Diário', 'Buscar', 'Adicionar', 'Progresso', 'Perfil'];
    final cs = Theme.of(context).colorScheme;
    return AppBar(
      backgroundColor: cs.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: _currentIndex == 0
          ? IconButton(
              tooltip: 'Dia anterior',
              icon: const Icon(Icons.chevron_left),
              onPressed: () {
                final d = _selectedDate.value.subtract(const Duration(days: 1));
                _selectedDate.value = DateTime(d.year, d.month, d.day);
                setState(() {});
              },
            )
          : null,
      title: (_currentIndex == 0)
          ? Builder(builder: (context) {
              final lang = Localizations.localeOf(context).languageCode.toLowerCase();
              final label = lang == 'pt' ? 'Hoje' : 'Today';
              return Text(
                label,
                style: Theme.of(context).textTheme.titleLarge,
              );
            })
          : Text(
              titles[_currentIndex],
              style: Theme.of(context).textTheme.titleLarge,
            ),
      actions: [
        if (_currentIndex == 0) ...[
          // Toggle Dashboard Button
          IconButton(
            tooltip: _useEnhancedDashboard ? 'Dashboard Original' : 'Dashboard v1',
            icon: Icon(
              _useEnhancedDashboard ? Icons.home_outlined : Icons.dashboard_outlined,
              size: 22,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            onPressed: () {
              setState(() {
                _useEnhancedDashboard = !_useEnhancedDashboard;
              });
            },
          ),
          // Gamification diamond
          IconButton(
            tooltip: 'Gamificação',
            icon: Icon(
              Icons.workspace_premium_outlined,
              size: 22,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Gamificação em breve')),
              );
            },
          ),
          // Streaks / engagement
          IconButton(
            tooltip: 'Sequência',
            icon: Icon(
              Icons.whatshot_outlined,
              size: 22,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sequência/Conquistas em breve')),
              );
            },
          ),
          // Statistics shortcut
          IconButton(
            tooltip: 'Estatísticas',
            icon: Icon(
              Icons.query_stats_outlined,
              size: 22,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.progressOverview);
            },
          ),
          IconButton(
            tooltip: 'Selecionar data',
            icon: Icon(
              Icons.calendar_today_outlined,
              size: 22,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            onPressed: () async {
              final now = DateTime.now();
              final picked = await showDatePicker(
                context: context,
                firstDate: DateTime(now.year - 1),
                lastDate: DateTime(now.year + 1),
                initialDate: _selectedDate.value,
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: Theme.of(context).colorScheme.copyWith(
                            primary: AppTheme.activeBlue,
                          ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                _selectedDate.value =
                    DateTime(picked.year, picked.month, picked.day);
                setState(() {});
              }
            },
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: ValueListenableBuilder<DateTime>(
        valueListenable: _selectedDate,
        builder: (context, _, __) {
          final pages = _buildPages();
          return IndexedStack(
            index: _currentIndex,
            children: pages,
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
        backgroundColor: Theme.of(context).colorScheme.surface,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Diário',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Buscar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Adicionar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.stacked_bar_chart_outlined),
            label: 'Progresso',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
