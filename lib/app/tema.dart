import 'package:flutter/material.dart';

class TemaHinario {
  static const Color corSuperficie = Color(0xFFF8F9FF);
  static const Color corSuperficieBaixa = Color(0xFFEFF4FF);
  static const Color corSuperficieMedia = Color(0xFFE6EEFF);
  static const Color corSuperficieAlta = Color(0xFFDEE9FC);
  static const Color corSuperficieMaisAlta = Color(0xFFD9E3F6);

  static const Color corPrimaria = Color(0xFF9E0027);
  static const Color corPrimariaContainer = Color(0xFFC41E3A);
  static const Color corPrimariaClara = Color(0xFFFFDAD9);
  static const Color corContorno = Color(0xFFD9DEE8);

  static const Color corSecundaria = Color(0xFF855400);
  static const Color corSecundariaContainer = Color(0xFFFFA504);

  static const Color corTerciaria = Color(0xFF005754);
  static const Color corTerciariaContainer = Color(0xFF00716E);

  static const Color corTexto = Color(0xFF121C2A);
  static const Color corTextoSecundario = Color(0xFF5B4040);
  static const Color corBranca = Colors.white;

  static const Color corSuperficieContainer = Color(0xFFE6EEFF);

  static ThemeData tema() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: corSuperficie,

      colorScheme: ColorScheme.fromSeed(
        seedColor: corPrimaria,
        primary: corPrimaria,
        secondary: corSecundaria,
        surface: corSuperficie,
      ),

      textTheme: const TextTheme(
        bodyLarge: TextStyle(
          color: corTexto,
        ),
        bodyMedium: TextStyle(
          color: corTexto,
        ),
      ),
    );
  }
}