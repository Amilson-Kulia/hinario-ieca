import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:xml/xml.dart';
import '../modelos/biblia_livro.dart';
import '../modelos/biblia_capitulo.dart';
import '../modelos/versiculo.dart';

class BibliaServico {
  static List<BibliaLivro> _livros = [];

  /// Carrega e processa o XML da Bíblia em uma thread separada para não travar a UI
  static Future<List<BibliaLivro>> carregarBiblia(String caminhoXml) async {
    if (_livros.isNotEmpty) return _livros;

    final xmlString = await rootBundle.loadString(caminhoXml);
    _livros = await compute(_parsearXml, xmlString);
    return _livros;
  }

  static List<BibliaLivro> _parsearXml(String xmlContent) {
    final document = XmlDocument.parse(xmlContent);
    final List<BibliaLivro> livros = [];

    final bookNodes = document.findAllElements('book');

    for (var bookNode in bookNodes) {
      final id = bookNode.getAttribute('id') ?? '';
      
      // Obtém o nome por extenso a partir da tag <h>
      final hElement = bookNode.findElements('h').firstOrNull;
      final String nome = hElement?.innerText.trim() ?? id; 

      List<BibliaCapitulo> capitulos = [];
      
      int numeroCapituloAtual = 0;
      List<Versiculo> versiculosDoCapitulo = [];

      // Percorre os nós do livro para capturar capítulos e seus respetivos versículos
      for (var child in bookNode.children) {
        if (child is XmlElement) {
          if (child.name.local == 'c') {
            // Se já estávamos processando um capítulo, salva o capítulo anterior
            if (numeroCapituloAtual > 0) {
              capitulos.add(BibliaCapitulo(
                numero: numeroCapituloAtual,
                versiculos: List.from(versiculosDoCapitulo),
              ));
              versiculosDoCapitulo.clear();
            }
            numeroCapituloAtual = int.tryParse(child.getAttribute('id') ?? '1') ?? 1;
          } else if (child.name.local == 'v') {
            final numeroVersiculo = child.getAttribute('id') ?? '';
            
            // Extrai o texto contido até a tag de fechamento <ve/>
            String textoVersiculo = '';
            var nextNode = child.nextSibling;
            
            while (nextNode != null) {
              if (nextNode is XmlElement && nextNode.name.local == 've') {
                break;
              }
              if (nextNode is XmlText) {
                textoVersiculo += nextNode.text;
              }
              nextNode = nextNode.nextSibling;
            }

            if (numeroVersiculo.isNotEmpty) {
              versiculosDoCapitulo.add(
                Versiculo(
                  referencia: numeroVersiculo,
                  texto: textoVersiculo.trim(),
                ),
              );
            }
          }
        }
      }

      // Adiciona o último capítulo do livro
      if (numeroCapituloAtual > 0) {
        capitulos.add(BibliaCapitulo(
          numero: numeroCapituloAtual,
          versiculos: versiculosDoCapitulo,
        ));
      }

      livros.add(BibliaLivro(id: id, nome: nome, capitulos: capitulos));
    }

    return livros;
  }
}