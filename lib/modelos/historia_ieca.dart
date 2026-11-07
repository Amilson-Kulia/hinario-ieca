import 'referencia_ieca.dart';

class HistoriaIeca {
  final String id;
  final String titulo;
  final String resumo;
  final String texto;
  final List<ReferenciaIeca> referencias;

  const HistoriaIeca({
    required this.id,
    required this.titulo,
    required this.resumo,
    required this.texto,
    required this.referencias,
  });

  factory HistoriaIeca.fromJson(Map<String, dynamic> json) {
    final referenciasJson =
        json['referencias'] as List<dynamic>? ?? [];

    return HistoriaIeca(
      id: json['id'] as String,
      titulo: json['titulo'] as String,
      resumo: json['resumo'] as String,
      texto: json['texto'] as String,
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