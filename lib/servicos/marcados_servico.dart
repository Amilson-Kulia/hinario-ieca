import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MarcadoItem {
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
  final int cor;

  const MarcadoItem({
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
    required this.cor,
  });

  // ============================================================
  // COR DA MARCAÇÃO
  // ============================================================

  Color get corData => Color(cor);

  // ============================================================
  // CHAVE ÚNICA
  // ============================================================

  String get chave => '${tipo.toLowerCase()}_$id';

  // ============================================================
  // NOME DA CATEGORIA
  // ============================================================

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

      case 'texto_liturgico':
      case 'texto litúrgico':
        return 'Textos Litúrgicos';

      default:
        return categoria.isNotEmpty ? categoria : 'Outros';
    }
  }

  // ============================================================
  // CONVERTER PARA MAP
  // ============================================================

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
      'cor': cor,
    };
  }

  // ============================================================
  // CRIAR A PARTIR DE MAP
  // ============================================================

  factory MarcadoItem.fromMap(Map<String, dynamic> map) {
    return MarcadoItem(
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
      cor: map['cor'] is int
          ? map['cor'] as int
          : int.tryParse(
                map['cor']?.toString() ?? '',
              ) ??
              Colors.grey.value,
    );
  }

  // ============================================================
  // COPY WITH
  // ============================================================

  MarcadoItem copyWith({
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
    int? cor,
  }) {
    return MarcadoItem(
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
      cor: cor ?? this.cor,
    );
  }
}

// ==================================================================
// SERVIÇO DE MARCAÇÕES
// ==================================================================

class MarcadosServico {
  MarcadosServico._();

  static final MarcadosServico instancia = MarcadosServico._();

  static const String _chave = 'ieca_marcados';

  List<MarcadoItem>? _cache;

  // ================================================================
  // CARREGAR MARCAÇÕES
  // ================================================================

  Future<List<MarcadoItem>> carregarMarcados() async {
    if (_cache != null) {
      return List<MarcadoItem>.from(_cache!);
    }

    final prefs = await SharedPreferences.getInstance();

    final dados = prefs.getStringList(_chave) ?? [];

    _cache = dados
        .map((item) {
          try {
            return MarcadoItem.fromMap(
              jsonDecode(item) as Map<String, dynamic>,
            );
          } catch (_) {
            return null;
          }
        })
        .whereType<MarcadoItem>()
        .toList();

    return List<MarcadoItem>.from(_cache!);
  }

  // ================================================================
  // SALVAR MARCAÇÕES
  // ================================================================

  Future<void> _salvar(List<MarcadoItem> marcados) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setStringList(
      _chave,
      marcados.map((item) => jsonEncode(item.toMap())).toList(),
    );

    _cache = List<MarcadoItem>.from(marcados);
  }

  // ================================================================
  // ADICIONAR OU ACTUALIZAR
  // ================================================================

  Future<bool> adicionarOuAtualizar(
    MarcadoItem marcado,
  ) async {
    final lista = await carregarMarcados();

    final indice = lista.indexWhere(
      (item) =>
          item.id == marcado.id &&
          item.tipo.toLowerCase() == marcado.tipo.toLowerCase(),
    );

    if (indice >= 0) {
      lista[indice] = marcado;
    } else {
      lista.add(marcado);
    }

    await _salvar(lista);

    return true;
  }

  // ================================================================
  // REMOVER UMA MARCAÇÃO
  // ================================================================

  Future<bool> remover({
    required String id,
    required String tipo,
  }) async {
    final lista = await carregarMarcados();

    lista.removeWhere(
      (item) =>
          item.id == id &&
          item.tipo.toLowerCase() == tipo.toLowerCase(),
    );

    await _salvar(lista);

    return true;
  }

  // ================================================================
  // VERIFICAR SE ESTÁ MARCADO
  // ================================================================

  Future<bool> eMarcado({
    required String id,
    required String tipo,
  }) async {
    final lista = await carregarMarcados();

    return lista.any(
      (item) =>
          item.id == id &&
          item.tipo.toLowerCase() == tipo.toLowerCase(),
    );
  }

  // ================================================================
  // OBTER UMA MARCAÇÃO
  // ================================================================

  Future<MarcadoItem?> obter({
    required String id,
    required String tipo,
  }) async {
    final lista = await carregarMarcados();

    try {
      return lista.firstWhere(
        (item) =>
            item.id == id &&
            item.tipo.toLowerCase() == tipo.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  // ================================================================
  // ALTERAR COR
  // ================================================================

  Future<bool> alterarCor({
    required String id,
    required String tipo,
    required Color cor,
  }) async {
    final lista = await carregarMarcados();

    final indice = lista.indexWhere(
      (item) =>
          item.id == id &&
          item.tipo.toLowerCase() == tipo.toLowerCase(),
    );

    if (indice < 0) {
      return false;
    }

    lista[indice] = lista[indice].copyWith(
      cor: cor.value,
    );

    await _salvar(lista);

    return true;
  }

  // ================================================================
  // REMOVER TODAS AS MARCAÇÕES
  // ================================================================

  Future<void> removerTodos() async {
    await _salvar([]);
  }

  // ================================================================
  // QUANTIDADE
  // ================================================================

  Future<int> quantidade() async {
    final lista = await carregarMarcados();

    return lista.length;
  }

  // ================================================================
  // LIMPAR CACHE
  // ================================================================

  void limparCache() {
    _cache = null;
  }
}