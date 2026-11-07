import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/tema.dart';
import '../../componentes/cabecalho_ieca.dart';
import '../../componentes/navegacao_inferior_ieca.dart';
import '../../modelos/salmo.dart';
import '../biblia/biblia_tela.dart';
import '../home/home_tela.dart';
import '../programa_culto/criar_programa_tela.dart';
import '../sobre/sobre_tela.dart';
import 'leitura_tela.dart';
import '../informacoes_ieca/informacoes_ieca_tela.dart';


class SalmosTela extends StatefulWidget {
  const SalmosTela({super.key});

  @override
  State<SalmosTela> createState() => _SalmosTelaState();
}

class _SalmosTelaState extends State<SalmosTela> {
  // =========================================================
  // DADOS
  // =========================================================

  List<Salmo> salmos = [];

  bool carregando = true;

  String? erro;

  // =========================================================
  // PESQUISA
  // =========================================================

  final TextEditingController pesquisaController =
      TextEditingController();

  String termoPesquisa = '';

  // =========================================================
  // INIT
  // =========================================================

  @override
  void initState() {
    super.initState();

    _carregarSalmos();

    pesquisaController.addListener(_atualizarPesquisa);
  }

  // =========================================================
  // ATUALIZAR PESQUISA
  // =========================================================

  void _atualizarPesquisa() {
    if (!mounted) return;

    setState(() {
      termoPesquisa = pesquisaController.text.trim();
    });
  }

  // =========================================================
  // DISPOSE
  // =========================================================

  @override
  void dispose() {
    pesquisaController.removeListener(_atualizarPesquisa);
    pesquisaController.dispose();
    super.dispose();
  }

  // =========================================================
  // CARREGAR SALMOS
  // =========================================================

  Future<void> _carregarSalmos() async {
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/dados/salmos.json',
      );

      final dynamic dados = json.decode(jsonString);

      List<dynamic> lista;

      // =====================================================
      // JSON COMO LISTA
      // =====================================================

      if (dados is List) {
        lista = dados;
      }

      // =====================================================
      // JSON COMO OBJETO
      // =====================================================

      else if (dados is Map && dados['salmos'] is List) {
        lista = dados['salmos'];
      }

      // =====================================================
      // FORMATO INVÁLIDO
      // =====================================================

      else {
        throw Exception(
          'Formato inválido do arquivo salmos.json.',
        );
      }

      // =====================================================
      // CONVERTER PARA O MODELO
      // =====================================================

      final List<Salmo> salmosCarregados = lista
          .map(
            (item) => Salmo.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();

      // =====================================================
      // ORDENAR POR NÚMERO
      // =====================================================

      salmosCarregados.sort(
        (a, b) => _numeroSalmo(a).compareTo(
          _numeroSalmo(b),
        ),
      );

      if (!mounted) return;

      setState(() {
        salmos = salmosCarregados;
        carregando = false;
        erro = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        carregando = false;
        erro = 'Não foi possível carregar os salmos.';
      });
    }
  }

  // =========================================================
  // NÚMERO DO SALMO
  // =========================================================

  int _numeroSalmo(Salmo salmo) {
    final dynamic numero = salmo.numero;

    if (numero is int) {
      return numero;
    }

    return int.tryParse(numero.toString()) ?? 0;
  }

  // =========================================================
  // SALMOS FILTRADOS
  // =========================================================

  List<Salmo> get salmosFiltrados {
    List<Salmo> resultado = List<Salmo>.from(salmos);

    if (termoPesquisa.isNotEmpty) {
      final String termo = termoPesquisa.toLowerCase();

      resultado = resultado.where(
        (salmo) {
          final String numero = _numeroSalmo(salmo).toString();

          return numero.contains(termo) ||
              'salmo $numero'.contains(termo);
        },
      ).toList();
    }

    return resultado;
  }

  // =========================================================
// ABRIR SALMO
// =========================================================

void _abrirSalmo(Salmo salmo) {
  final lista = salmosFiltrados;

  // Descobre o índice do salmo clicado
  final indice = lista.indexWhere(
    (s) => _numeroSalmo(s) == _numeroSalmo(salmo),
  );

  // Constrói a lista de navegação
  final listaNavegacao = lista
      .map((s) => LeituraItem(salmo: s))
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

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TemaHinario.corSuperficie,

      // =====================================================
      // CABEÇALHO PADRÃO IECA
      // =====================================================

      appBar: const CabecalhoIeca(),

      // =====================================================
      // CONTEÚDO
      // =====================================================

      body: SafeArea(
        top: false,
        bottom: false,
        child: carregando
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : erro != null
                ? _buildErro()
                : CustomScrollView(
                    slivers: [
                      // =======================================
                      // INTRODUÇÃO
                      // =======================================

                      SliverToBoxAdapter(
                        child: _buildIntroducao(),
                      ),

                      // =======================================
                      // PESQUISA
                      // =======================================

                      SliverToBoxAdapter(
                        child: _buildPesquisa(),
                      ),

                      // =======================================
                      // CONTADOR
                      // =======================================

                      SliverToBoxAdapter(
                        child: _buildContador(),
                      ),

                      // =======================================
                      // LISTA
                      // =======================================

                      if (salmosFiltrados.isNotEmpty)
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(
                            20,
                            12,
                            20,
                            110,
                          ),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final Salmo salmo =
                                    salmosFiltrados[index];

                                return Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: 10,
                                  ),
                                  child: _buildItemSalmo(salmo),
                                );
                              },
                              childCount: salmosFiltrados.length,
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

      // =====================================================
      // NAVEGAÇÃO PADRÃO IECA
      // =====================================================

      bottomNavigationBar: NavegacaoInferiorIeca(
        indiceSelecionado: 1,
        onDestinationSelected: _selecionarNavegacao,
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
          // =================================================
          // ÍCONE
          // =================================================

          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: TemaHinario.corPrimaria.withValues(
                alpha: 0.10,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.menu_book_outlined,
              size: 30,
              color: TemaHinario.corPrimaria,
            ),
          ),

          const SizedBox(width: 16),

          // =================================================
          // TEXTO
          // =================================================

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Salmos',
                  style: TextStyle(
                    color: TemaHinario.corTexto,
                    fontSize: 24,
                    height: 30 / 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Consulte os salmos disponíveis no Hinário IECA.',
                  style: TextStyle(
                    color: TemaHinario.corTextoSecundario,
                    fontSize: 13,
                    height: 19 / 13,
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
    final bool possuiTexto =
        pesquisaController.text.isNotEmpty;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        20,
        8,
        20,
        16,
      ),
      decoration: BoxDecoration(
        color: TemaHinario.corSuperficie.withValues(
          alpha: 0.96,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
        ),
        decoration: BoxDecoration(
          color: TemaHinario.corSecundaria.withValues(
            alpha: 0.10,
          ),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          children: [
            // ===============================================
            // ÍCONE
            // ===============================================

            const Icon(
              Icons.search_rounded,
              size: 24,
              color: TemaHinario.corTextoSecundario,
            ),

            const SizedBox(width: 10),

            // ===============================================
            // CAMPO
            // ===============================================

            Expanded(
              child: TextField(
                controller: pesquisaController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.search,
                style: const TextStyle(
                  color: TemaHinario.corTexto,
                  fontSize: 15,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isCollapsed: true,
                  hintText: 'Pesquisar por número...',
                  hintStyle: TextStyle(
                    color: TemaHinario.corTextoSecundario,
                    fontSize: 15,
                  ),
                ),
              ),
            ),

            // ===============================================
            // LIMPAR
            // ===============================================

            if (possuiTexto)
              Material(
                color: TemaHinario.corSuperficieAlta,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: pesquisaController.clear,
                  child: const SizedBox(
                    width: 32,
                    height: 32,
                    child: Icon(
                      Icons.close,
                      size: 19,
                      color: TemaHinario.corTextoSecundario,
                    ),
                  ),
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

  Widget _buildContador() {
    final int quantidade = salmosFiltrados.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        4,
        20,
        4,
      ),
      child: Text(
        '$quantidade ${quantidade == 1 ? 'salmo' : 'salmos'}',
        style: const TextStyle(
          color: TemaHinario.corTextoSecundario,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // =========================================================
  // ITEM DO SALMO
  // =========================================================

  Widget _buildItemSalmo(Salmo salmo) {
    final int numero = _numeroSalmo(salmo);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _abrirSalmo(salmo),
        child: Container(
          constraints: const BoxConstraints(
            minHeight: 104,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(
              alpha: 0.80,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: TemaHinario.corTextoSecundario.withValues(
                alpha: 0.30,
              ),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 20,
                spreadRadius: -10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: IntrinsicHeight(
            child: Row(
              children: [
                // =================================================
                // FAIXA LATERAL
                // =================================================

                Container(
                  width: 4,
                  color: TemaHinario.corPrimaria,
                ),

                // =================================================
                // CONTEÚDO
                // =================================================

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      16,
                      12,
                      16,
                    ),
                    child: Row(
                      children: [
                        // =========================================
                        // NÚMERO
                        // =========================================

                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: TemaHinario.corPrimaria
                                .withValues(alpha: 0.09),
                            borderRadius:
                                BorderRadius.circular(15),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            numero.toString(),
                            style: const TextStyle(
                              color: TemaHinario.corPrimaria,
                              fontSize: 20,
                              height: 24 / 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),

                        const SizedBox(width: 14),

                        // =========================================
                        // INFORMAÇÕES
                        // =========================================

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              Text(
                                'Salmo $numero',
                                maxLines: 1,
                                overflow:
                                    TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color:
                                      TemaHinario.corTexto,
                                  fontSize: 15,
                                  height: 21 / 15,
                                  fontWeight:
                                      FontWeight.w700,
                                ),
                              ),

                              const SizedBox(height: 6),

                              const Text(
                                'LER SALMO',
                                style: TextStyle(
                                  color:
                                      TemaHinario.corPrimaria,
                                  fontSize: 10,
                                  height: 14 / 10,
                                  fontWeight:
                                      FontWeight.w700,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // =========================================
                        // SETA
                        // =========================================

                        const Padding(
                          padding: EdgeInsets.only(
                            left: 8,
                          ),
                          child: Icon(
                            Icons.chevron_right,
                            size: 22,
                            color: Color(0x665B4040),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        30,
        70,
        30,
        120,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // =================================================
          // ÍCONE
          // =================================================

          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: TemaHinario.corSuperficieAlta,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.search_off,
              size: 32,
              color: TemaHinario.corTextoSecundario,
            ),
          ),

          const SizedBox(height: 18),

          // =================================================
          // TÍTULO
          // =================================================

          const Text(
            'Nenhum salmo encontrado',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: TemaHinario.corTexto,
              fontSize: 17,
              height: 24 / 17,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 7),

          // =================================================
          // DESCRIÇÃO
          // =================================================

          const Text(
            'Não existe nenhum salmo correspondente à sua pesquisa.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: TemaHinario.corTextoSecundario,
              fontSize: 13,
              height: 20 / 13,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // ERRO
  // =========================================================

  Widget _buildErro() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // =================================================
            // ÍCONE
            // =================================================

            const Icon(
              Icons.error_outline,
              size: 48,
              color: TemaHinario.corPrimaria,
            ),

            const SizedBox(height: 16),

            // =================================================
            // TEXTO
            // =================================================

            const Text(
              'Não foi possível carregar os salmos.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: TemaHinario.corTexto,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 16),

            // =================================================
            // TENTAR NOVAMENTE
            // =================================================

            ElevatedButton(
              onPressed: () {
                setState(() {
                  carregando = true;
                  erro = null;
                });

                _carregarSalmos();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: TemaHinario.corPrimaria,
                foregroundColor: Colors.white,
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
}