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

  @override
  String get dashboardSummary => 'Summary';

  @override
  String get dashboardDetails => 'Details';

  @override
  String get dashboardWeek => 'Week';

  @override
  String get dashboardNutrition => 'Nutrition';

  @override
  String get dismissToday => 'Dismiss today';

  @override
  String get notesTitle => 'Notes';

  @override
  String get addNote => 'Add note';

  @override
  String get addNoteHint => 'Open editor to create today\'s note';

  @override
  String todayNotesCount(int count) {
    return 'Today: $count note(s)';
  }

  @override
  String get addBodyMetrics => 'Add body metrics';

  @override
  String get noEntryTodayTapToLog => 'No entry today - tap to log';

  @override
  String get noMealsToDuplicateToday => 'No meals to duplicate today';

  @override
  String get duplicateLastMealTitle => 'Duplicate last meal';

  @override
  String mealDuplicated(String meal) {
    return 'Meal duplicated ($meal)';
  }

  @override
  String get goalsPerMealTitle => 'Goals per meal';

  @override
  String get goalsPerMealUpdated => 'Goals per meal updated';

  @override
  String get remainingPlural => 'Remaining';

  @override
  String remainingGrams(int grams) {
    return 'Remaining: ${grams}g';
  }

  @override
  String get duplicate => 'Duplicate';

  @override
  String get duplicateDayTomorrowTitle => 'Duplicate day → tomorrow';

  @override
  String get duplicateDayPickDateTitle => 'Duplicate day → pick date';

  @override
  String get duplicateNewPickDateTitle => 'Duplicate \"new\" → pick date';

  @override
  String get noNewItemsToDuplicate => 'No \"new\" items to duplicate';

  @override
  String get selectItemsToDuplicateTitle => 'Select items to duplicate';

  @override
  String get chooseFileCsv => 'Choose file (.csv)';

  @override
  String get reviewItemsTitle => 'Review items';

  @override
  String get addSelected => 'Add selected';

  @override
  String get saveAndAdd => 'Save and add';

  @override
  String get detectFoodHeadline => 'Detect Food with AI';

  @override
  String get detectFoodSubtitle =>
      'Capture a photo or pick from gallery to automatically identify foods and their nutrition';

  @override
  String get takePhoto => 'Take Photo';

  @override
  String get gallery => 'Gallery';

  @override
  String get initializingCamera => 'Initializing camera...';

  @override
  String get detectionTipsTitle => 'Tips for better detection:';

  @override
  String get detectionTip1 => 'Make sure lighting is good';

  @override
  String get detectionTip2 => 'Shoot foods close up';

  @override
  String get detectionTip3 => 'Avoid shadows on the plate';

  @override
  String get detectionTip4 => 'One food at a time works best';

  @override
  String get onePortion => '1 portion';

  @override
  String itemsAdded(int count) {
    return '$count item(s) added';
  }

  @override
  String get portionApplied => 'Portion applied';

  @override
  String addedToDiaryWithMeal(String meal) {
    return 'Added to diary ($meal)';
  }

  @override
  String get changesSaved => 'Changes saved';

  @override
  String saveChangesWithMeal(String meal) {
    return 'Save changes - $meal';
  }

  @override
  String addToDiaryWithMeal(String meal) {
    return 'Add to diary - $meal';
  }

  @override
  String get addedToMyFoods => 'Added to My Foods';

  @override
  String get addToMyFoods => 'Add to My Foods';

  @override
  String get noMyFoodsTitle => 'You don\'t have My Foods yet';

  @override
  String get presetsHelp =>
      'Open a food\'s details and tap \"Add to My Foods\" to create your presets.';

  @override
  String get portionSizeGramsLabel => 'Portion size (g)';

  @override
  String get grams => 'grams';

  @override
  String get caloriesLabel => 'Calories';

  @override
  String get carbsLabel => 'Carbohydrates';

  @override
  String get proteinLabel => 'Protein';

  @override
  String get fatLabel => 'Fat';

  @override
  String get genericBrand => 'Generic';

  @override
  String addWithCalories(int kcal) {
    return 'Add - $kcal kcal';
  }

  @override
  String get analyzingFoods => 'Analyzing foods...';

  @override
  String get pleaseWait => 'Please wait a few seconds';

  @override
  String get retakePhoto => 'Retake photo';

  @override
  String get noFoodDetected => 'No food detected';

  @override
  String get tryCloserPhoto => 'Try taking a closer photo of the food';

  @override
  String get detectedFoods => 'Detected Foods';

  @override
  String get addOrEdit => 'Add or edit';

  @override
  String get addedShort => 'Added!';

  @override
  String get noFoodDetectedInImage => 'No food detected in the image';

  @override
  String get saveAsMyFoodOptional => 'Save as My Food (optional label)';

  @override
  String get download => 'Download';

  @override
  String get copy => 'Copy';

  @override
  String get importDayCsv => 'Import day CSV';

  @override
  String get clearDayBeforeApply => 'Clear day before applying';

  @override
  String get untitled => 'untitled';

  @override
  String get duplicateNewPickDate => 'Duplicate new → pick date';

  @override
  String dayDuplicatedTo(String date) {
    return 'Day duplicated to $date';
  }

  @override
  String get exerciseAdded100 => 'Exercise logged: +100 kcal';

  @override
  String waterAdjustedMinus250(int total) {
    return 'Water adjusted: -250ml (total ${total}ml)';
  }

  @override
  String get weekDuplicatedNext => 'Week duplicated to next';

  @override
  String weekDuplicatedToStart(String date) {
    return 'Week duplicated to start on $date';
  }

  @override
  String get noItemsThisMeal => 'No items in this meal';

  @override
  String get tapAddToLog => 'Tap + Add to quickly log foods.';

  @override
  String get viewDay => 'View day';

  @override
  String get onlyNew => 'Only new';

  @override
  String get dayCsvDownloaded => 'Day CSV downloaded';

  @override
  String get dayCsvCopied => 'Day CSV copied';

  @override
  String get dayTemplateSaved => 'Day template saved';

  @override
  String get noDayTemplatesSaved => 'No day templates saved';

  @override
  String get templateName => 'Template name';

  @override
  String get weekTemplateSaved => 'Week template saved';

  @override
  String get noWeekTemplatesSaved => 'No week templates saved';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get carbAbbrPlus => 'Carb+';

  @override
  String get proteinAbbrPlus => 'Prot+';

  @override
  String get fatAbbrPlus => 'Fat+';

  @override
  String get activitiesTitle => 'Activities';

  @override
  String get more => 'More';

  @override
  String get noActivitiesToday => 'No activities logged today';

  @override
  String get addExercise => 'Add exercise';

  @override
  String get areYouSureStopFasting =>
      'Are you sure you want to stop your current fast? Your progress will be saved.';

  @override
  String get stopFasting => 'Stop Fasting';

  @override
  String get startFasting => 'Start Fasting';

  @override
  String get openFilters => 'Open filters';

  @override
  String get details => 'Details';

  @override
  String get addToDiary => 'Add to diary';

  @override
  String get prepMode => 'Preparation';

  @override
  String get prepDetailsUnavailable =>
      'Preparation details are not available in this mock version.';

  @override
  String get proRecipe => 'PRO Recipe';

  @override
  String get tapToUnlock => 'Tap to unlock';

  @override
  String get proOnly => 'PRO Only';

  @override
  String get qaAddMeal => 'Add\nMeal';

  @override
  String get qaLogWater => 'Log\nWater';

  @override
  String get qaExercise => 'Exercise';

  @override
  String get qaProgress => 'Progress';

  @override
  String get qaRecipes => 'Recipes';

  @override
  String get qaSetupGoals => 'Setup\nGoals';

  @override
  String get featureInDevelopment => 'Feature in development';

  @override
  String get email => 'Email';

  @override
  String get enterEmail => 'Enter your email';

  @override
  String get password => 'Password';

  @override
  String get enterPassword => 'Enter your password';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get emailInvalid => 'Invalid email';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get passwordMinLength => 'Password must be at least 6 characters';

  @override
  String get forgotPassword => 'Forgot my password?';

  @override
  String get login => 'Login';

  @override
  String get newUser => 'New user? ';

  @override
  String get register => 'Sign up';

  @override
  String get registerScreenInDevelopment =>
      'Registration screen in development';

  @override
  String get logout => 'Logout';

  @override
  String get clear => 'Clear';

  @override
  String get import => 'Import';

  @override
  String get myProgress => 'My progress';

  @override
  String get myGoals => 'My goals';

  @override
  String get diet => 'Diet';

  @override
  String get standard => 'Standard';

  @override
  String get weightGoal => 'Weight goal';

  @override
  String get lose => 'Lose';

  @override
  String get maintain => 'Maintain';

  @override
  String get gain => 'Gain';

  @override
  String get initialWeight => 'Initial weight (kg)';

  @override
  String get targetWeight => 'Target weight (kg)';

  @override
  String get editGoals => 'Edit goals';

  @override
  String get goalsUpdated => 'Goals updated';

  @override
  String get carbs => 'Carbohydrates';

  @override
  String get proteins => 'Proteins';

  @override
  String get fats => 'Fats';

  @override
  String get confirm => 'Confirm';

  @override
  String get validCaloriesRequired => 'Enter valid calories (> 0)';

  @override
  String get validMacrosRequired => 'Macros must be numbers ≥ 0)';

  @override
  String get weight => 'Weight';

  @override
  String get height => 'Height';

  @override
  String get bodyFat => 'Body fat';

  @override
  String get bodyMetrics => 'Body Metrics';

  @override
  String get proPlanPersonalized => 'Personalized plans';

  @override
  String get proPlanPersonalizedDesc =>
      'Meal plans and fasting cycles adjusted to your goals.';

  @override
  String get proSmartScanner => 'Smart scanner';

  @override
  String get proSmartScannerDesc => 'Barcode + OCR to log meals in seconds.';

  @override
  String get proAdvancedInsights => 'Advanced insights';

  @override
  String get proAdvancedInsightsDesc =>
      'Predictive reports and automatic goal adjustments.';

  @override
  String get proExclusiveRecipes => 'Exclusive recipes';

  @override
  String get proExclusiveRecipesDesc =>
      'PRO collection with calculated macros and advanced filters.';

  @override
  String get cancelAnytime => 'Cancel anytime';

  @override
  String get dayGuarantee => '7-day guarantee';

  @override
  String get averageRating => 'Average rating 4.8/5';

  @override
  String get noPlansAvailable =>
      'No plans available at the moment.\nTry again later.';

  @override
  String get errorLoadingPlans =>
      'Error loading plans.\nCheck your connection.';

  @override
  String get proActivated => 'PRO subscription activated successfully!';

  @override
  String get cancelPro => 'Cancel PRO';

  @override
  String get keepPro => 'Keep PRO';

  @override
  String get cancelProTestMode => 'Cancel PRO (test environment)';

  @override
  String get freePlanReactivated => 'Free plan reactivated';

  @override
  String get exploreProBenefits => 'Explore PRO benefits';

  @override
  String get restorePurchases => 'Restore Purchases';

  @override
  String get reduceAnimations => 'Reduce animations';

  @override
  String get reduceAnimationsDesc => 'Avoids confetti/exaggerated transitions';

  @override
  String get animationsReduced => 'Animations reduced';

  @override
  String get animationsNormal => 'Normal animations';

  @override
  String get celebrateAchievements => 'Celebrate achievements';

  @override
  String get celebrateAchievementsDesc =>
      'Shows confetti when unlocking badges';

  @override
  String get celebrationsDisabled => 'Celebrations disabled';

  @override
  String get celebrationsEnabled => 'Celebrations enabled';

  @override
  String get showNextMilestone => 'Show \'Next milestone\' in chips';

  @override
  String get showNextMilestoneDesc => 'Shows \'• next: Nd\' in streak chips';

  @override
  String get useLottieInCelebrations => 'Use Lottie in celebrations';

  @override
  String get searchAndFoods => 'Search and foods';

  @override
  String get interpretQuantitiesNLQ => 'Interpret quantities in text (NLQ)';

  @override
  String get collapse => 'Collapse';

  @override
  String get expand => 'Expand';

  @override
  String get breakfast => 'Breakfast';

  @override
  String get lunch => 'Lunch';

  @override
  String get dinner => 'Dinner';

  @override
  String get snacks => 'Snacks';

  @override
  String get exportJSON => 'Export JSON';

  @override
  String get importJSON => 'Import JSON';

  @override
  String get clearTemplates => 'Clear templates';

  @override
  String get clearFoods => 'Clear foods';

  @override
  String get setGoals => 'Set goals';

  @override
  String get knowProNutriTracker => 'Know NutriTracker PRO';

  @override
  String get friends => 'Friends';

  @override
  String get analysis => 'ANALYSIS';

  @override
  String get registerWeight => 'REGISTER WEIGHT';

  @override
  String get defineGoal => 'DEFINE GOAL';

  @override
  String get edit => 'EDIT';

  @override
  String dietType(String type) {
    return 'Diet: $type';
  }

  @override
  String goalObjective(String objective) {
    return 'Goal: $objective';
  }

  @override
  String unexpectedErrorMessage(String error) {
    return 'Unexpected error: $error';
  }

  @override
  String get dataSourceQA => 'Show data source (OFF/FDC/NLQ)';

  @override
  String get qaDebugging => 'QA / Debugging';

  @override
  String get achievementsStreaksCleared => 'Achievements and streaks cleared';

  @override
  String get clearAchievementsStreaks => 'Clear achievements/streaks';

  @override
  String get testBadgeGranted => 'Test badge granted';

  @override
  String get grantTestBadge => 'Grant test badge';

  @override
  String get recalculateStreaks60 => 'Recalculate streaks (60 days)';

  @override
  String get recalculatePerfectWeek => 'Recalculate perfect week';

  @override
  String get testCelebration => 'Test celebration';

  @override
  String get preferenceSaved => 'Preference saved';

  @override
  String get aiCacheNormalization => 'AI Cache (food normalization)';

  @override
  String get chipsUpdated => 'Chips updated';

  @override
  String get aiCacheCleared => 'AI cache cleared';

  @override
  String get aiCacheCopied => 'AI cache copied';

  @override
  String get aiCacheImported => 'AI cache imported';

  @override
  String invalidJSON(String error) {
    return 'Invalid JSON: $error';
  }

  @override
  String get mealGoalsSaved => 'Meal goals saved!';

  @override
  String get dataSource => 'Show data source (OFF/FDC/NLQ)';

  @override
  String get me => 'ME';

  @override
  String get freePlan => 'Free Plan';

  @override
  String get proSubscription => 'PRO Subscription';

  @override
  String get dailyGoals => 'Daily Goals';

  @override
  String get logoutAccount => 'Log out of account?';

  @override
  String get logoutConfirmMessage =>
      'You will need to log in again. To confirm, type: LOGOUT';

  @override
  String get intelligentReports => 'Intelligent reports';

  @override
  String get guidedPlans => 'Guided plans';

  @override
  String get barcodeScanner => 'Barcode scanner';

  @override
  String get nutriTrackerPro => 'NutriTracker PRO';

  @override
  String get proDescription =>
      'Customize meals, receive smart alerts and access the complete library of exclusive recipes.';

  @override
  String get meetNutriTrackerPro => 'Meet NutriTracker PRO';

  @override
  String get plansStartingAt =>
      'Plans starting at \$14.99/month · Cancel anytime';

  @override
  String get youArePro => 'You are PRO!';

  @override
  String get proEnjoyMessage =>
      'Enjoy all advanced features of NutriTracker. New recipes and plans arrive every week.';

  @override
  String get advancedInsights => 'Advanced insights';

  @override
  String get dynamicPlans => 'Dynamic plans';

  @override
  String get proRecipes => 'PRO Recipes';

  @override
  String get proSubscriptionActivated =>
      'PRO subscription activated successfully!';

  @override
  String unexpectedError(String error) {
    return 'Unexpected error: $error';
  }

  @override
  String get terminatePro => 'Terminate PRO';

  @override
  String get terminateProConfirmMessage =>
      'This action is only available for testing. Confirm cancellation of PRO subscription?';

  @override
  String get connectWithFriends =>
      'Connect with friends to compare progress. Coming soon.';

  @override
  String get goalReached => 'Goal reached!';

  @override
  String get noVariationYet => 'No variation yet';

  @override
  String youGainedWeight(String weight) {
    return 'You gained $weight kg';
  }

  @override
  String youLostWeight(String weight) {
    return 'You lost $weight kg';
  }

  @override
  String get defineWeightGoalMessage =>
      'Define your weight goal to track the bar';

  @override
  String get weightGoalKg => 'Weight goal (kg)';

  @override
  String get startingWeightKg => 'Starting weight (kg)';

  @override
  String get weightObjective => 'Weight objective';

  @override
  String get goalsUpdatedSuccess => 'Goals updated';

  @override
  String get reducedAnimations => 'Reduced animations';

  @override
  String get normalAnimations => 'Normal animations';

  @override
  String get showConfettiOnBadges => 'Show confetti when unlocking badges';

  @override
  String get showNextMilestoneDescription =>
      'Shows \'• next: Nd\' in streak chips';

  @override
  String get interpretQuantitiesInText => 'Interpret quantities in text (NLQ)';

  @override
  String get quantitiesExample =>
      'Ex.: \'150g chicken\', \'2 eggs and 1 banana\'';

  @override
  String get mealGoalsPerMeal => 'Goals per meal';

  @override
  String get kcal => 'kcal';

  @override
  String get carbGrams => 'Carb. (g)';

  @override
  String get protGrams => 'Prot. (g)';

  @override
  String get fatGrams => 'Fat (g)';

  @override
  String get saveMealGoals => 'Save goals';

  @override
  String get mealGoalsCleared => 'Meal goals cleared';

  @override
  String get clearMealGoalsConfirm => 'Clear meal goals?';

  @override
  String get clearMealGoalsMessage =>
      'This action resets the goals for Breakfast, Lunch, Dinner and Snacks.\nTo confirm, type: CONFIRM';

  @override
  String get diaryExported => 'Diary exported to clipboard';

  @override
  String exportFailed(String error) {
    return 'Export failed: $error';
  }

  @override
  String get importDiary => 'Import Diary (JSON)';

  @override
  String get diaryImported => 'Diary imported successfully';

  @override
  String get templatesExported => 'Templates copied to clipboard';

  @override
  String exportTemplatesFailed(String error) {
    return 'Failed to export templates: $error';
  }

  @override
  String get importTemplates => 'Import Templates (JSON)';

  @override
  String get templatesImported => 'Templates imported successfully';

  @override
  String get foodsExported => 'Foods copied to clipboard';

  @override
  String exportFoodsFailed(String error) {
    return 'Failed to export foods: $error';
  }

  @override
  String get importFoods => 'Import Foods (JSON)';

  @override
  String get foodsImported => 'Foods imported successfully';

  @override
  String get foodsCleared => 'Foods cleared';

  @override
  String get clearAllFoodsConfirm => 'Clear all foods?';

  @override
  String get clearAllFoodsMessage =>
      'This action removes Favorites and My Foods. Cannot be undone.\nTo confirm, type: CLEAR';

  @override
  String get templatesCleared => 'Templates cleared';

  @override
  String get clearAllTemplatesConfirm => 'Clear all templates?';

  @override
  String get clearAllTemplatesMessage =>
      'This action removes all day and week templates. Cannot be undone.\nTo confirm, type: CLEAR';

  @override
  String get importAICacheJSON => 'Import AI Cache (JSON)';

  @override
  String get water => 'Water';

  @override
  String get activities => 'Activities';

  @override
  String get walking => 'Walking';

  @override
  String get running => 'Running';

  @override
  String get cycling => 'Cycling';

  @override
  String get addMeal => 'Add Meal';

  @override
  String get navFasting => 'Fasting';

  @override
  String get navRecipes => 'Recipes';

  @override
  String get navCoach => 'Coach';

  @override
  String get eaten => 'Eaten';

  @override
  String get remaining => 'Remaining';

  @override
  String get burned => 'Burned';

  @override
  String get nutrition => 'Nutrition';

  @override
  String get dayActions => 'Day actions';

  @override
  String get statistics => 'Statistics';

  @override
  String get moreActions => 'More actions';

  @override
  String walkingMinutes(int minutes) {
    return 'Walking ${minutes}m';
  }

  @override
  String runningMinutes(int minutes) {
    return 'Running ${minutes}m';
  }

  @override
  String cyclingMinutes(int minutes) {
    return 'Cycling ${minutes}m';
  }

  @override
  String get macronutrients => 'Macronutrients';

  @override
  String get goals => 'Goals';

  @override
  String get adjustMacroGoals => 'Adjust macro goals';

  @override
  String get macroGoalsUpdated => 'Macro goals updated';

  @override
  String get intermittentFasting => 'Intermittent Fasting';

  @override
  String get fastingSchedules => 'Fasting schedules';

  @override
  String eatingWindow(String stop, String start) {
    return 'Eating window: $stop - $start';
  }

  @override
  String get fastingMethod168 => '16:8 Method';

  @override
  String get fastingMethod186 => '18:6 Method';

  @override
  String get fastingMethod204 => '20:4 Method';

  @override
  String fastingMethodCustom(int hours) {
    return 'Custom • ${hours}h';
  }

  @override
  String fastingMethodLabel(String method) {
    return 'Method $method';
  }

  @override
  String timezone(String timezone) {
    return 'Timezone: $timezone';
  }

  @override
  String endsAt(String time) {
    return 'Ends at $time';
  }

  @override
  String fastingDays(int days) {
    return '${days}d fasting';
  }

  @override
  String get noFastingStreak => 'No fasting streak';

  @override
  String get defineCustomMethod => 'Define custom method';

  @override
  String get fastingDuration => 'Fasting duration';

  @override
  String get minutes => 'Minutes';

  @override
  String fastStarted(String method) {
    return 'Fast started! Method $method';
  }

  @override
  String fastCompleted(int hours, int minutes) {
    return 'Fast completed! Duration: ${hours}h ${minutes}min';
  }

  @override
  String get congratulations => 'Congratulations!';

  @override
  String fastCompletedSuccess(String method) {
    return 'You completed your $method fast successfully! 🎉';
  }

  @override
  String notificationsMutedUntil(String time) {
    return 'Notifications muted until $time';
  }

  @override
  String get reactivate => 'Reactivate';

  @override
  String get stopCurrentFastToChangeMethod =>
      'Stop current fast to change method';

  @override
  String fastingOfDay(String date) {
    return 'Fast of $date';
  }

  @override
  String duration(int hours) {
    return 'Duration: ${hours}h';
  }

  @override
  String get fastCompletedSuccessfully => 'Fast completed successfully';

  @override
  String get remindersMuted24h => 'Reminders muted for 24h';

  @override
  String get remindersReactivated => 'Reminders reactivated';

  @override
  String get remindersMutedTomorrow => 'Reminders muted until tomorrow 08:00';

  @override
  String get startFastButton => 'Start fasting';

  @override
  String get endFastButton => 'End fast';
}
