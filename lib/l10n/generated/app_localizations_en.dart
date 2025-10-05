// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get streakOverviewTitle => 'Streak Overview';

  @override
  String get streakCurrentLabel => 'Current streak';

  @override
  String streakDays(int count) {
    return '$count days';
  }

  @override
  String get streakNoStreak => 'No streak yet';

  @override
  String get streakLogFood => 'Log food';

  @override
  String get streakMilestonesTitle => 'Milestones';

  @override
  String streakDayProgress(int current, int next) {
    return 'Day $current/$next';
  }

  @override
  String get streakGoalCompleted => 'Goal completed';

  @override
  String get streakWeeklyOverviewTitle => 'Weekly overview';

  @override
  String get streakLongestTitle => 'Longest streak';

  @override
  String get weekMon => 'Mon';

  @override
  String get weekTue => 'Tue';

  @override
  String get weekWed => 'Wed';

  @override
  String get weekThu => 'Thu';

  @override
  String get weekFri => 'Fri';

  @override
  String get weekSat => 'Sat';

  @override
  String get weekSun => 'Sun';

  @override
  String get gotIt => 'Got it';

  @override
  String get streakNuxBody =>
      'Tap the dots to jump to a specific day\nYour streak grows when you log any food entry for the day.';

  @override
  String get achievementsTitle => 'Achievements';

  @override
  String get achievementsTabAll => 'All';

  @override
  String get achievementsTabWater => 'Water';

  @override
  String get achievementsTabFasting => 'Fasting';

  @override
  String get achievementsTabCalories => 'Calories';

  @override
  String get achievementsTabProtein => 'Protein';

  @override
  String get achievementsTabFood => 'Food';

  @override
  String get achievementsTabTest => 'Test';

  @override
  String get achievementsTabFavorites => 'Favorites';

  @override
  String get achievementsListView => 'List view';

  @override
  String get achievementsGridView => 'Grid view';

  @override
  String get achievementsEmpty => 'No achievements yet';

  @override
  String get achievementsDefaultTitle => 'Achievement';

  @override
  String get achievementsType => 'Type';

  @override
  String get achievementsGoal => 'Goal';

  @override
  String get achievementsNewBadge => 'New';

  @override
  String get achievementsFavorite => 'Favorite';

  @override
  String get achievementsRemoveFavorite => 'Remove favorite';

  @override
  String achievementsTotal(int count) {
    return 'Total: $count';
  }

  @override
  String get filterTypeLabel => 'Type';

  @override
  String get filterTypeAll => 'All';

  @override
  String get filterTypeSuccess => 'Success';

  @override
  String get filterTypeStreak => 'Streak';

  @override
  String get filterTypePremium => 'Premium';

  @override
  String get filterTypeGeneral => 'General';

  @override
  String get filterGoalLabel => 'Goal';

  @override
  String get filterGoalAll => 'All';

  @override
  String get filterGoalWater => 'Water';

  @override
  String get filterGoalFasting => 'Fasting';

  @override
  String get filterGoalCalories => 'Calories';

  @override
  String get filterGoalProtein => 'Protein';

  @override
  String get filterGoalFood => 'Food';

  @override
  String get filterGoalTest => 'Test';

  @override
  String get filterSortLabel => 'Sort';

  @override
  String get sortRecent => 'Recent';

  @override
  String get sortOldest => 'Oldest';

  @override
  String get sortType => 'Type';

  @override
  String get navDiary => 'Diary';

  @override
  String get navSearch => 'Search';

  @override
  String get navAdd => 'Add';

  @override
  String get navProgress => 'Progress';

  @override
  String get navProfile => 'Profile';

  @override
  String get addSheetAddFood => 'Add food';

  @override
  String get addSheetAddBreakfast => 'Add to Breakfast';

  @override
  String get addSheetAddLunch => 'Add to Lunch';

  @override
  String get addSheetAddDinner => 'Add to Dinner';

  @override
  String get addSheetAddSnacks => 'Add to Snacks';

  @override
  String get addSheetAddWater250 => 'Add water (+250 ml)';

  @override
  String get addSheetAddedWater250 => 'Added 250 ml of water';

  @override
  String get addSheetAddWater500 => 'Add water (+500 ml)';

  @override
  String get addSheetAddedWater500 => 'Added 500 ml of water';

  @override
  String get addSheetFoodScanner => 'Food Scanner/AI';

  @override
  String get addSheetExploreRecipes => 'Explore recipes';

  @override
  String get addSheetIntermittentFasting => 'Intermittent fasting';

  @override
  String get appbarPrevDay => 'Previous day';

  @override
  String get appbarToday => 'Today';

  @override
  String get appbarToggleDashboardOriginal => 'Original Dashboard';

  @override
  String get appbarToggleDashboardV1 => 'Dashboard v1';

  @override
  String get appbarGamificationTooltip => 'Gamification';

  @override
  String get appbarGamificationSoon => 'Gamification coming soon';

  @override
  String get appbarStreakTooltip => 'Streaks';

  @override
  String get appbarStreakSoon => 'Streaks/Achievements coming soon';

  @override
  String get appbarStatisticsTooltip => 'Statistics';

  @override
  String get appbarSelectDate => 'Select date';

  @override
  String get splashUnexpectedError => 'Unexpected error during initialization';

  @override
  String get splashForceUpdateTitle => 'Update Required';

  @override
  String get splashForceUpdateBody =>
      'A new version of NutriTracker is available. Please update the app to continue.';

  @override
  String get splashUpdate => 'Update';

  @override
  String get splashUnknownError => 'Unknown error';

  @override
  String get splashRetry => 'Try Again';

  @override
  String versionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get dowMon => 'Monday';

  @override
  String get dowTue => 'Tuesday';

  @override
  String get dowWed => 'Wednesday';

  @override
  String get dowThu => 'Thursday';

  @override
  String get dowFri => 'Friday';

  @override
  String get dowSat => 'Saturday';

  @override
  String get dowSun => 'Sunday';

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String get dashboardQuickActions => 'Quick Actions';

  @override
  String get dashboardTodaysMeals => 'Today\'s Meals';

  @override
  String get dashboardViewAll => 'View All';

  @override
  String get dashboardAddMeal => 'Add Meal';

  @override
  String streakNext(int next) {
    return '• next: ${next}d';
  }

  @override
  String badgeEarnedOn(String date) {
    return 'Earned on: $date';
  }

  @override
  String get close => 'Close';

  @override
  String get weeklyProgressTitle => 'Weekly Progress';

  @override
  String get menu => 'Menu';

  @override
  String get exportCsv => 'Export CSV';

  @override
  String get downloadCsv => 'Download CSV';

  @override
  String get importCsv => 'Import CSV';

  @override
  String get saveWeekAsTemplate => 'Save week as template';

  @override
  String get applyWeekTemplate => 'Apply week template';

  @override
  String get duplicateWeekNext => 'Duplicate week → next';

  @override
  String get duplicateWeekPickDate => 'Duplicate week → pick date';

  @override
  String get installApp => 'Install app';

  @override
  String get caloriesPerDay => 'Calories per day';

  @override
  String daysWithNew(int count) {
    return '$count day(s) with new items';
  }

  @override
  String get perMealAverages => 'Per-meal averages (kcal/day)';

  @override
  String get weeklyMacroAverages => 'Weekly macro averages';

  @override
  String get carbsAvg => 'Carbs (avg)';

  @override
  String get proteinAvg => 'Protein (avg)';

  @override
  String get fatAvg => 'Fat (avg)';

  @override
  String get waterPerDay => 'Water per day';

  @override
  String get exercisePerDay => 'Exercise per day';

  @override
  String get dailySummary => 'Daily summary';

  @override
  String get mealBreakfast => 'Breakfast';

  @override
  String get mealLunch => 'Lunch';

  @override
  String get mealDinner => 'Dinner';

  @override
  String get mealSnack => 'Snack';

  @override
  String get weekCsvCopied => 'Week CSV copied/shared';

  @override
  String get fileName => 'File name';

  @override
  String get fileHint => 'file.csv';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get templateApplied => 'Template applied to day';

  @override
  String get duplicateTomorrow => 'Duplicate → tomorrow';

  @override
  String get weekActions => 'Week actions';

  @override
  String get hdrDate => 'Date';

  @override
  String get hdrWater => 'Water';

  @override
  String get hdrExercise => 'Exer.';

  @override
  String get hdrCarb => 'Carb';

  @override
  String get hdrProt => 'Prot';

  @override
  String get hdrFat => 'Fat';

  @override
  String get overGoal => 'Over goal';

  @override
  String get onbWelcome => 'Welcome';

  @override
  String get onbInfoTitle => 'It\'s okay to be imperfect';

  @override
  String get onbInfoBody =>
      'We will build habits gradually. Focus on consistency, not perfection.';

  @override
  String get continueLabel => 'Continue';

  @override
  String get finishLabel => 'Finish';

  @override
  String get onbCommitToday => 'Commitment marked for today';

  @override
  String get dayStreak => 'Day Streak';

  @override
  String get onbCongratsStreak => 'Great! You started your streak. Keep it up!';

  @override
  String get onbImCommitted => 'I\'m committed';

  @override
  String get goalsSet => 'Goals set';

  @override
  String get defineGoalsTitle => 'Set your goals';

  @override
  String get defineGoalsBody =>
      'Adjust calories and macros to your target. You can change later.';

  @override
  String get openGoalsWizard => 'Open goals wizard';

  @override
  String get notificationsConfigured => 'Notifications configured';

  @override
  String get remindersSaved => 'Reminders saved';

  @override
  String get remindersTitle => 'Reminders & Notifications';

  @override
  String get remindersBody =>
      'Enable hydration reminders to help daily consistency. You can change this later in settings.';

  @override
  String get enableHydrationReminders => 'Enable hydration reminders';

  @override
  String get intervalMinutes => 'Interval (min)';

  @override
  String get requesting => 'Requesting…';

  @override
  String get allowNotifications => 'Allow notifications';

  @override
  String get recipesTitle => 'Recipes';

  @override
  String get recipesEmptyFiltered => 'No recipes found';

  @override
  String get recipesLoadingTitle => 'Loading recipes...';

  @override
  String get recipesEmptySubtitle =>
      'Try adjusting your filters or search term';

  @override
  String get recipesLoadingSubtitle =>
      'Please wait while we load the best recipes for you';

  @override
  String get clearFilters => 'Clear filters';

  @override
  String get refresh => 'Refresh';

  @override
  String get recipeAddedToFavorites => 'Recipe added to favorites';

  @override
  String get recipeRemovedFromFavorites => 'Recipe removed from favorites';

  @override
  String openingRecipe(String name) {
    return 'Opening recipe: $name';
  }

  @override
  String addedToMealPlan(String name) {
    return '$name added to meal plan';
  }

  @override
  String sharingRecipe(String name) {
    return 'Sharing recipe: $name';
  }

  @override
  String findingSimilar(String name) {
    return 'Finding recipes similar to: $name';
  }

  @override
  String get qaAddToMealPlan => 'Add to Meal Plan';

  @override
  String get qaScheduleThisRecipe => 'Schedule this recipe for a meal';

  @override
  String get qaShareRecipe => 'Share Recipe';

  @override
  String get qaShareWithFriends => 'Share with friends and family';

  @override
  String get qaSimilarRecipes => 'Similar Recipes';

  @override
  String get qaFindSimilar => 'Find similar recipes';

  @override
  String get filtersTitle => 'Filters';

  @override
  String get clearAll => 'Clear all';

  @override
  String get apply => 'Apply';

  @override
  String get mealType => 'Meal Type';

  @override
  String get dietaryRestrictions => 'Dietary Restrictions';

  @override
  String get prepTime => 'Prep Time';

  @override
  String get calories => 'Calories';

  @override
  String get dietVegetarian => 'Vegetarian';

  @override
  String get dietVegan => 'Vegan';

  @override
  String get dietGlutenFree => 'Gluten-Free';

  @override
  String get prepLt15 => '< 15 min';

  @override
  String get prep15to30 => '15-30 min';

  @override
  String get prep30to60 => '30-60 min';

  @override
  String get prepGt60 => '> 60 min';

  @override
  String get calLt200 => '< 200 cal';

  @override
  String get cal200to400 => '200-400 cal';

  @override
  String get cal400to600 => '400-600 cal';

  @override
  String get calGt600 => '> 600 cal';

  @override
  String get searchRecipesHint => 'Search recipes...';
}
