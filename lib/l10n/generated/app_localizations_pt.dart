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
  String get streakNuxBody =>
      'Toque nos pontos para ir a um dia específico.\nSua sequência cresce quando você registra qualquer alimento no dia.';

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
  String get addSheetAddWater250 => 'Adicionar Água (+250 ml)';

  @override
  String get addSheetAddedWater250 => 'Adicionado 250 ml de Água';

  @override
  String get addSheetAddWater500 => 'Adicionar Água (+500 ml)';

  @override
  String get addSheetAddedWater500 => 'Adicionado 500 ml de Água';

  @override
  String get addSheetFoodScanner => 'Scanner/IA de alimento';

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
  String get splashForceUpdateBody =>
      'Uma nova versão do NutriTracker está disponível. Por favor, atualize o aplicativo para continuar.';

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
    return '→ próx: ${next}d';
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
  String get onbInfoBody =>
      'Vamos construir hábitos aos poucos. Foque na consistência, não na perfeição.';

  @override
  String get continueLabel => 'Continuar';

  @override
  String get finishLabel => 'Concluir';

  @override
  String get onbCommitToday => 'Compromisso marcado para hoje';

  @override
  String get dayStreak => 'Sequência de dias';

  @override
  String get onbCongratsStreak =>
      'Parabéns, você começou seu streak. Mantenha o ritmo!';

  @override
  String get onbImCommitted => 'Estou comprometido';

  @override
  String get goalsSet => 'Metas definidas';

  @override
  String get defineGoalsTitle => 'Defina suas metas';

  @override
  String get defineGoalsBody =>
      'Ajuste calorias e macros para o seu objetivo. Você pode alterar depois.';

  @override
  String get openGoalsWizard => 'Abrir assistente de metas';

  @override
  String get notificationsConfigured => 'Notificações configuradas';

  @override
  String get remindersSaved => 'Lembretes salvos';

  @override
  String get remindersTitle => 'Lembretes e Notificações';

  @override
  String get remindersBody =>
      'Ative lembretes de hidratação para ajudar na consistência diária. Você pode alterar nas configurações depois.';

  @override
  String get enableHydrationReminders => 'Ativar lembretes de hidratação';

  @override
  String get intervalMinutes => 'Intervalo (min)';

  @override
  String get requesting => 'Solicitando...';

  @override
  String get allowNotifications => 'Permitir notificações';

  @override
  String get recipesTitle => 'Receitas';

  @override
  String get recipesEmptyFiltered => 'Nenhuma receita encontrada';

  @override
  String get recipesLoadingTitle => 'Carregando receitas...';

  @override
  String get recipesEmptySubtitle =>
      'Tente ajustar seus filtros ou termo de busca';

  @override
  String get recipesLoadingSubtitle =>
      'Aguarde enquanto carregamos as melhores receitas para você';

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

  @override
  String get dashboardSummary => 'Resumo';

  @override
  String get dashboardDetails => 'Detalhes';

  @override
  String get dashboardWeek => 'Semana';

  @override
  String get dashboardNutrition => 'Nutrição';

  @override
  String get dismissToday => 'Dispensar hoje';

  @override
  String get notesTitle => 'Anotações';

  @override
  String get addNote => 'Adicionar anotação';

  @override
  String get addNoteHint => 'Abre editor para criar nova anotação do dia';

  @override
  String todayNotesCount(int count) {
    return 'Hoje: $count anotação(ões)';
  }

  @override
  String get addBodyMetrics => 'Adicionar valores corporais';

  @override
  String get noEntryTodayTapToLog => 'Sem registro hoje - toque para registrar';

  @override
  String get noMealsToDuplicateToday => 'Sem refeições para duplicar hoje';

  @override
  String get duplicateLastMealTitle => 'Duplicar última refeição';

  @override
  String mealDuplicated(String meal) {
    return 'Refeição duplicada ($meal)';
  }

  @override
  String get goalsPerMealTitle => 'Metas por refeição';

  @override
  String get goalsPerMealUpdated => 'Metas por refeição atualizadas';

  @override
  String get remainingPlural => 'Restantes';

  @override
  String remainingGrams(int grams) {
    return 'Restante: ${grams}g';
  }

  @override
  String get duplicate => 'Duplicar';

  @override
  String get duplicateDayTomorrowTitle => 'Duplicar dia → amanhã';

  @override
  String get duplicateDayPickDateTitle => 'Duplicar dia → escolher data';

  @override
  String get duplicateNewPickDateTitle => 'Duplicar \"novos\" → escolher data';

  @override
  String get noNewItemsToDuplicate => 'Nenhum item \"novo\" para duplicar';

  @override
  String get selectItemsToDuplicateTitle => 'Selecionar itens para duplicar';

  @override
  String get chooseFileCsv => 'Escolher arquivo (.csv)';

  @override
  String get reviewItemsTitle => 'Revisar itens';

  @override
  String get addSelected => 'Adicionar selecionados';

  @override
  String get saveAndAdd => 'Salvar e adicionar';

  @override
  String get detectFoodHeadline => 'Detectar Alimentos com IA';

  @override
  String get detectFoodSubtitle =>
      'Capture uma foto ou selecione da galeria para identificar automaticamente os alimentos e suas informações nutricionais';

  @override
  String get takePhoto => 'Tirar Foto';

  @override
  String get gallery => 'Galeria';

  @override
  String get initializingCamera => 'Inicializando câmera...';

  @override
  String get detectionTipsTitle => 'Dicas para melhor detecção:';

  @override
  String get detectionTip1 => 'Certifique-se de ter boa iluminação';

  @override
  String get detectionTip2 => 'Fotografe os alimentos de perto';

  @override
  String get detectionTip3 => 'Evite sombras no prato';

  @override
  String get detectionTip4 => 'Um alimento por vez funciona melhor';

  @override
  String get onePortion => '1 porção';

  @override
  String itemsAdded(int count) {
    return '$count item(ns) adicionados';
  }

  @override
  String get portionApplied => 'Porção aplicada';

  @override
  String addedToDiaryWithMeal(String meal) {
    return 'Adicionado ao diário ($meal)';
  }

  @override
  String get changesSaved => 'Alterações salvas';

  @override
  String saveChangesWithMeal(String meal) {
    return 'Salvar alterações - $meal';
  }

  @override
  String addToDiaryWithMeal(String meal) {
    return 'Adicionar ao diário - $meal';
  }

  @override
  String get addedToMyFoods => 'Adicionado em Meus Alimentos';

  @override
  String get addToMyFoods => 'Adicionar aos meus alimentos';

  @override
  String get noMyFoodsTitle => 'Você ainda não tem Meus Alimentos';

  @override
  String get presetsHelp =>
      'Abra os detalhes de um alimento e toque em \"Adicionar aos meus alimentos\" para criar seus presets.';

  @override
  String get portionSizeGramsLabel => 'Tamanho da porção (g)';

  @override
  String get grams => 'gramas';

  @override
  String get caloriesLabel => 'Calorias';

  @override
  String get carbsLabel => 'Carboidratos';

  @override
  String get proteinLabel => 'Proteína';

  @override
  String get fatLabel => 'Gordura';

  @override
  String get genericBrand => 'Genérico';

  @override
  String addWithCalories(int kcal) {
    return 'Adicionar - $kcal kcal';
  }

  @override
  String get analyzingFoods => 'Analisando alimentos...';

  @override
  String get pleaseWait => 'Aguarde alguns segundos';

  @override
  String get retakePhoto => 'Nova foto';

  @override
  String get noFoodDetected => 'Nenhum alimento detectado';

  @override
  String get tryCloserPhoto => 'Tente tirar uma foto mais próxima do alimento';

  @override
  String get detectedFoods => 'Alimentos Detectados';

  @override
  String get addOrEdit => 'Adicionar ou editar';

  @override
  String get addedShort => 'Adicionado!';

  @override
  String get noFoodDetectedInImage => 'Nenhum alimento detectado na imagem';

  @override
  String get saveAsMyFoodOptional => 'Salvar como alimento (rótulo opcional)';

  @override
  String get download => 'Download';

  @override
  String get copy => 'Copiar';

  @override
  String get importDayCsv => 'Importar CSV do dia';

  @override
  String get clearDayBeforeApply => 'Limpar dia antes de aplicar';

  @override
  String get untitled => 'sem nome';

  @override
  String get duplicateNewPickDate => 'Duplicar novos → escolher data';

  @override
  String dayDuplicatedTo(String date) {
    return 'Dia duplicado para $date';
  }

  @override
  String get exerciseAdded100 => 'Exercício registrado: +100 kcal';

  @override
  String waterAdjustedMinus250(int total) {
    return 'Água ajustada: -250ml (total ${total}ml)';
  }

  @override
  String get weekDuplicatedNext => 'Semana duplicada para a próxima';

  @override
  String weekDuplicatedToStart(String date) {
    return 'Semana duplicada para iniciar em $date';
  }

  @override
  String get noItemsThisMeal => 'Sem itens nesta refeição';

  @override
  String get tapAddToLog =>
      'Toque em + Adicionar para registrar alimentos rapidamente.';

  @override
  String get viewDay => 'Ver dia';

  @override
  String get onlyNew => 'Somente novos';

  @override
  String get dayCsvDownloaded => 'CSV do dia baixado';

  @override
  String get dayCsvCopied => 'CSV do dia copiado';

  @override
  String get dayTemplateSaved => 'Template de dia salvo';

  @override
  String get noDayTemplatesSaved => 'Nenhum template de dia salvo';

  @override
  String get templateName => 'Nome do template';

  @override
  String get weekTemplateSaved => 'Template de semana salvo';

  @override
  String get noWeekTemplatesSaved => 'Nenhum template de semana salvo';

  @override
  String get yesterday => 'Ontem';

  @override
  String get carbAbbrPlus => 'Carb+';

  @override
  String get proteinAbbrPlus => 'Prot+';

  @override
  String get fatAbbrPlus => 'Gord+';

  @override
  String get activitiesTitle => 'Atividades';

  @override
  String get more => 'Mais';

  @override
  String get noActivitiesToday => 'Nenhuma atividade registrada hoje';

  @override
  String get addExercise => 'Adicionar exercício';

  @override
  String get areYouSureStopFasting =>
      'Tem certeza que deseja interromper seu jejum atual? Seu progresso será salvo.';

  @override
  String get stopFasting => 'Parar Jejum';

  @override
  String get startFasting => 'Iniciar Jejum';

  @override
  String get openFilters => 'Abrir filtros';

  @override
  String get details => 'Detalhes';

  @override
  String get addToDiary => 'Adicionar ao diário';

  @override
  String get prepMode => 'Modo de preparo';

  @override
  String get prepDetailsUnavailable =>
      'Detalhes de preparo não disponíveis nesta versão (mock).';

  @override
  String get proRecipe => 'Receita PRO';

  @override
  String get tapToUnlock => 'Toque para desbloquear';

  @override
  String get proOnly => 'Somente PRO';

  @override
  String get qaAddMeal => 'Adicionar\nRefeição';

  @override
  String get qaLogWater => 'Registrar\nÁgua';

  @override
  String get qaExercise => 'Exercício';

  @override
  String get qaProgress => 'Progresso';

  @override
  String get qaRecipes => 'Receitas';

  @override
  String get qaSetupGoals => 'Configurar\nMetas';

  @override
  String get featureInDevelopment => 'Funcionalidade em desenvolvimento';

  @override
  String get email => 'Email';

  @override
  String get enterEmail => 'Digite seu email';

  @override
  String get password => 'Senha';

  @override
  String get enterPassword => 'Digite sua senha';

  @override
  String get emailRequired => 'Email é obrigatório';

  @override
  String get emailInvalid => 'Email inválido';

  @override
  String get passwordRequired => 'Senha é obrigatória';

  @override
  String get passwordMinLength => 'Senha deve ter pelo menos 6 caracteres';

  @override
  String get forgotPassword => 'Esqueci minha senha?';

  @override
  String get login => 'Entrar';

  @override
  String get newUser => 'Novo usuário? ';

  @override
  String get register => 'Cadastre-se';

  @override
  String get registerScreenInDevelopment =>
      'Tela de cadastro em desenvolvimento';

  @override
  String get logout => 'Sair';

  @override
  String get clear => 'Limpar';

  @override
  String get import => 'Importar';

  @override
  String get myProgress => 'Meu progresso';

  @override
  String get myGoals => 'Meus objetivos';

  @override
  String get diet => 'Alimentação';

  @override
  String get standard => 'Padrão';

  @override
  String get weightGoal => 'Objetivo de peso';

  @override
  String get lose => 'Perder';

  @override
  String get maintain => 'Manter';

  @override
  String get gain => 'Ganhar';

  @override
  String get initialWeight => 'Peso inicial (kg)';

  @override
  String get targetWeight => 'Meta de peso (kg)';

  @override
  String get editGoals => 'Editar objetivos';

  @override
  String get goalsUpdated => 'Objetivos atualizados';

  @override
  String get carbs => 'Carboidratos';

  @override
  String get proteins => 'Proteínas';

  @override
  String get fats => 'Gorduras';

  @override
  String get confirm => 'Confirmar';

  @override
  String get validCaloriesRequired => 'Informe calorias válidas (> 0)';

  @override
  String get validMacrosRequired => 'Macros devem ser números ≥ 0';

  @override
  String get weight => 'Peso';

  @override
  String get height => 'Altura';

  @override
  String get bodyFat => 'Gordura';

  @override
  String get bodyMetrics => 'Valores Corporais';

  @override
  String get proPlanPersonalized => 'Planos personalizados';

  @override
  String get proPlanPersonalizedDesc =>
      'Cardápios e ciclos de jejum ajustados às suas metas.';

  @override
  String get proSmartScanner => 'Scanner inteligente';

  @override
  String get proSmartScannerDesc =>
      'Barcode + OCR para lançar refeições em segundos.';

  @override
  String get proAdvancedInsights => 'Insights avançados';

  @override
  String get proAdvancedInsightsDesc =>
      'Relatórios preditivos e ajustes automáticos de meta.';

  @override
  String get proExclusiveRecipes => 'Receitas exclusivas';

  @override
  String get proExclusiveRecipesDesc =>
      'Coleção PRO com macros calculados e filtros avançados.';

  @override
  String get cancelAnytime => 'Cancele quando quiser';

  @override
  String get dayGuarantee => '7 dias de garantia';

  @override
  String get averageRating => 'Avaliação média 4,8/5';

  @override
  String get noPlansAvailable =>
      'Nenhum plano disponível no momento.\nTente novamente mais tarde.';

  @override
  String get errorLoadingPlans =>
      'Erro ao carregar planos.\nVerifique sua conexão.';

  @override
  String get proActivated => 'Assinatura PRO ativada com sucesso!';

  @override
  String get cancelPro => 'Encerrar PRO';

  @override
  String get keepPro => 'Manter PRO';

  @override
  String get cancelProTestMode => 'Cancelar PRO (ambiente de testes)';

  @override
  String get freePlanReactivated => 'Plano gratuito reativado';

  @override
  String get exploreProBenefits => 'Explorar benefícios PRO';

  @override
  String get restorePurchases => 'Restaurar Compras';

  @override
  String get reduceAnimations => 'Reduzir animações';

  @override
  String get reduceAnimationsDesc => 'Evita confetes/transições exageradas';

  @override
  String get animationsReduced => 'Animações reduzidas';

  @override
  String get animationsNormal => 'Animações normais';

  @override
  String get celebrateAchievements => 'Celebrar conquistas';

  @override
  String get celebrateAchievementsDesc =>
      'Mostra confete ao desbloquear badges';

  @override
  String get celebrationsDisabled => 'Celebrações desativadas';

  @override
  String get celebrationsEnabled => 'Celebrações ativadas';

  @override
  String get showNextMilestone => 'Exibir \'Próximo marco\' nos chips';

  @override
  String get showNextMilestoneDesc =>
      'Mostra \'• próx: Nd\' nos chips de streak';

  @override
  String get useLottieInCelebrations => 'Usar Lottie nas celebrações';

  @override
  String get searchAndFoods => 'Busca e alimentos';

  @override
  String get interpretQuantitiesNLQ => 'Interpretar quantidades no texto (NLQ)';

  @override
  String get collapse => 'Recolher';

  @override
  String get expand => 'Expandir';

  @override
  String get breakfast => 'Café da manhã';

  @override
  String get lunch => 'Almoço';

  @override
  String get dinner => 'Jantar';

  @override
  String get snacks => 'Lanches';

  @override
  String get exportJSON => 'Exportar JSON';

  @override
  String get importJSON => 'Importar JSON';

  @override
  String get clearTemplates => 'Limpar templates';

  @override
  String get clearFoods => 'Limpar alimentos';

  @override
  String get setGoals => 'Set goals';

  @override
  String get knowProNutriTracker => 'Conheça o NutriTracker PRO';

  @override
  String get friends => 'Amigos';

  @override
  String get analysis => 'ANÁLISE';

  @override
  String get registerWeight => 'REGISTRAR PESO';

  @override
  String get defineGoal => 'DEFINIR META';

  @override
  String get edit => 'EDITAR';

  @override
  String dietType(String type) {
    return 'Alimentação: $type';
  }

  @override
  String goalObjective(String objective) {
    return 'Objetivo: $objective';
  }

  @override
  String unexpectedErrorMessage(String error) {
    return 'Erro inesperado: $error';
  }

  @override
  String get dataSourceQA => 'Mostrar fonte dos dados (OFF/FDC/NLQ)';

  @override
  String get qaDebugging => 'QA / Depuração';

  @override
  String get achievementsStreaksCleared => 'Conquistas e streaks limpos';

  @override
  String get clearAchievementsStreaks => 'Limpar conquistas/streaks';

  @override
  String get testBadgeGranted => 'Badge de teste concedido';

  @override
  String get grantTestBadge => 'Conceder badge de teste';

  @override
  String get recalculateStreaks60 => 'Recalcular streaks (60 dias)';

  @override
  String get recalculatePerfectWeek => 'Recalcular semana perfeita';

  @override
  String get testCelebration => 'Testar celebração';

  @override
  String get preferenceSaved => 'Preferência salva';

  @override
  String get aiCacheNormalization => 'Cache de IA (normalização de alimentos)';

  @override
  String get chipsUpdated => 'Chips atualizados';

  @override
  String get aiCacheCleared => 'Cache de IA limpo';

  @override
  String get aiCacheCopied => 'Cache de IA copiado';

  @override
  String get aiCacheImported => 'Cache de IA importado';

  @override
  String invalidJSON(String error) {
    return 'JSON inválido: $error';
  }

  @override
  String get mealGoalsSaved => 'Metas por refeição salvas!';

  @override
  String get dataSource => 'Mostrar fonte dos dados (OFF/FDC/NLQ)';

  @override
  String get me => 'EU';

  @override
  String get freePlan => 'Plano Gratuito';

  @override
  String get proSubscription => 'Assinatura PRO';

  @override
  String get dailyGoals => 'Metas Diárias';

  @override
  String get logoutAccount => 'Sair da conta?';

  @override
  String get logoutConfirmMessage =>
      'Você precisará fazer login novamente. Para confirmar, digite: SAIR';

  @override
  String get intelligentReports => 'Relatórios inteligentes';

  @override
  String get guidedPlans => 'Planos guiados';

  @override
  String get barcodeScanner => 'Scanner de código de barras';

  @override
  String get nutriTrackerPro => 'NutriTracker PRO';

  @override
  String get proDescription =>
      'Personalize refeições, receba alertas inteligentes e acesse a biblioteca completa de receitas exclusivas.';

  @override
  String get meetNutriTrackerPro => 'Conheça o NutriTracker PRO';

  @override
  String get plansStartingAt =>
      'Planos a partir de R\$ 14,99/mês · Cancele quando quiser';

  @override
  String get youArePro => 'Você é PRO!';

  @override
  String get proEnjoyMessage =>
      'Aproveite todos os recursos avançados do NutriTracker. Novas receitas e planos chegam toda semana.';

  @override
  String get advancedInsights => 'Insights avançados';

  @override
  String get dynamicPlans => 'Planos dinâmicos';

  @override
  String get proRecipes => 'Receitas PRO';

  @override
  String get proSubscriptionActivated => 'Assinatura PRO ativada com sucesso!';

  @override
  String unexpectedError(String error) {
    return 'Erro inesperado: $error';
  }

  @override
  String get terminatePro => 'Encerrar PRO';

  @override
  String get terminateProConfirmMessage =>
      'Essa ação está disponível apenas para testes. Confirmar cancelamento da assinatura PRO?';

  @override
  String get connectWithFriends =>
      'Conecte-se com amigos para comparar progresso. Em breve.';

  @override
  String get goalReached => 'Meta atingida!';

  @override
  String get noVariationYet => 'Sem variação ainda';

  @override
  String youGainedWeight(String weight) {
    return 'Você ganhou $weight kg';
  }

  @override
  String youLostWeight(String weight) {
    return 'Você perdeu $weight kg';
  }

  @override
  String get defineWeightGoalMessage =>
      'Defina sua meta de peso para acompanhar a barra';

  @override
  String get weightGoalKg => 'Meta de peso (kg)';

  @override
  String get startingWeightKg => 'Peso inicial (kg)';

  @override
  String get weightObjective => 'Objetivo de peso';

  @override
  String get goalsUpdatedSuccess => 'Objetivos atualizados';

  @override
  String get reducedAnimations => 'Animações reduzidas';

  @override
  String get normalAnimations => 'Animações normais';

  @override
  String get showConfettiOnBadges => 'Mostra confete ao desbloquear badges';

  @override
  String get showNextMilestoneDescription =>
      'Mostra \'• próx: Nd\' nos chips de streak';

  @override
  String get interpretQuantitiesInText =>
      'Interpretar quantidades no texto (NLQ)';

  @override
  String get quantitiesExample => 'Ex.: \'150g frango\', \'2 ovos e 1 banana\'';

  @override
  String get mealGoalsPerMeal => 'Metas por refeição';

  @override
  String get kcal => 'kcal';

  @override
  String get carbGrams => 'Carb. (g)';

  @override
  String get protGrams => 'Prot. (g)';

  @override
  String get fatGrams => 'Gord. (g)';

  @override
  String get saveMealGoals => 'Salvar metas';

  @override
  String get mealGoalsCleared => 'Metas por refeição limpas';

  @override
  String get clearMealGoalsConfirm => 'Limpar metas por refeição?';

  @override
  String get clearMealGoalsMessage =>
      'Esta ação zera as metas de Café, Almoço, Jantar e Lanches.\nPara confirmar, digite: CONFIRMAR';

  @override
  String get diaryExported => 'Diário exportado para a área de transferência';

  @override
  String exportFailed(String error) {
    return 'Falha ao exportar: $error';
  }

  @override
  String get importDiary => 'Importar Diário (JSON)';

  @override
  String get diaryImported => 'Diário importado com sucesso';

  @override
  String get templatesExported =>
      'Templates copiados para a área de transferência';

  @override
  String exportTemplatesFailed(String error) {
    return 'Falha ao exportar templates: $error';
  }

  @override
  String get importTemplates => 'Importar Templates (JSON)';

  @override
  String get templatesImported => 'Templates importados com sucesso';

  @override
  String get foodsExported => 'Alimentos copiados para a área de transferência';

  @override
  String exportFoodsFailed(String error) {
    return 'Falha ao exportar alimentos: $error';
  }

  @override
  String get importFoods => 'Importar Alimentos (JSON)';

  @override
  String get foodsImported => 'Alimentos importados com sucesso';

  @override
  String get foodsCleared => 'Alimentos limpos';

  @override
  String get clearAllFoodsConfirm => 'Limpar todos os alimentos?';

  @override
  String get clearAllFoodsMessage =>
      'Esta ação remove Favoritos e Meus Alimentos. Não pode ser desfeita.\nPara confirmar, digite: LIMPAR';

  @override
  String get templatesCleared => 'Templates limpos';

  @override
  String get clearAllTemplatesConfirm => 'Limpar todos os templates?';

  @override
  String get clearAllTemplatesMessage =>
      'Esta ação remove todos os templates de dia e semana. Não pode ser desfeita.\nPara confirmar, digite: LIMPAR';

  @override
  String get importAICacheJSON => 'Importar Cache de IA (JSON)';

  @override
  String get water => 'Água';

  @override
  String get activities => 'Atividades';

  @override
  String get walking => 'Caminhada';

  @override
  String get running => 'Corrida';

  @override
  String get cycling => 'Bike';

  @override
  String get addMeal => 'Add Meal';

  @override
  String get navFasting => 'Jejum';

  @override
  String get navRecipes => 'Receitas';

  @override
  String get navCoach => 'Coach';

  @override
  String get eaten => 'Consumido';

  @override
  String get remaining => 'Restante';

  @override
  String get burned => 'Queimado';

  @override
  String get nutrition => 'Nutrição';

  @override
  String get dayActions => 'Ações do dia';

  @override
  String get statistics => 'Estatísticas';

  @override
  String get moreActions => 'Mais ações';

  @override
  String walkingMinutes(int minutes) {
    return 'Caminhada ${minutes}m';
  }

  @override
  String runningMinutes(int minutes) {
    return 'Corrida ${minutes}m';
  }

  @override
  String cyclingMinutes(int minutes) {
    return 'Bike ${minutes}m';
  }

  @override
  String get macronutrients => 'Macronutrientes';

  @override
  String get goals => 'Metas';

  @override
  String get adjustMacroGoals => 'Ajustar metas de macros';

  @override
  String get macroGoalsUpdated => 'Metas de macros atualizadas';

  @override
  String get intermittentFasting => 'Jejum Intermitente';

  @override
  String get fastingSchedules => 'Horários de jejum';

  @override
  String eatingWindow(String stop, String start) {
    return 'Janela de alimentação: $stop - $start';
  }

  @override
  String get fastingMethod168 => 'Método 16:8';

  @override
  String get fastingMethod186 => 'Método 18:6';

  @override
  String get fastingMethod204 => 'Método 20:4';

  @override
  String fastingMethodCustom(int hours) {
    return 'Custom • ${hours}h';
  }

  @override
  String fastingMethodLabel(String method) {
    return 'Método $method';
  }

  @override
  String timezone(String timezone) {
    return 'Fuso: $timezone';
  }

  @override
  String endsAt(String time) {
    return 'Termina às $time';
  }

  @override
  String fastingDays(int days) {
    return '${days}d jejum';
  }

  @override
  String get noFastingStreak => 'Sem streak jejum';

  @override
  String get defineCustomMethod => 'Definir método personalizado';

  @override
  String get fastingDuration => 'Duração do jejum';

  @override
  String get minutes => 'Minutos';

  @override
  String fastStarted(String method) {
    return 'Jejum iniciado! Método $method';
  }

  @override
  String fastCompleted(int hours, int minutes) {
    return 'Jejum finalizado! Duração: ${hours}h ${minutes}min';
  }

  @override
  String get congratulations => 'Parabéns!';

  @override
  String fastCompletedSuccess(String method) {
    return 'Você completou seu jejum $method com sucesso! 🎉';
  }

  @override
  String notificationsMutedUntil(String time) {
    return 'Notificações silenciadas até $time';
  }

  @override
  String get reactivate => 'Reativar';

  @override
  String get stopCurrentFastToChangeMethod =>
      'Finalize o jejum atual para alterar o método';

  @override
  String fastingOfDay(String date) {
    return 'Jejum de $date';
  }

  @override
  String duration(int hours) {
    return 'Duração: ${hours}h';
  }

  @override
  String get fastCompletedSuccessfully => 'Jejum completado com sucesso';

  @override
  String get remindersMuted24h => 'Lembretes silenciados por 24h';

  @override
  String get remindersReactivated => 'Lembretes reativados';

  @override
  String get remindersMutedTomorrow => 'Lembretes silenciados até amanhã 08:00';

  @override
  String get startFastButton => 'Iniciar jejum';

  @override
  String get endFastButton => 'Encerrar jejum';

  @override
  String get onbV3SplashTitle => 'nutriZ';

  @override
  String get onbV3WelcomeTitle => 'nutriZ';

  @override
  String get onbV3Welcome85Million => '85 milhões de usuários felizes';

  @override
  String get onbV3Welcome20Million =>
      '20 milhões de alimentos para rastreamento de calorias';

  @override
  String get onbV3WelcomeSubtitle => 'Vamos fazer cada dia valer a pena!';

  @override
  String get onbV3WelcomeGetStarted => 'Começar';

  @override
  String get onbV3WelcomeAlreadyHaveAccount => 'Já tenho uma conta';

  @override
  String get onbV3GoalTitle => 'Qual é o seu objetivo principal?';

  @override
  String get onbV3GoalLoseWeight => 'Perder peso';

  @override
  String get onbV3GoalGainWeight => 'Ganhar peso';

  @override
  String get onbV3GoalMaintain => 'Manter peso';

  @override
  String get onbV3GoalContinue => 'Continuar';

  @override
  String get onbV3AppBarSetup => 'Configuração';

  @override
  String onbV3ProgressStep(Object current, Object total) {
    return '$current/$total';
  }

  @override
  String get notifFastingOpenTitle => 'Janela de alimentação aberta';

  @override
  String get notifFastingOpenBody => 'Você pode começar a comer agora.';

  @override
  String get notifFastingStartTitle => 'Janela de jejum iniciada';

  @override
  String get notifFastingStartBody => 'Pare de comer para iniciar seu jejum.';

  @override
  String get notifFastingEndTitle => 'Jejum concluído';

  @override
  String notifFastingEndBody(String method) {
    return 'Seu jejum $method foi concluído.';
  }

  @override
  String get channelFastingName => 'Jejum';

  @override
  String get channelFastingDescription => 'Notificações de jejum intermitente';

  @override
  String get notifHydrationTitle => 'Lembrete de hidratação';

  @override
  String get notifHydrationBody => 'Hora de beber água.';

  @override
  String get channelHydrationName => 'Hidratação';

  @override
  String get channelHydrationDescription => 'Lembretes de hidratação';

  @override
  String get carbsShort => 'Carb';

  @override
  String get proteinShort => 'Prot';

  @override
  String get fatShort => 'Gord';

  @override
  String get eatenShort => 'Comido';

  @override
  String get burnedShort => 'Queimado';

  @override
  String get remainingShort => 'Restante';

  @override
  String get weekShort => 'Sem';

  @override
  String get nowEating => 'Agora: Comendo';

  @override
  String get nowFasting => 'Agora: Jejum';

  @override
  String get notesYourLastNote => 'Sua última nota';

  @override
  String get notesHowAreYouToday => 'Como você está hoje?';

  @override
  String get notesTrackMoodAndMeals =>
      'Registre humor, refeições e aprendizados.';

  @override
  String get notesViewAll => 'Ver todas';

  @override
  String get notesNoRecordsYet => 'Sem registros ainda.';

  @override
  String get notesWriteMyDay => 'Escrever meu dia';

  @override
  String get notesRegisterNow => 'Registrar agora';

  @override
  String notesTodayCount(int count) {
    return 'Hoje: $count nota(s)';
  }

  @override
  String get notesToday => 'Hoje';

  @override
  String get notesNotesSingular => 'nota';

  @override
  String get notesNotesPlural => 'notas';

  @override
  String get waterGoal => 'Meta';

  @override
  String get waterToday => 'hoje';

  @override
  String get waterRemaining => 'Faltam';

  @override
  String get waterAdd100 => '+ 100 mL';

  @override
  String get waterAdd200 => '+ 200 mL';

  @override
  String get waterReset => 'Redefinir';

  @override
  String get waterFromFood => 'Água dos alimentos';

  @override
  String get waterTipTap =>
      'Dica: toque nos botões para adicionar rapidamente.';

  @override
  String get waterAddWater => 'Adicionar água';

  @override
  String get waterCancel => 'Cancelar';

  @override
  String get waterAdd => 'Adicionar';

  @override
  String get waterCustom => 'Customizar';

  @override
  String get waterMotivation0 => 'Comece com um copo 💙';

  @override
  String get waterMotivation30 => 'Continue! Seu corpo agradece 💧';

  @override
  String get waterMotivation70 => 'Boa! Você está indo bem 👏';

  @override
  String get waterMotivation100Less => 'Quase lá! Só mais um pouco 🏁';

  @override
  String get waterMotivation100 => 'Meta atingida! 🎉';

  @override
  String get bodyMetricsTitle => 'Valores Corporais';

  @override
  String get bodyMetricsViewAll => 'Ver Tudo';

  @override
  String get bodyMetricsGoal => 'Meta';

  @override
  String get bodyMetricsThisWeek => 'esta semana';

  @override
  String get bodyMetricsEmptyTitle => 'Como está seu progresso hoje?';

  @override
  String get bodyMetricsEmptySubtitle =>
      'Registrar ajuda você a manter o foco ✨';

  @override
  String get bodyMetricsAddWeight => 'Registrar Peso';

  @override
  String get bodyMetricsBloodPressure => 'Pressão Arterial';

  @override
  String get bodyMetricsBloodGlucose => 'Glicemia';

  @override
  String get bodyMetricsBodyFat => 'Gordura Corporal';

  @override
  String get bodyMetricsMuscleMass => 'Massa Muscular';
}
