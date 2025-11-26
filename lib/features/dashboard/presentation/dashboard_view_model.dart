import 'package:flutter/foundation.dart';
import 'package:nutriz/features/dashboard/data/dashboard_repository.dart';

class DashboardViewModel extends ChangeNotifier {
  final DashboardRepository _repository = DashboardRepository();

  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Summary Data
  int _caloriesConsumed = 0;
  int _carbsConsumed = 0;
  int _proteinConsumed = 0;
  int _fatConsumed = 0;
  int _waterConsumed = 0;
  int _exerciseBurned = 0;
  List<Map<String, dynamic>> _foodEntries = [];

  int get caloriesConsumed => _caloriesConsumed;
  int get carbsConsumed => _carbsConsumed;
  int get proteinConsumed => _proteinConsumed;
  int get fatConsumed => _fatConsumed;
  int get waterConsumed => _waterConsumed;
  int get exerciseBurned => _exerciseBurned;
  List<Map<String, dynamic>> get foodEntries => _foodEntries;

  // Goals
  int _calorieGoal = 2000;
  int _carbsGoal = 250;
  int _proteinGoal = 150;
  int _fatGoal = 70;
  int _waterGoal = 2000;

  int get calorieGoal => _calorieGoal;
  int get carbsGoal => _carbsGoal;
  int get proteinGoal => _proteinGoal;
  int get fatGoal => _fatGoal;
  int get waterGoal => _waterGoal;

  // Meal-specific calorie goals (distributed from total)
  // Default distribution: Breakfast 25%, Lunch 35%, Dinner 30%, Snacks 10%
  int get breakfastCalorieGoal => (_calorieGoal * 0.25).round();
  int get lunchCalorieGoal => (_calorieGoal * 0.35).round();
  int get dinnerCalorieGoal => (_calorieGoal * 0.30).round();
  int get snackCalorieGoal => (_calorieGoal * 0.10).round();
  
  int getMealCalorieGoal(String mealName) {
    switch (mealName) {
      case 'breakfast': return breakfastCalorieGoal;
      case 'lunch': return lunchCalorieGoal;
      case 'dinner': return dinnerCalorieGoal;
      case 'snack': return snackCalorieGoal;
      default: return 0;
    }
  }

  int get caloriesRemaining => (_calorieGoal + _exerciseBurned) - _caloriesConsumed;

  DashboardViewModel() {
    loadData();
  }

  void changeDate(DateTime date) {
    _selectedDate = date;
    loadData();
  }

  // Weight & Notes
  double _currentWeight = 0.0;
  double _weightGoal = 0.0;
  Map<String, dynamic>? _dailyNote;

  double get currentWeight => _currentWeight;
  double get weightGoal => _weightGoal;
  Map<String, dynamic>? get dailyNote => _dailyNote;

  // Fasting
  bool _isFasting = false;
  bool _isEatingWindow = false;
  String _fastingStatus = '';
  Duration _fastingElapsed = Duration.zero;
  Duration _fastingGoal = const Duration(hours: 16);
  Duration _eatingWindowGoal = const Duration(hours: 8);
  DateTime? _fastingStartTime;
  DateTime? _eatingWindowStartTime;

  bool get isFasting => _isFasting;
  bool get isEatingWindow => _isEatingWindow;
  String get fastingStatus => _fastingStatus;
  Duration get fastingGoal => _fastingGoal;
  
  // Calcula o tempo decorrido em tempo real
  Duration get fastingElapsed {
    if (_isFasting && _fastingStartTime != null) {
      return DateTime.now().difference(_fastingStartTime!);
    } else if (_isEatingWindow && _eatingWindowStartTime != null) {
      return DateTime.now().difference(_eatingWindowStartTime!);
    }
    return _fastingElapsed;
  }

  // Inicia o jejum
  void startFasting() {
    _isFasting = true;
    _isEatingWindow = false;
    _fastingStartTime = DateTime.now();
    _eatingWindowStartTime = null;
    _fastingStatus = 'Jejum';
    _fastingElapsed = Duration.zero;
    notifyListeners();
  }

  // Inicia a janela alimentar
  void startEatingWindow() {
    _isFasting = false;
    _isEatingWindow = true;
    _eatingWindowStartTime = DateTime.now();
    _fastingStartTime = null;
    _fastingStatus = 'Janela Alimentar';
    _fastingElapsed = Duration.zero;
    notifyListeners();
  }

  // Para tudo
  void stopFasting() {
    _isFasting = false;
    _isEatingWindow = false;
    _fastingStartTime = null;
    _eatingWindowStartTime = null;
    _fastingStatus = '';
    _fastingElapsed = Duration.zero;
    notifyListeners();
  }

  // Força atualização do UI (chamar de um Timer)
  void refreshFastingTimer() {
    if (_isFasting || _isEatingWindow) {
      notifyListeners();
    }
  }

  // Para testes - simular jejum ativo
  void debugStartFasting({Duration? elapsed}) {
    _isFasting = true;
    _isEatingWindow = false;
    _fastingStartTime = DateTime.now().subtract(elapsed ?? const Duration(hours: 4, minutes: 32));
    _fastingStatus = 'Jejum';
    notifyListeners();
  }

  // Para testes - simular janela alimentar
  void debugStartEatingWindow({Duration? elapsed}) {
    _isFasting = false;
    _isEatingWindow = true;
    _eatingWindowStartTime = DateTime.now().subtract(elapsed ?? const Duration(hours: 2, minutes: 15));
    _fastingStatus = 'Janela Alimentar';
    notifyListeners();
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final summary = await _repository.getDailySummary(_selectedDate);
      final goals = await _repository.getUserGoals();
      final weight = await _repository.getWeight(_selectedDate);
      final note = await _repository.getNote(_selectedDate);

      _caloriesConsumed = summary['calories'];
      _carbsConsumed = summary['carbs'];
      _proteinConsumed = summary['protein'];
      _fatConsumed = summary['fat'];
      _waterConsumed = summary['waterMl'];
      _exerciseBurned = summary['exerciseKcal'];
      _foodEntries = List<Map<String, dynamic>>.from(summary['entries']);

      _calorieGoal = goals['calories'] ?? 2000;
      _carbsGoal = goals['carbs'] ?? 250;
      _proteinGoal = goals['protein'] ?? 150;
      _fatGoal = goals['fat'] ?? 70;
      _waterGoal = goals['waterMl'] ?? 2000;
      
      // TODO: Get real weight goal from user prefs, for now using a placeholder or last known
      _weightGoal = 70.0; // Placeholder
      _currentWeight = weight ?? 70.0; // Default if not set
      _dailyNote = note;

    } catch (e) {
      debugPrint('Error loading dashboard data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addWater(int amount) async {
    await _repository.addWater(_selectedDate, amount);
    _waterConsumed += amount;
    notifyListeners();
  }

  Future<void> updateWeight(double weight) async {
    await _repository.setWeight(_selectedDate, weight);
    _currentWeight = weight;
    notifyListeners();
  }

  Future<void> deleteEntry(int index) async {
    await _repository.deleteEntry(_selectedDate, index);
    loadData(); // Reload to recalculate totals
  }
  
  // Helper to group entries by meal
  Map<String, List<Map<String, dynamic>>> get entriesByMeal {
    final Map<String, List<Map<String, dynamic>>> grouped = {
      'breakfast': [],
      'lunch': [],
      'dinner': [],
      'snack': [],
    };

    for (var entry in _foodEntries) {
      final meal = entry['mealTime'] as String? ?? 'snack';
      if (grouped.containsKey(meal)) {
        grouped[meal]!.add(entry);
      } else {
        grouped['snack']!.add(entry);
      }
    }
    return grouped;
  }
}
