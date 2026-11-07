import 'dart:convert';

import 'package:flutter/services.dart';

import '../modelos/lecionario_modelo.dart';
 
class LecionarioServico {
  LecionarioServico._();

  static final LecionarioServico instancia = LecionarioServico._();

  final Map<int, LecionarioMes> _meses = {};

  bool _inicializado = false;

  static const Map<int, String> _arquivosMeses = {
    1: 'assets/dados/lecionario/janeiro.json',
    2: 'assets/dados/lecionario/fevereiro.json',
    3: 'assets/dados/lecionario/marco.json',
    4: 'assets/dados/lecionario/abril.json',
    5: 'assets/dados/lecionario/maio.json',
    6: 'assets/dados/lecionario/junho.json',
    7: 'assets/dados/lecionario/julho.json',
    8: 'assets/dados/lecionario/agosto.json',
    9: 'assets/dados/lecionario/setembro.json',
    10: 'assets/dados/lecionario/outubro.json',
    11: 'assets/dados/lecionario/novembro.json',
    12: 'assets/dados/lecionario/dezembro.json',
  };

  /// Carrega todos os meses do Lecionário.
  Future<void> inicializar() async {
    if (_inicializado) {
      return;
    }

    for (final entrada in _arquivosMeses.entries) {
      try {
        final conteudo = await rootBundle.loadString(entrada.value);

        final json = jsonDecode(conteudo);

        if (json is! Map) {
          continue;
        }

        final mes = LecionarioMes.fromJson(
          Map<String, dynamic>.from(json),
        );

        _meses[entrada.key] = mes;
      } catch (e) {
        // Um mês com problema não impede os restantes de serem carregados.
        // O erro poderá ser tratado posteriormente através de logs.
        continue;
      }
    }

    _inicializado = true;
  }

  /// Retorna um mês pelo número.
  Future<LecionarioMes?> obterMes(int numeroMes) async {
    await inicializar();

    return _meses[numeroMes];
  }

  /// Retorna todos os meses carregados.
  Future<List<LecionarioMes>> obterTodosMeses() async {
    await inicializar();

    final meses = _meses.values.toList();

    meses.sort((a, b) {
      return _numeroDoMes(a.mes).compareTo(
        _numeroDoMes(b.mes),
      );
    });

    return meses;
  }

  /// Retorna uma semana específica de um mês.
  Future<Semana?> obterSemana(
    int numeroMes,
    int indiceSemana,
  ) async {
    final mes = await obterMes(numeroMes);

    if (mes == null) {
      return null;
    }

    if (indiceSemana < 0 || indiceSemana >= mes.semanas.length) {
      return null;
    }

    return mes.semanas[indiceSemana];
  }

  /// Retorna um dia específico pelo índice.
  Future<DiaLecionario?> obterDia(
    int numeroMes,
    int indiceSemana,
    int indiceDia,
  ) async {
    final semana = await obterSemana(
      numeroMes,
      indiceSemana,
    );

    if (semana == null) {
      return null;
    }

    if (indiceDia < 0 || indiceDia >= semana.dias.length) {
      return null;
    }

    return semana.dias[indiceDia];
  }

  /// Procura um dia pelo texto da data.
  ///
  /// Exemplo:
  /// "Domingo, 19 de Abril de 2026"
  Future<DiaLecionario?> procurarDiaPorData(
    String data,
  ) async {
    await inicializar();

    final dataNormalizada = data.trim().toLowerCase();

    for (final mes in _meses.values) {
      for (final semana in mes.semanas) {
        for (final dia in semana.dias) {
          if (dia.data.trim().toLowerCase() == dataNormalizada) {
            return dia;
          }
        }
      }
    }

    return null;
  }

  /// Procura todos os dias que possuem um determinado evento.
  Future<List<DiaLecionario>> procurarPorEvento(
    String evento,
  ) async {
    await inicializar();

    final resultado = <DiaLecionario>[];
    final termo = evento.trim().toLowerCase();

    for (final mes in _meses.values) {
      for (final semana in mes.semanas) {
        for (final dia in semana.dias) {
          if ((dia.evento ?? '').toLowerCase().contains(termo)) {
            resultado.add(dia);
          }
        }
      }
    }

    return resultado;
  }

  /// Retorna o mês atual com base no número do mês.
  Future<LecionarioMes?> obterMesAtual() async {
    final agora = DateTime.now();

    return obterMes(agora.month);
  }

  /// Retorna o dia correspondente à data atual.
  ///
  /// A comparação é feita pela data textual existente no JSON.
  /// Para uma procura realmente automática pela data, futuramente
  /// podemos adicionar um parser das datas portuguesas.
  Future<DiaLecionario?> obterDiaAtual() async {
    await inicializar();

    final agora = DateTime.now();

    final mes = _meses[agora.month];

    if (mes == null) {
      return null;
    }

    for (final semana in mes.semanas) {
      for (final dia in semana.dias) {
        final data = _extrairData(dia.data);

        if (data != null &&
            data.year == agora.year &&
            data.month == agora.month &&
            data.day == agora.day) {
          return dia;
        }
      }
    }

    return null;
  }

  /// Procura um mês pelo nome.
  Future<LecionarioMes?> procurarMesPorNome(
    String nome,
  ) async {
    await inicializar();

    final nomeNormalizado = nome.trim().toLowerCase();

    for (final mes in _meses.values) {
      if (mes.mes.trim().toLowerCase() == nomeNormalizado) {
        return mes;
      }
    }

    return null;
  }

  /// Limpa o cache para permitir recarregar os JSONs.
  void limparCache() {
    _meses.clear();
    _inicializado = false;
  }

  int _numeroDoMes(String nome) {
    const meses = {
      'janeiro': 1,
      'fevereiro': 2,
      'março': 3,
      'marco': 3,
      'abril': 4,
      'maio': 5,
      'junho': 6,
      'julho': 7,
      'agosto': 8,
      'setembro': 9,
      'outubro': 10,
      'novembro': 11,
      'dezembro': 12,
    };

    return meses[nome.trim().toLowerCase()] ?? 99;
  }

  DateTime? _extrairData(String texto) {
    final regex = RegExp(
      r'(\d{1,2}) de ([A-Za-zÀ-ÿ]+) de (\d{4})',
      caseSensitive: false,
    );

    final resultado = regex.firstMatch(texto);

    if (resultado == null) {
      return null;
    }

    final dia = int.tryParse(resultado.group(1)!);
    final nomeMes = resultado.group(2)!.toLowerCase();
    final ano = int.tryParse(resultado.group(3)!);

    if (dia == null || ano == null) {
      return null;
    }

    final numeroMes = _numeroDoMes(nomeMes);

    if (numeroMes == 99) {
      return null;
    }

    return DateTime(
      ano,
      numeroMes,
      dia,
    );
  }
}