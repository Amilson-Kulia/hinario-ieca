class Invocatoria {
  final int id;
  final String numero;
  final String titulo;
  final String categoria;
  final String texto;

  const Invocatoria({
    required this.id,
    required this.numero,
    required this.titulo,
    required this.categoria,
    required this.texto,
  });

  factory Invocatoria.fromJson(
    Map<String, dynamic> json,
  ) {
    return Invocatoria(
      id: json['id'] as int,
      numero: json['numero'].toString(),
      titulo: json['titulo'] as String,
      categoria: json['categoria'] as String,
      texto: json['texto'] as String,
    );
  }
}