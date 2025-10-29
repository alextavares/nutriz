import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Sistema de ícones monocromáticos do NutriTracker.
///
/// Esta classe fornece ícones com estados padrão (neutral) e ativo (primary).
/// Segue o princípio de design "quiet" onde cores são reservadas para estados ativos.
///
/// Uso:
/// ```dart
/// // Ícone padrão (cinza neutro)
/// Icon(Icons.home, color: AppIcons.standard())
///
/// // Ícone ativo (azul primário)
/// Icon(Icons.home, color: AppIcons.active())
/// ```
class AppIcons {
  AppIcons._(); // Private constructor - utility class

  /// Cor padrão para ícones em estado normal (neutral700 - cinza médio)
  /// Usado para ícones não-selecionados, decorativos ou em repouso
  static Color standard() => AppColors.neutral700;

  /// Cor para ícones em estado ativo/selecionado (primary blue)
  /// Usado para ícones de navegação ativa, botões primários, ou destaques
  static Color active() => AppColors.primary;

  /// Cor para ícones em estado secundário (neutral500 - cinza mais claro)
  /// Usado para ícones menos importantes ou informativos
  static Color secondary() => AppColors.neutral500;

  /// Cor para ícones sobre fundos escuros (branco)
  /// Usado em cards com isHighlighted: true ou fundos neutral700
  static Color onDark() => AppColors.white;

  /// Cor para ícones de sucesso (verde)
  /// Usado para feedback positivo, confirmações
  static Color success() => AppColors.success;

  /// Cor para ícones desabilitados (neutral100 - cinza muito claro)
  /// Usado para indicar estados desabilitados ou inativos
  static Color disabled() => AppColors.neutral100;

  // ========== TAMANHOS DE ÍCONES ==========

  /// Tamanho extra pequeno: 16dp
  /// Usado em badges, chips pequenos
  static const double xs = 16.0;

  /// Tamanho pequeno: 20dp
  /// Usado em botões pequenos, trailing em ListTile
  static const double sm = 20.0;

  /// Tamanho médio: 24dp (padrão Material)
  /// Usado na maioria dos casos - BottomNav, AppBar, Cards
  static const double md = 24.0;

  /// Tamanho grande: 32dp
  /// Usado em botões primários grandes, FABs
  static const double lg = 32.0;

  /// Tamanho extra grande: 48dp
  /// Usado em ícones de destaque, placeholders, empty states
  static const double xl = 48.0;

  // ========== HELPERS PARA WIDGETS ==========

  /// Cria um Icon widget com cor padrão (neutral700)
  ///
  /// ```dart
  /// AppIcons.iconStandard(Icons.home, size: AppIcons.md)
  /// ```
  static Icon iconStandard(IconData icon, {double? size}) {
    return Icon(icon, color: standard(), size: size ?? md);
  }

  /// Cria um Icon widget com cor ativa (primary blue)
  ///
  /// ```dart
  /// AppIcons.iconActive(Icons.home, size: AppIcons.md)
  /// ```
  static Icon iconActive(IconData icon, {double? size}) {
    return Icon(icon, color: active(), size: size ?? md);
  }

  /// Cria um Icon widget com cor secundária (neutral500)
  ///
  /// ```dart
  /// AppIcons.iconSecondary(Icons.info_outline)
  /// ```
  static Icon iconSecondary(IconData icon, {double? size}) {
    return Icon(icon, color: secondary(), size: size ?? md);
  }

  /// Cria um Icon widget para fundos escuros (branco)
  ///
  /// ```dart
  /// AppIcons.iconOnDark(Icons.fitness_center)
  /// ```
  static Icon iconOnDark(IconData icon, {double? size}) {
    return Icon(icon, color: onDark(), size: size ?? md);
  }

  // ========== ÍCONES ESPECÍFICOS DO APP ==========

  /// Ícones de navegação (BottomNavigationBar)
  static const IconData navHome = Icons.home_outlined;
  static const IconData navDiary = Icons.calendar_today_outlined;
  static const IconData navGoals = Icons.flag_outlined;
  static const IconData navProfile = Icons.person_outline;

  /// Ícones de macronutrientes
  static const IconData macroCarbs = Icons.grain; // Carboidratos
  static const IconData macroProtein = Icons.egg_outlined; // Proteínas
  static const IconData macroFat = Icons.opacity; // Gorduras

  /// Ícones de refeições
  static const IconData mealBreakfast = Icons.free_breakfast;
  static const IconData mealLunch = Icons.restaurant;
  static const IconData mealDinner = Icons.dinner_dining;
  static const IconData mealSnack = Icons.cookie;

  /// Ícones de ações
  static const IconData actionAdd = Icons.add;
  static const IconData actionEdit = Icons.edit_outlined;
  static const IconData actionDelete = Icons.delete_outline;
  static const IconData actionSave = Icons.check;
  static const IconData actionCancel = Icons.close;
  static const IconData actionSearch = Icons.search;

  /// Ícones de status
  static const IconData statusSuccess = Icons.check_circle_outline;
  static const IconData statusWarning = Icons.warning_amber_outlined;
  static const IconData statusError = Icons.error_outline;
  static const IconData statusInfo = Icons.info_outline;

  /// Ícones de conteúdo
  static const IconData contentNotes = Icons.note_outlined;
  static const IconData contentActivity = Icons.fitness_center;
  static const IconData contentWeight = Icons.monitor_weight_outlined;
  static const IconData contentWater = Icons.water_drop_outlined;
  static const IconData contentPhoto = Icons.photo_camera_outlined;
}
