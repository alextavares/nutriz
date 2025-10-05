# Contratos de Estado — NutriTracker

## Sumário
- Estados locais por tela (alto nível)
- Persistência (SharedPreferences): chaves e formatos
- Eventos/Ações principais
- Riscos e considerações
- Observado vs. Inferência

## Estados Locais (alto nível)
- DailyTrackingDashboard: data selecionada, entradas do dia, metas por refeição, água/exercício semanais, conquistas.
- FoodLoggingScreen: aba ativa (recent/favorites/mine), refeição selecionada, data alvo, filtros, busca, item selecionado, porções rápidas.
- RootShell: `currentIndex` (tab), `selectedDate` (ValueNotifier<DateTime>), controle do bottom‑sheet de adição.

## Persistência — SharedPreferences
- NutritionStorage
  - `logged_meals_YYYY-MM-DD` → `List<Map>` de entradas do dia (observado)
    - Campos típicos (inferência a partir de uso e adição): `id`, `name`, `calories` (int), `carbs` (num), `protein` (num), `fat` (num), `serving` (string), `mealTime` (string: breakfast/lunch/dinner/snack), timestamps opcionais.
  - `exercise_kcal_YYYY-MM-DD` → `int` kcal exercício por dia (observado)
  - `water_ml_YYYY-MM-DD` → `int` ml água por dia (observado)
  - Templates:
    - `meal_templates_v1` → `List<Map>`
    - `day_templates_v1` → `List<Map>`
    - `week_templates_v1` → `List<Map>`
  - Export/Import: objeto `{ meals: {date: List}, exercise: {date: int}, water: {date: int}, version: 1 }`

- FavoritesStorage
  - `favorite_foods_v1` → `List<Map>`
  - `my_foods_v1` → `List<Map>` (inclui presets por unidade: `unitPresets`)

- UserPreferences
  - Metas globais: `user_goal_total_calories` (int), `user_goal_carbs` (int), `user_goal_proteins` (int), `user_goal_fats` (int), `user_goal_water_ml` (int)
  - Lembretes hidratação: `hydration_enabled` (bool), `hydration_interval_min` (int)
  - Metas por refeição (kcal/carb/prot/fat): `meal_goal_*_(breakfast|lunch|dinner|snack)`
  - UI porções rápidas: `ui_quick_portion_grams_v1` (CSV), e por refeição `ui_quick_portion_grams_(breakfast|...)_v1`
  - UI quick add default: `ui_quick_add_default_grams_v1` (double), `ui_quick_add_default_food_(breakfast|lunch|dinner|snack)_v1` (JSON)
  - Filtros de busca: `ui_filter_kcal_min_v1`/`max`, `ui_filter_protein_v1`, `ui_filter_carb_v1`, `ui_filter_fat_v1`, `ui_sort_key_v1`
  - Histórico de busca: `ui_search_history_v1` (JSON array de strings)

## Eventos/Ações (exemplos)
- Adicionar/atualizar/remover entrada do diário (por data/id) → `NutritionStorage.add/update/remove`
- Ajustar meta de água/calorias/macros → `UserPreferences.setGoals`, `setWaterGoal`
- Hidratação: `addWaterMl`, `setHydrationReminder`, `NotificationsService.showHydrationReminder`
- Favoritos/Meus alimentos: `FavoritesStorage.toggleFavorite/addMyFood/removeMyFood`
- Porções rápidas: `UserPreferences.setQuickPortionGrams(ForMeal)`

## Riscos e Considerações
- Consistência de dados (tipos numéricos double/int ao serializar/deserializar).
- Versão do esquema: somente `exportDiary.version=1` — considerar migrações futuras.
- Duplicidade por nome em favoritos/“meus alimentos”; chave primária apenas por `name`.
- Crescimento do storage: históricos, templates e favoritos podem inflar o SharedPreferences.

## Observado vs. Inferência
- Observado: chaves e acessos definidos nos serviços listados em Referências.
- Inferência: formato detalhado de itens de diário; timestamps e campos extras.

## Referências
- lib/services/nutrition_storage.dart:1-220
- lib/services/favorites_storage.dart:1-220
- lib/services/user_preferences.dart:1-360
