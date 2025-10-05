// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get streakOverviewTitle => 'Visão geral da sequência';

  @override
  String get streakCurrentLabel => 'Sequência atual';

  @override
  String streakDays(int count) {
    return '$count dias';
  }

  @override
  String get streakNoStreak => 'Sem sequência';

  @override
  String get streakLogFood => 'Registrar alimento';

  @override
  String get streakMilestonesTitle => 'Marcos';

  @override
  String streakDayProgress(int current, int next) {
    return 'Dia $current/$next';
  }

  @override
  String get streakGoalCompleted => 'Meta concluída';

  @override
  String get streakWeeklyOverviewTitle => 'Visão semanal';

  @override
  String get streakLongestTitle => 'Maior sequência';

  @override
  String get weekMon => 'Seg';

  @override
  String get weekTue => 'Ter';

  @override
  String get weekWed => 'Qua';

  @override
  String get weekThu => 'Qui';

  @override
  String get weekFri => 'Sex';

  @override
  String get weekSat => 'Sáb';

  @override
  String get weekSun => 'Dom';

  @override
  String get gotIt => 'Entendi';

  @override
  String get streakNuxBody => 'Toque nos pontos para ir a um dia específico.\nSua sequência cresce quando você registra qualquer alimento no dia.';

  @override
  String get achievementsTitle => 'Conquistas';

  @override
  String get achievementsTabAll => 'Todas';

  @override
  String get achievementsTabWater => 'Água';

  @override
  String get achievementsTabFasting => 'Jejum';

  @override
  String get achievementsTabCalories => 'Calorias';

  @override
  String get achievementsTabProtein => 'Proteína';

  @override
  String get achievementsTabFood => 'Alimentos';

  @override
  String get achievementsTabTest => 'Teste';

  @override
  String get achievementsTabFavorites => 'Favoritos';

  @override
  String get achievementsListView => 'Ver em lista';

  @override
  String get achievementsGridView => 'Ver em grade';

  @override
  String get achievementsEmpty => 'Sem conquistas ainda';

  @override
  String get achievementsDefaultTitle => 'Conquista';

  @override
  String get achievementsType => 'Tipo';

  @override
  String get achievementsGoal => 'Meta';

  @override
  String get achievementsNewBadge => 'Novo';

  @override
  String get achievementsFavorite => 'Favoritar';

  @override
  String get achievementsRemoveFavorite => 'Remover dos favoritos';

  @override
  String achievementsTotal(int count) {
    return 'Total: $count';
  }

  @override
  String get filterTypeLabel => 'Tipo';

  @override
  String get filterTypeAll => 'Todos';

  @override
  String get filterTypeSuccess => 'Sucesso';

  @override
  String get filterTypeStreak => 'Streak';

  @override
  String get filterTypePremium => 'Premium';

  @override
  String get filterTypeGeneral => 'Genérico';

  @override
  String get filterGoalLabel => 'Meta';

  @override
  String get filterGoalAll => 'Todas';

  @override
  String get filterGoalWater => 'Água';

  @override
  String get filterGoalFasting => 'Jejum';

  @override
  String get filterGoalCalories => 'Calorias';

  @override
  String get filterGoalProtein => 'Proteína';

  @override
  String get filterGoalFood => 'Alimentos';

  @override
  String get filterGoalTest => 'Teste';

  @override
  String get filterSortLabel => 'Ordenar';

  @override
  String get sortRecent => 'Recentes';

  @override
  String get sortOldest => 'Antigas';

  @override
  String get sortType => 'Tipo';

  @override
  String get navDiary => 'Diário';

  @override
  String get navSearch => 'Buscar';

  @override
  String get navAdd => 'Adicionar';

  @override
  String get navProgress => 'Progresso';

  @override
  String get navProfile => 'Perfil';

  @override
  String get addSheetAddFood => 'Adicionar alimento';

  @override
  String get addSheetAddBreakfast => 'Adicionar ao Café da manhã';

  @override
  String get addSheetAddLunch => 'Adicionar ao Almoço';

  @override
  String get addSheetAddDinner => 'Adicionar ao Jantar';

  @override
  String get addSheetAddSnacks => 'Adicionar aos Lanches';

  @override
  String get addSheetAddWater250 => 'Adicionar água (+250 ml)';

  @override
  String get addSheetAddedWater250 => 'Adicionado 250 ml de água';

  @override
  String get addSheetAddWater500 => 'Adicionar água (+500 ml)';

  @override
  String get addSheetAddedWater500 => 'Adicionado 500 ml de água';

  @override
  String get addSheetFoodScanner => 'Scanner/AI de alimento';

  @override
  String get addSheetExploreRecipes => 'Explorar receitas';

  @override
  String get addSheetIntermittentFasting => 'Jejum intermitente';

  @override
  String get appbarPrevDay => 'Dia anterior';

  @override
  String get appbarToday => 'Hoje';

  @override
  String get appbarToggleDashboardOriginal => 'Dashboard Original';

  @override
  String get appbarToggleDashboardV1 => 'Dashboard v1';

  @override
  String get appbarGamificationTooltip => 'Gamificação';

  @override
  String get appbarGamificationSoon => 'Gamificação em breve';

  @override
  String get appbarStreakTooltip => 'Sequência';

  @override
  String get appbarStreakSoon => 'Sequência/Conquistas em breve';

  @override
  String get appbarStatisticsTooltip => 'Estatísticas';

  @override
  String get appbarSelectDate => 'Selecionar data';

  @override
  String get splashUnexpectedError => 'Erro inesperado durante a inicialização';

  @override
  String get splashForceUpdateTitle => 'Atualização Necessária';

  @override
  String get splashForceUpdateBody => 'Uma nova versão do NutriTracker está disponível. Por favor, atualize o aplicativo para continuar.';

  @override
  String get splashUpdate => 'Atualizar';

  @override
  String get splashUnknownError => 'Erro desconhecido';

  @override
  String get splashRetry => 'Tentar Novamente';

  @override
  String versionLabel(String version) {
    return 'Versão $version';
  }

  @override
  String get dowMon => 'Segunda-feira';

  @override
  String get dowTue => 'Terça-feira';

  @override
  String get dowWed => 'Quarta-feira';

  @override
  String get dowThu => 'Quinta-feira';

  @override
  String get dowFri => 'Sexta-feira';

  @override
  String get dowSat => 'Sábado';

  @override
  String get dowSun => 'Domingo';

  @override
  String get dashboardTitle => 'Painel';

  @override
  String get dashboardQuickActions => 'Ações Rápidas';

  @override
  String get dashboardTodaysMeals => 'Refeições de Hoje';

  @override
  String get dashboardViewAll => 'Ver Todas';

  @override
  String get dashboardAddMeal => 'Adicionar Refeição';

  @override
  String streakNext(int next) {
    return '• próx: ${next}d';
  }

  @override
  String badgeEarnedOn(String date) {
    return 'Obtida em: $date';
  }

  @override
  String get close => 'Fechar';

  @override
  String get weeklyProgressTitle => 'Progresso semanal';

  @override
  String get menu => 'Menu';

  @override
  String get exportCsv => 'Export CSV';

  @override
  String get downloadCsv => 'Download CSV';

  @override
  String get importCsv => 'Import CSV';

  @override
  String get saveWeekAsTemplate => 'Salvar semana como template';

  @override
  String get applyWeekTemplate => 'Aplicar template de semana';

  @override
  String get duplicateWeekNext => 'Duplicar semana → próxima';

  @override
  String get duplicateWeekPickDate => 'Duplicar semana → escolher data';

  @override
  String get installApp => 'Instalar app';

  @override
  String get caloriesPerDay => 'Calorias por dia';

  @override
  String daysWithNew(int count) {
    return '$count dia(s) com itens novos';
  }

  @override
  String get perMealAverages => 'Médias por refeição (kcal/dia)';

  @override
  String get weeklyMacroAverages => 'Médias semanais de macros';

  @override
  String get carbsAvg => 'Carboidratos (média)';

  @override
  String get proteinAvg => 'Proteína (média)';

  @override
  String get fatAvg => 'Gordura (média)';

  @override
  String get waterPerDay => 'Água por dia';

  @override
  String get exercisePerDay => 'Exercício por dia';

  @override
  String get dailySummary => 'Resumo diário';

  @override
  String get mealBreakfast => 'Café';

  @override
  String get mealLunch => 'Almoço';

  @override
  String get mealDinner => 'Jantar';

  @override
  String get mealSnack => 'Lanche';

  @override
  String get weekCsvCopied => 'CSV da semana copiado/compartilhado';

  @override
  String get fileName => 'Nome do arquivo';

  @override
  String get fileHint => 'arquivo.csv';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Salvar';

  @override
  String get templateApplied => 'Template aplicado ao dia';

  @override
  String get duplicateTomorrow => 'Duplicar → amanhã';

  @override
  String get weekActions => 'Ações da semana';

  @override
  String get hdrDate => 'Data';

  @override
  String get hdrWater => 'Água';

  @override
  String get hdrExercise => 'Exerc.';

  @override
  String get hdrCarb => 'Carb';

  @override
  String get hdrProt => 'Prot';

  @override
  String get hdrFat => 'Gord';

  @override
  String get overGoal => 'Excedeu';

  @override
  String get onbWelcome => 'Bem-vindo';

  @override
  String get onbInfoTitle => 'Tudo bem não ser perfeito';

  @override
  String get onbInfoBody => 'Vamos construir hábitos aos poucos. Foque na consistência, não na perfeição.';

  @override
  String get continueLabel => 'Continuar';

  @override
  String get finishLabel => 'Concluir';

  @override
  String get onbCommitToday => 'Compromisso marcado para hoje';

  @override
  String get dayStreak => 'Sequência de dias';

  @override
  String get onbCongratsStreak => 'Parabéns, você começou seu streak. Mantenha o ritmo!';

  @override
  String get onbImCommitted => 'Estou comprometido';

  @override
  String get goalsSet => 'Metas definidas';

  @override
  String get defineGoalsTitle => 'Defina suas metas';

  @override
  String get defineGoalsBody => 'Ajuste calorias e macros para o seu objetivo. Você pode alterar depois.';

  @override
  String get openGoalsWizard => 'Abrir assistente de metas';

  @override
  String get notificationsConfigured => 'Notificações configuradas';

  @override
  String get remindersSaved => 'Lembretes salvos';

  @override
  String get remindersTitle => 'Lembretes e Notificações';

  @override
  String get remindersBody => 'Ative lembretes de hidratação para ajudar na consistência diária. Você pode alterar nas configurações depois.';

  @override
  String get enableHydrationReminders => 'Ativar lembretes de hidratação';

  @override
  String get intervalMinutes => 'Intervalo (min)';

  @override
  String get requesting => 'Solicitando…';

  @override
  String get allowNotifications => 'Permitir notificações';

  @override
  String get recipesTitle => 'Receitas';

  @override
  String get recipesEmptyFiltered => 'Nenhuma receita encontrada';

  @override
  String get recipesLoadingTitle => 'Carregando receitas...';

  @override
  String get recipesEmptySubtitle => 'Tente ajustar seus filtros ou termo de busca';

  @override
  String get recipesLoadingSubtitle => 'Aguarde enquanto carregamos as melhores receitas para você';

  @override
  String get clearFilters => 'Limpar Filtros';

  @override
  String get refresh => 'Atualizar';

  @override
  String get recipeAddedToFavorites => 'Receita adicionada aos favoritos';

  @override
  String get recipeRemovedFromFavorites => 'Receita removida dos favoritos';

  @override
  String openingRecipe(String name) {
    return 'Abrindo receita: $name';
  }

  @override
  String addedToMealPlan(String name) {
    return '$name adicionada ao plano de refeições';
  }

  @override
  String sharingRecipe(String name) {
    return 'Compartilhando receita: $name';
  }

  @override
  String findingSimilar(String name) {
    return 'Buscando receitas similares a: $name';
  }

  @override
  String get qaAddToMealPlan => 'Adicionar ao Plano de Refeições';

  @override
  String get qaScheduleThisRecipe => 'Agendar esta receita para uma refeição';

  @override
  String get qaShareRecipe => 'Compartilhar Receita';

  @override
  String get qaShareWithFriends => 'Enviar para amigos e família';

  @override
  String get qaSimilarRecipes => 'Receitas Similares';

  @override
  String get qaFindSimilar => 'Encontrar receitas parecidas';

  @override
  String get filtersTitle => 'Filtros';

  @override
  String get clearAll => 'Limpar Tudo';

  @override
  String get apply => 'Aplicar';

  @override
  String get mealType => 'Tipo de Refeição';

  @override
  String get dietaryRestrictions => 'Restrições Alimentares';

  @override
  String get prepTime => 'Tempo de Preparo';

  @override
  String get calories => 'Calorias';

  @override
  String get dietVegetarian => 'Vegetariano';

  @override
  String get dietVegan => 'Vegano';

  @override
  String get dietGlutenFree => 'Sem Glúten';

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
  String get searchRecipesHint => 'Buscar receitas...';
}
