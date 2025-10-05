import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt')
  ];

  /// No description provided for @streakOverviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Streak Overview'**
  String get streakOverviewTitle;

  /// No description provided for @streakCurrentLabel.
  ///
  /// In en, this message translates to:
  /// **'Current streak'**
  String get streakCurrentLabel;

  /// No description provided for @streakDays.
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String streakDays(int count);

  /// No description provided for @streakNoStreak.
  ///
  /// In en, this message translates to:
  /// **'No streak yet'**
  String get streakNoStreak;

  /// No description provided for @streakLogFood.
  ///
  /// In en, this message translates to:
  /// **'Log food'**
  String get streakLogFood;

  /// No description provided for @streakMilestonesTitle.
  ///
  /// In en, this message translates to:
  /// **'Milestones'**
  String get streakMilestonesTitle;

  /// No description provided for @streakDayProgress.
  ///
  /// In en, this message translates to:
  /// **'Day {current}/{next}'**
  String streakDayProgress(int current, int next);

  /// No description provided for @streakGoalCompleted.
  ///
  /// In en, this message translates to:
  /// **'Goal completed'**
  String get streakGoalCompleted;

  /// No description provided for @streakWeeklyOverviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly overview'**
  String get streakWeeklyOverviewTitle;

  /// No description provided for @streakLongestTitle.
  ///
  /// In en, this message translates to:
  /// **'Longest streak'**
  String get streakLongestTitle;

  /// No description provided for @weekMon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get weekMon;

  /// No description provided for @weekTue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get weekTue;

  /// No description provided for @weekWed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get weekWed;

  /// No description provided for @weekThu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get weekThu;

  /// No description provided for @weekFri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get weekFri;

  /// No description provided for @weekSat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get weekSat;

  /// No description provided for @weekSun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get weekSun;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get gotIt;

  /// No description provided for @streakNuxBody.
  ///
  /// In en, this message translates to:
  /// **'Tap the dots to jump to a specific day\nYour streak grows when you log any food entry for the day.'**
  String get streakNuxBody;

  /// No description provided for @achievementsTitle.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievementsTitle;

  /// No description provided for @achievementsTabAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get achievementsTabAll;

  /// No description provided for @achievementsTabWater.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get achievementsTabWater;

  /// No description provided for @achievementsTabFasting.
  ///
  /// In en, this message translates to:
  /// **'Fasting'**
  String get achievementsTabFasting;

  /// No description provided for @achievementsTabCalories.
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get achievementsTabCalories;

  /// No description provided for @achievementsTabProtein.
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get achievementsTabProtein;

  /// No description provided for @achievementsTabFood.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get achievementsTabFood;

  /// No description provided for @achievementsTabTest.
  ///
  /// In en, this message translates to:
  /// **'Test'**
  String get achievementsTabTest;

  /// No description provided for @achievementsTabFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get achievementsTabFavorites;

  /// No description provided for @achievementsListView.
  ///
  /// In en, this message translates to:
  /// **'List view'**
  String get achievementsListView;

  /// No description provided for @achievementsGridView.
  ///
  /// In en, this message translates to:
  /// **'Grid view'**
  String get achievementsGridView;

  /// No description provided for @achievementsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No achievements yet'**
  String get achievementsEmpty;

  /// No description provided for @achievementsDefaultTitle.
  ///
  /// In en, this message translates to:
  /// **'Achievement'**
  String get achievementsDefaultTitle;

  /// No description provided for @achievementsType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get achievementsType;

  /// No description provided for @achievementsGoal.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get achievementsGoal;

  /// No description provided for @achievementsNewBadge.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get achievementsNewBadge;

  /// No description provided for @achievementsFavorite.
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get achievementsFavorite;

  /// No description provided for @achievementsRemoveFavorite.
  ///
  /// In en, this message translates to:
  /// **'Remove favorite'**
  String get achievementsRemoveFavorite;

  /// No description provided for @achievementsTotal.
  ///
  /// In en, this message translates to:
  /// **'Total: {count}'**
  String achievementsTotal(int count);

  /// No description provided for @filterTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get filterTypeLabel;

  /// No description provided for @filterTypeAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterTypeAll;

  /// No description provided for @filterTypeSuccess.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get filterTypeSuccess;

  /// No description provided for @filterTypeStreak.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get filterTypeStreak;

  /// No description provided for @filterTypePremium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get filterTypePremium;

  /// No description provided for @filterTypeGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get filterTypeGeneral;

  /// No description provided for @filterGoalLabel.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get filterGoalLabel;

  /// No description provided for @filterGoalAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterGoalAll;

  /// No description provided for @filterGoalWater.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get filterGoalWater;

  /// No description provided for @filterGoalFasting.
  ///
  /// In en, this message translates to:
  /// **'Fasting'**
  String get filterGoalFasting;

  /// No description provided for @filterGoalCalories.
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get filterGoalCalories;

  /// No description provided for @filterGoalProtein.
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get filterGoalProtein;

  /// No description provided for @filterGoalFood.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get filterGoalFood;

  /// No description provided for @filterGoalTest.
  ///
  /// In en, this message translates to:
  /// **'Test'**
  String get filterGoalTest;

  /// No description provided for @filterSortLabel.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get filterSortLabel;

  /// No description provided for @sortRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get sortRecent;

  /// No description provided for @sortOldest.
  ///
  /// In en, this message translates to:
  /// **'Oldest'**
  String get sortOldest;

  /// No description provided for @sortType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get sortType;

  /// No description provided for @navDiary.
  ///
  /// In en, this message translates to:
  /// **'Diary'**
  String get navDiary;

  /// No description provided for @navSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get navSearch;

  /// No description provided for @navAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get navAdd;

  /// No description provided for @navProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get navProgress;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @addSheetAddFood.
  ///
  /// In en, this message translates to:
  /// **'Add food'**
  String get addSheetAddFood;

  /// No description provided for @addSheetAddBreakfast.
  ///
  /// In en, this message translates to:
  /// **'Add to Breakfast'**
  String get addSheetAddBreakfast;

  /// No description provided for @addSheetAddLunch.
  ///
  /// In en, this message translates to:
  /// **'Add to Lunch'**
  String get addSheetAddLunch;

  /// No description provided for @addSheetAddDinner.
  ///
  /// In en, this message translates to:
  /// **'Add to Dinner'**
  String get addSheetAddDinner;

  /// No description provided for @addSheetAddSnacks.
  ///
  /// In en, this message translates to:
  /// **'Add to Snacks'**
  String get addSheetAddSnacks;

  /// No description provided for @addSheetAddWater250.
  ///
  /// In en, this message translates to:
  /// **'Add water (+250 ml)'**
  String get addSheetAddWater250;

  /// No description provided for @addSheetAddedWater250.
  ///
  /// In en, this message translates to:
  /// **'Added 250 ml of water'**
  String get addSheetAddedWater250;

  /// No description provided for @addSheetAddWater500.
  ///
  /// In en, this message translates to:
  /// **'Add water (+500 ml)'**
  String get addSheetAddWater500;

  /// No description provided for @addSheetAddedWater500.
  ///
  /// In en, this message translates to:
  /// **'Added 500 ml of water'**
  String get addSheetAddedWater500;

  /// No description provided for @addSheetFoodScanner.
  ///
  /// In en, this message translates to:
  /// **'Food Scanner/AI'**
  String get addSheetFoodScanner;

  /// No description provided for @addSheetExploreRecipes.
  ///
  /// In en, this message translates to:
  /// **'Explore recipes'**
  String get addSheetExploreRecipes;

  /// No description provided for @addSheetIntermittentFasting.
  ///
  /// In en, this message translates to:
  /// **'Intermittent fasting'**
  String get addSheetIntermittentFasting;

  /// No description provided for @appbarPrevDay.
  ///
  /// In en, this message translates to:
  /// **'Previous day'**
  String get appbarPrevDay;

  /// No description provided for @appbarToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get appbarToday;

  /// No description provided for @appbarToggleDashboardOriginal.
  ///
  /// In en, this message translates to:
  /// **'Original Dashboard'**
  String get appbarToggleDashboardOriginal;

  /// No description provided for @appbarToggleDashboardV1.
  ///
  /// In en, this message translates to:
  /// **'Dashboard v1'**
  String get appbarToggleDashboardV1;

  /// No description provided for @appbarGamificationTooltip.
  ///
  /// In en, this message translates to:
  /// **'Gamification'**
  String get appbarGamificationTooltip;

  /// No description provided for @appbarGamificationSoon.
  ///
  /// In en, this message translates to:
  /// **'Gamification coming soon'**
  String get appbarGamificationSoon;

  /// No description provided for @appbarStreakTooltip.
  ///
  /// In en, this message translates to:
  /// **'Streaks'**
  String get appbarStreakTooltip;

  /// No description provided for @appbarStreakSoon.
  ///
  /// In en, this message translates to:
  /// **'Streaks/Achievements coming soon'**
  String get appbarStreakSoon;

  /// No description provided for @appbarStatisticsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get appbarStatisticsTooltip;

  /// No description provided for @appbarSelectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get appbarSelectDate;

  /// No description provided for @splashUnexpectedError.
  ///
  /// In en, this message translates to:
  /// **'Unexpected error during initialization'**
  String get splashUnexpectedError;

  /// No description provided for @splashForceUpdateTitle.
  ///
  /// In en, this message translates to:
  /// **'Update Required'**
  String get splashForceUpdateTitle;

  /// No description provided for @splashForceUpdateBody.
  ///
  /// In en, this message translates to:
  /// **'A new version of NutriTracker is available. Please update the app to continue.'**
  String get splashForceUpdateBody;

  /// No description provided for @splashUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get splashUpdate;

  /// No description provided for @splashUnknownError.
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get splashUnknownError;

  /// No description provided for @splashRetry.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get splashRetry;

  /// No description provided for @versionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String versionLabel(String version);

  /// No description provided for @dowMon.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get dowMon;

  /// No description provided for @dowTue.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get dowTue;

  /// No description provided for @dowWed.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get dowWed;

  /// No description provided for @dowThu.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get dowThu;

  /// No description provided for @dowFri.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get dowFri;

  /// No description provided for @dowSat.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get dowSat;

  /// No description provided for @dowSun.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get dowSun;

  /// No description provided for @dashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboardTitle;

  /// No description provided for @dashboardQuickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get dashboardQuickActions;

  /// No description provided for @dashboardTodaysMeals.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Meals'**
  String get dashboardTodaysMeals;

  /// No description provided for @dashboardViewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get dashboardViewAll;

  /// No description provided for @dashboardAddMeal.
  ///
  /// In en, this message translates to:
  /// **'Add Meal'**
  String get dashboardAddMeal;

  /// No description provided for @streakNext.
  ///
  /// In en, this message translates to:
  /// **'• next: {next}d'**
  String streakNext(int next);

  /// No description provided for @badgeEarnedOn.
  ///
  /// In en, this message translates to:
  /// **'Earned on: {date}'**
  String badgeEarnedOn(String date);

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @weeklyProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly Progress'**
  String get weeklyProgressTitle;

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @exportCsv.
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get exportCsv;

  /// No description provided for @downloadCsv.
  ///
  /// In en, this message translates to:
  /// **'Download CSV'**
  String get downloadCsv;

  /// No description provided for @importCsv.
  ///
  /// In en, this message translates to:
  /// **'Import CSV'**
  String get importCsv;

  /// No description provided for @saveWeekAsTemplate.
  ///
  /// In en, this message translates to:
  /// **'Save week as template'**
  String get saveWeekAsTemplate;

  /// No description provided for @applyWeekTemplate.
  ///
  /// In en, this message translates to:
  /// **'Apply week template'**
  String get applyWeekTemplate;

  /// No description provided for @duplicateWeekNext.
  ///
  /// In en, this message translates to:
  /// **'Duplicate week → next'**
  String get duplicateWeekNext;

  /// No description provided for @duplicateWeekPickDate.
  ///
  /// In en, this message translates to:
  /// **'Duplicate week → pick date'**
  String get duplicateWeekPickDate;

  /// No description provided for @installApp.
  ///
  /// In en, this message translates to:
  /// **'Install app'**
  String get installApp;

  /// No description provided for @caloriesPerDay.
  ///
  /// In en, this message translates to:
  /// **'Calories per day'**
  String get caloriesPerDay;

  /// No description provided for @daysWithNew.
  ///
  /// In en, this message translates to:
  /// **'{count} day(s) with new items'**
  String daysWithNew(int count);

  /// No description provided for @perMealAverages.
  ///
  /// In en, this message translates to:
  /// **'Per-meal averages (kcal/day)'**
  String get perMealAverages;

  /// No description provided for @weeklyMacroAverages.
  ///
  /// In en, this message translates to:
  /// **'Weekly macro averages'**
  String get weeklyMacroAverages;

  /// No description provided for @carbsAvg.
  ///
  /// In en, this message translates to:
  /// **'Carbs (avg)'**
  String get carbsAvg;

  /// No description provided for @proteinAvg.
  ///
  /// In en, this message translates to:
  /// **'Protein (avg)'**
  String get proteinAvg;

  /// No description provided for @fatAvg.
  ///
  /// In en, this message translates to:
  /// **'Fat (avg)'**
  String get fatAvg;

  /// No description provided for @waterPerDay.
  ///
  /// In en, this message translates to:
  /// **'Water per day'**
  String get waterPerDay;

  /// No description provided for @exercisePerDay.
  ///
  /// In en, this message translates to:
  /// **'Exercise per day'**
  String get exercisePerDay;

  /// No description provided for @dailySummary.
  ///
  /// In en, this message translates to:
  /// **'Daily summary'**
  String get dailySummary;

  /// No description provided for @mealBreakfast.
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get mealBreakfast;

  /// No description provided for @mealLunch.
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get mealLunch;

  /// No description provided for @mealDinner.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get mealDinner;

  /// No description provided for @mealSnack.
  ///
  /// In en, this message translates to:
  /// **'Snack'**
  String get mealSnack;

  /// No description provided for @weekCsvCopied.
  ///
  /// In en, this message translates to:
  /// **'Week CSV copied/shared'**
  String get weekCsvCopied;

  /// No description provided for @fileName.
  ///
  /// In en, this message translates to:
  /// **'File name'**
  String get fileName;

  /// No description provided for @fileHint.
  ///
  /// In en, this message translates to:
  /// **'file.csv'**
  String get fileHint;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @templateApplied.
  ///
  /// In en, this message translates to:
  /// **'Template applied to day'**
  String get templateApplied;

  /// No description provided for @duplicateTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Duplicate → tomorrow'**
  String get duplicateTomorrow;

  /// No description provided for @weekActions.
  ///
  /// In en, this message translates to:
  /// **'Week actions'**
  String get weekActions;

  /// No description provided for @hdrDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get hdrDate;

  /// No description provided for @hdrWater.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get hdrWater;

  /// No description provided for @hdrExercise.
  ///
  /// In en, this message translates to:
  /// **'Exer.'**
  String get hdrExercise;

  /// No description provided for @hdrCarb.
  ///
  /// In en, this message translates to:
  /// **'Carb'**
  String get hdrCarb;

  /// No description provided for @hdrProt.
  ///
  /// In en, this message translates to:
  /// **'Prot'**
  String get hdrProt;

  /// No description provided for @hdrFat.
  ///
  /// In en, this message translates to:
  /// **'Fat'**
  String get hdrFat;

  /// No description provided for @overGoal.
  ///
  /// In en, this message translates to:
  /// **'Over goal'**
  String get overGoal;

  /// No description provided for @onbWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get onbWelcome;

  /// No description provided for @onbInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'It\'s okay to be imperfect'**
  String get onbInfoTitle;

  /// No description provided for @onbInfoBody.
  ///
  /// In en, this message translates to:
  /// **'We will build habits gradually. Focus on consistency, not perfection.'**
  String get onbInfoBody;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @finishLabel.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finishLabel;

  /// No description provided for @onbCommitToday.
  ///
  /// In en, this message translates to:
  /// **'Commitment marked for today'**
  String get onbCommitToday;

  /// No description provided for @dayStreak.
  ///
  /// In en, this message translates to:
  /// **'Day Streak'**
  String get dayStreak;

  /// No description provided for @onbCongratsStreak.
  ///
  /// In en, this message translates to:
  /// **'Great! You started your streak. Keep it up!'**
  String get onbCongratsStreak;

  /// No description provided for @onbImCommitted.
  ///
  /// In en, this message translates to:
  /// **'I\'m committed'**
  String get onbImCommitted;

  /// No description provided for @goalsSet.
  ///
  /// In en, this message translates to:
  /// **'Goals set'**
  String get goalsSet;

  /// No description provided for @defineGoalsTitle.
  ///
  /// In en, this message translates to:
  /// **'Set your goals'**
  String get defineGoalsTitle;

  /// No description provided for @defineGoalsBody.
  ///
  /// In en, this message translates to:
  /// **'Adjust calories and macros to your target. You can change later.'**
  String get defineGoalsBody;

  /// No description provided for @openGoalsWizard.
  ///
  /// In en, this message translates to:
  /// **'Open goals wizard'**
  String get openGoalsWizard;

  /// No description provided for @notificationsConfigured.
  ///
  /// In en, this message translates to:
  /// **'Notifications configured'**
  String get notificationsConfigured;

  /// No description provided for @remindersSaved.
  ///
  /// In en, this message translates to:
  /// **'Reminders saved'**
  String get remindersSaved;

  /// No description provided for @remindersTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminders & Notifications'**
  String get remindersTitle;

  /// No description provided for @remindersBody.
  ///
  /// In en, this message translates to:
  /// **'Enable hydration reminders to help daily consistency. You can change this later in settings.'**
  String get remindersBody;

  /// No description provided for @enableHydrationReminders.
  ///
  /// In en, this message translates to:
  /// **'Enable hydration reminders'**
  String get enableHydrationReminders;

  /// No description provided for @intervalMinutes.
  ///
  /// In en, this message translates to:
  /// **'Interval (min)'**
  String get intervalMinutes;

  /// No description provided for @requesting.
  ///
  /// In en, this message translates to:
  /// **'Requesting…'**
  String get requesting;

  /// No description provided for @allowNotifications.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications'**
  String get allowNotifications;

  /// No description provided for @recipesTitle.
  ///
  /// In en, this message translates to:
  /// **'Recipes'**
  String get recipesTitle;

  /// No description provided for @recipesEmptyFiltered.
  ///
  /// In en, this message translates to:
  /// **'No recipes found'**
  String get recipesEmptyFiltered;

  /// No description provided for @recipesLoadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Loading recipes...'**
  String get recipesLoadingTitle;

  /// No description provided for @recipesEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your filters or search term'**
  String get recipesEmptySubtitle;

  /// No description provided for @recipesLoadingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Please wait while we load the best recipes for you'**
  String get recipesLoadingSubtitle;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get clearFilters;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @recipeAddedToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Recipe added to favorites'**
  String get recipeAddedToFavorites;

  /// No description provided for @recipeRemovedFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Recipe removed from favorites'**
  String get recipeRemovedFromFavorites;

  /// No description provided for @openingRecipe.
  ///
  /// In en, this message translates to:
  /// **'Opening recipe: {name}'**
  String openingRecipe(String name);

  /// No description provided for @addedToMealPlan.
  ///
  /// In en, this message translates to:
  /// **'{name} added to meal plan'**
  String addedToMealPlan(String name);

  /// No description provided for @sharingRecipe.
  ///
  /// In en, this message translates to:
  /// **'Sharing recipe: {name}'**
  String sharingRecipe(String name);

  /// No description provided for @findingSimilar.
  ///
  /// In en, this message translates to:
  /// **'Finding recipes similar to: {name}'**
  String findingSimilar(String name);

  /// No description provided for @qaAddToMealPlan.
  ///
  /// In en, this message translates to:
  /// **'Add to Meal Plan'**
  String get qaAddToMealPlan;

  /// No description provided for @qaScheduleThisRecipe.
  ///
  /// In en, this message translates to:
  /// **'Schedule this recipe for a meal'**
  String get qaScheduleThisRecipe;

  /// No description provided for @qaShareRecipe.
  ///
  /// In en, this message translates to:
  /// **'Share Recipe'**
  String get qaShareRecipe;

  /// No description provided for @qaShareWithFriends.
  ///
  /// In en, this message translates to:
  /// **'Share with friends and family'**
  String get qaShareWithFriends;

  /// No description provided for @qaSimilarRecipes.
  ///
  /// In en, this message translates to:
  /// **'Similar Recipes'**
  String get qaSimilarRecipes;

  /// No description provided for @qaFindSimilar.
  ///
  /// In en, this message translates to:
  /// **'Find similar recipes'**
  String get qaFindSimilar;

  /// No description provided for @filtersTitle.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filtersTitle;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get clearAll;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @mealType.
  ///
  /// In en, this message translates to:
  /// **'Meal Type'**
  String get mealType;

  /// No description provided for @dietaryRestrictions.
  ///
  /// In en, this message translates to:
  /// **'Dietary Restrictions'**
  String get dietaryRestrictions;

  /// No description provided for @prepTime.
  ///
  /// In en, this message translates to:
  /// **'Prep Time'**
  String get prepTime;

  /// No description provided for @calories.
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get calories;

  /// No description provided for @dietVegetarian.
  ///
  /// In en, this message translates to:
  /// **'Vegetarian'**
  String get dietVegetarian;

  /// No description provided for @dietVegan.
  ///
  /// In en, this message translates to:
  /// **'Vegan'**
  String get dietVegan;

  /// No description provided for @dietGlutenFree.
  ///
  /// In en, this message translates to:
  /// **'Gluten-Free'**
  String get dietGlutenFree;

  /// No description provided for @prepLt15.
  ///
  /// In en, this message translates to:
  /// **'< 15 min'**
  String get prepLt15;

  /// No description provided for @prep15to30.
  ///
  /// In en, this message translates to:
  /// **'15-30 min'**
  String get prep15to30;

  /// No description provided for @prep30to60.
  ///
  /// In en, this message translates to:
  /// **'30-60 min'**
  String get prep30to60;

  /// No description provided for @prepGt60.
  ///
  /// In en, this message translates to:
  /// **'> 60 min'**
  String get prepGt60;

  /// No description provided for @calLt200.
  ///
  /// In en, this message translates to:
  /// **'< 200 cal'**
  String get calLt200;

  /// No description provided for @cal200to400.
  ///
  /// In en, this message translates to:
  /// **'200-400 cal'**
  String get cal200to400;

  /// No description provided for @cal400to600.
  ///
  /// In en, this message translates to:
  /// **'400-600 cal'**
  String get cal400to600;

  /// No description provided for @calGt600.
  ///
  /// In en, this message translates to:
  /// **'> 600 cal'**
  String get calGt600;

  /// No description provided for @searchRecipesHint.
  ///
  /// In en, this message translates to:
  /// **'Search recipes...'**
  String get searchRecipesHint;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'pt': return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
