import 'dart:convert';
import 'package:flutter/services.dart';

import '../modelos/hino.dart';

class HinoServico {
  static Future<List<Hino>> carregarHinos() async {
    final jsonString =
        await rootBundle.loadString(
          'assets/dados/hinos.json', 
        );

    final List dados =
        json.decode(jsonString);

    return dados
        .map((e) => Hino.fromJson(e))
        .toList();
  }
}