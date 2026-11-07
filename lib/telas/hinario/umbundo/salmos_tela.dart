import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/tema.dart';
import '../../../componentes/cabecalho_ieca.dart';
import '../../../componentes/navegacao_inferior_ieca.dart';
import '../../../modelos/salmo.dart';
import '../../biblia/biblia_tela.dart';
import '../../home/home_tela.dart';
import '../leitura_tela.dart';
import '../../sobre/sobre_tela.dart';
import '../../informacoes_ieca/informacoes_ieca_tela.dart';
 

class SalmosTela extends StatefulWidget {
  const SalmosTela({super.key});

  @override
  State<SalmosTela> createState() => _SalmosTelaState();
}

class _SalmosTelaState extends State<SalmosTela> {
  final TextEditingController pesquisaController =
      TextEditingController();

  List<Salmo> _salmos = [];
  List<Salmo> _salmosFiltrados = [];

  bool _carregando = true;
  bool _erro = false;

  @override
  void initState() {
    super.initState();

    _carregarSalmos();
    pesquisaController.addListener(_atualizarPesquisa);
  }

  @override
  void dispose() {
    pesquisaController.removeListener(_atualizarPesquisa);
    pesquisaController.dispose();

    super.dispose();
  }

  Future<void> _carregarSalmos() async {
    setState(() {
      _carregando = true;
      _erro = false;
    });

    try {
      final String conteudo =
          await rootBundle.loadString('assets/dados/salmos_umbundo.json');

      final dynamic dados = jsonDecode(conteudo);

      List<dynamic> lista;

      if (dados is List) {
        lista = dados;
      } else if (dados is Map<String, dynamic> &&
          dados['Osamo'] is List) {
        lista = dados['Osamo'] as List<dynamic>;
      } else {
        throw const FormatException(
          'Formato inválido para o arquivo salmos.json.',
        );
      }

      final salmos = lista
          .map(
            (item) => Salmo.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();

      salmos.sort(
        (a, b) => _numeroSalmo(a.numero).compareTo(
          _numeroSalmo(b.numero),
        ),
      );

      if (!mounted) return;

      setState(() {
        _salmos = salmos;
        _salmosFiltrados = salmos;
        _carregando = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _carregando = false;
        _erro = true;
      });
    }
  }

  int _numeroSalmo(dynamic numero) {
    return int.tryParse(numero.toString()) ?? 0;
  }

  void _atualizarPesquisa() {
    final pesquisa =
        pesquisaController.text.trim().toLowerCase();

    if (pesquisa.isEmpty) {
      setState(() {
        _salmosFiltrados = _salmos;
      });
      return; 
    }

    final resultado = _salmos.where((salmo) {
      final numero =
          _numeroSalmo(salmo.numero).toString();

      return numero.contains(pesquisa) ||
          'salmo $numero'.contains(pesquisa);
    }).toList();

    setState(() {
      _salmosFiltrados = resultado;
    });
  }

  void _abrirSalmo(Salmo salmo) {
  final lista = _salmosFiltrados;

  // Descobre o índice do salmo clicado dentro da lista filtrada
  final indice = lista.indexWhere(
    (s) => _numeroSalmo(s.numero) == _numeroSalmo(salmo.numero),
  );

  // Constrói a lista de navegação
  final listaNavegacao = lista
      .map((s) => LeituraItem(salmo: s))
      .toList();

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => LeituraTela(
        indiceInicial: indice < 0 ? 0 : indice,
        listaNavegacao: listaNavegacao,
      ),
    ),
  );
}

   // =========================================================
  // NAVEGAÇÃO INFERIOR
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TemaHinario.corSuperficie,
      appBar: const CabecalhoIeca(),
      body: SafeArea(
        top: false,
        bottom: false,
        child: _carregando
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : _erro
                ? _buildErro()
                : CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: _buildIntroducao(),
                      ),

                      SliverToBoxAdapter(
                        child: _buildPesquisa(),
                      ),

                      SliverToBoxAdapter(
                        child: _buildContador(),
                      ),

                      if (_salmosFiltrados.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: _buildEstadoVazio(),
                        )
                      else
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
                                final salmo =
                                    _salmosFiltrados[index];

                                return Padding(
                                  padding:
                                      const EdgeInsets.only(
                                    bottom: 12,
                                  ),
                                  child:
                                      _buildItemSalmo(salmo),
                                );
                              },
                              childCount:
                                  _salmosFiltrados.length,
                            ),
                          ),
                        ),
                    ],
                  ),
      ),
      bottomNavigationBar: NavegacaoInferiorIeca(
        indiceSelecionado: 1,
        onDestinationSelected:
            _selecionarNavegacao,
      ),
    );
  }

  Widget _buildIntroducao() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        24,
        20,
        18,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color:
                  TemaHinario.corPrimaria.withValues(
                alpha: 0.10,
              ),
              borderRadius:
                  BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.menu_book_outlined,
              color: TemaHinario.corPrimaria,
              size: 27,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Salmos',
                  style: TextStyle(
                    color: TemaHinario.corTexto,
                    fontSize: 24,
                    fontWeight:
                        FontWeight.w800,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Consulte os salmos disponíveis no Hinário IECA.',
                  style: TextStyle(
                    color:
                        TemaHinario
                            .corTextoSecundario,
                    fontSize: 14,
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

  Widget _buildPesquisa() {
    final temPesquisa =
        pesquisaController.text.trim().isNotEmpty;

    return Container(
      margin: const EdgeInsets.fromLTRB(
        20,
        0,
        20,
        14,
      ),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color:
            TemaHinario.corSuperficie.withValues(
          alpha: 0.96,
        ),
        borderRadius:
            BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: TemaHinario
                .corTextoSecundario
                .withValues(alpha: 0.08),
            blurRadius: 18,
            spreadRadius: -8,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: TemaHinario
                    .corSecundaria
                    .withValues(alpha: 0.10),
                borderRadius:
                    BorderRadius.circular(15),
              ),
              child: TextField(
                controller:
                    pesquisaController,
                textInputAction:
                    TextInputAction.search,
                decoration: InputDecoration(
                  hintText:
                      'Pesquisar por número...',
                  hintStyle: TextStyle(
                    color: TemaHinario
                        .corTextoSecundario
                        .withValues(
                      alpha: 0.75,
                    ),
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color:
                        TemaHinario.corSecundaria,
                    size: 23,
                  ),
                  suffixIcon: temPesquisa
                      ? IconButton(
                          onPressed:
                              pesquisaController
                                  .clear,
                          icon: Icon(
                            Icons.close_rounded,
                            color: TemaHinario
                                .corTextoSecundario,
                            size: 20,
                          ),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 15,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            height: 52,
            padding:
                const EdgeInsets.symmetric(
              horizontal: 14,
            ),
            decoration: BoxDecoration(
              color: TemaHinario
                  .corSuperficieAlta,
              borderRadius:
                  BorderRadius.circular(15),
            ),
            child: Row(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                Icon(
                  Icons.filter_list_rounded,
                  color:
                      TemaHinario.corPrimaria,
                  size: 19,
                ),
                const SizedBox(width: 6),
                Text(
                  'Todos',
                  style: TextStyle(
                    color:
                        TemaHinario.corTexto,
                    fontSize: 13,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContador() {
    final quantidade =
        _salmosFiltrados.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        2,
        20,
        0,
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color:
                  TemaHinario.corPrimaria,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$quantidade ${quantidade == 1 ? 'salmo' : 'salmos'}',
            style: TextStyle(
              color: TemaHinario
                  .corTextoSecundario,
              fontSize: 13,
              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemSalmo(Salmo salmo) {
    final numero =
        _numeroSalmo(salmo.numero);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () =>
            _abrirSalmo(salmo),
        borderRadius:
            BorderRadius.circular(16),
        child: Container(
          constraints:
              const BoxConstraints(
            minHeight: 104,
          ),
          decoration: BoxDecoration(
            color: TemaHinario
                .corSuperficie
                .withValues(alpha: 0.80),
            borderRadius:
                BorderRadius.circular(16),
            border: Border.all(
              color: TemaHinario
                  .corTextoSecundario
                  .withValues(alpha: 0.30),
            ),
            boxShadow: [
              BoxShadow(
                color: TemaHinario
                    .corTextoSecundario
                    .withValues(alpha: 0.08),
                blurRadius: 20,
                spreadRadius: -10,
                offset:
                    const Offset(0, 4),
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
                              14,
                            ),
                          ),
                          alignment:
                              Alignment.center,
                          child: Text(
                            '$numero',
                            style: TextStyle(
                              color: TemaHinario
                                  .corPrimaria,
                              fontSize: 19,
                              fontWeight:
                                  FontWeight
                                      .w800,
                            ),
                          ),
                        ),
                        const SizedBox(
                            width: 14),
                        Expanded(
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .center,
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              Text(
                                'Salmo $numero',
                                style:
                                    TextStyle(
                                  color:
                                      TemaHinario
                                          .corTexto,
                                  fontSize: 16,
                                  fontWeight:
                                      FontWeight
                                          .w800,
                                ),
                              ),
                              const SizedBox(
                                  height: 5),
                              Text(
                                'LER SALMO',
                                style:
                                    TextStyle(
                                  color:
                                      TemaHinario
                                          .corSecundaria,
                                  fontSize: 11,
                                  fontWeight:
                                      FontWeight
                                          .w800,
                                  letterSpacing:
                                      0.7,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                            width: 8),
                        Container(
                          width: 36,
                          height: 36,
                          decoration:
                              BoxDecoration(
                            color: TemaHinario
                                .corSuperficieAlta,
                            shape:
                                BoxShape.circle,
                          ),
                          child: Icon(
                            Icons
                                .chevron_right_rounded,
                            color: TemaHinario
                                .corTextoSecundario,
                            size: 22,
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

  Widget _buildEstadoVazio() {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.fromLTRB(
          30,
          30,
          30,
          100,
        ),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration:
                  BoxDecoration(
                color: TemaHinario
                    .corSuperficieAlta,
                shape:
                    BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                color: TemaHinario
                    .corTextoSecundario,
                size: 34,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Nenhum salmo encontrado',
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                color:
                    TemaHinario.corTexto,
                fontSize: 17,
                fontWeight:
                    FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Não existe nenhum salmo correspondente à sua pesquisa.',
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                color: TemaHinario
                    .corTextoSecundario,
                fontSize: 14,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErro() {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(30),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration:
                  BoxDecoration(
                color: TemaHinario
                    .corPrimaria
                    .withValues(
                  alpha: 0.10,
                ),
                shape:
                    BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                color:
                    TemaHinario.corPrimaria,
                size: 36,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Não foi possível carregar os salmos.',
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                color:
                    TemaHinario.corTexto,
                fontSize: 17,
                fontWeight:
                    FontWeight.w800,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed:
                  _carregarSalmos,
              icon: const Icon(
                Icons.refresh_rounded,
              ),
              label: const Text(
                'Tentar novamente',
              ),
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    TemaHinario.corPrimaria,
                foregroundColor:
                    Colors.white,
                elevation: 0,
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 20,
                  vertical: 13,
                ),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}