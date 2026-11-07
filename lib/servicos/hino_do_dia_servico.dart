import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../modelos/hino.dart';
import 'hinos_servico.dart';

class HinoDoDiaServico {
  static const String _chaveData = 'hino_do_dia_data';
  static const String _chaveNumero = 'hino_do_dia_numero';

  // ===========================================================
  // OBTER HINO DO DIA
  // ===========================================================

  static Future<Hino> obterHinoDoDia() async {
    final prefs = await SharedPreferences.getInstance();

    final String hoje = _dataAtual();

    final String? dataGuardada =
        prefs.getString(_chaveData);

    final int? numeroGuardado =
        prefs.getInt(_chaveNumero);

    final hinos =
        await HinosServico.carregarHinos();

    if (hinos.isEmpty) {
      throw Exception(
        'Nenhum hino encontrado no arquivo JSON.',
      );
    }

    // =========================================================
    // SE JÁ EXISTE HINO PARA O DIA ATUAL
    // =========================================================

    if (dataGuardada == hoje &&
        numeroGuardado != null) {
      try {
        return hinos.firstWhere(
          (hino) =>
              hino.numero == numeroGuardado,
        );
      } catch (_) {
        // Se o hino não existir mais no JSON,
        // será sorteado outro.
      }
    }

    // =========================================================
    // NOVO DIA DO HINO → SORTEAR
    // =========================================================

    final random = Random();

    final hino =
        hinos[random.nextInt(hinos.length)];

    // =========================================================
    // GUARDAR
    // =========================================================

    await prefs.setString(
      _chaveData,
      hoje,
    );

    await prefs.setInt(
      _chaveNumero,
      hino.numero,
    );

    return hino;
  }

  // ===========================================================
  // DATA LÓGICA DO HINO DO DIA
  //
  // O novo Hino do Dia começa às 06:01.
  //
  // Antes das 06:01, ainda pertence ao dia anterior.
  // A partir das 06:01, pertence ao novo dia.
  // ===========================================================

  static String _dataAtual() {
    final agora = DateTime.now();

    // Antes das 06:01, considerar que ainda estamos
    // no dia anterior para efeito do Hino do Dia.
    if (agora.hour < 6 ||
        (agora.hour == 6 && agora.minute == 0)) {
      final diaAnterior =
          agora.subtract(const Duration(days: 1));

      return _formatarData(diaAnterior);
    }

    return _formatarData(agora);
  }

  // ===========================================================
  // FORMATAR DATA
  // ===========================================================

  static String _formatarData(DateTime data) {
    final ano = data.year
        .toString()
        .padLeft(4, '0');

    final mes = data.month
        .toString()
        .padLeft(2, '0');

    final dia = data.day
        .toString()
        .padLeft(2, '0');

    return '$ano-$mes-$dia';
  }

  // ===========================================================
  // FORÇAR NOVO HINO
  //
  // Útil durante os testes.
  // ===========================================================

  static Future<Hino> sortearNovoHino() async {
    final prefs =
        await SharedPreferences.getInstance();

    final hinos =
        await HinosServico.carregarHinos();

    if (hinos.isEmpty) {
      throw Exception(
        'Nenhum hino encontrado.',
      );
    }

    final random = Random();

    final hino =
        hinos[random.nextInt(hinos.length)];

    await prefs.setString(
      _chaveData,
      _dataAtual(),
    );

    await prefs.setInt(
      _chaveNumero,
      hino.numero,
    );

    return hino;
  }
}