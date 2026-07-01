import 'package:flutter/material.dart';
import '../constants/preferences_keys.dart';
import '../utils/preferences_manager.dart';

/// Adapter at the persistence seam for all app config keys.
///
/// The controller (caller) never touches SharedPreferences directly.
/// Loads are batched via [loadAll]; saves are per-field so the reactive
/// `ever()` watchers in the controller can fire independently.
class ConfigPersistence {
  ConfigPersistence._();

  // -- Loaders ----------------------------------------------------------

  static bool loadShowAppBar() =>
      PreferencesManager.getBool(PreferencesKeys.showAppBar, defaultValue: true);

  static Color loadAppBarColor() =>
      Color(PreferencesManager.getInt(PreferencesKeys.appBarColor,
          defaultValue: const Color(0XFF007AFF).toARGB32()));

  static Color loadBodyColor() =>
      Color(PreferencesManager.getInt(PreferencesKeys.bodyColor,
          defaultValue: const Color(0XFFFFFFFF).toARGB32()));

  static String loadTitleText() =>
      PreferencesManager.getString(PreferencesKeys.titleText,
          defaultValue: '');

  static bool loadIsCountdownMode() =>
      PreferencesManager.getBool(PreferencesKeys.isCountdownMode,
          defaultValue: false);

  static int loadCountdownMinutes() =>
      PreferencesManager.getInt(PreferencesKeys.countdownMinutes,
          defaultValue: 1);

  static Color loadClockBackgroundColor() =>
      Color(PreferencesManager.getInt(PreferencesKeys.clockBackgroundColor,
          defaultValue: const Color(0XFFFFA500).toARGB32()));

  // -- Savers -----------------------------------------------------------

  static Future<void> saveShowAppBar(bool value) =>
      PreferencesManager.setBool(PreferencesKeys.showAppBar, value);

  static Future<void> saveAppBarColor(Color value) =>
      PreferencesManager.setInt(PreferencesKeys.appBarColor, value.toARGB32());

  static Future<void> saveBodyColor(Color value) =>
      PreferencesManager.setInt(PreferencesKeys.bodyColor, value.toARGB32());

  static Future<void> saveTitleText(String value) =>
      PreferencesManager.setString(PreferencesKeys.titleText, value);

  static Future<void> saveIsCountdownMode(bool value) =>
      PreferencesManager.setBool(PreferencesKeys.isCountdownMode, value);

  static Future<void> saveCountdownMinutes(int value) =>
      PreferencesManager.setInt(PreferencesKeys.countdownMinutes, value);

  static Future<void> saveClockBackgroundColor(Color value) =>
      PreferencesManager.setInt(PreferencesKeys.clockBackgroundColor,
          value.toARGB32());
}
