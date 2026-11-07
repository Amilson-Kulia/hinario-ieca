import 'package:flutter/material.dart';

class FavoritoItem {
  final String id;
  final String tipo;
  final String titulo;
  final String subtitulo;
  final String numero;
  final String referencia;
  final String categoria;
  final String idioma;
  final String texto;
  final DateTime data;
  final int icone;

  const FavoritoItem({
    required this.id,
    required this.tipo,
    required this.titulo,
    this.subtitulo = '',
    this.numero = '',
    this.referencia = '',
    this.categoria = '',
    this.idioma = 'Português',
    this.texto = '',
    required this.data,
    required this.icone,
  });

  String get nomeCategoria {
    switch (tipo.toLowerCase()) {
      case 'hino':
        return 'Hinos';

      case 'salmo':
        return 'Salmos';

      case 'litania':
        return 'Litanias';

      case 'doxologia':
        return 'Doxologias';

      case 'invocatoria':
      case 'invocatória':
        return 'Invocatórias';

      case 'credo':
        return 'Credo Apostólico';

      case 'oracao':
      case 'oração':
        return 'Oração do Senhor';

      case 'leitura':
        return 'Leituras';

      default:
        return categoria.isNotEmpty ? categoria : 'Outros';
    }
  }

  IconData get iconeData {
  switch (tipo.toLowerCase()) {
    case 'hino':
      return Icons.music_note_rounded;

    case 'salmo':
      return Icons.menu_book_rounded;

    case 'litania':
      return Icons.format_list_bulleted_rounded;

    case 'doxologia':
      return Icons.auto_awesome_rounded;

    case 'invocatoria':
    case 'invocatória':
      return Icons.wb_sunny_rounded;

    case 'credo':
      return Icons.church_rounded;

    case 'oracao':
    case 'oração':
      return Icons.volunteer_activism_rounded;

    case 'leitura':
      return Icons.menu_book_rounded;

    default:
      return Icons.description_rounded;
  }
}

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tipo': tipo,
      'titulo': titulo,
      'subtitulo': subtitulo,
      'numero': numero,
      'referencia': referencia,
      'categoria': categoria,
      'idioma': idioma,
      'texto': texto,
      'data': data.toIso8601String(),
      'icone': icone,
    };
  }

  factory FavoritoItem.fromMap(Map<String, dynamic> map) {
    return FavoritoItem(
      id: map['id']?.toString() ?? '',
      tipo: map['tipo']?.toString() ?? '',
      titulo: map['titulo']?.toString() ?? '',
      subtitulo: map['subtitulo']?.toString() ?? '',
      numero: map['numero']?.toString() ?? '',
      referencia: map['referencia']?.toString() ?? '',
      categoria: map['categoria']?.toString() ?? '',
      idioma: map['idioma']?.toString() ?? 'Português',
      texto: map['texto']?.toString() ?? '',
      data: DateTime.tryParse(
            map['data']?.toString() ?? '',
          ) ??
          DateTime.now(),
      icone: map['icone'] is int
          ? map['icone'] as int
          : Icons.menu_book_rounded.codePoint,
    );
  }

  FavoritoItem copyWith({
    String? id,
    String? tipo,
    String? titulo,
    String? subtitulo,
    String? numero,
    String? referencia,
    String? categoria,
    String? idioma,
    String? texto,
    DateTime? data,
    int? icone,
  }) {
    return FavoritoItem(
      id: id ?? this.id,
      tipo: tipo ?? this.tipo,
      titulo: titulo ?? this.titulo,
      subtitulo: subtitulo ?? this.subtitulo,
      numero: numero ?? this.numero,
      referencia: referencia ?? this.referencia,
      categoria: categoria ?? this.categoria,
      idioma: idioma ?? this.idioma,
      texto: texto ?? this.texto,
      data: data ?? this.data,
      icone: icone ?? this.icone,
    );
  }
}