class Litania {
  final String id;
  final String titulo;
  final String subtitulo;
  final String texto;
  final List<BlocoLitania> blocos;

  const Litania({
    required this.id,
    required this.titulo,
    required this.subtitulo,
    required this.texto,
    this.blocos = const [],
  });

  /// Indica se esta litania tem blocos responsivos
  /// (dirigente + congregação alternados).
  bool get temBlocosResponsivos => blocos.isNotEmpty;

  factory Litania.fromJson(Map<String, dynamic> json) {
    // =========================================================
    // ID
    // =========================================================

    final String id = json['id']?.toString() ?? '';

    // =========================================================
    // TÍTULO
    // =========================================================

    final String titulo = json['titulo']?.toString() ?? '';

    // =========================================================
    // SUBTÍTULO
    // =========================================================

    final String subtitulo = json['subtitulo']?.toString() ?? '';

    // =========================================================
    // TEXTO (formato antigo — mantido por compatibilidade)
    // =========================================================

    final String texto = json['texto']?.toString() ?? '';

    // =========================================================
    // BLOCOS (novo formato responsivo)
    // =========================================================

    final List<BlocoLitania> blocos = [];

    final dynamic blocosJson = json['blocos'];

    if (blocosJson is List) {
      for (final item in blocosJson) {
        if (item is Map<String, dynamic>) {
          blocos.add(BlocoLitania.fromJson(item));
        }
      }
    }

    return Litania(
      id: id,
      titulo: titulo,
      subtitulo: subtitulo,
      texto: texto,
      blocos: blocos,
    );
  }
}

// =============================================================
// BLOCO DE LITANIA (dirigente, congregação ou todos)
// =============================================================

class BlocoLitania {
  final String papel; // 'dirigente', 'congregacao' ou 'todos'
  final String texto;

  const BlocoLitania({
    required this.papel,
    required this.texto,
  });

  bool get isDirigente => papel == 'dirigente';
  bool get isCongregacao => papel == 'congregacao';
  bool get isTodos => papel == 'todos';

  factory BlocoLitania.fromJson(Map<String, dynamic> json) {
    return BlocoLitania(
      papel: json['papel']?.toString() ?? 'dirigente',
      texto: json['texto']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'papel': papel,
      'texto': texto,
    };
  }
}