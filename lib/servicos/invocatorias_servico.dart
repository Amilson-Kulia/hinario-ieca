import 'dart:convert';

import 'package:flutter/services.dart';

import '../modelos/invocatoria.dart';

class InvocatoriasServico {
  static Future<List<Invocatoria>> carregar({
    String idioma = 'portugues',
  }) async {
    final String caminho = idioma == 'umbundo'
        ? 'assets/dados/invocatorias_umbundo.json'
        : 'assets/dados/invocatorias.json';

    final String conteudo =
        await rootBundle.loadString(caminho);

    final List<dynamic> dados =
        jsonDecode(conteudo);

    return dados
        .map(
          (item) => Invocatoria.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }
}