import 'referencia_ieca.dart';

class MissaoIeca {
  final String id;
  final String tipo;
  final String titulo;
  final String? nomeAlternativo;
  final String localizacao;
  final int? anoFundacao;
  final String? dataFundacao;
  final String resumo;
  final String texto;
  final String curiosidade;
  final String? imagem;
  final List<ReferenciaIeca> referencias;

  const MissaoIeca({ 
    required this.id,
    required this.tipo,
    required this.titulo,
    required this.nomeAlternativo,
    required this.localizacao,
    required this.anoFundacao,
    required this.dataFundacao,
    required this.resumo,
    required this.texto,
    required this.curiosidade,
    required this.imagem,
    required this.referencias,
  });

  factory MissaoIeca.fromJson(Map<String, dynamic> json) {
    final referenciasJson =
        json['referencias'] as List<dynamic>? ?? [];

    return MissaoIeca(
      id: json['id'] as String,
      tipo: json['tipo'] as String,
      titulo: json['titulo'] as String,
      nomeAlternativo: json['nomeAlternativo'] as String?,
      localizacao: json['localizacao'] as String,
      anoFundacao: json['anoFundacao'] as int?,
      dataFundacao: json['dataFundacao'] as String?,
      resumo: json['resumo'] as String,
      texto: json['texto'] as String,
      curiosidade: json['curiosidade'] as String,
      imagem: json['imagem'] as String?,
      referencias: referenciasJson
          .map(
            (item) => ReferenciaIeca.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }
}