import 'package:shared_preferences/shared_preferences.dart';

class OnboardingServico {
  static const String _chave = 'onboarding_concluido';

  /// Retorna true se o onboarding ainda deve ser mostrado.
  static Future<bool> deveMostrar() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_chave) ?? false);
  }

  /// Marca o onboarding como concluído.
  static Future<void> marcarComoConcluido() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_chave, true);
  }

  /// Reinicia o onboarding (útil para "Ver tutorial novamente").
  static Future<void> reiniciar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_chave);
  }
}