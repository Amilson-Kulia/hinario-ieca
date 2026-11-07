import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/tema.dart';
import '../../../componentes/cabecalho_ieca.dart';
import '../../../componentes/navegacao_inferior_ieca.dart';
import '../../../modelos/hino.dart';
import '../../informacoes_ieca/informacoes_ieca_tela.dart';
import '../idiomas_tela.dart';
import '../../biblia/biblia_tela.dart';
import '../../sobre/sobre_tela.dart';
import '../leitura_tela.dart';

class HinosPortuguesTela extends StatefulWidget {
  const HinosPortuguesTela({super.key});

  @override
  State<HinosPortuguesTela> createState() =>
      _HinosPortuguesTelaState();
}

class _HinosPortuguesTelaState
    extends State<HinosPortuguesTela> {
  final TextEditingController _pesquisaController =
      TextEditingController();

  String _filtroAtual = 'Número';

  // =========================================================
  // ESTADO DOS DADOS
  // =========================================================

  List<Hino> _hinos = [];

  bool _carregando = true;

  String? _erro;

  /// Categorias atualmente expandidas (pelo utilizador).
  /// Durante a pesquisa, este conjunto é ignorado — todas as
  /// categorias com correspondência abrem automaticamente.
  final Set<String> _categoriasAbertas = {};

  // =========================================================
  // CICLO DE VIDA
  // =========================================================

  @override
  void initState() {
    super.initState();

    _pesquisaController.addListener(
      _atualizarPesquisa,
    );

    _carregarHinos();
  }

  @override
  void dispose() {
    _pesquisaController.removeListener(
      _atualizarPesquisa,
    );

    _pesquisaController.dispose();

    super.dispose();
  }

  // =========================================================
  // ATUALIZAR PESQUISA
  // =========================================================

  void _atualizarPesquisa() {
    if (mounted) {
      setState(() {});
    }
  }

  // =========================================================
  // CARREGAR HINOS DE UMBUNDO
  // =========================================================

  Future<void> _carregarHinos() async {
    try {
      final String jsonString =
          await rootBundle.loadString(
        'assets/dados/hinos_umbundo.json',
      );

      final dynamic dados =
          json.decode(jsonString);

      final List<dynamic> lista;

      if (dados is List) {
        lista = dados;
      } else if (dados is Map<String, dynamic> &&
          dados['hinos'] is List) {
        lista =
            dados['hinos'] as List<dynamic>;
      } else {
        throw const FormatException(
          'Formato inválido do arquivo de hinos.',
        );
      }

      final List<Hino> hinos = [];

      for (final item in lista) {
        if (item is! Map) {
          continue;
        }

        try {
          final Map<String, dynamic> mapa =
              Map<String, dynamic>.from(item);

          hinos.add(
            Hino.fromJson(mapa),
          );
        } catch (e) {
          debugPrint(
            'Erro ao converter hino de Umbundo: $e',
          );
        }
      }

      hinos.sort(
        (a, b) => a.numero.compareTo(
          b.numero,
        ),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _hinos = hinos;
        _carregando = false;
        _erro = null;
      });
    } catch (e) {
      debugPrint(
        'ERRO AO CARREGAR HINOS UMBUNDO: $e',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _carregando = false;
        _hinos = [];
        _erro =
            'Não foi possível carregar os hinos em Umbundo.';
      });
    }
  }

  // =========================================================
  // CATEGORIAS (todas, agrupadas)
  // =========================================================

  /// Estrutura de cada categoria:
  /// {
  ///   'titulo': String,
  ///   'inicio': int,
  ///   'fim': int,
  ///   'hinos': List<Hino>,
  ///   'hinosFiltrados': List<Hino>,
  /// }
  List<Map<String, dynamic>> get _categorias {
    final Map<String, List<Hino>> agrupadas = {};

    for (final hino in _hinos) {
      final String categoria =
          hino.categoria.trim();

      if (categoria.isEmpty) continue;

      agrupadas.putIfAbsent(categoria, () => []);
      agrupadas[categoria]!.add(hino);
    }

    final List<Map<String, dynamic>> categorias = [];

    for (final entrada in agrupadas.entries) {
      final List<Hino> lista =
          List<Hino>.from(entrada.value)
            ..sort(
              (a, b) =>
                  a.numero.compareTo(b.numero),
            );

      if (lista.isEmpty) continue;

      categorias.add({
        'titulo': entrada.key,
        'inicio': lista.first.numero,
        'fim': lista.last.numero,
        'hinos': lista,
        'hinosFiltrados': lista,
      });
    }

    categorias.sort(
      (a, b) => (a['inicio'] as int)
          .compareTo(b['inicio'] as int),
    );

    return categorias;
  }

  // =========================================================
  // CATEGORIAS FILTRADAS PELA PESQUISA
  // =========================================================

  List<Map<String, dynamic>> get _categoriasFiltradas {
    final String pesquisa =
        _pesquisaController.text.trim().toLowerCase();

    final categorias = _categorias;

    if (pesquisa.isEmpty) {
      return categorias;
    }

    final List<Map<String, dynamic>> resultado = [];

    for (final cat in categorias) {
      final List<Hino> todos =
          cat['hinos'] as List<Hino>;

      final List<Hino> filtrados;

      if (_filtroAtual == 'Nome') {
        filtrados = todos.where((h) {
          return h.titulo
              .toLowerCase()
              .contains(pesquisa);
        }).toList();
      } else {
        // Filtro "Número"
        filtrados = todos.where((h) {
          return h.numero
              .toString()
              .contains(pesquisa);
        }).toList();
      }

      if (filtrados.isEmpty) continue;

      resultado.add({
        ...cat,
        'hinosFiltrados': filtrados,
      });
    }

    return resultado;
  }

  // =========================================================
  // ABRIR HINO (com navegação só dentro da categoria)
  // =========================================================

  void _abrirHino(
    Hino hino,
    List<Hino> hinosDaCategoria,
  ) {
    final int indice = hinosDaCategoria
        .indexWhere((h) => h.numero == hino.numero);

    final List<LeituraItem> listaNavegacao =
        hinosDaCategoria
            .map((h) => LeituraItem(hino: h))
            .toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LeituraTela(
          indiceInicial: indice < 0 ? 0 : indice,
          listaNavegacao: listaNavegacao,
        ),
      ),
    );
  }

  // =========================================================
  // TOGGLE DE CATEGORIA
  // =========================================================

  void _toggleCategoria(String titulo) {
    setState(() {
      if (_categoriasAbertas.contains(titulo)) {
        _categoriasAbertas.remove(titulo);
      } else {
        _categoriasAbertas.add(titulo);
      }
    });
  }

  // =========================================================
  // NAVEGAÇÃO INFERIOR
  // =========================================================

  void _selecionarNavegacao(int indice) {
    if (!mounted) return;

    switch (indice) {
      case 0:
        // Já estamos no Hinário.
        break;

      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const IdiomasTela(),
          ),
        );
        break;

      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const BibliaTela(),
          ),
        );
        break;

      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                const InformacoesIecaTela(),
          ),
        );
        break;

      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const SobreTela(),
          ),
        );
        break;
    }
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TemaHinario.corSuperficie,

      appBar: const CabecalhoIeca(),

      body: SafeArea(
        top: false,
        bottom: false,
        child: _buildConteudo(),
      ),

      bottomNavigationBar: NavegacaoInferiorIeca(
        indiceSelecionado: 1,
        onDestinationSelected: _selecionarNavegacao,
      ),
    );
  }

  // =========================================================
  // CONTEÚDO
  // =========================================================

  Widget _buildConteudo() {
    if (_carregando) {
      return const Center(
        child: CircularProgressIndicator(
          color: TemaHinario.corPrimaria,
        ),
      );
    }

    if (_erro != null) {
      return _buildErro();
    }

    final categorias = _categoriasFiltradas;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _buildCabecalhoPagina(),
        ),

        SliverPersistentHeader(
          pinned: true,
          delegate: _PesquisaDelegate(
            child: _buildPesquisa(categorias.length),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            20,
            20,
            20,
            32,
          ),
          sliver: categorias.isEmpty
              ? const SliverFillRemaining(
                  hasScrollBody: false,
                  child: _NenhumResultado(),
                )
              : SliverList(
                  delegate:
                      SliverChildBuilderDelegate(
                    (context, index) {
                      final categoria = categorias[index];

                      final String titulo =
                          categoria['titulo'] as String;

                      final bool temPesquisa =
                          _pesquisaController.text
                              .trim()
                              .isNotEmpty;

                      // Durante a pesquisa, todas as categorias
                      // com correspondência abrem automaticamente.
                      final bool aberta = temPesquisa ||
                          _categoriasAbertas.contains(titulo);

                      return Padding(
                        padding:
                            const EdgeInsets.only(bottom: 12),
                        child: _CartaoCategoriaExpansivel(
                          categoria: categoria,
                          aberta: aberta,
                          onToggle: () =>
                              _toggleCategoria(titulo),
                          onHinoTap: (hino) => _abrirHino(
                            hino,
                            categoria['hinos']
                                as List<Hino>,
                          ),
                        ),
                      );
                    },
                    childCount: categorias.length,
                  ),
                ),
        ),
      ],
    );
  }

  // =========================================================
  // CABEÇALHO DA PÁGINA
  // =========================================================

  Widget _buildCabecalhoPagina() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        24,
        24,
        24,
        20,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: TemaHinario.corPrimaria
                  .withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.music_note_rounded,
              color: TemaHinario.corPrimaria,
              size: 27,
            ),
          ),

          const SizedBox(width: 14),

          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Hinos',
                  style: TextStyle(
                    fontSize: 28,
                    height: 1.15,
                    fontWeight: FontWeight.w800,
                    color: TemaHinario.corTexto,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Hinos em Umbundo',
                  style: TextStyle(
                    fontSize: 14,
                    color: TemaHinario
                        .corTextoSecundario,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // PESQUISA
  // =========================================================

  Widget _buildPesquisa(int totalCategorias) {
    final bool temTexto =
        _pesquisaController.text.isNotEmpty;

    return Container(
      width: double.infinity,
      color: TemaHinario.corSuperficie,
      padding: const EdgeInsets.fromLTRB(
        20,
        8,
        20,
        14,
      ),
      child: Column(
        children: [
          Container(
            height: 52,
            decoration: BoxDecoration(
              color: TemaHinario.corSuperficieMedia,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: TemaHinario
                    .corTextoSecundario
                    .withValues(alpha: 0.10),
              ),
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),

                const Icon(
                  Icons.search_rounded,
                  size: 23,
                  color:
                      TemaHinario.corTextoSecundario,
                ),

                const SizedBox(width: 11),

                Expanded(
                  child: TextField(
                    controller: _pesquisaController,
                    textInputAction:
                        TextInputAction.search,
                    decoration: const InputDecoration(
                      hintText:
                          'Pesquisar hino por número ou título...',
                      hintStyle: TextStyle(
                        color: TemaHinario
                            .corTextoSecundario,
                        fontSize: 15,
                      ),
                      border: InputBorder.none,
                      isCollapsed: true,
                    ),
                    style: const TextStyle(
                      color: TemaHinario.corTexto,
                      fontSize: 15,
                    ),
                  ),
                ),

                if (temTexto)
                  IconButton(
                    tooltip: 'Limpar pesquisa',
                    onPressed: () {
                      _pesquisaController.clear();
                    },
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: TemaHinario
                          .corTextoSecundario,
                    ),
                  )
                else
                  const SizedBox(width: 8),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              _buildFiltro(
                icone:
                    Icons.format_list_numbered_rounded,
                texto: 'Número',
              ),

              const SizedBox(width: 8),

              _buildFiltro(
                icone: Icons.sort_by_alpha_rounded,
                texto: 'Nome',
              ),

              const Spacer(),

              Text(
                '$totalCategorias '
                '${totalCategorias == 1 ? 'categoria' : 'categorias'}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color:
                      TemaHinario.corTextoSecundario,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =========================================================
  // FILTRO
  // =========================================================

  Widget _buildFiltro({
    required IconData icone,
    required String texto,
  }) {
    final bool ativo = _filtroAtual == texto;

    return Material(
      color: ativo
          ? TemaHinario.corPrimaria
          : TemaHinario.corSuperficieMedia,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: () {
          setState(() {
            _filtroAtual = texto;
          });
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 8,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icone,
                size: 16,
                color: ativo
                    ? Colors.white
                    : TemaHinario
                        .corTextoSecundario,
              ),
              const SizedBox(width: 5),
              Text(
                texto,
                style: TextStyle(
                  color: ativo
                      ? Colors.white
                      : TemaHinario
                          .corTextoSecundario,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // ERRO
  // =========================================================

  Widget _buildErro() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: TemaHinario.corPrimaria
                    .withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 36,
                color: TemaHinario.corPrimaria,
              ),
            ),

            const SizedBox(height: 18),

            Text(
              _erro!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: TemaHinario.corTexto,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: _carregarHinos,
              icon: const Icon(
                Icons.refresh_rounded,
              ),
              label: const Text(
                'Tentar novamente',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    TemaHinario.corPrimaria,
                foregroundColor: Colors.white,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================
// CARTÃO DE CATEGORIA EXPANSÍVEL
// =============================================================

class _CartaoCategoriaExpansivel extends StatelessWidget {
  final Map<String, dynamic> categoria;
  final bool aberta;
  final VoidCallback onToggle;
  final ValueChanged<Hino> onHinoTap;

  const _CartaoCategoriaExpansivel({
    required this.categoria,
    required this.aberta,
    required this.onToggle,
    required this.onHinoTap,
  });

  @override
  Widget build(BuildContext context) {
    final int inicio = categoria['inicio'] as int;
    final int fim = categoria['fim'] as int;
    final String titulo = categoria['titulo'] as String;

    final List<Hino> hinos =
        categoria['hinos'] as List<Hino>;
    final List<Hino> hinosFiltrados =
        categoria['hinosFiltrados'] as List<Hino>;

    final bool emPesquisa =
        hinosFiltrados.length != hinos.length;

    final int quantidade = emPesquisa
        ? hinosFiltrados.length
        : hinos.length;

    final String intervalo = inicio == fim
        ? '$inicio'
        : '$inicio-$fim';

    // Durante a pesquisa, mostramos apenas os hinos filtrados.
    final List<Hino> hinosVisiveis =
        emPesquisa ? hinosFiltrados : hinos;

    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: TemaHinario.corSuperficie,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: TemaHinario.corPrimaria
                .withValues(alpha: 0.10),
          ),
          boxShadow: [
            BoxShadow(
              color:
                  Colors.black.withValues(alpha: 0.035),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // =================================================
            // CABEÇALHO (clicável para expandir/colapsar)
            // =================================================

            InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: onToggle,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Intervalo
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: TemaHinario.corPrimaria
                            .withValues(alpha: 0.08),
                        borderRadius:
                            BorderRadius.circular(18),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        intervalo,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color:
                              TemaHinario.corPrimaria,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),

                    const SizedBox(width: 15),

                    // Informações
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            titulo,
                            maxLines: 2,
                            overflow:
                                TextOverflow.ellipsis,
                            style: const TextStyle(
                              color:
                                  TemaHinario.corTexto,
                              fontSize: 17,
                              height: 1.3,
                              fontWeight:
                                  FontWeight.w700,
                            ),
                          ),

                          const SizedBox(height: 6),

                          Row(
                            children: [
                              const Icon(
                                Icons
                                    .library_music_outlined,
                                size: 15,
                                color: TemaHinario
                                    .corTextoSecundario,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                quantidade == 1
                                    ? '1 hino'
                                    : '$quantidade hinos',
                                style:
                                    const TextStyle(
                                  color: TemaHinario
                                      .corTextoSecundario,
                                  fontSize: 13,
                                  fontWeight:
                                      FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 10),

                    // Seta (roda 90° quando aberta)
                    AnimatedRotation(
                      turns: aberta ? 0.25 : 0,
                      duration:
                          const Duration(milliseconds: 200),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: TemaHinario
                              .corSuperficieMedia,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons
                              .arrow_forward_ios_rounded,
                          size: 14,
                          color: TemaHinario
                              .corTextoSecundario,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // =================================================
            // CÍRCULOS DOS HINOS (quando aberta)
            // =================================================

            AnimatedCrossFade(
              duration:
                  const Duration(milliseconds: 200),
              crossFadeState: aberta
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: const SizedBox(
                width: double.infinity,
                height: 0,
              ),
              secondChild: Padding(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  0,
                  16,
                  16,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Divider(
                      height: 1,
                      color: TemaHinario
                          .corTextoSecundario
                          .withValues(alpha: 0.10),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: hinosVisiveis
                          .map(
                            (hino) => _CirculoHino(
                              hino: hino,
                              onTap: () =>
                                  onHinoTap(hino),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================
// CÍRCULO DO HINO
// =============================================================

class _CirculoHino extends StatelessWidget {
  final Hino hino;
  final VoidCallback onTap;

  const _CirculoHino({
    required this.hino,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: TemaHinario.corPrimaria
          .withValues(alpha: 0.08),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: TemaHinario.corPrimaria
                  .withValues(alpha: 0.20),
            ),
          ),
          child: Text(
            hino.numero.toString(),
            style: const TextStyle(
              color: TemaHinario.corPrimaria,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================
// NENHUM RESULTADO
// =============================================================

class _NenhumResultado extends StatelessWidget {
  const _NenhumResultado();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: TemaHinario.corPrimaria
                    .withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 34,
                color: TemaHinario.corPrimaria,
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'Nenhum hino encontrado',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: TemaHinario.corTexto,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 7),

            const Text(
              'Tente pesquisar por outro número '
              'ou título de hino.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color:
                    TemaHinario.corTextoSecundario,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================
// HEADER STICKY DA PESQUISA
// =============================================================

class _PesquisaDelegate
    extends SliverPersistentHeaderDelegate {
  final Widget child;

  _PesquisaDelegate({required this.child});

  @override
  double get minExtent => 132;

  @override
  double get maxExtent => 132;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Material(
      color: TemaHinario.corSuperficie,
      elevation: overlapsContent ? 2 : 0,
      child: child,
    );
  }

  @override
  bool shouldRebuild(
    covariant _PesquisaDelegate oldDelegate,
  ) {
    return true;
  }
}