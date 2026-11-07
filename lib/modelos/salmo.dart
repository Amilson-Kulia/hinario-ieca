class Salmo {
  final int id;
  final String numero;
  final String texto;
  final List<BlocoSalmo> blocos;

  const Salmo({
    required this.id,
    required this.numero,
    required this.texto,
    this.blocos = const [],
  });

  /// Indica se este salmo tem blocos responsivos
  /// (dirigente + congregação alternados).
  bool get temBlocosResponsivos => blocos.isNotEmpty;

  factory Salmo.fromJson(Map<String, dynamic> json) {
    // =========================================================
    // ID
    // =========================================================

    final int id = int.tryParse(
          json['id']?.toString() ?? '',
        ) ??
        0;

    // =========================================================
    // NÚMERO
    // =========================================================

    final String numero = json['numero']?.toString() ?? '';

    // =========================================================
    // TEXTO (formato antigo — mantido por compatibilidade)
    // =========================================================

    final String texto = json['texto']?.toString() ?? '';

    // =========================================================
    // BLOCOS (novo formato responsivo)
    // =========================================================

    final List<BlocoSalmo> blocos = [];

    final dynamic blocosJson = json['blocos'];

    if (blocosJson is List) {
      for (final item in blocosJson) {
        if (item is Map<String, dynamic>) {
          blocos.add(BlocoSalmo.fromJson(item));
        }
      }
    }

    return Salmo(
      id: id,
      numero: numero,
      texto: texto,
      blocos: blocos,
    );
  }
}

// =============================================================
// BLOCO DE SALMO (dirigente ou congregação)
// =============================================================

class BlocoSalmo {
  final String papel; // 'dirigente' ou 'congregacao'
  final String texto;

  const BlocoSalmo({
    required this.papel,
    required this.texto,
  });

  bool get isDirigente => papel == 'dirigente';
  bool get isCongregacao => papel == 'congregacao';

  factory BlocoSalmo.fromJson(Map<String, dynamic> json) {
    return BlocoSalmo(
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