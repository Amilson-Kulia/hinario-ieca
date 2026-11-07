import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../modelos/favorito.dart';
import '../modelos/hino.dart';
import '../modelos/invocatoria.dart';
import '../modelos/litania.dart';
import '../modelos/salmo.dart';
import '../modelos/texto_liturgico.dart';

class FavoritosServico {
  FavoritosServico._();

  static final FavoritosServico instancia = FavoritosServico._();

  static const String _chaveFavoritos = 'ieca_favoritos';

  List<FavoritoItem>? _cache;

  // ============================================================
  // CARREGAR
  // ============================================================

  Future<List<FavoritoItem>> carregarFavoritos() async {
    if (_cache != null) {
      return List<FavoritoItem>.from(_cache!);
    }

    final prefs = await SharedPreferences.getInstance();

    final lista = prefs.getStringList(_chaveFavoritos) ?? [];

    final favoritos = <FavoritoItem>[];

    for (final item in lista) {
      try {
        final mapa = jsonDecode(item);

        if (mapa is Map<String, dynamic>) {
          favoritos.add(
            FavoritoItem.fromMap(mapa),
          );
        }
      } catch (_) {
        // Ignora favoritos corrompidos.
      }
    }

    _cache = favoritos;

    return List<FavoritoItem>.from(favoritos);
  }

  // ============================================================
  // SALVAR
  // ============================================================

  Future<void> _salvar(
    List<FavoritoItem> favoritos,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    final lista = favoritos
        .map(
          (favorito) => jsonEncode(
            favorito.toMap(),
          ),
        )
        .toList();

    await prefs.setStringList(
      _chaveFavoritos,
      lista,
    );

    _cache = List<FavoritoItem>.from(favoritos);
  }

  // ============================================================
  // VERIFICAR
  // ============================================================

  Future<bool> eFavorito({
    required String id,
    required String tipo,
  }) async {
    final favoritos = await carregarFavoritos();

    return favoritos.any(
      (favorito) =>
          favorito.id == id &&
          favorito.tipo.toLowerCase() == tipo.toLowerCase(),
    );
  }

  // ============================================================
  // ADICIONAR
  // ============================================================

  Future<bool> adicionarFavorito(
    FavoritoItem favorito,
  ) async {
    final favoritos = await carregarFavoritos();

    final existe = favoritos.any(
      (item) =>
          item.id == favorito.id &&
          item.tipo.toLowerCase() == favorito.tipo.toLowerCase(),
    );

    if (existe) {
      return false;
    }

    final novoFavorito = favorito.copyWith(
      data: DateTime.now(),
    );

    favoritos.insert(
      0,
      novoFavorito,
    );

    await _salvar(favoritos);

    return true;
  }

  // ============================================================
  // REMOVER
  // ============================================================

  Future<bool> removerFavorito({
    required String id,
    required String tipo,
  }) async {
    final favoritos = await carregarFavoritos();

    final quantidadeAntes = favoritos.length;

    favoritos.removeWhere(
      (favorito) =>
          favorito.id == id &&
          favorito.tipo.toLowerCase() == tipo.toLowerCase(),
    );

    if (favoritos.length == quantidadeAntes) {
      return false;
    }

    await _salvar(favoritos);

    return true;
  }

  // ============================================================
  // ALTERNAR
  // ============================================================

  Future<bool> alternarFavorito(
    FavoritoItem favorito,
  ) async {
    final existe = await eFavorito(
      id: favorito.id,
      tipo: favorito.tipo,
    );

    if (existe) {
      await removerFavorito(
        id: favorito.id,
        tipo: favorito.tipo,
      );

      return false;
    }

    await adicionarFavorito(favorito);

    return true;
  }

  // ============================================================
  // REMOVER TODOS
  // ============================================================

  Future<void> removerTodos() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(
      _chaveFavoritos,
    );

    _cache = [];
  }

  // ============================================================
  // QUANTIDADE
  // ============================================================

  Future<int> quantidade() async {
    final favoritos = await carregarFavoritos();

    return favoritos.length;
  }

  // ============================================================
  // PESQUISAR
  // ============================================================

  Future<List<FavoritoItem>> pesquisar(
    String termo,
  ) async {
    final favoritos = await carregarFavoritos();

    final busca = termo.trim().toLowerCase();

    if (busca.isEmpty) {
      return favoritos;
    }

    return favoritos.where(
      (favorito) {
        final campos = [
          favorito.id,
          favorito.tipo,
          favorito.titulo,
          favorito.subtitulo,
          favorito.numero,
          favorito.referencia,
          favorito.categoria,
          favorito.idioma,
          favorito.texto,
          favorito.nomeCategoria,
        ];

        return campos.any(
          (campo) => campo.toLowerCase().contains(
                busca,
              ),
        );
      },
    ).toList();
  }

  // ============================================================
  // FILTRAR POR CATEGORIA
  // ============================================================

  Future<List<FavoritoItem>> filtrarPorCategoria(
    String categoria,
  ) async {
    final favoritos = await carregarFavoritos();

    if (categoria.isEmpty || categoria == 'Todas') {
      return favoritos;
    }

    return favoritos.where(
      (favorito) {
        return favorito.nomeCategoria == categoria;
      },
    ).toList();
  }

  // ============================================================
  // ORDENAR
  // ============================================================

  Future<List<FavoritoItem>> ordenar(
    String ordem,
  ) async {
    final favoritos = await carregarFavoritos();

    switch (ordem) {
      case 'recentes':
        favoritos.sort(
          (a, b) => b.data.compareTo(a.data),
        );
        break;

      case 'antigos':
        favoritos.sort(
          (a, b) => a.data.compareTo(b.data),
        );
        break;

      case 'nome':
        favoritos.sort(
          (a, b) => a.titulo.toLowerCase().compareTo(
                b.titulo.toLowerCase(),
              ),
        );
        break;

      case 'categoria':
        favoritos.sort(
          (a, b) => a.nomeCategoria.toLowerCase().compareTo(
                b.nomeCategoria.toLowerCase(),
              ),
        );
        break;
    }

    return favoritos;
  }

  // ============================================================
  // LIMPAR CACHE
  // ============================================================

  void limparCache() {
    _cache = null;
  }

  // ============================================================
  // FACTORY — HINO (com coros preservados)
  // ============================================================

  FavoritoItem criarFavoritoHino(
    Hino hino,
  ) {
    final idioma = hino.idioma.trim().isEmpty
        ? 'Português'
        : hino.idioma.trim();

    // Constrói o texto preservando os coros.
    //
    // Regras:
    // - Sem coro → só estrofes.
    // - 1 coro → guardado UMA VEZ entre a 1.ª e a 2.ª estrofe
    //   (para não inflacionar o texto guardado).
    // - N coros → guardado cada coro após a sua estrofe
    //   (ex: hino 264 com 3 coros).
    //
    final buffer = StringBuffer();
    final estrofes = hino.estrofes;
    final coros = hino.coros;

    final temCoro = coros != null && coros!.isNotEmpty;

    for (int i = 0; i < estrofes.length; i++) {
      buffer.writeln(estrofes[i]);

      if (temCoro) {
        // Caso especial: N coros → cada um após a estrofe
        // de índice correspondente.
        if (coros!.length > 1) {
          if (i < coros.length) {
            final coro = coros[i].trim();
            if (coro.isNotEmpty) {
              buffer.writeln();
              buffer.writeln('[CORO]');
              buffer.writeln(coro);
              buffer.writeln('[/CORO]');
            }
          }
        }
        // Caso normal: 1 coro → guardado apenas UMA VEZ,
        // após a primeira estrofe.
        else if (i == 0) {
          final coro = coros.first.trim();
          if (coro.isNotEmpty) {
            buffer.writeln();
            buffer.writeln('[CORO]');
            buffer.writeln(coro);
            buffer.writeln('[/CORO]');
          }
        }
      }

      if (i < estrofes.length - 1) {
        buffer.writeln();
      }
    }

    return FavoritoItem(
      id: 'hino_${_normalizarId(idioma)}_${hino.numero}',
      tipo: 'hino',
      titulo: hino.titulo,
      subtitulo: '',
      numero: hino.numero.toString(),
      referencia: hino.categoria,
      categoria: hino.categoria,
      idioma: idioma,
      texto: buffer.toString().trim(),
      data: DateTime.now(),
      icone: Icons.music_note_rounded.codePoint,
    );
  }

  // ============================================================
  // FACTORY — INVOCATÓRIA
  // ============================================================

  FavoritoItem criarFavoritoInvocatoria(
    Invocatoria invocatoria,
  ) {
    return FavoritoItem(
      id: 'invocatoria_${invocatoria.numero}',
      tipo: 'invocatoria',
      titulo: invocatoria.titulo,
      subtitulo: '',
      numero: invocatoria.numero,
      referencia: invocatoria.categoria,
      categoria: invocatoria.categoria,
      idioma: 'Português',
      texto: invocatoria.texto,
      data: DateTime.now(),
      icone: Icons.wb_sunny_rounded.codePoint,
    );
  }

  // ============================================================
  // FACTORY — LITANIA (com blocos preservados)
  // ============================================================

  FavoritoItem criarFavoritoLitania(
    Litania litania,
  ) {
    // Constrói o texto a partir dos blocos, com marcadores,
    // para o conteúdo não se perder.
    final buffer = StringBuffer();

    if (litania.blocos.isNotEmpty) {
      for (final bloco in litania.blocos) {
        if (bloco.texto.trim().isEmpty) continue;

        if (bloco.isTodos) {
          buffer.writeln('[TODOS]');
          buffer.writeln(bloco.texto);
          buffer.writeln('[/TODOS]');
        } else if (bloco.isCongregacao) {
          buffer.writeln('[CONGREGAÇÃO]');
          buffer.writeln(bloco.texto);
          buffer.writeln('[/CONGREGAÇÃO]');
        } else {
          buffer.writeln('[Dirigente]');
          buffer.writeln(bloco.texto);
        }

        buffer.writeln();
      }
    } else {
      // Fallback: formato antigo (texto corrido)
      buffer.writeln(litania.texto);
    }

    return FavoritoItem(
      id: 'litania_${litania.id}',
      tipo: 'litania',
      titulo: litania.titulo,
      subtitulo: litania.subtitulo,
      numero: litania.id,
      referencia: 'Litania',
      categoria: 'Litanias',
      idioma: 'Português',
      texto: buffer.toString().trim(),
      data: DateTime.now(),
      icone: Icons.format_list_bulleted_rounded.codePoint,
    );
  }

  // ============================================================
  // FACTORY — SALMO
  // ============================================================

  FavoritoItem criarFavoritoSalmo(
    Salmo salmo,
  ) {
    return FavoritoItem(
      id: 'salmo_${salmo.numero}',
      tipo: 'salmo',
      titulo: 'Salmo ${salmo.numero}',
      subtitulo: '',
      numero: salmo.numero,
      referencia: 'Salmo ${salmo.numero}',
      categoria: 'Salmos',
      idioma: 'Português',
      texto: salmo.texto,
      data: DateTime.now(),
      icone: Icons.menu_book_rounded.codePoint,
    );
  }

  // ============================================================
  // FACTORY — TEXTO LITÚRGICO
  // ============================================================

  FavoritoItem criarFavoritoTextoLiturgico(
    TextoLiturgico textoLiturgico,
  ) {
    return FavoritoItem(
      id: 'texto_${_normalizarId(textoLiturgico.titulo)}',
      tipo: 'texto_liturgico',
      titulo: textoLiturgico.titulo,
      subtitulo: textoLiturgico.subtitulo,
      numero: '',
      referencia: textoLiturgico.categoria,
      categoria: textoLiturgico.categoria,
      idioma: textoLiturgico.idioma,
      texto: textoLiturgico.texto,
      data: DateTime.now(),
      icone: Icons.menu_book_rounded.codePoint,
    );
  }

  // ============================================================
  // FACTORY — TEXTO LIVRE
  // ============================================================

  FavoritoItem criarFavoritoTextoLivre({
    required String id,
    required String tipo,
    required String titulo,
    String subtitulo = '',
    String numero = '',
    String referencia = '',
    String categoria = '',
    String idioma = 'Português',
    required String texto,
    IconData icone = Icons.auto_awesome_rounded,
  }) {
    return FavoritoItem(
      id: id,
      tipo: tipo,
      titulo: titulo,
      subtitulo: subtitulo,
      numero: numero,
      referencia: referencia,
      categoria: categoria,
      idioma: idioma,
      texto: texto,
      data: DateTime.now(),
      icone: icone.codePoint,
    );
  }

  // ============================================================
  // UTILITÁRIOS
  // ============================================================

  String _normalizarId(
    String valor,
  ) {
    return _limparTexto(valor)
        .toLowerCase()
        .replaceAll(
          RegExp(r'[^a-z0-9]+'),
          '_',
        )
        .replaceAll(
          RegExp(r'^_|_$'),
          '',
        );
  }

  String _limparTexto(
    String texto,
  ) {
    return texto
        .replaceAll(
          RegExp(r'<[^>]*>'),
          ' ',
        )
        .replaceAll(
          '&nbsp;',
          ' ',
        )
        .replaceAll(
          '&amp;',
          '&',
        )
        .replaceAll(
          '&quot;',
          '"',
        )
        .replaceAll(
          '&#39;',
          "'",
        )
        .replaceAll(
          RegExp(r'\s+'),
          ' ',
        )
        .trim();
  }
}