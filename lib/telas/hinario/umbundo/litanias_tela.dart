import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
 
import '../../../app/tema.dart';
import '../../../componentes/cabecalho_ieca.dart';
import '../../../componentes/navegacao_inferior_ieca.dart';
import '../../../modelos/litania.dart';
import '../../biblia/biblia_tela.dart';
import '../../home/home_tela.dart';
import '../../informacoes_ieca/informacoes_ieca_tela.dart';
import '../../sobre/sobre_tela.dart';
import '../leitura_tela.dart';

class LitaniasTela extends StatefulWidget {
  const LitaniasTela({
    super.key,
  });

  @override
  State<LitaniasTela> createState() => _LitaniasTelaState();
}

class _LitaniasTelaState extends State<LitaniasTela> {
  final TextEditingController _pesquisaController =
      TextEditingController();

  String _filtroAtual = 'ordem';

  List<Litania> _litanias = [];

  bool _carregando = true;

  String? _erro;

  // =========================================================
  // CICLO DE VIDA
  // =========================================================

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
  // CARREGAR LITANIAS UMBUNDO
  // =========================================================

  Future<void> _carregarLitanias() async {
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/dados/litanias_umbundo.json',
      );

      final dynamic dados = json.decode(jsonString);

      final List<dynamic> lista;

      // -------------------------------------------------------
      // FORMATO 1
      // -------------------------------------------------------

      if (dados is List) {
        lista = dados;
      }

      // -------------------------------------------------------
      // FORMATO 2
      // -------------------------------------------------------

      else if (dados is Map<String, dynamic> &&
          dados['litanias'] is List) {
        lista = dados['litanias'] as List<dynamic>;
      }

      // -------------------------------------------------------
      // FORMATO INVÁLIDO
      // -------------------------------------------------------

      else {
        throw const FormatException(
          'Formato inválido do arquivo de litanias.',
        );
      }

      // -------------------------------------------------------
      // CONVERTER PARA MODELO
      // -------------------------------------------------------

      final List<Litania> litanias = [];

      for (final item in lista) {
        if (item is! Map) {
          continue;
        }

        try {
          final Map<String, dynamic> mapa =
              Map<String, dynamic>.from(item);

          litanias.add(
            Litania.fromJson(mapa),
          );
        } catch (e) {
          debugPrint(
            'Erro ao converter litania de Umbundo: $e',
          );
        }
      }

      if (!mounted) return;

      setState(() {
        _litanias = litanias;
        _carregando = false;
        _erro = null;
      });
    } catch (e) {
      debugPrint(
        'ERRO AO CARREGAR LITANIAS UMBUNDO: $e',
      );

      if (!mounted) return;

      setState(() {
        _carregando = false;
        _litanias = [];
        _erro =
            'Não foi possível carregar as litanias em Umbundo.';
      });
    }
  }

  // =========================================================
  // RESULTADOS
  // =========================================================

  List<Litania> get _resultados {
    final String termo =
        _pesquisaController.text.trim().toLowerCase();

    List<Litania> resultados =
        List<Litania>.from(_litanias);

    // ---------------------------------------------------------
    // PESQUISA
    // ---------------------------------------------------------

    if (termo.isNotEmpty) {
      resultados = resultados.where(
        (litania) {
          return litania.titulo
                  .toLowerCase()
                  .contains(termo) ||
              litania.subtitulo
                  .toLowerCase()
                  .contains(termo);
        },
      ).toList();
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
  // NAVEGAÇÃO INFERIOR
  // =========================================================

  void navegar(int indice) {
    if (!mounted) return;

    switch (indice) {
      // -------------------------------------------------------
      // HOME
      // -------------------------------------------------------

      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute<void>(
            builder: (_) => const HomeTela(),
          ),
        );
        break;

      // -------------------------------------------------------
      // HINÁRIO
      // -------------------------------------------------------

      case 1:
        // Já estamos dentro do Hinário.
        break;

      // -------------------------------------------------------
      // BÍBLIA
      // -------------------------------------------------------

      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute<void>(
            builder: (_) => const BibliaTela(),
          ),
        );
        break;

      // -------------------------------------------------------
      // INFORMAÇÕES DA IECA
      // -------------------------------------------------------

      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute<void>(
            builder: (_) => const InformacoesIecaTela(),
          ),
        );
        break;

      // -------------------------------------------------------
      // SOBRE
      // -------------------------------------------------------

      case 4:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute<void>(
            builder: (_) => const SobreTela(),
          ),
        );
        break;

      default:
        return;
    }
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    final List<Litania> resultados = _resultados;

    return Scaffold(
      backgroundColor: TemaHinario.corSuperficie,

      // =======================================================
      // CABEÇALHO
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
            : _erro != null
                ? _buildErro()
                : CustomScrollView(
                    slivers: [
                      // =========================================
                      // INTRODUÇÃO
                      // =========================================

                      SliverToBoxAdapter(
                        child: _buildIntroducao(),
                      ),

                      // =========================================
                      // PESQUISA
                      // =========================================

                      SliverToBoxAdapter(
                        child: _buildPesquisa(),
                      ),

                      // =========================================
                      // CONTADOR
                      // =========================================

                      SliverToBoxAdapter(
                        child: _buildContador(
                          resultados.length,
                        ),
                      ),

                      // =========================================
                      // LISTA
                      // =========================================

                      if (resultados.isNotEmpty)
                        SliverPadding(
                          padding:
                              const EdgeInsets.fromLTRB(
                            20,
                            12,
                            20,
                            110,
                          ),
                          sliver: SliverList(
                            delegate:
                                SliverChildBuilderDelegate(
                              (
                                context,
                                index,
                              ) {
                                final Litania litania =
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

      // =======================================================
      // BARRA DE NAVEGAÇÃO INFERIOR
      // =======================================================

      bottomNavigationBar: NavegacaoInferiorIeca(
        indiceSelecionado: 1,
        onDestinationSelected: navegar,
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
                color: TemaHinario.corSuperficieMedia,
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
            ElevatedButton(
              onPressed: _carregarLitanias,
              style: ElevatedButton.styleFrom(
                backgroundColor: TemaHinario.corPrimaria,
                foregroundColor: TemaHinario.corBranca,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Tentar novamente',
              ),
            ),
          ],
        ),
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
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: TemaHinario.corSuperficieMedia,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: TemaHinario.corContorno.withValues(
              alpha: 0.30,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: TemaHinario.corPrimaria.withValues(
                  alpha: 0.10,
                ),
                borderRadius:
                    BorderRadius.circular(17),
              ),
              child: const Icon(
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
                  const Text(
                    'Litanias',
                    style: TextStyle(
                      color: TemaHinario.corTexto,
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Orações e liturgias para diferentes '
                    'momentos do culto e da vida cristã.',
                    style: TextStyle(
                      color:
                          TemaHinario.corTextoSecundario,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_litanias.length} '
                    '${_litanias.length == 1 ? 'litania' : 'litanias'}',
                    style: const TextStyle(
                      color:
                          TemaHinario.corTextoSecundario,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // PESQUISA
  // =========================================================

  Widget _buildPesquisa() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        0,
        20,
        16,
      ),
      child: Column(
        children: [
          TextField(
            controller: _pesquisaController,
            onChanged: (_) {
              setState(() {});
            },
            textInputAction: TextInputAction.search,
            style: const TextStyle(
              color: TemaHinario.corTexto,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              hintText: 'Pesquisar litania...',
              hintStyle: const TextStyle(
                color:
                    TemaHinario.corTextoSecundario,
                fontSize: 14,
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color:
                    TemaHinario.corTextoSecundario,
              ),
              suffixIcon:
                  _pesquisaController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _pesquisaController.clear();

                            setState(() {});
                          },
                          icon: const Icon(
                            Icons.close_rounded,
                            size: 20,
                            color: TemaHinario
                                .corTextoSecundario,
                          ),
                        )
                      : null,
              filled: true,
              fillColor:
                  TemaHinario.corSuperficieAlta,
              contentPadding:
                  const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 15,
              ),
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: TemaHinario.corContorno
                      .withValues(alpha: 0.30),
                ),
              ),
              enabledBorder:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: TemaHinario.corContorno
                      .withValues(alpha: 0.30),
                ),
              ),
              focusedBorder:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: TemaHinario.corPrimaria
                      .withValues(alpha: 0.65),
                  width: 1.2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFiltro(
                  'ordem',
                  Icons.format_list_numbered_rounded,
                  'Ordem',
                ),
                const SizedBox(width: 8),
                _buildFiltro(
                  'alfabetica',
                  Icons.sort_by_alpha_rounded,
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
    final bool ativo = _filtroAtual == filtro;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius:
            BorderRadius.circular(999),
        onTap: () => _alterarFiltro(filtro),
        child: AnimatedContainer(
          duration:
              const Duration(milliseconds: 200),
          padding:
              const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 9,
          ),
          decoration: BoxDecoration(
            color: ativo
                ? TemaHinario.corPrimaria
                : TemaHinario.corSuperficieAlta,
            borderRadius:
                BorderRadius.circular(999),
            border: Border.all(
              color: ativo
                  ? TemaHinario.corPrimaria
                  : TemaHinario.corContorno
                      .withValues(alpha: 0.30),
            ),
            boxShadow: ativo
                ? [
                    BoxShadow(
                      color: TemaHinario.corPrimaria
                          .withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset:
                          const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icone,
                size: 16,
                color: ativo
                    ? TemaHinario.corBranca
                    : TemaHinario
                        .corTextoSecundario,
              ),
              const SizedBox(width: 6),
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
      ),
    );
  }

  // =========================================================
  // CONTADOR
  // =========================================================

  Widget _buildContador(int quantidade) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        4,
        20,
        4,
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Litanias',
              style: TextStyle(
                color: TemaHinario.corTexto,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 11,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color:
                  TemaHinario.corSuperficieMedia,
              borderRadius:
                  BorderRadius.circular(999),
            ),
            child: Text(
              '$quantidade '
              '${quantidade == 1 ? 'resultado' : 'resultados'}',
              style: const TextStyle(
                color:
                    TemaHinario.corTextoSecundario,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // ITEM DA LITANIA
  // =========================================================

  Widget _buildLitaniaItem(Litania litania) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _abrirLitania(litania),
        child: Container(
          constraints:
              const BoxConstraints(
            minHeight: 104,
          ),
          decoration: BoxDecoration(
            color:
                TemaHinario.corSuperficieAlta,
            borderRadius:
                BorderRadius.circular(16),
            border: Border.all(
              color: TemaHinario.corContorno
                  .withValues(alpha: 0.35),
            ),
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(
                  width: 4,
                  decoration: const BoxDecoration(
                    color:
                        TemaHinario.corPrimaria,
                    borderRadius:
                        BorderRadius.only(
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
                        const EdgeInsets.fromLTRB(
                      16,
                      15,
                      12,
                      15,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration:
                              BoxDecoration(
                            color: TemaHinario
                                .corPrimaria
                                .withValues(
                              alpha: 0.09,
                            ),
                            borderRadius:
                                BorderRadius
                                    .circular(15),
                          ),
                          child: const Icon(
                            Icons.church_outlined,
                            size: 25,
                            color: TemaHinario
                                .corPrimaria,
                          ),
                        ),
                        const SizedBox(width: 14),
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
                                    const TextStyle(
                                  color: TemaHinario
                                      .corTexto,
                                  fontSize: 15,
                                  fontWeight:
                                      FontWeight.w700,
                                  height: 1.35,
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                litania.subtitulo,
                                maxLines: 1,
                                overflow:
                                    TextOverflow
                                        .ellipsis,
                                style:
                                    const TextStyle(
                                  color: TemaHinario
                                      .corTextoSecundario,
                                  fontSize: 11,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(
                                height: 6,
                              ),
                              const Text(
                                'LER LITANIA',
                                style:
                                    TextStyle(
                                  color: TemaHinario
                                      .corPrimaria,
                                  fontSize: 10,
                                  fontWeight:
                                      FontWeight.w700,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons
                              .chevron_right_rounded,
                          size: 23,
                          color: TemaHinario
                              .corTextoSecundario
                              .withValues(
                            alpha: 0.45,
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
    final bool temPesquisa =
        _pesquisaController.text
            .trim()
            .isNotEmpty;

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
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                color: TemaHinario
                    .corSuperficieMedia,
                shape: BoxShape.circle,
              ),
              child: Icon(
                temPesquisa
                    ? Icons.search_off_rounded
                    : Icons.church_outlined,
                size: 36,
                color: TemaHinario
                    .corTextoSecundario,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              temPesquisa
                  ? 'Nenhuma litania encontrada'
                  : 'Nenhuma litania disponível',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: TemaHinario.corTexto,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              temPesquisa
                  ? 'Tente pesquisar por outro nome ou título.'
                  : 'Não existem litanias disponíveis neste momento.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color:
                    TemaHinario.corTextoSecundario,
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