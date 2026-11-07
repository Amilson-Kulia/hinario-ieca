import 'tipo_item_programa.dart';

class ItemPrograma {
  final String id;

  TipoItemPrograma tipo;

  String titulo;

  String subtitulo;

  /// Conteúdo completo do item.
  ///
  /// Para hinos, invocatórias, litanias e salmos,
  /// este campo guarda o texto que será usado no programa
  /// e posteriormente no PDF.
  String conteudo;

  /// Referência do item.
  ///
  /// Exemplos:
  /// Hino nº 25
  /// Salmo 100
  String referencia;

  bool fixo;

  ItemPrograma({
    required this.id,
    required this.tipo,
    required this.titulo,
    this.subtitulo = '',
    this.conteudo = '',
    this.referencia = '',
    this.fixo = false,
  });

  ItemPrograma copyWith({
    String? id,
    TipoItemPrograma? tipo,
    String? titulo,
    String? subtitulo,
    String? conteudo,
    String? referencia,
    bool? fixo,
  }) {
    return ItemPrograma(
      id: id ?? this.id,
      tipo: tipo ?? this.tipo,
      titulo: titulo ?? this.titulo,
      subtitulo: subtitulo ?? this.subtitulo,
      conteudo: conteudo ?? this.conteudo,
      referencia: referencia ?? this.referencia,
      fixo: fixo ?? this.fixo,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tipo': tipo.name,
      'titulo': titulo,
      'subtitulo': subtitulo,
      'conteudo': conteudo,
      'referencia': referencia,
      'fixo': fixo,
    };
  }

  factory ItemPrograma.fromMap(Map<String, dynamic> map) {
    return ItemPrograma(
      id: map['id']?.toString() ?? '',
      tipo: TipoItemPrograma.values.firstWhere(
        (e) => e.name == map['tipo'],
        orElse: () => TipoItemPrograma.personalizado,
      ),
      titulo: map['titulo']?.toString() ?? '',
      subtitulo: map['subtitulo']?.toString() ?? '',
      conteudo: map['conteudo']?.toString() ?? '',
      referencia: map['referencia']?.toString() ?? '',
      fixo: map['fixo'] == true,
    );
  }
}