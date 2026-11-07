import 'dart:convert';

import 'package:flutter/services.dart';

import '../modelos/litania.dart';

class LitaniasServico {
  static Future<List<Litania>> carregarLitanias({
    String idioma = 'portugues',
  }) async {
    final String caminho = idioma == 'umbundo'
        ? 'assets/dados/litanias_umbundo.json'
        : 'assets/dados/litanias.json';

    final String jsonString =
        await rootBundle.loadString(caminho);

    final List<dynamic> dados =
        json.decode(jsonString);

    return dados
        .map(
          (e) => Litania.fromJson(
            e as Map<String, dynamic>,
          ),
        )
        .toList();
  }
}