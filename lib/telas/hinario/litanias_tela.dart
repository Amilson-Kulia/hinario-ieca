import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/tema.dart';
import '../../componentes/cabecalho_ieca.dart';
import '../../componentes/navegacao_inferior_ieca.dart';
import '../../modelos/litania.dart';
import '../biblia/biblia_tela.dart';
import '../home/home_tela.dart';
import '../programa_culto/criar_programa_tela.dart';
import '../sobre/sobre_tela.dart';
import 'leitura_tela.dart';
import '../informacoes_ieca/informacoes_ieca_tela.dart';


class LitaniasTela extends StatefulWidget {
  const LitaniasTela({super.key});

  @override
  State<LitaniasTela> createState() => _LitaniasTelaState();
}

class _LitaniasTelaState extends State<LitaniasTela> {
  final TextEditingController _pesquisaController =
      TextEditingController();

  String _filtroAtual = 'ordem';

  List<Litania> _litanias = [];

  bool _carregando = true;

  @override
  void initState() {
    super.initState();

    _carregarLitanias();
  }

  @override
  void dispose() {
    _pesquisaController.dispose();

    super.dispose();
  }

  // =========================================================
  // CARREGAR LITANIAS DO JSON
  // =========================================================

  Future<void> _carregarLitanias() async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/dados/litanias.json',
      );

      final List dados = json.decode(jsonString);

      final litanias = dados
          .map(
            (item) => Litania.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();

      if (!mounted) return;

      setState(() {
        _litanias = litanias;
        _carregando = false;
      });
    } catch (e) {
      debugPrint(
        'ERRO AO CARREGAR LITANIAS: $e',
      );

      if (!mounted) return;

      setState(() {
        _carregando = false;
        _litanias = [];
      });
    }
  }

  // =========================================================
  // RESULTADOS
  // =========================================================

  List<Litania> get _resultados {
    final termo =
        _pesquisaController.text.trim().toLowerCase();

    List<Litania> resultados =
        List<Litania>.from(_litanias);

    // ---------------------------------------------------------
    // PESQUISA
    // ---------------------------------------------------------

    if (termo.isNotEmpty) {
      resultados = resultados.where((litania) {
        return litania.titulo
                .toLowerCase()
                .contains(termo) ||
            litania.subtitulo
                .toLowerCase()
                .contains(termo);
      }).toList();
    }

    // ---------------------------------------------------------
    // ORDEM ALFABÉTICA
    // ---------------------------------------------------------

    if (_filtroAtual == 'alfabetica') {
      resultados.sort(
        (a, b) => a.titulo.compareTo(b.titulo),
      );
    }

    return resultados;
  }

  // =========================================================
  // ALTERAR FILTRO
  // =========================================================

  void _alterarFiltro(String filtro) {
    setState(() {
      _filtroAtual = filtro;
    });
  }

  // =========================================================
  // ABRIR LITANIA
  // =========================================================
  //
  // A LeituraTela é a mesma utilizada para:
  // - Hinos
  // - Invocatórias
  // - Litanias
  //
  // =========================================================

  void _abrirLitania(Litania litania) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LeituraTela(
          litania: litania,
        ),
      ),
    );
  }

  // =========================================================
  // NAVEGAÇÃO PRINCIPAL
  // =========================================================

  void _selecionarNavegacao(int indice) {
  // =======================================================
  // HINÁRIO
  // =======================================================

  if (indice == 1) {
    Navigator.pop(context);
    return;
  }

  Widget tela;

  switch (indice) {
    // =====================================================
    // HOME
    // =====================================================

    case 0:
      tela = const HomeTela();
      break;

    // =====================================================
    // BÍBLIA
    // =====================================================

    case 2:
      tela = const BibliaTela();
      break;

    // =====================================================
    // INFORMAÇÕES DA IECA
    // =====================================================

    case 3:
      tela = const InformacoesIecaTela();
      break;

    // =====================================================
    // SOBRE
    // =====================================================

    case 4:
      tela = const SobreTela();
      break;

    default:
      return;
  }

  Navigator.pushReplacement(
    context,
    MaterialPageRoute<void>(
      builder: (_) => tela,
    ),
  );
}
  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    final resultados = _resultados;

    return Scaffold(
      backgroundColor: TemaHinario.corSuperficie,

      // =======================================================
      // CABEÇALHO PADRÃO IECA
      // =======================================================

      appBar: const CabecalhoIeca(),

      // =======================================================
      // CONTEÚDO
      // =======================================================

      body: SafeArea(
        top: false,
        bottom: false,
        child: _carregando
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : CustomScrollView(
                slivers: [
                  // -------------------------------------------------
                  // INTRODUÇÃO
                  // -------------------------------------------------

                  SliverToBoxAdapter(
                    child: _buildIntroducao(),
                  ),

                  // -------------------------------------------------
                  // PESQUISA E FILTROS
                  // -------------------------------------------------

                  SliverToBoxAdapter(
                    child: _buildPesquisa(),
                  ),

                  // -------------------------------------------------
                  // CONTADOR
                  // -------------------------------------------------

                  SliverToBoxAdapter(
                    child: _buildContador(
                      resultados.length,
                    ),
                  ),

                  // -------------------------------------------------
                  // LISTA
                  // -------------------------------------------------

                  if (resultados.isNotEmpty)
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        20,
                        12,
                        20,
                        110,
                      ),
                      sliver: SliverList(
                        delegate:
                            SliverChildBuilderDelegate(
                          (context, index) {
                            final litania =
                                resultados[index];

                            return Padding(
                              padding:
                                  const EdgeInsets.only(
                                bottom: 12,
                              ),
                              child:
                                  _buildLitaniaItem(
                                litania,
                              ),
                            );
                          },
                          childCount:
                              resultados.length,
                        ),
                      ),
                    )
                  else
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _buildEstadoVazio(),
                    ),
                ],
              ),
      ),

      // =========================================================
      // RODAPÉ PADRÃO IECA
      // =========================================================

      bottomNavigationBar: NavegacaoInferiorIeca(
        indiceSelecionado: 1,
        onDestinationSelected:
            _selecionarNavegacao,
      ),
    );
  }

  // =========================================================
  // INTRODUÇÃO
  // =========================================================

  Widget _buildIntroducao() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        24,
        20,
        16,
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: TemaHinario.corPrimaria
                  .withValues(alpha: 0.10),
              borderRadius:
                  BorderRadius.circular(18),
            ),
            child: Icon(
              Icons.church_outlined,
              size: 30,
              color: TemaHinario.corPrimaria,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Litanias',
                  style: TextStyle(
                    color: TemaHinario.corTexto,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'Orações e liturgias para diferentes momentos '
                  'do culto e da vida cristã.',
                  style: TextStyle(
                    color:
                        TemaHinario.corTextoSecundario,
                    fontSize: 13,
                    height: 1.45,
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

  Widget _buildPesquisa() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        20,
        8,
        20,
        16,
      ),
      decoration: BoxDecoration(
        color: TemaHinario.corSuperficie
            .withValues(alpha: 0.96),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 50,
            padding:
                const EdgeInsets.symmetric(
              horizontal: 14,
            ),
            decoration: BoxDecoration(
              color: TemaHinario
                  .corSecundaria
                  .withValues(alpha: 0.10),
              borderRadius:
                  BorderRadius.circular(999),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.search,
                  size: 24,
                  color: TemaHinario
                      .corTextoSecundario
                      .withValues(alpha: 0.55),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: TextField(
                    controller:
                        _pesquisaController,
                    onChanged: (_) {
                      setState(() {});
                    },
                    style: TextStyle(
                      color:
                          TemaHinario.corTexto,
                      fontSize: 15,
                    ),
                    decoration:
                        InputDecoration(
                      border:
                          InputBorder.none,
                      hintText:
                          'Pesquisar litania...',
                      hintStyle: TextStyle(
                        color: TemaHinario
                            .corTextoSecundario
                            .withValues(
                              alpha: 0.50,
                            ),
                        fontSize: 15,
                      ),
                      isDense: true,
                    ),
                  ),
                ),

                if (_pesquisaController
                    .text
                    .isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _pesquisaController
                          .clear();

                      setState(() {});
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration:
                          BoxDecoration(
                        color: TemaHinario
                            .corSuperficieMedia
                            .withValues(
                              alpha: 0.35,
                            ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        size: 19,
                        color: TemaHinario
                            .corTextoSecundario,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          SingleChildScrollView(
            scrollDirection:
                Axis.horizontal,
            child: Row(
              children: [
                _buildFiltro(
                  'ordem',
                  Icons.format_list_numbered,
                  'Ordem',
                ),

                const SizedBox(width: 8),

                _buildFiltro(
                  'alfabetica',
                  Icons.sort_by_alpha,
                  'A-Z',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // FILTRO
  // =========================================================

  Widget _buildFiltro(
    String filtro,
    IconData icone,
    String texto,
  ) {
    final ativo =
        _filtroAtual == filtro;

    return GestureDetector(
      onTap: () =>
          _alterarFiltro(filtro),
      child: AnimatedContainer(
        duration:
            const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: ativo
              ? TemaHinario.corPrimaria
              : TemaHinario.corSuperficieAlta,
          borderRadius:
              BorderRadius.circular(999),
          boxShadow: ativo
              ? const [
                  BoxShadow(
                    color:
                        Color(0x14000000),
                    blurRadius: 6,
                    offset:
                        Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icone,
              size: 16,
              color: ativo
                  ? TemaHinario.corBranca
                  : TemaHinario
                      .corTextoSecundario,
            ),

            const SizedBox(width: 5),

            Text(
              texto,
              style: TextStyle(
                color: ativo
                    ? TemaHinario.corBranca
                    : TemaHinario
                        .corTextoSecundario,
                fontSize: 12,
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // CONTADOR
  // =========================================================

  Widget _buildContador(
    int quantidade,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        20,
        20,
        4,
      ),
      child: Align(
        alignment:
            Alignment.centerLeft,
        child: Text(
          '$quantidade '
          '${quantidade == 1 ? 'litania' : 'litanias'}',
          style: TextStyle(
            color: TemaHinario
                .corTextoSecundario,
            fontSize: 12,
            fontWeight:
                FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // =========================================================
  // ITEM DA LITANIA
  // =========================================================

  Widget _buildLitaniaItem(
    Litania litania,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius:
            BorderRadius.circular(16),
        onTap: () =>
            _abrirLitania(litania),
        child: Container(
          constraints:
              const BoxConstraints(
            minHeight: 104,
          ),
          decoration: BoxDecoration(
            color:
                Colors.white.withValues(alpha: 0.80),
            borderRadius:
                BorderRadius.circular(16),
            border: Border.all(
              color: TemaHinario
                  .corTextoSecundario
                  .withValues(alpha: 0.30),
            ),
            boxShadow: const [
              BoxShadow(
                color:
                    Color(0x14000000),
                blurRadius: 20,
                spreadRadius: -10,
                offset:
                    Offset(0, 4),
              ),
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(
                  width: 4,
                  decoration:
                      BoxDecoration(
                    color: TemaHinario
                        .corPrimaria,
                    borderRadius:
                        const BorderRadius
                            .only(
                      topLeft:
                          Radius.circular(16),
                      bottomLeft:
                          Radius.circular(16),
                    ),
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets
                            .fromLTRB(
                      16,
                      16,
                      12,
                      16,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration:
                              BoxDecoration(
                            color: TemaHinario
                                .corPrimaria
                                .withValues(
                                  alpha: 0.09,
                                ),
                            borderRadius:
                                BorderRadius
                                    .circular(
                              15,
                            ),
                          ),
                          child: Icon(
                            Icons.church_outlined,
                            size: 26,
                            color:
                                TemaHinario
                                    .corPrimaria,
                          ),
                        ),

                        const SizedBox(
                          width: 14,
                        ),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .center,
                            children: [
                              Text(
                                litania.titulo,
                                maxLines: 2,
                                overflow:
                                    TextOverflow
                                        .ellipsis,
                                style:
                                    TextStyle(
                                  color:
                                      TemaHinario
                                          .corTexto,
                                  fontSize: 15,
                                  fontWeight:
                                      FontWeight
                                          .w700,
                                  height: 1.4,
                                ),
                              ),

                              const SizedBox(
                                height: 4,
                              ),

                              Text(
                                litania.subtitulo,
                                maxLines: 1,
                                overflow:
                                    TextOverflow
                                        .ellipsis,
                                style:
                                    TextStyle(
                                  color:
                                      TemaHinario
                                          .corTextoSecundario,
                                  fontSize: 11,
                                  height: 1.45,
                                ),
                              ),

                              const SizedBox(
                                height: 6,
                              ),

                              Text(
                                'LER LITANIA',
                                style:
                                    TextStyle(
                                  color:
                                      TemaHinario
                                          .corPrimaria,
                                  fontSize: 10,
                                  fontWeight:
                                      FontWeight
                                          .w700,
                                  letterSpacing:
                                      0.4,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(
                          width: 4,
                        ),

                        Icon(
                          Icons.chevron_right,
                          size: 22,
                          color: TemaHinario
                              .corTextoSecundario
                              .withValues(
                                alpha: 0.40,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================
  // ESTADO VAZIO
  // =========================================================

  Widget _buildEstadoVazio() {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 30,
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: TemaHinario
                    .corSuperficieAlta,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off,
                size: 32,
                color: TemaHinario
                    .corTextoSecundario,
              ),
            ),

            const SizedBox(height: 18),

            Text(
              'Nenhuma litania encontrada',
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                color:
                    TemaHinario.corTexto,
                fontSize: 17,
                fontWeight:
                    FontWeight.w700,
              ),
            ),

            const SizedBox(height: 7),

            Text(
              'Tente pesquisar por outro nome ou '
              'altere o filtro selecionado.',
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                color: TemaHinario
                    .corTextoSecundario,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}