class LecionarioMes {
  final String mes;
  final int ano;
  final String temaMensal;
  final String introducaoMensal;
  final String? observacao;
  final List<DataImportante> datasImportantes;
  final List<Semana> semanas;

  const LecionarioMes({
    required this.mes,
    required this.ano,
    required this.temaMensal,
    required this.introducaoMensal,
    this.observacao,
    required this.datasImportantes,
    required this.semanas,
  });

  factory LecionarioMes.fromJson(Map<String, dynamic> json) {
    return LecionarioMes(
      mes: json['mes']?.toString() ?? '',
      ano: _parseInt(json['ano'], 2026),
      temaMensal: json['tema_mensal']?.toString() ?? '',
      introducaoMensal: json['introducao_mensal']?.toString() ?? '',
      observacao: json['observacao']?.toString(),
      datasImportantes: _parseList(
        json['datas_importantes'],
        DataImportante.fromJson,
      ),
      semanas: _parseList(
        json['semanas'],
        Semana.fromJson,
      ),
    );
  }
}

class DataImportante {
  final String data;
  final String evento;

  const DataImportante({
    required this.data,
    required this.evento,
  });

  factory DataImportante.fromJson(Map<String, dynamic> json) {
    return DataImportante(
      data: json['data']?.toString() ?? '',
      evento: json['evento']?.toString() ?? '',
    );
  }
}

class Semana {
  final String periodo;
  final String temaSemanal;
  final String? eventoEspecial;
  final String? introducaoSemanal;
  final List<DiaLecionario> dias;

  const Semana({
    required this.periodo,
    required this.temaSemanal,
    this.eventoEspecial,
    this.introducaoSemanal,
    required this.dias,
  });

  factory Semana.fromJson(Map<String, dynamic> json) {
    return Semana(
      periodo: json['periodo']?.toString() ?? '',
      temaSemanal: json['tema_semanal']?.toString() ?? '',
      eventoEspecial: json['evento_especial']?.toString(),
      introducaoSemanal: json['introducao_semanal']?.toString(),
      dias: _parseList(
        json['dias'],
        DiaLecionario.fromJson,
      ),
    );
  }
}

class DiaLecionario {
  final String data;
  final String? evento;
  final String? textoBiblico;
  final List<String> textosBiblicos;
  final String? tema;
  final String? temaCentral;
  final String reflexao;
  final String? oracao;
  final List<PalavraCristo> palavras;
  final Liturgia? liturgia;

  const DiaLecionario({
    required this.data,
    this.evento,
    this.textoBiblico,
    required this.textosBiblicos,
    this.tema,
    this.temaCentral,
    required this.reflexao,
    this.oracao,
    required this.palavras,
    this.liturgia,
  });

  factory DiaLecionario.fromJson(Map<String, dynamic> json) {
    return DiaLecionario(
      data: json['data']?.toString() ?? '',
      evento: json['evento']?.toString(),
      textoBiblico: json['texto_biblico']?.toString(),
      textosBiblicos: _parseStringList(json['textos_biblicos']),
      tema: json['tema']?.toString(),
      temaCentral: json['tema_central']?.toString(),
      reflexao: json['reflexao']?.toString() ?? '',
      oracao: json['oracao']?.toString(),
      palavras: _parseList(
        json['palavras'],
        PalavraCristo.fromJson,
      ),
      liturgia: json['liturgia'] is Map
          ? Liturgia.fromJson(
              Map<String, dynamic>.from(json['liturgia']),
            )
          : null,
    );
  }

  bool get isDomingo {
    return liturgia != null || temaCentral != null;
  }

  bool get possuiPalavras {
    return palavras.isNotEmpty;
  }

  bool get possuiOracao {
    return oracao != null && oracao!.trim().isNotEmpty;
  }

  String get titulo {
    if (temaCentral != null && temaCentral!.trim().isNotEmpty) {
      return temaCentral!;
    }

    if (tema != null && tema!.trim().isNotEmpty) {
      return tema!;
    }

    if (evento != null && evento!.trim().isNotEmpty) {
      return evento!;
    }

    return 'Meditação Diária';
  }

  List<String> get referenciasBiblicas {
    final referencias = <String>[];

    if (textoBiblico != null && textoBiblico!.trim().isNotEmpty) {
      referencias.add(textoBiblico!);
    }

    referencias.addAll(
      textosBiblicos.where(
        (texto) => texto.trim().isNotEmpty,
      ),
    );

    return referencias;
  }
}

class PalavraCristo {
  final int ordem;
  final String texto;
  final String palavra;
  final String meditacao;

  const PalavraCristo({
    required this.ordem,
    required this.texto,
    required this.palavra,
    required this.meditacao,
  });

  factory PalavraCristo.fromJson(Map<String, dynamic> json) {
    return PalavraCristo(
      ordem: _parseInt(json['ordem'], 0),
      texto: json['texto']?.toString() ?? '',
      palavra: json['palavra']?.toString() ?? '',
      meditacao: json['meditacao']?.toString() ?? '',
    );
  }
}

class Liturgia {
  final List<String> hinos;
  final String? salmo;
  final List<String> leiturasBiblicas;

  const Liturgia({
    required this.hinos,
    this.salmo,
    required this.leiturasBiblicas,
  });

  factory Liturgia.fromJson(Map<String, dynamic> json) {
    return Liturgia(
      hinos: _parseStringList(json['hinos']),
      salmo: json['salmo']?.toString(),
      leiturasBiblicas: _parseStringList(
        json['leituras_biblicas'],
      ),
    );
  }

  bool get possuiSalmo {
    return salmo != null && salmo!.trim().isNotEmpty;
  }

  bool get possuiHinos => hinos.isNotEmpty;

  bool get possuiLeiturasBiblicas {
    return leiturasBiblicas.isNotEmpty;
  }
}

List<T> _parseList<T>(
  dynamic valor,
  T Function(Map<String, dynamic>) fromJson,
) {
  if (valor is! List) {
    return <T>[];
  }

  return valor
      .whereType<Map>()
      .map(
        (item) => fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
      .toList();
}

List<String> _parseStringList(dynamic valor) {
  if (valor is! List) {
    return <String>[];
  }

  return valor
      .map((item) => item.toString())
      .where((item) => item.trim().isNotEmpty)
      .toList();
}

int _parseInt(dynamic valor, int valorPadrao) {
  if (valor is int) {
    return valor;
  }

  if (valor is num) {
    return valor.toInt();
  }

  return int.tryParse(valor?.toString() ?? '') ?? valorPadrao;
}