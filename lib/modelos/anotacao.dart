class Anotacao {
  final int? id;
  final String livroId;
  final String livroNome;
  final int capitulo;
  final String versiculoReferencia;
  final String textoVersiculo;
  final String textoNota;
  final DateTime dataCriacao;

  Anotacao({
    this.id,
    required this.livroId,
    required this.livroNome,
    required this.capitulo,
    required this.versiculoReferencia,
    required this.textoVersiculo,
    required this.textoNota,
    required this.dataCriacao,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'livroId': livroId,
      'livroNome': livroNome,
      'capitulo': capitulo,
      'versiculoReferencia': versiculoReferencia,
      'textoVersiculo': textoVersiculo,
      'textoNota': textoNota,
      'dataCriacao': dataCriacao.toIso8601String(),
    };
  }

  factory Anotacao.fromMap(Map<String, dynamic> map) {
    return Anotacao(
      id: map['id'],
      livroId: map['livroId'],
      livroNome: map['livroNome'],
      capitulo: map['capitulo'],
      versiculoReferencia: map['versiculoReferencia'],
      textoVersiculo: map['textoVersiculo'],
      textoNota: map['textoNota'],
      dataCriacao: DateTime.parse(map['dataCriacao']),
    );
  }
}