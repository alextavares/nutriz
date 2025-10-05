Plano de Gamificação — Referências do YAZIO e aplicação no NutriTracker

Resumo do estudo rápido no YAZIO

- Onboarding guiado por metas: logo no início o app pergunta o objetivo principal do usuário (perder peso, ganhar peso, etc.), seguido de passos curtos. Isso já “liga” um contexto de meta ativa para personalizar a experiência.
- Micro‑cópias motivacionais: textos como “Let’s make every day count!” aparecem nas telas iniciais, reforçando reforço positivo.
- Streaks e conquistas: o YAZIO emprega streaks (sequência de dias) e “badges” (conquistas) para metas como água, jejum, etc. Ao atingir marcos, há realces visuais (chips/insígnias) e telas de celebração.
- Animações de celebração: quando o usuário inicia/atinge metas, aparecem animações/overlays (efeito confete/celebrações) que dão feedback claro de progresso.
- Ícones e cores: insígnias usam ícones simples (estrela, chama, troféu/diamante) com paleta consistente (azul ativo, âmbar/laranja para streak, verde para sucesso, dourado/premium).

Estado atual do NutriTracker (repo)

- Já existem pontos de partida úteis:
  - lib/presentation/daily_tracking_dashboard/widgets/achievement_badges_widget.dart — componente de insígnias (“Conquistas Recentes”) com cores/ícones baseados em tipo: diamond/flame/success/star.
  - lib/services/fasting_storage.dart — persistência e streak de jejum (getCurrentStreak), com histórico diário em SharedPreferences.
  - Preferências de metas (água, refeições, peso) em services/user_preferences.dart e telas Profile/GoalsWizard.

O que implementar (MVP de gamificação)

1) Núcleo (Camada de domínio/serviço)
- GamificationEvent (enum): goal_started, goal_completed, streak_incremented, milestone_reached, badge_unlocked.
- GamificationEngine (serviço): recebe eventos, atualiza streaks/achievements e decide “recompensas visuais”.
- StreakService unificado: generalizar o padrão de fasting_storage para água/registro diário (parametrizado por chave e limiar), mantendo getCurrentStreak(key, threshold).
- AchievementService: registra e consulta conquistas (tipo, data, payload). Gera badges como no AchievementBadgesWidget.

2) Modelo de dados (SharedPreferences no MVP)
- Tabelas/entradas (chaves JSON):
  - gamification_events_v1: fila/LOG (opcional, útil para debug)
  - streaks_v1: { "water": nDias, "fasting": nDias, ... }
  - achievements_v1: lista de conquistas [{ id, type, title, dateIso, metaKey, value }]

3) UI/UX
- CelebrationOverlay (Widget): overlay modal com Lottie (ou simples ConfettiPainter) disparado por goal_completed, milestone_reached e badge_unlocked. Fecha sozinho após 2–3s.
- StreakChip (Widget): chip com ícone “flame” e contador de dias; animar contagem (+1) com scale/bounce.
- MetaBar/ProgressRing: ao atingir 100% do dia (água/calorias), disparar CelebrationOverlay e vibração curta.
- Atualizar AchievementBadgesWidget: quando onBadgeTap, abrir BottomSheet com detalhes: “Conquista X — obtida em DD/MM, continue por NN dias para a próxima!”.

4) Gatilhos de eventos (exemplos)
- Água: ao salvar ingestão e atingir meta diária >= 100% pela 1ª vez no dia => goal_completed(water).
- Jejum: ao encerrar jejum com duração >= threshold => goal_completed(fasting) e avaliar streak_incremented.
- Refeições: 7 dias seguidos dentro da meta calórica => milestone_reached(weekly_target).

5) Ícones e cores (mapa rápido)
- success: check_circle + verde (AppTheme.successGreen)
- flame (streak): local_fire_department + âmbar (AppTheme.warningAmber)
- diamond/premium: diamond + dourado (AppTheme.premiumGold)
- star (genérico): star + ativo (AppTheme.activeBlue)

6) Animações (leve e incremental)
- ConfettiLight: Canvas simples com 12–20 partículas, 600–900ms, fps friendly (sem dependência externa, ou usar pacote confetti/lottie se já permitido).
- ScaleInOut: para ícones de streak/badge ao desbloquear (200ms in, 100ms hold, 200ms out).

7) Integração sugerida no código
- lib/services/gamification_engine.dart (novo):
  - fire(event): decide streak/achievement + aciona celebrationCallback opcional.
  - dependency: StreakService, AchievementService.
- lib/presentation/common/celebration_overlay.dart (novo): widget overlay com confete/anim.
- Wiring: nos pontos de “salvar água”, “encerrar jejum”, “bater meta diária de calorias”, chamar GamificationEngine.fire(...).

8) Fases de entrega
- Fase 1 (núcleo + água/jejum):
  - StreakService genérico
  - GamificationEngine (eventos: goal_completed, streak_incremented)
  - CelebrationOverlay simples (confete)
  - Hook em água e jejum
- Fase 2 (badges + milestones):
  - AchievementService
  - Novos gatilhos (semana perfeita, 3/5/7 dias de água)
  - BottomSheet de detalhes de conquista
- Fase 3 (polimento visual):
  - Lottie/ilustrações leves
  - Vibração (HapticFeedback.lightImpact) e sons opcionais
  - Preferência “reduzir animações” em Settings

9) Mapeamento YAZIO → NutriTracker
- Onboarding por meta: já existe GoalsWizard/Profile; manter fluxo curto e conectar ao GamificationEngine ao concluir o wizard (fire(goal_started)).
- Streaks: replicar padrão de fasting_storage para “water” e “calories_ok_day”, exibindo chama (flame) e contador.
- Conquistas: usar AchievementBadgesWidget como galeria, gerar badges ao completar milestones (ex.: 7 dias de água ⇒ badge).
- Animações: confete ligero + scale em ícones ao desbloquear/atingir meta — mesmo padrão observado no YAZIO (feedback imediato, curto e positivo).

10) Riscos e cuidados
- Fuso horário/virada de dia: normalizar datas a meia‑noite local (DateTime(year,month,day)).
- Edição retroativa: se o usuário mexer em logs anteriores, recalcular streaks daquele período em background leve.
- Performance: limitar partículas/frames das animações e proteger com flag “reduzir animações”.

Checklist técnico (para abrir issues)

- [ ] Criar lib/services/gamification_engine.dart (MVP com água e jejum)
- [ ] Criar lib/services/streak_service.dart (genérico por chave)
- [ ] Criar lib/services/achievement_service.dart (persistência simples)
- [ ] Criar lib/presentation/common/celebration_overlay.dart
- [ ] Integrar água: disparar eventos ao atingir 100% (única vez por dia)
- [ ] Integrar jejum: disparar eventos ao encerrar com >= threshold
- [ ] Exibir StreakChip (água/jejum) no dashboard
- [ ] Gerar 1 badge simples (“7 dias de água”) e exibir na AchievementBadgesWidget
- [ ] Flag “reduzir animações” em Settings

Este plano mantém o app leve e incremental, aproveitando código já existente (streak de jejum, badges recentes) e adicionando a camada de feedback/celebração similar ao YAZIO, com streaks, insígnias e micro‑animações ao iniciar/atingir metas.

