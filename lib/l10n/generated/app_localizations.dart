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
/// import 'generated/app_localizations.dart';
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
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
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

  /// No description provided for @dashboardSummary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get dashboardSummary;

  /// No description provided for @dashboardDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get dashboardDetails;

  /// No description provided for @dashboardWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get dashboardWeek;

  /// No description provided for @dashboardNutrition.
  ///
  /// In en, this message translates to:
  /// **'Nutrition'**
  String get dashboardNutrition;

  /// No description provided for @dismissToday.
  ///
  /// In en, this message translates to:
  /// **'Dismiss today'**
  String get dismissToday;

  /// No description provided for @notesTitle.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notesTitle;

  /// No description provided for @addNote.
  ///
  /// In en, this message translates to:
  /// **'Add note'**
  String get addNote;

  /// No description provided for @addNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Open editor to create today\'s note'**
  String get addNoteHint;

  /// No description provided for @todayNotesCount.
  ///
  /// In en, this message translates to:
  /// **'Today: {count} note(s)'**
  String todayNotesCount(int count);

  /// No description provided for @addBodyMetrics.
  ///
  /// In en, this message translates to:
  /// **'Add body metrics'**
  String get addBodyMetrics;

  /// No description provided for @noEntryTodayTapToLog.
  ///
  /// In en, this message translates to:
  /// **'No entry today - tap to log'**
  String get noEntryTodayTapToLog;

  /// No description provided for @noMealsToDuplicateToday.
  ///
  /// In en, this message translates to:
  /// **'No meals to duplicate today'**
  String get noMealsToDuplicateToday;

  /// No description provided for @duplicateLastMealTitle.
  ///
  /// In en, this message translates to:
  /// **'Duplicate last meal'**
  String get duplicateLastMealTitle;

  /// No description provided for @mealDuplicated.
  ///
  /// In en, this message translates to:
  /// **'Meal duplicated ({meal})'**
  String mealDuplicated(String meal);

  /// No description provided for @goalsPerMealTitle.
  ///
  /// In en, this message translates to:
  /// **'Goals per meal'**
  String get goalsPerMealTitle;

  /// No description provided for @goalsPerMealUpdated.
  ///
  /// In en, this message translates to:
  /// **'Goals per meal updated'**
  String get goalsPerMealUpdated;

  /// No description provided for @remainingPlural.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get remainingPlural;

  /// No description provided for @remainingGrams.
  ///
  /// In en, this message translates to:
  /// **'Remaining: {grams}g'**
  String remainingGrams(int grams);

  /// No description provided for @duplicate.
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get duplicate;

  /// No description provided for @duplicateDayTomorrowTitle.
  ///
  /// In en, this message translates to:
  /// **'Duplicate day → tomorrow'**
  String get duplicateDayTomorrowTitle;

  /// No description provided for @duplicateDayPickDateTitle.
  ///
  /// In en, this message translates to:
  /// **'Duplicate day → pick date'**
  String get duplicateDayPickDateTitle;

  /// No description provided for @duplicateNewPickDateTitle.
  ///
  /// In en, this message translates to:
  /// **'Duplicate \"new\" → pick date'**
  String get duplicateNewPickDateTitle;

  /// No description provided for @noNewItemsToDuplicate.
  ///
  /// In en, this message translates to:
  /// **'No \"new\" items to duplicate'**
  String get noNewItemsToDuplicate;

  /// No description provided for @selectItemsToDuplicateTitle.
  ///
  /// In en, this message translates to:
  /// **'Select items to duplicate'**
  String get selectItemsToDuplicateTitle;

  /// No description provided for @chooseFileCsv.
  ///
  /// In en, this message translates to:
  /// **'Choose file (.csv)'**
  String get chooseFileCsv;

  /// No description provided for @reviewItemsTitle.
  ///
  /// In en, this message translates to:
  /// **'Review items'**
  String get reviewItemsTitle;

  /// No description provided for @addSelected.
  ///
  /// In en, this message translates to:
  /// **'Add selected'**
  String get addSelected;

  /// No description provided for @saveAndAdd.
  ///
  /// In en, this message translates to:
  /// **'Save and add'**
  String get saveAndAdd;

  /// No description provided for @detectFoodHeadline.
  ///
  /// In en, this message translates to:
  /// **'Detect Food with AI'**
  String get detectFoodHeadline;

  /// No description provided for @detectFoodSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Capture a photo or pick from gallery to automatically identify foods and their nutrition'**
  String get detectFoodSubtitle;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @initializingCamera.
  ///
  /// In en, this message translates to:
  /// **'Initializing camera...'**
  String get initializingCamera;

  /// No description provided for @detectionTipsTitle.
  ///
  /// In en, this message translates to:
  /// **'Tips for better detection:'**
  String get detectionTipsTitle;

  /// No description provided for @detectionTip1.
  ///
  /// In en, this message translates to:
  /// **'Make sure lighting is good'**
  String get detectionTip1;

  /// No description provided for @detectionTip2.
  ///
  /// In en, this message translates to:
  /// **'Shoot foods close up'**
  String get detectionTip2;

  /// No description provided for @detectionTip3.
  ///
  /// In en, this message translates to:
  /// **'Avoid shadows on the plate'**
  String get detectionTip3;

  /// No description provided for @detectionTip4.
  ///
  /// In en, this message translates to:
  /// **'One food at a time works best'**
  String get detectionTip4;

  /// No description provided for @onePortion.
  ///
  /// In en, this message translates to:
  /// **'1 portion'**
  String get onePortion;

  /// No description provided for @itemsAdded.
  ///
  /// In en, this message translates to:
  /// **'{count} item(s) added'**
  String itemsAdded(int count);

  /// No description provided for @portionApplied.
  ///
  /// In en, this message translates to:
  /// **'Portion applied'**
  String get portionApplied;

  /// No description provided for @addedToDiaryWithMeal.
  ///
  /// In en, this message translates to:
  /// **'Added to diary ({meal})'**
  String addedToDiaryWithMeal(String meal);

  /// No description provided for @changesSaved.
  ///
  /// In en, this message translates to:
  /// **'Changes saved'**
  String get changesSaved;

  /// No description provided for @saveChangesWithMeal.
  ///
  /// In en, this message translates to:
  /// **'Save changes - {meal}'**
  String saveChangesWithMeal(String meal);

  /// No description provided for @addToDiaryWithMeal.
  ///
  /// In en, this message translates to:
  /// **'Add to diary - {meal}'**
  String addToDiaryWithMeal(String meal);

  /// No description provided for @addedToMyFoods.
  ///
  /// In en, this message translates to:
  /// **'Added to My Foods'**
  String get addedToMyFoods;

  /// No description provided for @addToMyFoods.
  ///
  /// In en, this message translates to:
  /// **'Add to My Foods'**
  String get addToMyFoods;

  /// No description provided for @noMyFoodsTitle.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have My Foods yet'**
  String get noMyFoodsTitle;

  /// No description provided for @presetsHelp.
  ///
  /// In en, this message translates to:
  /// **'Open a food\'s details and tap \"Add to My Foods\" to create your presets.'**
  String get presetsHelp;

  /// No description provided for @portionSizeGramsLabel.
  ///
  /// In en, this message translates to:
  /// **'Portion size (g)'**
  String get portionSizeGramsLabel;

  /// No description provided for @grams.
  ///
  /// In en, this message translates to:
  /// **'grams'**
  String get grams;

  /// No description provided for @caloriesLabel.
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get caloriesLabel;

  /// No description provided for @carbsLabel.
  ///
  /// In en, this message translates to:
  /// **'Carbohydrates'**
  String get carbsLabel;

  /// No description provided for @proteinLabel.
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get proteinLabel;

  /// No description provided for @fatLabel.
  ///
  /// In en, this message translates to:
  /// **'Fat'**
  String get fatLabel;

  /// No description provided for @genericBrand.
  ///
  /// In en, this message translates to:
  /// **'Generic'**
  String get genericBrand;

  /// No description provided for @addWithCalories.
  ///
  /// In en, this message translates to:
  /// **'Add - {kcal} kcal'**
  String addWithCalories(int kcal);

  /// No description provided for @analyzingFoods.
  ///
  /// In en, this message translates to:
  /// **'Analyzing foods...'**
  String get analyzingFoods;

  /// No description provided for @pleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Please wait a few seconds'**
  String get pleaseWait;

  /// No description provided for @retakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Retake photo'**
  String get retakePhoto;

  /// No description provided for @noFoodDetected.
  ///
  /// In en, this message translates to:
  /// **'No food detected'**
  String get noFoodDetected;

  /// No description provided for @tryCloserPhoto.
  ///
  /// In en, this message translates to:
  /// **'Try taking a closer photo of the food'**
  String get tryCloserPhoto;

  /// No description provided for @detectedFoods.
  ///
  /// In en, this message translates to:
  /// **'Detected Foods'**
  String get detectedFoods;

  /// No description provided for @addOrEdit.
  ///
  /// In en, this message translates to:
  /// **'Add or edit'**
  String get addOrEdit;

  /// No description provided for @addedShort.
  ///
  /// In en, this message translates to:
  /// **'Added!'**
  String get addedShort;

  /// No description provided for @noFoodDetectedInImage.
  ///
  /// In en, this message translates to:
  /// **'No food detected in the image'**
  String get noFoodDetectedInImage;

  /// No description provided for @saveAsMyFoodOptional.
  ///
  /// In en, this message translates to:
  /// **'Save as My Food (optional label)'**
  String get saveAsMyFoodOptional;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @importDayCsv.
  ///
  /// In en, this message translates to:
  /// **'Import day CSV'**
  String get importDayCsv;

  /// No description provided for @clearDayBeforeApply.
  ///
  /// In en, this message translates to:
  /// **'Clear day before applying'**
  String get clearDayBeforeApply;

  /// No description provided for @untitled.
  ///
  /// In en, this message translates to:
  /// **'untitled'**
  String get untitled;

  /// No description provided for @duplicateNewPickDate.
  ///
  /// In en, this message translates to:
  /// **'Duplicate new → pick date'**
  String get duplicateNewPickDate;

  /// No description provided for @dayDuplicatedTo.
  ///
  /// In en, this message translates to:
  /// **'Day duplicated to {date}'**
  String dayDuplicatedTo(String date);

  /// No description provided for @exerciseAdded100.
  ///
  /// In en, this message translates to:
  /// **'Exercise logged: +100 kcal'**
  String get exerciseAdded100;

  /// No description provided for @waterAdjustedMinus250.
  ///
  /// In en, this message translates to:
  /// **'Water adjusted: -250ml (total {total}ml)'**
  String waterAdjustedMinus250(int total);

  /// No description provided for @weekDuplicatedNext.
  ///
  /// In en, this message translates to:
  /// **'Week duplicated to next'**
  String get weekDuplicatedNext;

  /// No description provided for @weekDuplicatedToStart.
  ///
  /// In en, this message translates to:
  /// **'Week duplicated to start on {date}'**
  String weekDuplicatedToStart(String date);

  /// No description provided for @noItemsThisMeal.
  ///
  /// In en, this message translates to:
  /// **'No items in this meal'**
  String get noItemsThisMeal;

  /// No description provided for @tapAddToLog.
  ///
  /// In en, this message translates to:
  /// **'Tap + Add to quickly log foods.'**
  String get tapAddToLog;

  /// No description provided for @viewDay.
  ///
  /// In en, this message translates to:
  /// **'View day'**
  String get viewDay;

  /// No description provided for @onlyNew.
  ///
  /// In en, this message translates to:
  /// **'Only new'**
  String get onlyNew;

  /// No description provided for @dayCsvDownloaded.
  ///
  /// In en, this message translates to:
  /// **'Day CSV downloaded'**
  String get dayCsvDownloaded;

  /// No description provided for @dayCsvCopied.
  ///
  /// In en, this message translates to:
  /// **'Day CSV copied'**
  String get dayCsvCopied;

  /// No description provided for @dayTemplateSaved.
  ///
  /// In en, this message translates to:
  /// **'Day template saved'**
  String get dayTemplateSaved;

  /// No description provided for @noDayTemplatesSaved.
  ///
  /// In en, this message translates to:
  /// **'No day templates saved'**
  String get noDayTemplatesSaved;

  /// No description provided for @templateName.
  ///
  /// In en, this message translates to:
  /// **'Template name'**
  String get templateName;

  /// No description provided for @weekTemplateSaved.
  ///
  /// In en, this message translates to:
  /// **'Week template saved'**
  String get weekTemplateSaved;

  /// No description provided for @noWeekTemplatesSaved.
  ///
  /// In en, this message translates to:
  /// **'No week templates saved'**
  String get noWeekTemplatesSaved;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @carbAbbrPlus.
  ///
  /// In en, this message translates to:
  /// **'Carb+'**
  String get carbAbbrPlus;

  /// No description provided for @proteinAbbrPlus.
  ///
  /// In en, this message translates to:
  /// **'Prot+'**
  String get proteinAbbrPlus;

  /// No description provided for @fatAbbrPlus.
  ///
  /// In en, this message translates to:
  /// **'Fat+'**
  String get fatAbbrPlus;

  /// No description provided for @activitiesTitle.
  ///
  /// In en, this message translates to:
  /// **'Activities'**
  String get activitiesTitle;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @noActivitiesToday.
  ///
  /// In en, this message translates to:
  /// **'No activities logged today'**
  String get noActivitiesToday;

  /// No description provided for @addExercise.
  ///
  /// In en, this message translates to:
  /// **'Add exercise'**
  String get addExercise;

  /// No description provided for @areYouSureStopFasting.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to stop your current fast? Your progress will be saved.'**
  String get areYouSureStopFasting;

  /// No description provided for @stopFasting.
  ///
  /// In en, this message translates to:
  /// **'Stop Fasting'**
  String get stopFasting;

  /// No description provided for @startFasting.
  ///
  /// In en, this message translates to:
  /// **'Start Fasting'**
  String get startFasting;

  /// No description provided for @openFilters.
  ///
  /// In en, this message translates to:
  /// **'Open filters'**
  String get openFilters;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @addToDiary.
  ///
  /// In en, this message translates to:
  /// **'Add to diary'**
  String get addToDiary;

  /// No description provided for @prepMode.
  ///
  /// In en, this message translates to:
  /// **'Preparation'**
  String get prepMode;

  /// No description provided for @prepDetailsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Preparation details are not available in this mock version.'**
  String get prepDetailsUnavailable;

  /// No description provided for @proRecipe.
  ///
  /// In en, this message translates to:
  /// **'PRO Recipe'**
  String get proRecipe;

  /// No description provided for @tapToUnlock.
  ///
  /// In en, this message translates to:
  /// **'Tap to unlock'**
  String get tapToUnlock;

  /// No description provided for @proOnly.
  ///
  /// In en, this message translates to:
  /// **'PRO Only'**
  String get proOnly;

  /// No description provided for @qaAddMeal.
  ///
  /// In en, this message translates to:
  /// **'Add\nMeal'**
  String get qaAddMeal;

  /// No description provided for @qaLogWater.
  ///
  /// In en, this message translates to:
  /// **'Log\nWater'**
  String get qaLogWater;

  /// No description provided for @qaExercise.
  ///
  /// In en, this message translates to:
  /// **'Exercise'**
  String get qaExercise;

  /// No description provided for @qaProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get qaProgress;

  /// No description provided for @qaRecipes.
  ///
  /// In en, this message translates to:
  /// **'Recipes'**
  String get qaRecipes;

  /// No description provided for @qaSetupGoals.
  ///
  /// In en, this message translates to:
  /// **'Setup\nGoals'**
  String get qaSetupGoals;

  /// No description provided for @featureInDevelopment.
  ///
  /// In en, this message translates to:
  /// **'Feature in development'**
  String get featureInDevelopment;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterEmail;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterPassword;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get emailInvalid;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMinLength;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot my password?'**
  String get forgotPassword;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @newUser.
  ///
  /// In en, this message translates to:
  /// **'New user? '**
  String get newUser;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get register;

  /// No description provided for @registerScreenInDevelopment.
  ///
  /// In en, this message translates to:
  /// **'Registration screen in development'**
  String get registerScreenInDevelopment;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @import.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get import;

  /// No description provided for @myProgress.
  ///
  /// In en, this message translates to:
  /// **'My progress'**
  String get myProgress;

  /// No description provided for @myGoals.
  ///
  /// In en, this message translates to:
  /// **'My goals'**
  String get myGoals;

  /// No description provided for @diet.
  ///
  /// In en, this message translates to:
  /// **'Diet'**
  String get diet;

  /// No description provided for @standard.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get standard;

  /// No description provided for @weightGoal.
  ///
  /// In en, this message translates to:
  /// **'Weight goal'**
  String get weightGoal;

  /// No description provided for @lose.
  ///
  /// In en, this message translates to:
  /// **'Lose'**
  String get lose;

  /// No description provided for @maintain.
  ///
  /// In en, this message translates to:
  /// **'Maintain'**
  String get maintain;

  /// No description provided for @gain.
  ///
  /// In en, this message translates to:
  /// **'Gain'**
  String get gain;

  /// No description provided for @initialWeight.
  ///
  /// In en, this message translates to:
  /// **'Initial weight (kg)'**
  String get initialWeight;

  /// No description provided for @targetWeight.
  ///
  /// In en, this message translates to:
  /// **'Target weight (kg)'**
  String get targetWeight;

  /// No description provided for @editGoals.
  ///
  /// In en, this message translates to:
  /// **'Edit goals'**
  String get editGoals;

  /// No description provided for @goalsUpdated.
  ///
  /// In en, this message translates to:
  /// **'Goals updated'**
  String get goalsUpdated;

  /// No description provided for @carbs.
  ///
  /// In en, this message translates to:
  /// **'Carbohydrates'**
  String get carbs;

  /// No description provided for @proteins.
  ///
  /// In en, this message translates to:
  /// **'Proteins'**
  String get proteins;

  /// No description provided for @fats.
  ///
  /// In en, this message translates to:
  /// **'Fats'**
  String get fats;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @validCaloriesRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter valid calories (> 0)'**
  String get validCaloriesRequired;

  /// No description provided for @validMacrosRequired.
  ///
  /// In en, this message translates to:
  /// **'Macros must be numbers ≥ 0)'**
  String get validMacrosRequired;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @height.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get height;

  /// No description provided for @bodyFat.
  ///
  /// In en, this message translates to:
  /// **'Body fat'**
  String get bodyFat;

  /// No description provided for @bodyMetrics.
  ///
  /// In en, this message translates to:
  /// **'Body Metrics'**
  String get bodyMetrics;

  /// No description provided for @proPlanPersonalized.
  ///
  /// In en, this message translates to:
  /// **'Personalized plans'**
  String get proPlanPersonalized;

  /// No description provided for @proPlanPersonalizedDesc.
  ///
  /// In en, this message translates to:
  /// **'Meal plans and fasting cycles adjusted to your goals.'**
  String get proPlanPersonalizedDesc;

  /// No description provided for @proSmartScanner.
  ///
  /// In en, this message translates to:
  /// **'Smart scanner'**
  String get proSmartScanner;

  /// No description provided for @proSmartScannerDesc.
  ///
  /// In en, this message translates to:
  /// **'Barcode + OCR to log meals in seconds.'**
  String get proSmartScannerDesc;

  /// No description provided for @proAdvancedInsights.
  ///
  /// In en, this message translates to:
  /// **'Advanced insights'**
  String get proAdvancedInsights;

  /// No description provided for @proAdvancedInsightsDesc.
  ///
  /// In en, this message translates to:
  /// **'Predictive reports and automatic goal adjustments.'**
  String get proAdvancedInsightsDesc;

  /// No description provided for @proExclusiveRecipes.
  ///
  /// In en, this message translates to:
  /// **'Exclusive recipes'**
  String get proExclusiveRecipes;

  /// No description provided for @proExclusiveRecipesDesc.
  ///
  /// In en, this message translates to:
  /// **'PRO collection with calculated macros and advanced filters.'**
  String get proExclusiveRecipesDesc;

  /// No description provided for @cancelAnytime.
  ///
  /// In en, this message translates to:
  /// **'Cancel anytime'**
  String get cancelAnytime;

  /// No description provided for @dayGuarantee.
  ///
  /// In en, this message translates to:
  /// **'7-day guarantee'**
  String get dayGuarantee;

  /// No description provided for @averageRating.
  ///
  /// In en, this message translates to:
  /// **'Average rating 4.8/5'**
  String get averageRating;

  /// No description provided for @noPlansAvailable.
  ///
  /// In en, this message translates to:
  /// **'No plans available at the moment.\nTry again later.'**
  String get noPlansAvailable;

  /// No description provided for @errorLoadingPlans.
  ///
  /// In en, this message translates to:
  /// **'Error loading plans.\nCheck your connection.'**
  String get errorLoadingPlans;

  /// No description provided for @proActivated.
  ///
  /// In en, this message translates to:
  /// **'PRO subscription activated successfully!'**
  String get proActivated;

  /// No description provided for @cancelPro.
  ///
  /// In en, this message translates to:
  /// **'Cancel PRO'**
  String get cancelPro;

  /// No description provided for @keepPro.
  ///
  /// In en, this message translates to:
  /// **'Keep PRO'**
  String get keepPro;

  /// No description provided for @cancelProTestMode.
  ///
  /// In en, this message translates to:
  /// **'Cancel PRO (test environment)'**
  String get cancelProTestMode;

  /// No description provided for @freePlanReactivated.
  ///
  /// In en, this message translates to:
  /// **'Free plan reactivated'**
  String get freePlanReactivated;

  /// No description provided for @exploreProBenefits.
  ///
  /// In en, this message translates to:
  /// **'Explore PRO benefits'**
  String get exploreProBenefits;

  /// No description provided for @restorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore Purchases'**
  String get restorePurchases;

  /// No description provided for @reduceAnimations.
  ///
  /// In en, this message translates to:
  /// **'Reduce animations'**
  String get reduceAnimations;

  /// No description provided for @reduceAnimationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Avoids confetti/exaggerated transitions'**
  String get reduceAnimationsDesc;

  /// No description provided for @animationsReduced.
  ///
  /// In en, this message translates to:
  /// **'Animations reduced'**
  String get animationsReduced;

  /// No description provided for @animationsNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal animations'**
  String get animationsNormal;

  /// No description provided for @celebrateAchievements.
  ///
  /// In en, this message translates to:
  /// **'Celebrate achievements'**
  String get celebrateAchievements;

  /// No description provided for @celebrateAchievementsDesc.
  ///
  /// In en, this message translates to:
  /// **'Shows confetti when unlocking badges'**
  String get celebrateAchievementsDesc;

  /// No description provided for @celebrationsDisabled.
  ///
  /// In en, this message translates to:
  /// **'Celebrations disabled'**
  String get celebrationsDisabled;

  /// No description provided for @celebrationsEnabled.
  ///
  /// In en, this message translates to:
  /// **'Celebrations enabled'**
  String get celebrationsEnabled;

  /// No description provided for @showNextMilestone.
  ///
  /// In en, this message translates to:
  /// **'Show \'Next milestone\' in chips'**
  String get showNextMilestone;

  /// No description provided for @showNextMilestoneDesc.
  ///
  /// In en, this message translates to:
  /// **'Shows \'• next: Nd\' in streak chips'**
  String get showNextMilestoneDesc;

  /// No description provided for @useLottieInCelebrations.
  ///
  /// In en, this message translates to:
  /// **'Use Lottie in celebrations'**
  String get useLottieInCelebrations;

  /// No description provided for @searchAndFoods.
  ///
  /// In en, this message translates to:
  /// **'Search and foods'**
  String get searchAndFoods;

  /// No description provided for @interpretQuantitiesNLQ.
  ///
  /// In en, this message translates to:
  /// **'Interpret quantities in text (NLQ)'**
  String get interpretQuantitiesNLQ;

  /// No description provided for @collapse.
  ///
  /// In en, this message translates to:
  /// **'Collapse'**
  String get collapse;

  /// No description provided for @expand.
  ///
  /// In en, this message translates to:
  /// **'Expand'**
  String get expand;

  /// No description provided for @breakfast.
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get breakfast;

  /// No description provided for @lunch.
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get lunch;

  /// No description provided for @dinner.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get dinner;

  /// No description provided for @snacks.
  ///
  /// In en, this message translates to:
  /// **'Snacks'**
  String get snacks;

  /// No description provided for @exportJSON.
  ///
  /// In en, this message translates to:
  /// **'Export JSON'**
  String get exportJSON;

  /// No description provided for @importJSON.
  ///
  /// In en, this message translates to:
  /// **'Import JSON'**
  String get importJSON;

  /// No description provided for @clearTemplates.
  ///
  /// In en, this message translates to:
  /// **'Clear templates'**
  String get clearTemplates;

  /// No description provided for @clearFoods.
  ///
  /// In en, this message translates to:
  /// **'Clear foods'**
  String get clearFoods;

  /// No description provided for @setGoals.
  ///
  /// In en, this message translates to:
  /// **'Set goals'**
  String get setGoals;

  /// No description provided for @knowProNutriTracker.
  ///
  /// In en, this message translates to:
  /// **'Know NutriTracker PRO'**
  String get knowProNutriTracker;

  /// No description provided for @friends.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get friends;

  /// No description provided for @analysis.
  ///
  /// In en, this message translates to:
  /// **'ANALYSIS'**
  String get analysis;

  /// No description provided for @registerWeight.
  ///
  /// In en, this message translates to:
  /// **'REGISTER WEIGHT'**
  String get registerWeight;

  /// No description provided for @defineGoal.
  ///
  /// In en, this message translates to:
  /// **'DEFINE GOAL'**
  String get defineGoal;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'EDIT'**
  String get edit;

  /// No description provided for @dietType.
  ///
  /// In en, this message translates to:
  /// **'Diet: {type}'**
  String dietType(String type);

  /// No description provided for @goalObjective.
  ///
  /// In en, this message translates to:
  /// **'Goal: {objective}'**
  String goalObjective(String objective);

  /// No description provided for @unexpectedErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Unexpected error: {error}'**
  String unexpectedErrorMessage(String error);

  /// No description provided for @dataSourceQA.
  ///
  /// In en, this message translates to:
  /// **'Show data source (OFF/FDC/NLQ)'**
  String get dataSourceQA;

  /// No description provided for @qaDebugging.
  ///
  /// In en, this message translates to:
  /// **'QA / Debugging'**
  String get qaDebugging;

  /// No description provided for @achievementsStreaksCleared.
  ///
  /// In en, this message translates to:
  /// **'Achievements and streaks cleared'**
  String get achievementsStreaksCleared;

  /// No description provided for @clearAchievementsStreaks.
  ///
  /// In en, this message translates to:
  /// **'Clear achievements/streaks'**
  String get clearAchievementsStreaks;

  /// No description provided for @testBadgeGranted.
  ///
  /// In en, this message translates to:
  /// **'Test badge granted'**
  String get testBadgeGranted;

  /// No description provided for @grantTestBadge.
  ///
  /// In en, this message translates to:
  /// **'Grant test badge'**
  String get grantTestBadge;

  /// No description provided for @recalculateStreaks60.
  ///
  /// In en, this message translates to:
  /// **'Recalculate streaks (60 days)'**
  String get recalculateStreaks60;

  /// No description provided for @recalculatePerfectWeek.
  ///
  /// In en, this message translates to:
  /// **'Recalculate perfect week'**
  String get recalculatePerfectWeek;

  /// No description provided for @testCelebration.
  ///
  /// In en, this message translates to:
  /// **'Test celebration'**
  String get testCelebration;

  /// No description provided for @preferenceSaved.
  ///
  /// In en, this message translates to:
  /// **'Preference saved'**
  String get preferenceSaved;

  /// No description provided for @aiCacheNormalization.
  ///
  /// In en, this message translates to:
  /// **'AI Cache (food normalization)'**
  String get aiCacheNormalization;

  /// No description provided for @chipsUpdated.
  ///
  /// In en, this message translates to:
  /// **'Chips updated'**
  String get chipsUpdated;

  /// No description provided for @aiCacheCleared.
  ///
  /// In en, this message translates to:
  /// **'AI cache cleared'**
  String get aiCacheCleared;

  /// No description provided for @aiCacheCopied.
  ///
  /// In en, this message translates to:
  /// **'AI cache copied'**
  String get aiCacheCopied;

  /// No description provided for @aiCacheImported.
  ///
  /// In en, this message translates to:
  /// **'AI cache imported'**
  String get aiCacheImported;

  /// No description provided for @invalidJSON.
  ///
  /// In en, this message translates to:
  /// **'Invalid JSON: {error}'**
  String invalidJSON(String error);

  /// No description provided for @mealGoalsSaved.
  ///
  /// In en, this message translates to:
  /// **'Meal goals saved!'**
  String get mealGoalsSaved;

  /// No description provided for @dataSource.
  ///
  /// In en, this message translates to:
  /// **'Show data source (OFF/FDC/NLQ)'**
  String get dataSource;

  /// No description provided for @me.
  ///
  /// In en, this message translates to:
  /// **'ME'**
  String get me;

  /// No description provided for @freePlan.
  ///
  /// In en, this message translates to:
  /// **'Free Plan'**
  String get freePlan;

  /// No description provided for @proSubscription.
  ///
  /// In en, this message translates to:
  /// **'PRO Subscription'**
  String get proSubscription;

  /// No description provided for @dailyGoals.
  ///
  /// In en, this message translates to:
  /// **'Daily Goals'**
  String get dailyGoals;

  /// No description provided for @logoutAccount.
  ///
  /// In en, this message translates to:
  /// **'Log out of account?'**
  String get logoutAccount;

  /// No description provided for @logoutConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'You will need to log in again. To confirm, type: LOGOUT'**
  String get logoutConfirmMessage;

  /// No description provided for @intelligentReports.
  ///
  /// In en, this message translates to:
  /// **'Intelligent reports'**
  String get intelligentReports;

  /// No description provided for @guidedPlans.
  ///
  /// In en, this message translates to:
  /// **'Guided plans'**
  String get guidedPlans;

  /// No description provided for @barcodeScanner.
  ///
  /// In en, this message translates to:
  /// **'Barcode scanner'**
  String get barcodeScanner;

  /// No description provided for @nutriTrackerPro.
  ///
  /// In en, this message translates to:
  /// **'NutriTracker PRO'**
  String get nutriTrackerPro;

  /// No description provided for @proDescription.
  ///
  /// In en, this message translates to:
  /// **'Customize meals, receive smart alerts and access the complete library of exclusive recipes.'**
  String get proDescription;

  /// No description provided for @meetNutriTrackerPro.
  ///
  /// In en, this message translates to:
  /// **'Meet NutriTracker PRO'**
  String get meetNutriTrackerPro;

  /// No description provided for @plansStartingAt.
  ///
  /// In en, this message translates to:
  /// **'Plans starting at \$14.99/month · Cancel anytime'**
  String get plansStartingAt;

  /// No description provided for @youArePro.
  ///
  /// In en, this message translates to:
  /// **'You are PRO!'**
  String get youArePro;

  /// No description provided for @proEnjoyMessage.
  ///
  /// In en, this message translates to:
  /// **'Enjoy all advanced features of NutriTracker. New recipes and plans arrive every week.'**
  String get proEnjoyMessage;

  /// No description provided for @advancedInsights.
  ///
  /// In en, this message translates to:
  /// **'Advanced insights'**
  String get advancedInsights;

  /// No description provided for @dynamicPlans.
  ///
  /// In en, this message translates to:
  /// **'Dynamic plans'**
  String get dynamicPlans;

  /// No description provided for @proRecipes.
  ///
  /// In en, this message translates to:
  /// **'PRO Recipes'**
  String get proRecipes;

  /// No description provided for @proSubscriptionActivated.
  ///
  /// In en, this message translates to:
  /// **'PRO subscription activated successfully!'**
  String get proSubscriptionActivated;

  /// No description provided for @unexpectedError.
  ///
  /// In en, this message translates to:
  /// **'Unexpected error: {error}'**
  String unexpectedError(String error);

  /// No description provided for @terminatePro.
  ///
  /// In en, this message translates to:
  /// **'Terminate PRO'**
  String get terminatePro;

  /// No description provided for @terminateProConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This action is only available for testing. Confirm cancellation of PRO subscription?'**
  String get terminateProConfirmMessage;

  /// No description provided for @connectWithFriends.
  ///
  /// In en, this message translates to:
  /// **'Connect with friends to compare progress. Coming soon.'**
  String get connectWithFriends;

  /// No description provided for @goalReached.
  ///
  /// In en, this message translates to:
  /// **'Goal reached!'**
  String get goalReached;

  /// No description provided for @noVariationYet.
  ///
  /// In en, this message translates to:
  /// **'No variation yet'**
  String get noVariationYet;

  /// No description provided for @youGainedWeight.
  ///
  /// In en, this message translates to:
  /// **'You gained {weight} kg'**
  String youGainedWeight(String weight);

  /// No description provided for @youLostWeight.
  ///
  /// In en, this message translates to:
  /// **'You lost {weight} kg'**
  String youLostWeight(String weight);

  /// No description provided for @defineWeightGoalMessage.
  ///
  /// In en, this message translates to:
  /// **'Define your weight goal to track the bar'**
  String get defineWeightGoalMessage;

  /// No description provided for @weightGoalKg.
  ///
  /// In en, this message translates to:
  /// **'Weight goal (kg)'**
  String get weightGoalKg;

  /// No description provided for @startingWeightKg.
  ///
  /// In en, this message translates to:
  /// **'Starting weight (kg)'**
  String get startingWeightKg;

  /// No description provided for @weightObjective.
  ///
  /// In en, this message translates to:
  /// **'Weight objective'**
  String get weightObjective;

  /// No description provided for @goalsUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Goals updated'**
  String get goalsUpdatedSuccess;

  /// No description provided for @reducedAnimations.
  ///
  /// In en, this message translates to:
  /// **'Reduced animations'**
  String get reducedAnimations;

  /// No description provided for @normalAnimations.
  ///
  /// In en, this message translates to:
  /// **'Normal animations'**
  String get normalAnimations;

  /// No description provided for @showConfettiOnBadges.
  ///
  /// In en, this message translates to:
  /// **'Show confetti when unlocking badges'**
  String get showConfettiOnBadges;

  /// No description provided for @showNextMilestoneDescription.
  ///
  /// In en, this message translates to:
  /// **'Shows \'• next: Nd\' in streak chips'**
  String get showNextMilestoneDescription;

  /// No description provided for @interpretQuantitiesInText.
  ///
  /// In en, this message translates to:
  /// **'Interpret quantities in text (NLQ)'**
  String get interpretQuantitiesInText;

  /// No description provided for @quantitiesExample.
  ///
  /// In en, this message translates to:
  /// **'Ex.: \'150g chicken\', \'2 eggs and 1 banana\''**
  String get quantitiesExample;

  /// No description provided for @mealGoalsPerMeal.
  ///
  /// In en, this message translates to:
  /// **'Goals per meal'**
  String get mealGoalsPerMeal;

  /// No description provided for @kcal.
  ///
  /// In en, this message translates to:
  /// **'kcal'**
  String get kcal;

  /// No description provided for @carbGrams.
  ///
  /// In en, this message translates to:
  /// **'Carb. (g)'**
  String get carbGrams;

  /// No description provided for @protGrams.
  ///
  /// In en, this message translates to:
  /// **'Prot. (g)'**
  String get protGrams;

  /// No description provided for @fatGrams.
  ///
  /// In en, this message translates to:
  /// **'Fat (g)'**
  String get fatGrams;

  /// No description provided for @saveMealGoals.
  ///
  /// In en, this message translates to:
  /// **'Save goals'**
  String get saveMealGoals;

  /// No description provided for @mealGoalsCleared.
  ///
  /// In en, this message translates to:
  /// **'Meal goals cleared'**
  String get mealGoalsCleared;

  /// No description provided for @clearMealGoalsConfirm.
  ///
  /// In en, this message translates to:
  /// **'Clear meal goals?'**
  String get clearMealGoalsConfirm;

  /// No description provided for @clearMealGoalsMessage.
  ///
  /// In en, this message translates to:
  /// **'This action resets the goals for Breakfast, Lunch, Dinner and Snacks.\nTo confirm, type: CONFIRM'**
  String get clearMealGoalsMessage;

  /// No description provided for @diaryExported.
  ///
  /// In en, this message translates to:
  /// **'Diary exported to clipboard'**
  String get diaryExported;

  /// No description provided for @exportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed: {error}'**
  String exportFailed(String error);

  /// No description provided for @importDiary.
  ///
  /// In en, this message translates to:
  /// **'Import Diary (JSON)'**
  String get importDiary;

  /// No description provided for @diaryImported.
  ///
  /// In en, this message translates to:
  /// **'Diary imported successfully'**
  String get diaryImported;

  /// No description provided for @templatesExported.
  ///
  /// In en, this message translates to:
  /// **'Templates copied to clipboard'**
  String get templatesExported;

  /// No description provided for @exportTemplatesFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to export templates: {error}'**
  String exportTemplatesFailed(String error);

  /// No description provided for @importTemplates.
  ///
  /// In en, this message translates to:
  /// **'Import Templates (JSON)'**
  String get importTemplates;

  /// No description provided for @templatesImported.
  ///
  /// In en, this message translates to:
  /// **'Templates imported successfully'**
  String get templatesImported;

  /// No description provided for @foodsExported.
  ///
  /// In en, this message translates to:
  /// **'Foods copied to clipboard'**
  String get foodsExported;

  /// No description provided for @exportFoodsFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to export foods: {error}'**
  String exportFoodsFailed(String error);

  /// No description provided for @importFoods.
  ///
  /// In en, this message translates to:
  /// **'Import Foods (JSON)'**
  String get importFoods;

  /// No description provided for @foodsImported.
  ///
  /// In en, this message translates to:
  /// **'Foods imported successfully'**
  String get foodsImported;

  /// No description provided for @foodsCleared.
  ///
  /// In en, this message translates to:
  /// **'Foods cleared'**
  String get foodsCleared;

  /// No description provided for @clearAllFoodsConfirm.
  ///
  /// In en, this message translates to:
  /// **'Clear all foods?'**
  String get clearAllFoodsConfirm;

  /// No description provided for @clearAllFoodsMessage.
  ///
  /// In en, this message translates to:
  /// **'This action removes Favorites and My Foods. Cannot be undone.\nTo confirm, type: CLEAR'**
  String get clearAllFoodsMessage;

  /// No description provided for @templatesCleared.
  ///
  /// In en, this message translates to:
  /// **'Templates cleared'**
  String get templatesCleared;

  /// No description provided for @clearAllTemplatesConfirm.
  ///
  /// In en, this message translates to:
  /// **'Clear all templates?'**
  String get clearAllTemplatesConfirm;

  /// No description provided for @clearAllTemplatesMessage.
  ///
  /// In en, this message translates to:
  /// **'This action removes all day and week templates. Cannot be undone.\nTo confirm, type: CLEAR'**
  String get clearAllTemplatesMessage;

  /// No description provided for @importAICacheJSON.
  ///
  /// In en, this message translates to:
  /// **'Import AI Cache (JSON)'**
  String get importAICacheJSON;

  /// No description provided for @water.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get water;

  /// No description provided for @activities.
  ///
  /// In en, this message translates to:
  /// **'Activities'**
  String get activities;

  /// No description provided for @walking.
  ///
  /// In en, this message translates to:
  /// **'Walking'**
  String get walking;

  /// No description provided for @running.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get running;

  /// No description provided for @cycling.
  ///
  /// In en, this message translates to:
  /// **'Cycling'**
  String get cycling;

  /// No description provided for @addMeal.
  ///
  /// In en, this message translates to:
  /// **'Add Meal'**
  String get addMeal;

  /// No description provided for @navFasting.
  ///
  /// In en, this message translates to:
  /// **'Fasting'**
  String get navFasting;

  /// No description provided for @navRecipes.
  ///
  /// In en, this message translates to:
  /// **'Recipes'**
  String get navRecipes;

  /// No description provided for @navCoach.
  ///
  /// In en, this message translates to:
  /// **'Coach'**
  String get navCoach;

  /// No description provided for @eaten.
  ///
  /// In en, this message translates to:
  /// **'Eaten'**
  String get eaten;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get remaining;

  /// No description provided for @burned.
  ///
  /// In en, this message translates to:
  /// **'Burned'**
  String get burned;

  /// No description provided for @nutrition.
  ///
  /// In en, this message translates to:
  /// **'Nutrition'**
  String get nutrition;

  /// No description provided for @dayActions.
  ///
  /// In en, this message translates to:
  /// **'Day actions'**
  String get dayActions;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @moreActions.
  ///
  /// In en, this message translates to:
  /// **'More actions'**
  String get moreActions;

  /// No description provided for @walkingMinutes.
  ///
  /// In en, this message translates to:
  /// **'Walking {minutes}m'**
  String walkingMinutes(int minutes);

  /// No description provided for @runningMinutes.
  ///
  /// In en, this message translates to:
  /// **'Running {minutes}m'**
  String runningMinutes(int minutes);

  /// No description provided for @cyclingMinutes.
  ///
  /// In en, this message translates to:
  /// **'Cycling {minutes}m'**
  String cyclingMinutes(int minutes);

  /// No description provided for @macronutrients.
  ///
  /// In en, this message translates to:
  /// **'Macronutrients'**
  String get macronutrients;

  /// No description provided for @goals.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get goals;

  /// No description provided for @adjustMacroGoals.
  ///
  /// In en, this message translates to:
  /// **'Adjust macro goals'**
  String get adjustMacroGoals;

  /// No description provided for @macroGoalsUpdated.
  ///
  /// In en, this message translates to:
  /// **'Macro goals updated'**
  String get macroGoalsUpdated;

  /// No description provided for @intermittentFasting.
  ///
  /// In en, this message translates to:
  /// **'Intermittent Fasting'**
  String get intermittentFasting;

  /// No description provided for @fastingSchedules.
  ///
  /// In en, this message translates to:
  /// **'Fasting schedules'**
  String get fastingSchedules;

  /// No description provided for @eatingWindow.
  ///
  /// In en, this message translates to:
  /// **'Eating window: {stop} - {start}'**
  String eatingWindow(String stop, String start);

  /// No description provided for @fastingMethod168.
  ///
  /// In en, this message translates to:
  /// **'16:8 Method'**
  String get fastingMethod168;

  /// No description provided for @fastingMethod186.
  ///
  /// In en, this message translates to:
  /// **'18:6 Method'**
  String get fastingMethod186;

  /// No description provided for @fastingMethod204.
  ///
  /// In en, this message translates to:
  /// **'20:4 Method'**
  String get fastingMethod204;

  /// No description provided for @fastingMethodCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom • {hours}h'**
  String fastingMethodCustom(int hours);

  /// No description provided for @fastingMethodLabel.
  ///
  /// In en, this message translates to:
  /// **'Method {method}'**
  String fastingMethodLabel(String method);

  /// No description provided for @timezone.
  ///
  /// In en, this message translates to:
  /// **'Timezone: {timezone}'**
  String timezone(String timezone);

  /// No description provided for @endsAt.
  ///
  /// In en, this message translates to:
  /// **'Ends at {time}'**
  String endsAt(String time);

  /// No description provided for @fastingDays.
  ///
  /// In en, this message translates to:
  /// **'{days}d fasting'**
  String fastingDays(int days);

  /// No description provided for @noFastingStreak.
  ///
  /// In en, this message translates to:
  /// **'No fasting streak'**
  String get noFastingStreak;

  /// No description provided for @defineCustomMethod.
  ///
  /// In en, this message translates to:
  /// **'Define custom method'**
  String get defineCustomMethod;

  /// No description provided for @fastingDuration.
  ///
  /// In en, this message translates to:
  /// **'Fasting duration'**
  String get fastingDuration;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'Minutes'**
  String get minutes;

  /// No description provided for @fastStarted.
  ///
  /// In en, this message translates to:
  /// **'Fast started! Method {method}'**
  String fastStarted(String method);

  /// No description provided for @fastCompleted.
  ///
  /// In en, this message translates to:
  /// **'Fast completed! Duration: {hours}h {minutes}min'**
  String fastCompleted(int hours, int minutes);

  /// No description provided for @congratulations.
  ///
  /// In en, this message translates to:
  /// **'Congratulations!'**
  String get congratulations;

  /// No description provided for @fastCompletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'You completed your {method} fast successfully! 🎉'**
  String fastCompletedSuccess(String method);

  /// No description provided for @notificationsMutedUntil.
  ///
  /// In en, this message translates to:
  /// **'Notifications muted until {time}'**
  String notificationsMutedUntil(String time);

  /// No description provided for @reactivate.
  ///
  /// In en, this message translates to:
  /// **'Reactivate'**
  String get reactivate;

  /// No description provided for @stopCurrentFastToChangeMethod.
  ///
  /// In en, this message translates to:
  /// **'Stop current fast to change method'**
  String get stopCurrentFastToChangeMethod;

  /// No description provided for @fastingOfDay.
  ///
  /// In en, this message translates to:
  /// **'Fast of {date}'**
  String fastingOfDay(String date);

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration: {hours}h'**
  String duration(int hours);

  /// No description provided for @fastCompletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Fast completed successfully'**
  String get fastCompletedSuccessfully;

  /// No description provided for @remindersMuted24h.
  ///
  /// In en, this message translates to:
  /// **'Reminders muted for 24h'**
  String get remindersMuted24h;

  /// No description provided for @remindersReactivated.
  ///
  /// In en, this message translates to:
  /// **'Reminders reactivated'**
  String get remindersReactivated;

  /// No description provided for @remindersMutedTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Reminders muted until tomorrow 08:00'**
  String get remindersMutedTomorrow;

  /// No description provided for @startFastButton.
  ///
  /// In en, this message translates to:
  /// **'Start fasting'**
  String get startFastButton;

  /// No description provided for @endFastButton.
  ///
  /// In en, this message translates to:
  /// **'End fast'**
  String get endFastButton;

  /// No description provided for @onbV3SplashTitle.
  ///
  /// In en, this message translates to:
  /// **'nutriZ'**
  String get onbV3SplashTitle;

  /// No description provided for @onbV3WelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'nutriZ'**
  String get onbV3WelcomeTitle;

  /// No description provided for @onbV3Welcome85Million.
  ///
  /// In en, this message translates to:
  /// **'85 million happy users'**
  String get onbV3Welcome85Million;

  /// No description provided for @onbV3Welcome20Million.
  ///
  /// In en, this message translates to:
  /// **'20 million foods for calorie tracking'**
  String get onbV3Welcome20Million;

  /// No description provided for @onbV3WelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Let\'s make every day count!'**
  String get onbV3WelcomeSubtitle;

  /// No description provided for @onbV3WelcomeGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onbV3WelcomeGetStarted;

  /// No description provided for @onbV3WelcomeAlreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'I Already Have an Account'**
  String get onbV3WelcomeAlreadyHaveAccount;

  /// No description provided for @onbV3GoalTitle.
  ///
  /// In en, this message translates to:
  /// **'What\'s your main goal?'**
  String get onbV3GoalTitle;

  /// No description provided for @onbV3GoalLoseWeight.
  ///
  /// In en, this message translates to:
  /// **'Lose weight'**
  String get onbV3GoalLoseWeight;

  /// No description provided for @onbV3GoalGainWeight.
  ///
  /// In en, this message translates to:
  /// **'Gain weight'**
  String get onbV3GoalGainWeight;

  /// No description provided for @onbV3GoalMaintain.
  ///
  /// In en, this message translates to:
  /// **'Maintain weight'**
  String get onbV3GoalMaintain;

  /// No description provided for @onbV3GoalContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get onbV3GoalContinue;

  /// No description provided for @onbV3AppBarSetup.
  ///
  /// In en, this message translates to:
  /// **'Setup'**
  String get onbV3AppBarSetup;

  /// No description provided for @onbV3ProgressStep.
  ///
  /// In en, this message translates to:
  /// **'{current}/{total}'**
  String onbV3ProgressStep(Object current, Object total);

  /// No description provided for @notifFastingOpenTitle.
  ///
  /// In en, this message translates to:
  /// **'Eating Window Open'**
  String get notifFastingOpenTitle;

  /// No description provided for @notifFastingOpenBody.
  ///
  /// In en, this message translates to:
  /// **'You can start eating now.'**
  String get notifFastingOpenBody;

  /// No description provided for @notifFastingStartTitle.
  ///
  /// In en, this message translates to:
  /// **'Fasting Window Started'**
  String get notifFastingStartTitle;

  /// No description provided for @notifFastingStartBody.
  ///
  /// In en, this message translates to:
  /// **'Stop eating to begin your fast.'**
  String get notifFastingStartBody;

  /// No description provided for @notifFastingEndTitle.
  ///
  /// In en, this message translates to:
  /// **'Fasting Complete'**
  String get notifFastingEndTitle;

  /// No description provided for @notifFastingEndBody.
  ///
  /// In en, this message translates to:
  /// **'Your {method} fast is complete.'**
  String notifFastingEndBody(String method);

  /// No description provided for @channelFastingName.
  ///
  /// In en, this message translates to:
  /// **'Fasting'**
  String get channelFastingName;

  /// No description provided for @channelFastingDescription.
  ///
  /// In en, this message translates to:
  /// **'Intermittent fasting notifications'**
  String get channelFastingDescription;

  /// No description provided for @notifHydrationTitle.
  ///
  /// In en, this message translates to:
  /// **'Hydration Reminder'**
  String get notifHydrationTitle;

  /// No description provided for @notifHydrationBody.
  ///
  /// In en, this message translates to:
  /// **'Time to drink some water.'**
  String get notifHydrationBody;

  /// No description provided for @channelHydrationName.
  ///
  /// In en, this message translates to:
  /// **'Hydration'**
  String get channelHydrationName;

  /// No description provided for @channelHydrationDescription.
  ///
  /// In en, this message translates to:
  /// **'Hydration reminders'**
  String get channelHydrationDescription;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
