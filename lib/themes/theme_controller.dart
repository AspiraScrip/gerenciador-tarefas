import 'package:flutter/material.dart';

import '../services/preferences_service.dart';

/// Guarda o ThemeMode atual e persiste a escolha no SharedPreferences.
class ThemeController extends ChangeNotifier {
  final PreferencesService _prefs = PreferencesService();

  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;
  bool get escuro => _themeMode == ThemeMode.dark;

  Future<void> carregar() async {
    _themeMode = await _prefs.carregarTema();
    notifyListeners();
  }

  Future<void> definirEscuro(bool valor) async {
    _themeMode = valor ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    await _prefs.salvarTema(_themeMode);
  }
}

final ThemeController themeController = ThemeController();
