import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:front/src/app.dart';

import 'settings_service.dart';

/// A class that many Widgets can interact with to read user settings, update
/// user settings, or listen to user settings changes.
///
/// Controllers glue Data Services to Flutter Widgets. The SettingsController
/// uses the SettingsService to store and retrieve user settings.
class SettingsController with ChangeNotifier {
  SettingsController(this._settingsService);

  // Make SettingsService a private variable so it is not used directly.
  final SettingsService _settingsService;

  // Make ThemeMode a private variable so it is not updated directly without
  // also persisting the changes with the SettingsService.
  late ThemeMode _themeMode;
  late Locale _langage;

  // Allow Widgets to read the user's preferred ThemeMode.
  ThemeMode get themeMode => _themeMode;
  Locale get Language => _langage;

  /// Load the user's settings from the SettingsService. It may load from a
  /// local database or the internet. The controller only knows it can load the
  /// settings from the service.
  Future<void> loadSettings() async {
    _themeMode = await _settingsService.themeMode();

    // Important! Inform listeners a change has occurred.
    notifyListeners();
  }

  /// Update and persist the ThemeMode based on the user's selection.
  Future<void> updateThemeMode(ThemeMode? newThemeMode) async {
    if (newThemeMode == null) return;
    if (newThemeMode == _themeMode) return;

    _themeMode = newThemeMode;
    notifyListeners();
    await _settingsService.updateThemeMode(newThemeMode);
  }

  /// Update and persist the Language based on the user's selection.
  Future<void> updateLanguage(Locale? currentLanguage, context) async {
    if (currentLanguage == null) return;
    if (currentLanguage == _langage) return;

    if (currentLanguage == Locale('fr' 'FR')) {
      MyApp.of(context).changeLanguage(Locale('en' 'US'));
    } else if (currentLanguage == Locale('en' 'US')) {
      MyApp.of(context).changeLanguage(Locale('fr' 'FR'));
    }
  }
}
