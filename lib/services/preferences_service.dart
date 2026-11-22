import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService extends ChangeNotifier {
  SharedPreferences? _preferences;
  bool _escuro = false;
  bool get escuro => _escuro;
  ThemeMode get themeMode => _escuro ? ThemeMode.dark : ThemeMode.light;

  Future<void> carregar() async {
    _preferences = await SharedPreferences.getInstance();
    _escuro = _preferences!.getBool('temaEscuro') ?? false;
    notifyListeners();
  }

  Future<void> alterarTema(bool escuro) async {
    final salvo = await _preferences!.setBool('temaEscuro', escuro);
    if (!salvo) throw StateError('Não foi possível salvar o tema.');
    _escuro = escuro;
    notifyListeners();
  }
}
