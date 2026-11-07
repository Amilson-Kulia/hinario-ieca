import 'package:flutter/services.dart';
import 'package:xml/xml.dart';

import '../modelos/versiculo.dart';

class VersiculosServico {
  static const String _caminhoXml =
      'assets/dados/por-almeida.usfx.xml';

  static List<Versiculo>? _versiculosCache;

  // =============================================================
  // CARREGAR TODOS OS VERSÍCULOS
  // =============================================================

  static Future<List<Versiculo>> carregarVersiculos() async {
    if (_versiculosCache != null) {
      return _versiculosCache!;
    }

    final xmlString =
        await rootBundle.loadString(_caminhoXml);

    final documento =
        XmlDocument.parse(xmlString);

    final List<Versiculo> versiculos = [];

    // ===========================================================
    // PERCORRER LIVROS
    // ===========================================================

    for (final livro
        in documento.findAllElements('book')) {
      final nomeLivro =
          livro.getElement('h')?.innerText.trim() ?? '';

      if (nomeLivro.isEmpty) {
        continue;
      }

      String? capituloAtual;
      String? numeroVersiculoAtual;

      final StringBuffer textoVersiculo =
          StringBuffer();

      // =========================================================
      // PERCORRER NÓS
      // =========================================================

      for (final no in livro.children) {

        // -------------------------------------------------------
        // CAPÍTULO
        // -------------------------------------------------------

        if (no is XmlElement &&
            no.name.local == 'c') {

          _finalizarVersiculo(
            versiculos: versiculos,
            nomeLivro: nomeLivro,
            capitulo: capituloAtual,
            numeroVersiculo: numeroVersiculoAtual,
            texto: textoVersiculo,
          );

          capituloAtual =
              no.getAttribute('id');

          numeroVersiculoAtual = null;
          textoVersiculo.clear();

          continue;
        }

        // -------------------------------------------------------
        // NOVO VERSÍCULO
        // -------------------------------------------------------

        if (no is XmlElement &&
            no.name.local == 'v') {

          _finalizarVersiculo(
            versiculos: versiculos,
            nomeLivro: nomeLivro,
            capitulo: capituloAtual,
            numeroVersiculo: numeroVersiculoAtual,
            texto: textoVersiculo,
          );

          numeroVersiculoAtual =
              no.getAttribute('id');

          textoVersiculo.clear();

          continue;
        }

        // -------------------------------------------------------
        // FIM DO VERSÍCULO
        // -------------------------------------------------------

        if (no is XmlElement &&
            no.name.local == 've') {

          _finalizarVersiculo(
            versiculos: versiculos,
            nomeLivro: nomeLivro,
            capitulo: capituloAtual,
            numeroVersiculo: numeroVersiculoAtual,
            texto: textoVersiculo,
          );

          numeroVersiculoAtual = null;
          textoVersiculo.clear();

          continue;
        }

        // -------------------------------------------------------
        // TEXTO DO VERSÍCULO
        // -------------------------------------------------------

        if (numeroVersiculoAtual != null) {

          if (no is XmlText) {
            textoVersiculo.write(no.text);
          }

          else if (no is XmlElement) {
            textoVersiculo.write(no.innerText);
          }
        }
      }

      // =========================================================
      // ÚLTIMO VERSÍCULO
      // =========================================================

      _finalizarVersiculo(
        versiculos: versiculos,
        nomeLivro: nomeLivro,
        capitulo: capituloAtual,
        numeroVersiculo: numeroVersiculoAtual,
        texto: textoVersiculo,
      );
    }

    // ===========================================================
    // CACHE
    // ===========================================================

    _versiculosCache =
        List.unmodifiable(versiculos);

    return _versiculosCache!;
  }

  // =============================================================
  // FINALIZAR VERSÍCULO
  // =============================================================

  static void _finalizarVersiculo({
    required List<Versiculo> versiculos,
    required String nomeLivro,
    required String? capitulo,
    required String? numeroVersiculo,
    required StringBuffer texto,
  }) {
    if (capitulo == null ||
        numeroVersiculo == null) {
      return;
    }

    final textoLimpo =
        _limparTexto(texto.toString());

    if (textoLimpo.isEmpty) {
      return;
    }

    versiculos.add(
      Versiculo(
        referencia:
            '$nomeLivro $capitulo:$numeroVersiculo',
        texto: textoLimpo,
      ),
    );
  }

  // =============================================================
  // LIMPAR TEXTO
  // =============================================================

  static String _limparTexto(String texto) {
    return texto
        .replaceAll('\u00A0', ' ')
        .replaceAll('\n', ' ')
        .replaceAll('\r', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}