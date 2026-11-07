import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../componentes/cabecalho_ieca.dart';
import '../../componentes/navegacao_inferior_ieca.dart';
import '../../modelos/favorito.dart';
import '../../modelos/hino.dart';
import '../../modelos/invocatoria.dart';
import '../../modelos/litania.dart';
import '../../modelos/salmo.dart';
import '../../modelos/texto_liturgico.dart';
import '../../servicos/constancia_servico.dart';
import '../../servicos/favoritos_servico.dart';
import '../../servicos/marcados_servico.dart';
import '../biblia/biblia_tela.dart';
import '../home/home_tela.dart';
import '../sobre/sobre_tela.dart';
import 'idiomas_tela.dart';
import '../informacoes_ieca/informacoes_ieca_tela.dart';

class LeituraTela extends StatefulWidget {
  final Hino? hino;
  final Invocatoria? invocatoria;
  final Litania? litania;
  final Salmo? salmo;
  final TextoLiturgico? textoLiturgico;
  final FavoritoItem? favorito;

  final String? titulo;
  final String? subtitulo;
  final IconData? icone;
  final String? textoLivre;

  final List<LeituraItem>? listaNavegacao;
  final int indiceInicial;

  const LeituraTela({
    super.key,
    this.hino,
    this.invocatoria,
    this.litania,
    this.salmo,
    this.textoLiturgico,
    this.favorito,
    this.titulo,
    this.subtitulo,
    this.icone,
    this.textoLivre,
    this.listaNavegacao,
    this.indiceInicial = 0,
  }) : assert(
          hino != null ||
              invocatoria != null ||
              litania != null ||
              salmo != null ||
              textoLiturgico != null ||
              favorito != null ||
              textoLivre != null ||
              listaNavegacao != null,
          'É necessário fornecer um conteúdo.',
        ),
        assert(
          (hino != null ? 1 : 0) +
                  (invocatoria != null ? 1 : 0) +
                  (litania != null ? 1 : 0) +
                  (salmo != null ? 1 : 0) +
                  (textoLiturgico != null ? 1 : 0) +
                  (favorito != null ? 1 : 0) +
                  (textoLivre != null ? 1 : 0) <=
              1,
          'Forneça apenas um conteúdo direto (ou use listaNavegacao).',
        );

  @override
  State<LeituraTela> createState() => _LeituraTelaState();
}

class _LeituraTelaState extends State<LeituraTela> {
  final FavoritosServico _favoritosServico = FavoritosServico.instancia;
  final MarcadosServico _marcadosServico = MarcadosServico.instancia;

  int _indiceAtual = 0;
  late PageController _pageController;

  List<LeituraItem> get _lista {
    if (widget.listaNavegacao != null && widget.listaNavegacao!.isNotEmpty) {
      return widget.listaNavegacao!;
    }
    return [
      LeituraItem(
        hino: widget.hino,
        invocatoria: widget.invocatoria,
        litania: widget.litania,
        salmo: widget.salmo,
        textoLiturgico: widget.textoLiturgico,
        favorito: widget.favorito,
        titulo: widget.titulo,
        subtitulo: widget.subtitulo,
        icone: widget.icone,
        textoLivre: widget.textoLivre,
      ),
    ];
  }

  LeituraItem get _itemAtual => _lista[_indiceAtual];

  bool get _temAnterior => _indiceAtual > 0;
  bool get _temProximo => _indiceAtual < _lista.length - 1;

  bool favorito = false;
  bool carregandoFavorito = true;

  bool marcado = false;
  Color? corMarcacao;
  bool carregandoMarcacao = true;

  bool mostrarTamanhoTexto = false;
  bool modoEscuro = false;
  bool modoLeitura = false;

  double tamanhoFonte = 21;

  static const Color fundoClaro = Color(0xFFF8F9FF);
  static const Color fundoEscuro = Color(0xFF111318);

  static const Color textoClaro = Color(0xFF121C2A);
  static const Color textoEscuro = Color(0xFFF4F5F7);

  static const Color textoSecundarioClaro = Color(0xFF5B4040);
  static const Color textoSecundarioEscuro = Color(0xFFC5B8B8);

  static const Color primary = Color(0xFF9E0027);
  static const Color secondaryContainer = Color(0xFFFFA504);

  static const Map<String, Color> coresMarcacao = {
    'vermelho': Color(0xFFD32F2F),
    'laranja': Color(0xFFF57C00),
    'amarelo': Color(0xFFFBC02D),
    'verde': Color(0xFF388E3C),
    'azul': Color(0xFF1976D2),
    'roxo': Color(0xFF7B1FA2),
    'rosa': Color(0xFFD81B60),
    'cinzento': Color(0xFF757575),
  };

  @override
  void initState() {
    super.initState();
    _indiceAtual = widget.indiceInicial.clamp(0, _lista.length - 1);
    _pageController = PageController(initialPage: _indiceAtual);

    _carregarEstadoFavorito();
    _carregarEstadoMarcacao();
    _registrarConstanciaHinario();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _irPara(int indice) {
    if (indice < 0 || indice >= _lista.length) return;
    _pageController.animateToPage(
      indice,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOutCubic,
    );
  }

  void _anterior() {
    if (_temAnterior) _irPara(_indiceAtual - 1);
  }

  void _proximo() {
    if (_temProximo) _irPara(_indiceAtual + 1);
  }

  void _aoMudarPagina(int indice) {
    setState(() {
      _indiceAtual = indice;
      favorito = false;
      carregandoFavorito = true;
      marcado = false;
      corMarcacao = null;
      carregandoMarcacao = true;
    });
    _carregarEstadoFavorito();
    _carregarEstadoMarcacao();
  }

  Future<void> _registrarConstanciaHinario() async {
    try {
      await ConstanciaServico.instancia.registrarUsoHinario();
      debugPrint('Constância do Hinário registada.');
    } catch (e, stackTrace) {
      debugPrint('Erro ao registar constância do Hinário: $e');
      debugPrint('$stackTrace');
    }
  }

  Future<void> _carregarEstadoFavorito() async {
    try {
      final item = _favoritoAtual;

      final resultado = await _favoritosServico.eFavorito(
        id: item.id,
        tipo: item.tipo,
      );

      if (!mounted) return;

      setState(() {
        favorito = resultado;
        carregandoFavorito = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        favorito = false;
        carregandoFavorito = false;
      });
    }
  }

  Future<void> _carregarEstadoMarcacao() async {
    try {
      final item = _favoritoAtual;

      final resultado = await _marcadosServico.obter(
        id: item.id,
        tipo: item.tipo,
      );

      if (!mounted) return;

      setState(() {
        if (resultado != null) {
          marcado = true;
          corMarcacao = resultado.corData;
        } else {
          marcado = false;
          corMarcacao = null;
        }
        carregandoMarcacao = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        marcado = false;
        corMarcacao = null;
        carregandoMarcacao = false;
      });
    }
  }

  void _selecionarNavegacao(int indice) {
    if (!mounted) return;

    switch (indice) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const HomeTela()),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const IdiomasTela()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BibliaTela()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const InformacoesIecaTela(),
          ),
        );
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SobreTela()),
        );
        break;
    }
  }

  Future<void> _abrirPaletaMarcacao() async {
    if (carregandoMarcacao) return;

    final resultado = await showModalBottomSheet<_ResultadoMarcacao>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _buildPaletaMarcacao(),
    );

    if (resultado == null) return;

    if (resultado.remover) {
      await _removerMarcacao();
      return;
    }

    if (resultado.cor != null) {
      await _aplicarMarcacao(resultado.cor!);
    }
  }

  Widget _buildPaletaMarcacao() {
    const nomes = [
      'Vermelho', 'Laranja', 'Amarelo', 'Verde',
      'Azul', 'Roxo', 'Rosa', 'Cinzento',
    ];

    final cores = coresMarcacao.values.toList();

    return Container(
      decoration: const BoxDecoration(
        color: fundoClaro,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Marcar conteúdo',
              style: TextStyle(
                color: textoClaro,
                fontSize: 21,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Escolha uma cor para destacar este conteúdo.',
              style: TextStyle(
                color: textoSecundarioClaro,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 22),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: cores.length,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 14,
                childAspectRatio: 0.95,
              ),
              itemBuilder: (context, index) {
                final cor = cores[index];
                final selecionada = corMarcacao?.value == cor.value;

                return InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.pop(
                      context,
                      _ResultadoMarcacao.cor(cor),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: selecionada
                            ? cor
                            : const Color(0xFFE4E1E1),
                        width: selecionada ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: cor,
                            shape: BoxShape.circle,
                          ),
                          child: selecionada
                              ? const Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                  size: 20,
                                )
                              : null,
                        ),
                        const SizedBox(height: 7),
                        Text(
                          nomes[index],
                          style: const TextStyle(
                            color: textoClaro,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            if (marcado) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.pop(
                      context,
                      _ResultadoMarcacao.remover(),
                    );
                  },
                  icon: const Icon(
                    Icons.bookmark_remove_outlined,
                    color: primary,
                  ),
                  label: const Text(
                    'Remover marcação',
                    style: TextStyle(
                      color: primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _aplicarMarcacao(Color cor) async {
    try {
      final item = _favoritoAtual;

      final marcadoItem = MarcadoItem(
        id: item.id,
        tipo: item.tipo,
        titulo: item.titulo,
        subtitulo: item.subtitulo,
        numero: item.numero,
        referencia: item.referencia,
        categoria: item.categoria,
        idioma: item.idioma,
        texto: item.texto,
        data: DateTime.now(),
        cor: cor.value,
      );

      final sucesso =
          await _marcadosServico.adicionarOuAtualizar(marcadoItem);

      if (!mounted) return;

      if (!sucesso) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text('Não foi possível guardar a marcação.'),
            ),
          );
        return;
      }

      setState(() {
        marcado = true;
        corMarcacao = cor;
        carregandoMarcacao = false;
      });

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            duration: const Duration(milliseconds: 1800),
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            backgroundColor:
                modoEscuro ? const Color(0xFF272B34) : textoClaro,
            content: Row(
              children: [
                Icon(Icons.bookmark, color: cor),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Conteúdo marcado.',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Não foi possível guardar a marcação.'),
          ),
        );
    }
  }

  Future<void> _removerMarcacao() async {
    try {
      final item = _favoritoAtual;

      final sucesso = await _marcadosServico.remover(
        id: item.id,
        tipo: item.tipo,
      );

      if (!mounted) return;

      if (!sucesso) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text(
                'Não foi possível remover a marcação.',
              ),
            ),
          );
        return;
      }

      setState(() {
        marcado = false;
        corMarcacao = null;
        carregandoMarcacao = false;
      });

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('Marcação removida.'),
          ),
        );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Não foi possível remover a marcação.',
            ),
          ),
        );
    }
  }

  String get _idTextoLivre {
    final titulo = (widget.titulo ?? '').trim().toLowerCase();

    if (titulo.contains('credo')) return 'credo_apostolico';
    if (titulo.contains('oração') || titulo.contains('oracao')) {
      return 'oracao_senhor';
    }

    final tituloNormalizado = titulo
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');

    return 'texto_$tituloNormalizado';
  }

  String get _tipoTextoLivre {
    final titulo = (widget.titulo ?? '').trim().toLowerCase();

    if (titulo.contains('credo')) return 'credo';
    if (titulo.contains('oração') || titulo.contains('oracao')) {
      return 'oracao';
    }

    return 'texto_liturgico';
  }

  String get _categoriaTextoLivre {
    final titulo = (widget.titulo ?? '').trim().toLowerCase();

    if (titulo.contains('credo')) return 'Credo Apostólico';
    if (titulo.contains('oração') || titulo.contains('oracao')) {
      return 'Oração do Senhor';
    }

    return 'Textos Litúrgicos';
  }

  FavoritoItem get _favoritoAtual {
    final item = _itemAtual;

    if (item.favorito != null) return item.favorito!;

    if (item.hino != null) {
      return _favoritosServico.criarFavoritoHino(item.hino!);
    }

    if (item.invocatoria != null) {
      return _favoritosServico
          .criarFavoritoInvocatoria(item.invocatoria!);
    }

    if (item.litania != null) {
      return _favoritosServico.criarFavoritoLitania(item.litania!);
    }

    if (item.salmo != null) {
      return _favoritosServico.criarFavoritoSalmo(item.salmo!);
    }

    if (item.textoLiturgico != null) {
      return _favoritosServico
          .criarFavoritoTextoLiturgico(item.textoLiturgico!);
    }

    return _favoritosServico.criarFavoritoTextoLivre(
      id: _idTextoLivre,
      titulo: tituloConteudo,
      subtitulo: subtituloConteudo,
      texto: textoLivreConteudo,
      categoria: _categoriaTextoLivre,
      referencia: tituloConteudo,
      tipo: _tipoTextoLivre,
      idioma: '',
      icone: iconeConteudo,
    );
  }

  Future<void> _alternarFavorito() async {
    if (carregandoFavorito) return;

    final estadoAnterior = favorito;

    setState(() => favorito = !favorito);

    try {
      final resultado =
          await _favoritosServico.alternarFavorito(_favoritoAtual);

      if (!mounted) return;

      setState(() => favorito = resultado);

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            duration: const Duration(milliseconds: 1800),
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            backgroundColor:
                modoEscuro ? const Color(0xFF272B34) : textoClaro,
            content: Row(
              children: [
                Icon(
                  resultado ? Icons.favorite : Icons.favorite_border,
                  color: resultado
                      ? secondaryContainer
                      : Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    resultado
                        ? 'Adicionado aos favoritos'
                        : 'Removido dos favoritos',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
    } catch (_) {
      if (!mounted) return;
      setState(() => favorito = estadoAnterior);

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            duration: const Duration(milliseconds: 2200),
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            backgroundColor: primary,
            content: const Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Não foi possível atualizar os favoritos.',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
    }
  }

  String get numeroConteudo {
    final item = _itemAtual;
    if (item.favorito != null) return item.favorito!.numero;
    if (item.hino != null) return item.hino!.numeroExibicao;
    if (item.invocatoria != null) return item.invocatoria!.numero;
    if (item.litania != null) return item.litania!.id;
    if (item.salmo != null) return item.salmo!.numero.toString();
    return '✦';
  }

  String get tituloConteudo {
    final item = _itemAtual;
    if (item.favorito != null) return item.favorito!.titulo;
    if (item.hino != null) return item.hino!.titulo;
    if (item.invocatoria != null) return item.invocatoria!.titulo;
    if (item.litania != null) return item.litania!.titulo;
    if (item.salmo != null) return 'Salmo ${item.salmo!.numero}';
    if (item.textoLiturgico != null) {
      return item.textoLiturgico!.titulo;
    }
    return item.titulo ?? '';
  }

  String get subtituloConteudo {
    final item = _itemAtual;
    if (item.favorito != null) return item.favorito!.subtitulo;
    if (item.litania != null) return item.litania!.subtitulo;
    if (item.textoLiturgico != null) {
      return item.textoLiturgico!.subtitulo;
    }
    return item.subtitulo ?? '';
  }

  String get categoriaConteudo {
    final item = _itemAtual;
    if (item.favorito != null) return item.favorito!.nomeCategoria;
    if (item.hino != null) return item.hino!.categoria;
    if (item.invocatoria != null) return item.invocatoria!.categoria;
    if (item.litania != null) return 'Litanias';
    if (item.salmo != null) return 'Salmos';
    if (item.textoLiturgico != null) {
      return item.textoLiturgico!.categoria;
    }
    return _categoriaTextoLivre;
  }

  String get tipoConteudo {
    final item = _itemAtual;

    if (item.favorito != null) {
      final tipo = item.favorito!.tipo.toLowerCase();

      switch (tipo) {
        case 'hino':
          return 'HINO';
        case 'invocatoria':
        case 'invocatória':
          return 'INVOCATÓRIA';
        case 'litania':
          return 'LITANIA';
        case 'salmo':
          return 'SALMO';
        case 'credo':
          return 'CREDO APOSTÓLICO';
        case 'oracao':
        case 'oração':
          return 'ORAÇÃO DO SENHOR';
        case 'doxologia':
          return 'DOXOLOGIA';
        case 'leitura':
          return 'LEITURA';
        default:
          return 'TEXTO LITÚRGICO';
      }
    }

    if (item.hino != null) return 'HINO';
    if (item.invocatoria != null) return 'INVOCATÓRIA';
    if (item.litania != null) return 'LITANIA';
    if (item.salmo != null) return 'SALMO';
    if (item.textoLiturgico != null) return 'TEXTO LITÚRGICO';

    final tipo = _tipoTextoLivre;
    if (tipo == 'credo') return 'CREDO APOSTÓLICO';
    if (tipo == 'oracao') return 'ORAÇÃO DO SENHOR';

    return 'TEXTO LITÚRGICO';
  }

  IconData get iconeConteudo {
    final item = _itemAtual;
    if (item.favorito != null) return item.favorito!.iconeData;
    if (item.icone != null) return item.icone!;
    if (item.textoLiturgico != null) return Icons.menu_book_rounded;
    if (item.hino != null) return Icons.music_note_rounded;
    if (item.invocatoria != null) return Icons.wb_sunny_rounded;
    if (item.litania != null) {
      return Icons.format_list_bulleted_rounded;
    }
    if (item.salmo != null) return Icons.menu_book_rounded;
    return Icons.auto_awesome_rounded;
  }

  String get textoLivreConteudo {
    final item = _itemAtual;
    if (item.favorito != null) return item.favorito!.texto;
    return item.textoLivre ?? '';
  }

  String _limparTexto(String texto) {
    String resultado = texto;

    resultado = resultado.replaceAll(RegExp(r'<[^>]*>'), '');
    resultado = resultado.replaceAll('&nbsp;', ' ');
    resultado = resultado.replaceAll('&amp;', '&');
    resultado = resultado.replaceAll('&quot;', '"');
    resultado = resultado.replaceAll('&#39;', "'");
    resultado = resultado.replaceAll('&lt;', '<');
    resultado = resultado.replaceAll('&gt;', '>');
    resultado = resultado.replaceAll('\u00A0', ' ');

    return resultado.trim();
  }

  List<String> get textosConteudo {
    final item = _itemAtual;

    if (item.favorito != null) {
      final texto = _limparTexto(item.favorito!.texto);
      return texto.isEmpty ? [''] : [texto];
    }

    if (item.hino != null) return item.hino!.estrofes;

    if (item.invocatoria != null) {
      return [_limparTexto(item.invocatoria!.texto)];
    }

    if (item.litania != null) {
      return [_limparTexto(item.litania!.texto)];
    }

    if (item.salmo != null) {
      return [_limparTexto(item.salmo!.texto)];
    }

    if (item.textoLiturgico != null) {
      return [_limparTexto(item.textoLiturgico!.texto)];
    }

    return [_limparTexto(textoLivreConteudo)];
  }

  // =========================================================
  // BLOCOS DE CONTEÚDO (com coro intercalado)
  // =========================================================
  //
  // Regras:
  // - Hino sem coro → só estrofes.
  // - Hino com 1 coro → o coro aparece DEPOIS DE CADA ESTROFE.
  // - Hino com N coros (ex: 264) → cada coro aparece depois da
  //   estrofe de índice correspondente.
  //
  List<_BlocoConteudo> get _blocosConteudo {
    final item = _itemAtual;

    // Conteúdos que não são hinos → só estrofes.
    if (item.hino == null) {
      return textosConteudo
          .map((t) => _BlocoConteudo.estrofe(t))
          .toList();
    }

    final hino = item.hino!;
    final estrofes = hino.estrofes;

    final blocos = <_BlocoConteudo>[];

    for (int i = 0; i < estrofes.length; i++) {
      // Adiciona a estrofe.
      blocos.add(_BlocoConteudo.estrofe(estrofes[i]));

      // Adiciona o coro correspondente (se houver).
      final coro = hino.coroParaEstrofe(i);
      if (coro != null && coro.trim().isNotEmpty) {
        blocos.add(_BlocoConteudo.coro(coro));
      }
    }

    return blocos;
  }

  // =========================================================
  // PARSEAR BLOCOS DE LITANIA A PARTIR DO FAVORITO
  // =========================================================

  List<BlocoLitania> _parsearBlocosLitania(String texto) {
    final blocos = <BlocoLitania>[];

    if (texto.trim().isEmpty) return blocos;

    final linhas = texto.split('\n');

    String papelAtual = 'dirigente';
    final bufferBloco = StringBuffer();

    void finalizarBloco() {
      final t = bufferBloco.toString().trim();
      if (t.isNotEmpty) {
        blocos.add(BlocoLitania(papel: papelAtual, texto: t));
      }
      bufferBloco.clear();
    }

    for (final linha in linhas) {
      final l = linha.trim();

      if (l == '[TODOS]') {
        finalizarBloco();
        papelAtual = 'todos';
        continue;
      }
      if (l == '[/TODOS]') {
        finalizarBloco();
        papelAtual = 'dirigente';
        continue;
      }
      if (l == '[CONGREGAÇÃO]' || l == '[CONGREGACAO]') {
        finalizarBloco();
        papelAtual = 'congregacao';
        continue;
      }
      if (l == '[/CONGREGAÇÃO]' || l == '[/CONGREGACAO]') {
        finalizarBloco();
        papelAtual = 'dirigente';
        continue;
      }
      if (l == '[Dirigente]') {
        finalizarBloco();
        papelAtual = 'dirigente';
        continue;
      }

      if (l.isNotEmpty) {
        bufferBloco.writeln(l);
      }
    }

    finalizarBloco();

    return blocos;
  }

  // =========================================================
  // PARSEAR BLOCOS DE HINO A PARTIR DO FAVORITO
  // =========================================================
  //
  // O favorito guarda o coro UMA ÚNICA VEZ entre [CORO]...[/CORO].
  // Aqui replicamos o coro após cada estrofe para manter a
  // mesma regra de exibição.
  //
  List<_BlocoConteudo> _parsearBlocosHino(String texto) {
    final blocos = <_BlocoConteudo>[];

    if (texto.trim().isEmpty) return blocos;

    final regexCoro = RegExp(
      r'\[CORO\]\s*([\s\S]*?)\s*\[/CORO\]',
      caseSensitive: false,
    );

    final match = regexCoro.firstMatch(texto);

    // Sem coro no favorito → só estrofes.
    if (match == null) {
      final estrofes = texto
          .split(RegExp(r'\n\s*\n'))
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty);

      for (final estrofe in estrofes) {
        blocos.add(_BlocoConteudo.estrofe(estrofe));
      }

      return blocos;
    }

    final coroTexto = match.group(1)!.trim();
    final antes = texto.substring(0, match.start).trim();
    final depois = texto.substring(match.end).trim();

    final estrofes = <String>[];

    if (antes.isNotEmpty) {
      estrofes.addAll(
        antes
            .split(RegExp(r'\n\s*\n'))
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty),
      );
    }

    if (depois.isNotEmpty) {
      estrofes.addAll(
        depois
            .split(RegExp(r'\n\s*\n'))
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty),
      );
    }

    // Intercala coro após cada estrofe.
    for (int i = 0; i < estrofes.length; i++) {
      blocos.add(_BlocoConteudo.estrofe(estrofes[i]));

      if (coroTexto.isNotEmpty) {
        blocos.add(_BlocoConteudo.coro(coroTexto));
      }
    }

    return blocos;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: modoEscuro ? fundoEscuro : fundoClaro,
      appBar: modoLeitura ? null : const CabecalhoIeca(),
      body: SafeArea(
        top: modoLeitura,
        bottom: false,
        child: modoLeitura
            ? _buildModoLeitura()
            : _buildPaginaNormal(),
      ),
    );
  }

  Widget _buildPaginaNormal() {
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: _aoMudarPagina,
            itemCount: _lista.length,
            itemBuilder: (context, index) {
              return SingleChildScrollView(
                padding: const EdgeInsets.only(
                  left: 24,
                  right: 24,
                  bottom: 24,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Column(
                      children: [
                        _buildCabecalhoConteudo(),
                        _buildAcoes(),
                        if (mostrarTamanhoTexto) _buildPainelFonte(),
                        _buildTexto(),
                        _buildInformacao(),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        _buildBarraNavegacao(),
        _buildRodape(),
      ],
    );
  }

  Widget _buildCabecalhoConteudo() {
    final corTexto = modoEscuro ? textoEscuro : textoClaro;
    final corSec =
        modoEscuro ? textoSecundarioEscuro : textoSecundarioClaro;

    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: primary.withOpacity(0.10),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              tipoConteudo,
              style: const TextStyle(
                color: primary,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 16),

          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [primary, Color(0xFFC2185B)],
              ),
              boxShadow: [
                BoxShadow(
                  color: primary.withOpacity(0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              numeroConteudo,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 16),

          Text(
            tituloConteudo,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: corTexto,
              fontSize: 26,
              height: 1.25,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),

          if (subtituloConteudo.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              subtituloConteudo,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: corSec,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: Divider(
                  color: corSec.withOpacity(0.2),
                  height: 1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  categoriaConteudo.toUpperCase(),
                  style: TextStyle(
                    color: corSec.withOpacity(0.7),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              Expanded(
                child: Divider(
                  color: corSec.withOpacity(0.2),
                  height: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAcoes() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: modoEscuro
            ? const Color(0xE61B1E25)
            : Colors.white.withOpacity(0.75),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: modoEscuro
              ? Colors.white.withOpacity(0.06)
              : const Color(0x145B4040),
        ),
        boxShadow: modoEscuro
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Row(
        children: [
          _acao(
            icone: carregandoFavorito
                ? Icons.hourglass_empty_rounded
                : favorito
                    ? Icons.favorite
                    : Icons.favorite_border,
            texto: favorito ? 'Favorito' : 'Favoritar',
            ativo: favorito,
            onTap: _alternarFavorito,
            carregando: carregandoFavorito,
          ),
          _acao(
            icone: carregandoMarcacao
                ? Icons.hourglass_empty_rounded
                : marcado
                    ? Icons.bookmark
                    : Icons.bookmark_border,
            texto: marcado ? 'Marcado' : 'Marcar',
            ativo: marcado,
            corAtiva: corMarcacao,
            onTap: _abrirPaletaMarcacao,
            carregando: carregandoMarcacao,
          ),
          _acao(
            icone: Icons.ios_share_rounded,
            texto: 'Partilhar',
            onTap: _partilhar,
          ),
          _acao(
            icone: Icons.format_size_rounded,
            texto: 'Texto',
            ativo: mostrarTamanhoTexto,
            onTap: () => setState(
              () => mostrarTamanhoTexto = !mostrarTamanhoTexto,
            ),
          ),
          _acao(
            icone: modoEscuro
                ? Icons.light_mode_rounded
                : Icons.dark_mode_rounded,
            texto: modoEscuro ? 'Claro' : 'Escuro',
            ativo: modoEscuro,
            onTap: () => setState(() => modoEscuro = !modoEscuro),
          ),
        ],
      ),
    );
  }

  Widget _acao({
    required IconData icone,
    required String texto,
    required VoidCallback onTap,
    bool ativo = false,
    Color? corAtiva,
    bool carregando = false,
  }) {
    final corTexto =
        modoEscuro ? textoSecundarioEscuro : textoSecundarioClaro;
    final corSelecionada = corAtiva ?? primary;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: ativo
                      ? corSelecionada.withOpacity(0.14)
                      : (modoEscuro
                          ? const Color(0xFF1F232B)
                          : const Color(0xFFF2F4F9)),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: carregando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: primary,
                        ),
                      )
                    : Icon(
                        icone,
                        size: 20,
                        color: ativo ? corSelecionada : corTexto,
                      ),
              ),
              const SizedBox(height: 5),
              Text(
                texto,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: ativo ? corSelecionada : corTexto,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _partilhar() async {
    try {
      final texto = _textoParaPartilhar();

      final resultado = await SharePlus.instance.share(
        ShareParams(
          text: texto,
          title: tituloConteudo,
          subject: '$tipoConteudo - $tituloConteudo',
        ),
      );

      if (!mounted) return;

      if (resultado.status == ShareResultStatus.unavailable) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text(
                'A partilha não está disponível neste dispositivo.',
              ),
            ),
          );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(
              'Não foi possível partilhar este conteúdo.',
            ),
          ),
        );
    }
  }

  String _textoParaPartilhar() {
    final buffer = StringBuffer();
    final item = _itemAtual;

    buffer.writeln(tipoConteudo);

    if (numeroConteudo.trim().isNotEmpty && numeroConteudo != '✦') {
      buffer.writeln('Nº $numeroConteudo');
    }

    buffer.writeln();
    buffer.writeln(tituloConteudo);

    if (subtituloConteudo.trim().isNotEmpty) {
      buffer.writeln(subtituloConteudo);
    }

    buffer.writeln();

    // FAVORITO DE HINO
    if (item.favorito != null &&
        item.favorito!.tipo.toLowerCase() == 'hino') {
      final blocos = _parsearBlocosHino(item.favorito!.texto);

      for (int i = 0; i < blocos.length; i++) {
        final bloco = blocos[i];
        final texto = _limparTexto(bloco.texto);

        if (texto.isEmpty) continue;

        if (bloco.isCoro) {
          buffer.writeln('[CORO]');
          buffer.writeln(texto);
          buffer.writeln('[/CORO]');
        } else {
          buffer.writeln(texto);
        }

        if (i < blocos.length - 1) {
          buffer.writeln();
        }
      }
    }
    // FAVORITO DE LITANIA
    else if (item.favorito != null &&
        item.favorito!.tipo.toLowerCase() == 'litania') {
      final blocos = _parsearBlocosLitania(item.favorito!.texto);

      for (final bloco in blocos) {
        final texto = _limparTexto(bloco.texto);
        if (texto.isEmpty) continue;

        if (bloco.isTodos) {
          buffer.writeln('[TODOS]');
          buffer.writeln(texto);
          buffer.writeln('[/TODOS]');
        } else if (bloco.isCongregacao) {
          buffer.writeln('[CONGREGAÇÃO]');
          buffer.writeln(texto);
          buffer.writeln('[/CONGREGAÇÃO]');
        } else {
          buffer.writeln('[Dirigente]');
          buffer.writeln(texto);
        }

        buffer.writeln();
      }
    }
    // SALMO RESPONSIVO
    else if (item.salmo != null && item.salmo!.temBlocosResponsivos) {
      for (final bloco in item.salmo!.blocos) {
        final texto = _limparTexto(bloco.texto);
        if (texto.isEmpty) continue;

        if (bloco.isCongregacao) {
          buffer.writeln('[TODOS]');
          buffer.writeln(texto);
          buffer.writeln('[/TODOS]');
        } else {
          buffer.writeln(texto);
        }

        buffer.writeln();
      }
    }
    // LITANIA RESPONSIVA
    else if (item.litania != null && item.litania!.temBlocosResponsivos) {
      for (final bloco in item.litania!.blocos) {
        final texto = _limparTexto(bloco.texto);
        if (texto.isEmpty) continue;

        if (bloco.isTodos) {
          buffer.writeln('[TODOS]');
          buffer.writeln(texto);
          buffer.writeln('[/TODOS]');
        } else if (bloco.isCongregacao) {
          buffer.writeln('[CONGREGAÇÃO]');
          buffer.writeln(texto);
          buffer.writeln('[/CONGREGAÇÃO]');
        } else {
          buffer.writeln('[Dirigente]');
          buffer.writeln(texto);
        }

        buffer.writeln();
      }
    }
    // HINO / OUTROS
    else {
      final blocos = _blocosConteudo;

      for (int i = 0; i < blocos.length; i++) {
        final bloco = blocos[i];
        final texto = _limparTexto(bloco.texto);

        if (texto.isEmpty) continue;

        if (bloco.isCoro) {
          buffer.writeln('[CORO]');
          buffer.writeln(texto);
          buffer.writeln('[/CORO]');
        } else {
          buffer.writeln(texto);
        }

        if (i < blocos.length - 1) {
          buffer.writeln();
        }
      }
    }

    buffer.writeln();
    buffer.writeln('────────────────────');
    buffer.writeln('APP IECA - Hinário');

    return buffer.toString().trim();
  }

  Widget _buildPainelFonte() {
    final corTexto = modoEscuro ? textoEscuro : textoClaro;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: modoEscuro
            ? const Color(0xFF1B1E25)
            : const Color(0xFFEFF4FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Tamanho do texto',
            style: TextStyle(
              color: corTexto.withOpacity(0.7),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          Row(
            children: [
              _botaoFonte(Icons.text_decrease, () {
                if (tamanhoFonte > 16) {
                  setState(() => tamanhoFonte--);
                }
              }),
              const SizedBox(width: 12),
              SizedBox(
                width: 32,
                child: Text(
                  tamanhoFonte.round().toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: corTexto,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _botaoFonte(Icons.text_increase, () {
                if (tamanhoFonte < 34) {
                  setState(() => tamanhoFonte++);
                }
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _botaoFonte(IconData icone, VoidCallback onTap) {
    return Material(
      color: modoEscuro ? const Color(0xFF272B34) : Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            icone,
            size: 20,
            color: modoEscuro ? Colors.white : textoClaro,
          ),
        ),
      ),
    );
  }

  Widget _buildTexto() {
    final corTexto = modoEscuro ? textoEscuro : textoClaro;
    final item = _itemAtual;

    // =======================================================
    // FAVORITO DE TIPO LITANIA
    // =======================================================

    if (item.favorito != null &&
        item.favorito!.tipo.toLowerCase() == 'litania') {
      final blocos = _parsearBlocosLitania(item.favorito!.texto);

      if (blocos.isNotEmpty) {
        return Padding(
          padding: const EdgeInsets.only(
            left: 4,
            right: 4,
            bottom: 32,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (int i = 0; i < blocos.length; i++)
                Padding(
                  padding: EdgeInsets.only(
                    bottom: i == blocos.length - 1 ? 0 : 22,
                  ),
                  child: _buildBlocoLitania(blocos[i]),
                ),
            ],
          ),
        );
      }
    }

    // =======================================================
    // FAVORITO DE TIPO HINO
    // =======================================================

    if (item.favorito != null &&
        item.favorito!.tipo.toLowerCase() == 'hino') {
      final blocos = _parsearBlocosHino(item.favorito!.texto);

      if (blocos.isNotEmpty) {
        return Padding(
          padding: const EdgeInsets.only(
            left: 4,
            right: 4,
            bottom: 32,
          ),
          child: Column(
            children: [
              for (int i = 0; i < blocos.length; i++)
                Padding(
                  padding: EdgeInsets.only(
                    bottom: i == blocos.length - 1 ? 0 : 28,
                  ),
                  child: blocos[i].isCoro
                      ? _buildBlocoCoro(
                          texto: blocos[i].texto,
                          corTexto: corTexto,
                        )
                      : _buildBlocoTextoMarcado(
                          texto: blocos[i].texto,
                          corTexto: corTexto,
                          corDestaque: corMarcacao,
                        ),
                ),
            ],
          ),
        );
      }
    }

    // SALMO RESPONSIVO
    if (item.salmo != null && item.salmo!.temBlocosResponsivos) {
      return Padding(
        padding: const EdgeInsets.only(
          left: 4,
          right: 4,
          bottom: 32,
        ),
        child: _buildBlocosSalmoResponsivo(),
      );
    }

    // LITANIA RESPONSIVA
    if (item.litania != null && item.litania!.temBlocosResponsivos) {
      return Padding(
        padding: const EdgeInsets.only(
          left: 4,
          right: 4,
          bottom: 32,
        ),
        child: _buildBlocosLitaniaResponsiva(),
      );
    }

    // INVOCATÓRIA
    if (item.invocatoria != null) {
      return Padding(
        padding: const EdgeInsets.only(
          left: 4,
          right: 4,
          bottom: 32,
        ),
        child: _buildBlocoInvocatoria(),
      );
    }

    // CREDO APOSTÓLICO
    final tipoLivre = _tipoTextoLivre;

    if (tipoLivre == 'credo') {
      return Padding(
        padding: const EdgeInsets.only(
          left: 4,
          right: 4,
          bottom: 32,
        ),
        child: _buildBlocoCredo(),
      );
    }

    // ORAÇÃO DO SENHOR
    if (tipoLivre == 'oracao') {
      return Padding(
        padding: const EdgeInsets.only(
          left: 4,
          right: 4,
          bottom: 32,
        ),
        child: _buildBlocoOracaoSenhor(),
      );
    }

    // OUTROS
    final blocos = _blocosConteudo;

    return Padding(
      padding: const EdgeInsets.only(
        left: 4,
        right: 4,
        bottom: 32,
      ),
      child: Column(
        children: [
          for (int i = 0; i < blocos.length; i++)
            Padding(
              padding: EdgeInsets.only(
                bottom: i == blocos.length - 1 ? 0 : 28,
              ),
              child: blocos[i].isCoro
                  ? _buildBlocoCoro(
                      texto: blocos[i].texto,
                      corTexto: corTexto,
                    )
                  : _buildBlocoTextoMarcado(
                      texto: blocos[i].texto,
                      corTexto: corTexto,
                      corDestaque: corMarcacao,
                    ),
            ),
        ],
      ),
    );
  }

  Widget _buildBlocosSalmoResponsivo() {
    final salmo = _itemAtual.salmo!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int i = 0; i < salmo.blocos.length; i++)
          Padding(
            padding: EdgeInsets.only(
              bottom: i == salmo.blocos.length - 1 ? 0 : 22,
            ),
            child: salmo.blocos[i].isCongregacao
                ? _buildBlocoCongregacao(salmo.blocos[i].texto)
                : _buildBlocoDirigente(salmo.blocos[i].texto),
          ),
      ],
    );
  }

  Widget _buildBlocoDirigente(String texto) {
    final corTexto = modoEscuro ? textoEscuro : textoClaro;

    return Text(
      texto,
      textAlign: TextAlign.start,
      style: TextStyle(
        color: corTexto,
        fontSize: tamanhoFonte,
        height: 1.6,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _buildBlocoCongregacao(String texto) {
    final corTexto = modoEscuro ? textoEscuro : textoClaro;

    final corFundo = modoEscuro
        ? primary.withOpacity(0.18)
        : primary.withOpacity(0.08);

    final corBorda = modoEscuro
        ? secondaryContainer.withOpacity(0.85)
        : primary;

    final corLabel = modoEscuro ? secondaryContainer : primary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: corFundo,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(color: corBorda, width: 5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.groups_rounded,
                size: 16,
                color: corLabel,
              ),
              const SizedBox(width: 6),
              Text(
                'TODOS',
                style: TextStyle(
                  color: corLabel,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            texto,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: corTexto,
              fontSize: tamanhoFonte,
              height: 1.6,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlocosLitaniaResponsiva() {
    final litania = _itemAtual.litania!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int i = 0; i < litania.blocos.length; i++)
          Padding(
            padding: EdgeInsets.only(
              bottom: i == litania.blocos.length - 1 ? 0 : 22,
            ),
            child: _buildBlocoLitania(litania.blocos[i]),
          ),
      ],
    );
  }

  Widget _buildBlocoLitania(BlocoLitania bloco) {
    if (bloco.isTodos) {
      return _buildBlocoLitaniaTodos(bloco.texto);
    }

    if (bloco.isCongregacao) {
      return _buildBlocoLitaniaCongregacao(bloco.texto);
    }

    return _buildBlocoLitaniaDirigente(bloco.texto);
  }

  Widget _buildBlocoLitaniaDirigente(String texto) {
    final corTexto = modoEscuro ? textoEscuro : textoClaro;
    final corEtiqueta =
        modoEscuro ? textoSecundarioEscuro : textoSecundarioClaro;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 6, right: 10),
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: corEtiqueta.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'D',
            style: TextStyle(
              color: corEtiqueta,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Expanded(
          child: Text(
            texto,
            textAlign: TextAlign.start,
            style: TextStyle(
              color: corTexto,
              fontSize: tamanhoFonte,
              height: 1.6,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBlocoLitaniaCongregacao(String texto) {
    final corTexto = modoEscuro ? textoEscuro : textoClaro;

    final corFundo = modoEscuro
        ? primary.withOpacity(0.18)
        : primary.withOpacity(0.08);

    final corBorda = modoEscuro
        ? secondaryContainer.withOpacity(0.85)
        : primary;

    final corLabel = modoEscuro ? secondaryContainer : primary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: corFundo,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(color: corBorda, width: 5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.groups_rounded,
                size: 16,
                color: corLabel,
              ),
              const SizedBox(width: 6),
              Text(
                'CONGREGAÇÃO',
                style: TextStyle(
                  color: corLabel,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            texto,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: corTexto,
              fontSize: tamanhoFonte,
              height: 1.6,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlocoLitaniaTodos(String texto) {
    final corTexto = modoEscuro ? textoEscuro : textoClaro;

    final corFundo = modoEscuro
        ? secondaryContainer.withOpacity(0.18)
        : secondaryContainer.withOpacity(0.15);

    final corBorda = modoEscuro
        ? secondaryContainer
        : const Color(0xFFB87A00);

    final corLabel = modoEscuro
        ? secondaryContainer
        : const Color(0xFF8B5A00);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: corFundo,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(color: corBorda, width: 5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.people_alt_rounded,
                size: 16,
                color: corLabel,
              ),
              const SizedBox(width: 6),
              Text(
                'TODOS',
                style: TextStyle(
                  color: corLabel,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            texto,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: corTexto,
              fontSize: tamanhoFonte,
              height: 1.6,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlocoInvocatoria() {
    final texto = _limparTexto(_itemAtual.invocatoria!.texto);
    final corTexto = modoEscuro ? textoEscuro : textoClaro;

    final corFundo = modoEscuro
        ? secondaryContainer.withOpacity(0.10)
        : secondaryContainer.withOpacity(0.10);

    final corBorda = modoEscuro
        ? secondaryContainer.withOpacity(0.85)
        : const Color(0xFFB87A00);

    final corIcone = modoEscuro
        ? secondaryContainer
        : const Color(0xFF8B5A00);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
      decoration: BoxDecoration(
        color: corFundo,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: corBorda.withOpacity(0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: corBorda.withOpacity(0.08),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: corBorda.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.wb_sunny_rounded,
                  size: 20,
                  color: corIcone,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'INVOCATÓRIA',
                      style: TextStyle(
                        color: corIcone,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.6,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Oração de abertura',
                      style: TextStyle(
                        color: (modoEscuro
                                ? textoSecundarioEscuro
                                : textoSecundarioClaro)
                            .withOpacity(0.7),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  corBorda.withOpacity(0.0),
                  corBorda.withOpacity(0.4),
                  corBorda.withOpacity(0.0),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            texto,
            textAlign: TextAlign.start,
            style: TextStyle(
              color: corTexto,
              fontSize: tamanhoFonte,
              height: 1.65,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Ámen',
                style: TextStyle(
                  color: corIcone,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  fontStyle: FontStyle.italic,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBlocoCredo() {
    final texto = _limparTexto(textoLivreConteudo);
    final corTexto = modoEscuro ? textoEscuro : textoClaro;

    const corCredo = Color(0xFF3D5A80);
    const corCredoSuave = Color(0xFF5C7FA8);

    final corFundo = modoEscuro
        ? corCredo.withOpacity(0.20)
        : corCredo.withOpacity(0.06);

    final corBorda = modoEscuro ? corCredoSuave : corCredo;
    final corIcone = modoEscuro ? corCredoSuave : corCredo;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
      decoration: BoxDecoration(
        color: corFundo,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: corBorda.withOpacity(0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: corBorda.withOpacity(0.08),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: corBorda.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.menu_book_rounded,
                  size: 20,
                  color: corIcone,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CREDO APOSTÓLICO',
                      style: TextStyle(
                        color: corIcone,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.6,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Profissão de fé',
                      style: TextStyle(
                        color: (modoEscuro
                                ? textoSecundarioEscuro
                                : textoSecundarioClaro)
                            .withOpacity(0.7),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  corBorda.withOpacity(0.0),
                  corBorda.withOpacity(0.4),
                  corBorda.withOpacity(0.0),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            texto,
            textAlign: TextAlign.start,
            style: TextStyle(
              color: corTexto,
              fontSize: tamanhoFonte,
              height: 1.65,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Ámen',
                style: TextStyle(
                  color: corIcone,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  fontStyle: FontStyle.italic,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBlocoOracaoSenhor() {
    final texto = _limparTexto(textoLivreConteudo);
    final corTexto = modoEscuro ? textoEscuro : textoClaro;

    const corOracao = Color(0xFF6A4C93);
    const corOracaoSuave = Color(0xFF8B6FB0);

    final corFundo = modoEscuro
        ? corOracao.withOpacity(0.20)
        : corOracao.withOpacity(0.06);

    final corBorda = modoEscuro ? corOracaoSuave : corOracao;
    final corIcone = modoEscuro ? corOracaoSuave : corOracao;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
      decoration: BoxDecoration(
        color: corFundo,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: corBorda.withOpacity(0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: corBorda.withOpacity(0.08),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: corBorda.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.auto_awesome_rounded,
                  size: 20,
                  color: corIcone,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ORAÇÃO DO SENHOR',
                      style: TextStyle(
                        color: corIcone,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.6,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'O Pai Nosso',
                      style: TextStyle(
                        color: (modoEscuro
                                ? textoSecundarioEscuro
                                : textoSecundarioClaro)
                            .withOpacity(0.7),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  corBorda.withOpacity(0.0),
                  corBorda.withOpacity(0.4),
                  corBorda.withOpacity(0.0),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            texto,
            textAlign: TextAlign.start,
            style: TextStyle(
              color: corTexto,
              fontSize: tamanhoFonte,
              height: 1.65,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Ámen',
                style: TextStyle(
                  color: corIcone,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  fontStyle: FontStyle.italic,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBlocoTextoMarcado({
    required String texto,
    required Color corTexto,
    required Color? corDestaque,
  }) {
    final possuiMarcacao = marcado && corDestaque != null;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      width: double.infinity,
      padding: possuiMarcacao
          ? const EdgeInsets.fromLTRB(18, 14, 18, 14)
          : EdgeInsets.zero,
      decoration: possuiMarcacao
          ? BoxDecoration(
              color: corDestaque!.withOpacity(
                modoEscuro ? 0.14 : 0.20,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border(
                left: BorderSide(
                  color: corDestaque,
                  width: 5,
                ),
              ),
            )
          : null,
      child: Text(
        texto,
        textAlign: TextAlign.start,
        style: TextStyle(
          color: corTexto,
          fontSize: tamanhoFonte,
          height: 1.6,
        ),
      ),
    );
  }

  Widget _buildBlocoCoro({
    required String texto,
    required Color corTexto,
  }) {
    final corFundo = modoEscuro
        ? primary.withOpacity(0.18)
        : primary.withOpacity(0.08);

    final corBorda = modoEscuro
        ? secondaryContainer.withOpacity(0.85)
        : primary;

    final corLabel = modoEscuro ? secondaryContainer : primary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: corFundo,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(color: corBorda, width: 5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.music_note_rounded,
                size: 16,
                color: corLabel,
              ),
              const SizedBox(width: 6),
              Text(
                'CORO',
                style: TextStyle(
                  color: corLabel,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            texto,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: corTexto,
              fontSize: tamanhoFonte,
              height: 1.6,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInformacao() {
    final cor =
        modoEscuro ? textoSecundarioEscuro : textoSecundarioClaro;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: modoEscuro
                ? Colors.white.withOpacity(0.08)
                : const Color(0x145B4040),
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(iconeConteudo, size: 16, color: cor),
              const SizedBox(width: 6),
              const Text(
                'Hinário IECA',
                style: TextStyle(
                  color: textoSecundarioClaro,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            categoriaConteudo,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: cor.withOpacity(0.75),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarraNavegacao() {
    final corTexto = modoEscuro ? textoEscuro : textoClaro;
    final corSec =
        modoEscuro ? textoSecundarioEscuro : textoSecundarioClaro;

    final temMultiplos = _lista.length > 1;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: modoEscuro
            ? const Color(0xFF171A21)
            : Colors.white.withOpacity(0.85),
        border: Border(
          top: BorderSide(
            color: modoEscuro
                ? Colors.white.withOpacity(0.06)
                : const Color(0x145B4040),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _botaoNavegacao(
              icone: Icons.chevron_left_rounded,
              texto: 'Anterior',
              ativo: _temAnterior,
              corTexto: corTexto,
              onTap: _anterior,
              alinhamento: MainAxisAlignment.start,
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: modoEscuro
                  ? const Color(0xFF1F232B)
                  : const Color(0xFFEFF4FF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              temMultiplos
                  ? '${_indiceAtual + 1} / ${_lista.length}'
                  : '1 / 1',
              style: TextStyle(
                color: corSec,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),

          Expanded(
            child: _botaoNavegacao(
              icone: Icons.chevron_right_rounded,
              texto: 'Próximo',
              ativo: _temProximo,
              corTexto: corTexto,
              onTap: _proximo,
              alinhamento: MainAxisAlignment.end,
              inverter: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _botaoNavegacao({
    required IconData icone,
    required String texto,
    required bool ativo,
    required Color corTexto,
    required VoidCallback onTap,
    required MainAxisAlignment alinhamento,
    bool inverter = false,
  }) {
    final cor = ativo ? corTexto : corTexto.withOpacity(0.3);

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: ativo ? onTap : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          mainAxisAlignment: alinhamento,
          children: [
            if (!inverter) Icon(icone, color: cor, size: 24),
            if (!inverter) const SizedBox(width: 4),
            Flexible(
              child: Text(
                texto,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: cor,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (inverter) const SizedBox(width: 4),
            if (inverter) Icon(icone, color: cor, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildRodape() {
    return Container(
      decoration: BoxDecoration(
        color: modoEscuro
            ? const Color(0xF2111318)
            : const Color(0xF2F8F9FF),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 12,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() => modoLeitura = true);
              },
              icon: const Icon(Icons.fullscreen, size: 20),
              label: const Text('Modo leitura'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                elevation: 2,
                minimumSize: const Size(0, 42),
                padding: const EdgeInsets.symmetric(horizontal: 18),
                shape: const StadiumBorder(),
              ),
            ),
          ),
          NavegacaoInferiorIeca(
            indiceSelecionado: 1,
            onDestinationSelected: _selecionarNavegacao,
          ),
        ],
      ),
    );
  }

  Widget _buildModoLeitura() {
    final corTexto = modoEscuro ? textoEscuro : textoClaro;

    return Stack(
      children: [
        Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(40),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: const BoxDecoration(
                      color: primary,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      numeroConteudo,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    tituloConteudo,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: corTexto,
                      fontSize: 34,
                      height: 1.25,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (subtituloConteudo.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      subtituloConteudo,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: modoEscuro
                            ? textoSecundarioEscuro
                            : textoSecundarioClaro,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 30),
                  _buildTexto(),
                ],
              ),
            ),
          ),
        ),

        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: Row(
            children: [
              if (_lista.length > 1)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: modoEscuro
                        ? const Color(0xFF1F232B)
                        : Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: _temAnterior ? _anterior : null,
                        icon: Icon(
                          Icons.chevron_left_rounded,
                          color: _temAnterior
                              ? corTexto
                              : corTexto.withOpacity(0.3),
                        ),
                      ),
                      Text(
                        '${_indiceAtual + 1}/${_lista.length}',
                        style: TextStyle(
                          color: corTexto.withOpacity(0.7),
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      IconButton(
                        onPressed: _temProximo ? _proximo : null,
                        icon: Icon(
                          Icons.chevron_right_rounded,
                          color: _temProximo
                              ? corTexto
                              : corTexto.withOpacity(0.3),
                        ),
                      ),
                    ],
                  ),
                ),
              const Spacer(),
              IconButton(
                tooltip: 'Sair do modo leitura',
                onPressed: () {
                  setState(() => modoLeitura = false);
                },
                icon: Icon(
                  Icons.close_fullscreen,
                  color: corTexto,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ResultadoMarcacao {
  final Color? cor;
  final bool remover;

  const _ResultadoMarcacao({
    this.cor,
    this.remover = false,
  });

  factory _ResultadoMarcacao.cor(Color cor) {
    return _ResultadoMarcacao(cor: cor);
  }

  factory _ResultadoMarcacao.remover() {
    return const _ResultadoMarcacao(remover: true);
  }
}

class _BlocoConteudo {
  final String texto;
  final bool isCoro;

  const _BlocoConteudo({
    required this.texto,
    required this.isCoro,
  });

  factory _BlocoConteudo.estrofe(String texto) {
    return _BlocoConteudo(texto: texto, isCoro: false);
  }

  factory _BlocoConteudo.coro(String texto) {
    return _BlocoConteudo(texto: texto, isCoro: true);
  }
}

class LeituraItem {
  final Hino? hino;
  final Invocatoria? invocatoria;
  final Litania? litania;
  final Salmo? salmo;
  final TextoLiturgico? textoLiturgico;
  final FavoritoItem? favorito;
  final String? titulo;
  final String? subtitulo;
  final IconData? icone;
  final String? textoLivre;

  const LeituraItem({
    this.hino,
    this.invocatoria,
    this.litania,
    this.salmo,
    this.textoLiturgico,
    this.favorito,
    this.titulo,
    this.subtitulo,
    this.icone,
    this.textoLivre,
  });

  LeituraItem copyWith({
    Hino? hino,
    Invocatoria? invocatoria,
    Litania? litania,
    Salmo? salmo,
    TextoLiturgico? textoLiturgico,
    FavoritoItem? favorito,
    String? titulo,
    String? subtitulo,
    IconData? icone,
    String? textoLivre,
  }) {
    return LeituraItem(
      hino: hino ?? this.hino,
      invocatoria: invocatoria ?? this.invocatoria,
      litania: litania ?? this.litania,
      salmo: salmo ?? this.salmo,
      textoLiturgico: textoLiturgico ?? this.textoLiturgico,
      favorito: favorito ?? this.favorito,
      titulo: titulo ?? this.titulo,
      subtitulo: subtitulo ?? this.subtitulo,
      icone: icone ?? this.icone,
      textoLivre: textoLivre ?? this.textoLivre,
    );
  }
}