import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ===============================================================
/// TIPOS DE CONSTÂNCIA
/// ===============================================================
enum TipoConstancia {
  geral,
  biblia,
  hinario,
  lecionario,
}

/// ===============================================================
/// RESULTADO DA CONSTÂNCIA
/// ===============================================================
class ResultadoConstancia {
  final TipoConstancia tipo;
  final DateTime data;
  final int sequenciaAtual;
  final int maiorSequencia;
  final int totalDias;
  final int? marcoParaReconhecer;

  const ResultadoConstancia({
    required this.tipo,
    required this.data,
    required this.sequenciaAtual,
    required this.maiorSequencia,
    required this.totalDias,
    this.marcoParaReconhecer,
  });

  bool get possuiMarcoParaReconhecer => marcoParaReconhecer != null;
}

/// ===============================================================
/// SERVIÇO DE CONSTÂNCIA DO HINÁRIO IECA
/// ===============================================================
class ConstanciaServico {
  static final ConstanciaServico instancia = ConstanciaServico._interno();

  ConstanciaServico._interno();

  // =============================================================
  // MARCOS
  // =============================================================
  static const List<int> marcos = <int>[
    3,
    7,
    14,
    21,
    30,
    60,
    90,
    180,
    365,
  ];

  // =============================================================
  // TOLERÂNCIA DE FALHA
  // =============================================================
  //
  // Se o utilizador falhar até 6 dias consecutivos, mantém a
  // sequência (continua de onde parou).
  //
  // Se falhar 7 dias consecutivos ou mais, reinicia a 1.
  //
  static const int diasMaximosDeFalha = 6;

  // =============================================================
  // PREFIXOS DAS CHAVES
  // =============================================================
  static const String _prefixoGeral = 'constancia_geral';
  static const String _prefixoBiblia = 'constancia_biblia';
  static const String _prefixoHinario = 'constancia_hinario';
  static const String _prefixoLecionario = 'constancia_lecionario';

  // =============================================================
  // SUFIXOS
  // =============================================================
  static const String _ultimoDia = 'ultimo_dia';
  static const String _sequenciaAtual = 'sequencia_atual';
  static const String _maiorSequencia = 'maior_sequencia';
  static const String _totalDias = 'total_dias';
  static const String _marcosPendentes = 'marcos_pendentes';

  // =============================================================
  // REGISTRAR UTILIZAÇÃO
  // =============================================================
  Future<ResultadoConstancia> registrarUso(
    TipoConstancia tipo,
  ) async {
    final SharedPreferences preferencias =
        await SharedPreferences.getInstance();

    final DateTime hoje = _normalizarData(DateTime.now());

    final String prefixo = _obterPrefixo(tipo);

    final DateTime? ultimoDia = _obterData(
      preferencias.getString('$prefixo$_ultimoDia'),
    );

    int sequenciaAtual =
        preferencias.getInt('$prefixo$_sequenciaAtual') ?? 0;

    int maiorSequencia =
        preferencias.getInt('$prefixo$_maiorSequencia') ?? 0;

    int totalDias = preferencias.getInt('$prefixo$_totalDias') ?? 0;

    final List<int> marcosPendentes =
        _obterMarcosPendentes(preferencias, prefixo);

    // Já foi utilizado hoje?
    if (ultimoDia != null && _mesmoDia(ultimoDia, hoje)) {
      return ResultadoConstancia(
        tipo: tipo,
        data: hoje,
        sequenciaAtual: sequenciaAtual,
        maiorSequencia: maiorSequencia,
        totalDias: totalDias,
        marcoParaReconhecer: marcosPendentes.isNotEmpty
            ? marcosPendentes.first
            : null,
      );
    }

    // Calcular nova sequência
    //
    // Regra:
    // - primeiro uso: 1
    // - dia consecutivo: +1
    // - falhou 1 a 6 dias: continua de onde parou (soma 1)
    // - falhou 7 dias ou mais: reinicia a 1
    //
    if (ultimoDia == null) {
      sequenciaAtual = 1;
    } else {
      final int diferenca = hoje.difference(ultimoDia).inDays;

      if (diferenca == 1) {
        // Dia consecutivo
        sequenciaAtual++;
      } else if (diferenca <= diasMaximosDeFalha + 1) {
        // Falhou até 6 dias: continua de onde parou
        sequenciaAtual++;
      } else {
        // Falhou 7 dias ou mais: reinicia
        sequenciaAtual = 1;
      }
    }

    if (sequenciaAtual > maiorSequencia) {
      maiorSequencia = sequenciaAtual;
    }

    totalDias++;

    if (marcos.contains(sequenciaAtual)) {
      final bool jaExiste = marcosPendentes.contains(sequenciaAtual);
      if (!jaExiste) {
        marcosPendentes.add(sequenciaAtual);
        marcosPendentes.sort();
      }
    }

    await preferencias.setString(
      '$prefixo$_ultimoDia',
      _dataParaString(hoje),
    );
    await preferencias.setInt(
      '$prefixo$_sequenciaAtual',
      sequenciaAtual,
    );
    await preferencias.setInt(
      '$prefixo$_maiorSequencia',
      maiorSequencia,
    );
    await preferencias.setInt(
      '$prefixo$_totalDias',
      totalDias,
    );
    await _guardarMarcosPendentes(
      preferencias,
      prefixo,
      marcosPendentes,
    );

    debugPrint(
      'Constância ${_nomeTipo(tipo)} atualizada: '
      '$sequenciaAtual dias consecutivos.',
    );

    return ResultadoConstancia(
      tipo: tipo,
      data: hoje,
      sequenciaAtual: sequenciaAtual,
      maiorSequencia: maiorSequencia,
      totalDias: totalDias,
      marcoParaReconhecer:
          marcosPendentes.isNotEmpty ? marcosPendentes.first : null,
    );
  }

  // =============================================================
  // MÉTODOS DE CONVENIÊNCIA
  // =============================================================
  Future<ResultadoConstancia> registrarUsoGeral() {
    return registrarUso(TipoConstancia.geral);
  }

  Future<ResultadoConstancia> registrarUsoBiblia() {
    return registrarUso(TipoConstancia.biblia);
  }

  Future<ResultadoConstancia> registrarUsoHinario() {
    return registrarUso(TipoConstancia.hinario);
  }

  Future<ResultadoConstancia> registrarUsoLecionario() {
    return registrarUso(TipoConstancia.lecionario);
  }

  // =============================================================
  // OBTER ESTADO ATUAL
  // =============================================================
  Future<ResultadoConstancia> obterEstado(
    TipoConstancia tipo,
  ) async {
    final SharedPreferences preferencias =
        await SharedPreferences.getInstance();

    final String prefixo = _obterPrefixo(tipo);
    final DateTime data = _normalizarData(DateTime.now());

    final List<int> marcosPendentes =
        _obterMarcosPendentes(preferencias, prefixo);

    return ResultadoConstancia(
      tipo: tipo,
      data: data,
      sequenciaAtual:
          preferencias.getInt('$prefixo$_sequenciaAtual') ?? 0,
      maiorSequencia:
          preferencias.getInt('$prefixo$_maiorSequencia') ?? 0,
      totalDias: preferencias.getInt('$prefixo$_totalDias') ?? 0,
      marcoParaReconhecer:
          marcosPendentes.isNotEmpty ? marcosPendentes.first : null,
    );
  }

  // =============================================================
  // OBTER SEQUÊNCIA ATUAL
  // =============================================================
  Future<int> obterSequenciaAtual(TipoConstancia tipo) async {
    final ResultadoConstancia resultado = await obterEstado(tipo);
    return resultado.sequenciaAtual;
  }

  // =============================================================
  // OBTER MAIOR SEQUÊNCIA
  // =============================================================
  Future<int> obterMaiorSequencia(TipoConstancia tipo) async {
    final ResultadoConstancia resultado = await obterEstado(tipo);
    return resultado.maiorSequencia;
  }

  // =============================================================
  // OBTER TOTAL DE DIAS
  // =============================================================
  Future<int> obterTotalDias(TipoConstancia tipo) async {
    final ResultadoConstancia resultado = await obterEstado(tipo);
    return resultado.totalDias;
  }

  // =============================================================
  // OBTER ÚLTIMO DIA DE UTILIZAÇÃO
  // =============================================================
  Future<DateTime?> obterUltimoDia(TipoConstancia tipo) async {
    final SharedPreferences preferencias =
        await SharedPreferences.getInstance();

    final String prefixo = _obterPrefixo(tipo);

    return _obterData(preferencias.getString('$prefixo$_ultimoDia'));
  }

  // =============================================================
  // OBTER PRÓXIMO MARCO
  // =============================================================
  Future<int?> obterProximoMarco(TipoConstancia tipo) async {
    final int sequencia = await obterSequenciaAtual(tipo);
    for (final int marco in marcos) {
      if (marco > sequencia) return marco;
    }
    return null;
  }

  // =============================================================
  // DIAS ATÉ O PRÓXIMO MARCO
  // =============================================================
  Future<int?> obterDiasAteProximoMarco(TipoConstancia tipo) async {
    final int? proximo = await obterProximoMarco(tipo);
    if (proximo == null) return null;

    final int atual = await obterSequenciaAtual(tipo);
    return proximo - atual;
  }

  // =============================================================
  // MARCOS ALCANÇADOS
  // =============================================================
  Future<List<int>> obterMarcosAlcancados(TipoConstancia tipo) async {
    final int maiorSequencia = await obterMaiorSequencia(tipo);
    return marcos
        .where((int marco) => marco <= maiorSequencia)
        .toList();
  }

  // =============================================================
  // MARCOS PENDENTES
  // =============================================================
  Future<List<int>> obterMarcosPendentes(TipoConstancia tipo) async {
    final SharedPreferences preferencias =
        await SharedPreferences.getInstance();

    final String prefixo = _obterPrefixo(tipo);

    return _obterMarcosPendentes(preferencias, prefixo);
  }

  Future<int?> obterMarcoPendente(TipoConstancia tipo) async {
    final List<int> pendentes = await obterMarcosPendentes(tipo);
    if (pendentes.isEmpty) return null;
    return pendentes.first;
  }

  // =============================================================
  // RECONHECER MARCO
  // =============================================================
  Future<int?> reconhecerProximoMarco(TipoConstancia tipo) async {
    final SharedPreferences preferencias =
        await SharedPreferences.getInstance();

    final String prefixo = _obterPrefixo(tipo);

    final List<int> marcosPendentes =
        _obterMarcosPendentes(preferencias, prefixo);

    if (marcosPendentes.isEmpty) return null;

    final int marco = marcosPendentes.removeAt(0);

    await _guardarMarcosPendentes(
      preferencias,
      prefixo,
      marcosPendentes,
    );

    debugPrint(
      'Marco de constância reconhecido: '
      '${_nomeTipo(tipo)} - $marco dias.',
    );

    return marco;
  }

  // =============================================================
  // LIMPAR CONSTÂNCIA
  // =============================================================
  Future<void> limpar(TipoConstancia tipo) async {
    final SharedPreferences preferencias =
        await SharedPreferences.getInstance();

    final String prefixo = _obterPrefixo(tipo);

    await preferencias.remove('$prefixo$_ultimoDia');
    await preferencias.remove('$prefixo$_sequenciaAtual');
    await preferencias.remove('$prefixo$_maiorSequencia');
    await preferencias.remove('$prefixo$_totalDias');
    await preferencias.remove('$prefixo$_marcosPendentes');

    debugPrint('Constância ${_nomeTipo(tipo)} limpa.');
  }

  // =============================================================
  // LIMPAR TODAS
  // =============================================================
  Future<void> limparTodas() async {
    await limpar(TipoConstancia.geral);
    await limpar(TipoConstancia.biblia);
    await limpar(TipoConstancia.hinario);
    await limpar(TipoConstancia.lecionario);
  }

  // =============================================================
  // PREFIXO
  // =============================================================
  String _obterPrefixo(TipoConstancia tipo) {
    switch (tipo) {
      case TipoConstancia.geral:
        return _prefixoGeral;
      case TipoConstancia.biblia:
        return _prefixoBiblia;
      case TipoConstancia.hinario:
        return _prefixoHinario;
      case TipoConstancia.lecionario:
        return _prefixoLecionario;
    }
  }

  // =============================================================
  // NOME DO TIPO
  // =============================================================
  String _nomeTipo(TipoConstancia tipo) {
    switch (tipo) {
      case TipoConstancia.geral:
        return 'geral';
      case TipoConstancia.biblia:
        return 'Bíblia';
      case TipoConstancia.hinario:
        return 'Hinário';
      case TipoConstancia.lecionario:
        return 'Lecionário';
    }
  }

  // =============================================================
  // NORMALIZAR DATA
  // =============================================================
  DateTime _normalizarData(DateTime data) {
    return DateTime(data.year, data.month, data.day);
  }

  // =============================================================
  // DATA PARA STRING
  // =============================================================
  String _dataParaString(DateTime data) {
    final String ano = data.year.toString().padLeft(4, '0');
    final String mes = data.month.toString().padLeft(2, '0');
    final String dia = data.day.toString().padLeft(2, '0');
    return '$ano-$mes-$dia';
  }

  // =============================================================
  // STRING PARA DATA
  // =============================================================
  DateTime? _obterData(String? valor) {
    if (valor == null || valor.isEmpty) return null;
    try {
      return DateTime.parse(valor);
    } catch (_) {
      return null;
    }
  }

  // =============================================================
  // COMPARAR DIAS
  // =============================================================
  bool _mesmoDia(DateTime primeiro, DateTime segundo) {
    return primeiro.year == segundo.year &&
        primeiro.month == segundo.month &&
        primeiro.day == segundo.day;
  }

  // =============================================================
  // OBTER MARCOS PENDENTES
  // =============================================================
  List<int> _obterMarcosPendentes(
    SharedPreferences preferencias,
    String prefixo,
  ) {
    final List<String> valores =
        preferencias.getStringList('$prefixo$_marcosPendentes') ??
            <String>[];

    return valores
        .map((String valor) => int.tryParse(valor))
        .whereType<int>()
        .toList();
  }

  // =============================================================
  // GUARDAR MARCOS PENDENTES
  // =============================================================
  Future<void> _guardarMarcosPendentes(
    SharedPreferences preferencias,
    String prefixo,
    List<int> marcosPendentes,
  ) async {
    await preferencias.setStringList(
      '$prefixo$_marcosPendentes',
      marcosPendentes.map((int marco) => marco.toString()).toList(),
    );
  }
}