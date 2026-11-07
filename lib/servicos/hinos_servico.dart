import 'dart:convert';

import 'package:flutter/services.dart';

import '../modelos/hino.dart';

class HinosServico {
  static Future<List<Hino>> carregarHinos({
    String idioma = 'portugues',
  }) async {
    final String caminho = idioma == 'umbundo'
        ? 'assets/dados/hinos_umbundo.json'
        : 'assets/dados/categorias_hinos.json';

    final String jsonString =
        await rootBundle.loadString(caminho);

    final List<dynamic> dados =
        json.decode(jsonString);

    return dados
        .map(
          (e) => Hino.fromJson(e),
        )
        .toList();
  }
}