import 'package:flutter/material.dart';

import '../telas/home/home_tela.dart';
import '../telas/splash/splash_tela.dart';

class Rotas {
  static const String splash = '/';
  static const String home = '/home';

  static Route<dynamic> gerarRota(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(
          builder: (_) => const SplashTela(),
        );

      case home:
        return MaterialPageRoute(
          builder: (_) => const HomeTela(),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const HomeTela(),
        );
    }
  }
}