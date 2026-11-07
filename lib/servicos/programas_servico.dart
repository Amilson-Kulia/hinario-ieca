import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../modelos/programa_culto.dart';

class ProgramasServico {
  static const String _chave = 'programas_culto';

  Future<List<ProgramaCulto>> listarProgramas() async {
    final prefs = await SharedPreferences.getInstance();

    final dados = prefs.getString(_chave);

    if (dados == null || dados.isEmpty) {
      return [];
    }

    try {
      final lista = jsonDecode(dados);

      if (lista is! List) {
        return [];
      }

      return lista
          .whereType<Map>()
          .map(
            (item) => ProgramaCulto.fromMap(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> guardarPrograma(ProgramaCulto programa) async {
    final prefs = await SharedPreferences.getInstance();

    final programas = await listarProgramas();

    final indice = programas.indexWhere(
      (p) => p.id == programa.id,
    );

    if (indice >= 0) {
      programas[indice] = programa;
    } else {
      programas.add(programa);
    }

    await prefs.setString(
      _chave,
      jsonEncode(
        programas.map((p) => p.toMap()).toList(),
      ),
    );
  }

  Future<void> eliminarPrograma(String id) async {
    final prefs = await SharedPreferences.getInstance();

    final programas = await listarProgramas();

    programas.removeWhere(
      (programa) => programa.id == id,
    );

    await prefs.setString(
      _chave,
      jsonEncode(
        programas.map((p) => p.toMap()).toList(),
      ),
    );
  }

  Future<ProgramaCulto?> obterPrograma(String id) async {
    final programas = await listarProgramas();

    try {
      return programas.firstWhere(
        (programa) => programa.id == id,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> limparProgramas() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_chave);
  }
}