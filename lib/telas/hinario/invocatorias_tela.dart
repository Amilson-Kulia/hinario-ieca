import 'package:flutter/material.dart';

import '../../app/tema.dart';
import '../../componentes/cabecalho_ieca.dart';
import '../../componentes/navegacao_inferior_ieca.dart';
import '../../modelos/invocatoria.dart';
import '../../servicos/invocatorias_servico.dart';
import '../biblia/biblia_tela.dart';
import '../home/home_tela.dart';
import '../programa_culto/criar_programa_tela.dart';
import '../sobre/sobre_tela.dart';
import 'leitura_tela.dart';
import '../informacoes_ieca/informacoes_ieca_tela.dart';
import 'idiomas_tela.dart';

class InvocatoriasTela extends StatefulWidget {
  const InvocatoriasTela({
    super.key,
  });

  @override
  State<InvocatoriasTela> createState() =>
      _InvocatoriasTelaState();
}

class _InvocatoriasTelaState extends State<InvocatoriasTela> {
  // =========================================================
  // CONTROLADOR DE PESQUISA
  // =========================================================

  final TextEditingController _pesquisaController =
      TextEditingController();

  // =========================================================
  // FILTRO ATUAL
  // =========================================================

  String _filtroAtual = 'ordem';

  // =========================================================
  // DADOS
  // =========================================================

  List<Invocatoria> _invocatorias = [];

  bool _carregando = true;

  String? _erro;

  // =========================================================
  // INIT
  // =========================================================

  @override
  void initState() {
    super.initState();

    _carregarInvocatorias();
  }

  // =========================================================
  // DISPOSE
  // =========================================================

  @override
  void dispose() {
    _pesquisaController.dispose();

    super.dispose();
  }

  // =========================================================
  // CARREGAR INVOCATÓRIAS
  // =========================================================

  Future<void> _carregarInvocatorias() async {
    try {
      final dados = await InvocatoriasServico.carregar();

      if (!mounted) return;

      setState(() {
        _invocatorias = dados;
        _carregando = false;
        _erro = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _carregando = false;
        _erro =
            'Não foi possível carregar as invocatórias.';
      });
    }
  }

  // =========================================================
  // RESULTADOS
  // =========================================================

  List<Invocatoria> get _resultados {
    final termo =
        _pesquisaController.text.trim().toLowerCase();

    List<Invocatoria> resultados =
        List<Invocatoria>.from(_invocatorias);

    // ---------------------------------------------------------
    // PESQUISA
    // ---------------------------------------------------------

    if (termo.isNotEmpty) {
      resultados = resultados.where((item) {
        final numero = item.numero.toLowerCase();
        final titulo = item.titulo.toLowerCase();
        final categoria = item.categoria.toLowerCase();
        final texto = item.texto.toLowerCase();

        return numero.contains(termo) ||
            titulo.contains(termo) ||
            categoria.contains(termo) ||
            texto.contains(termo);
      }).toList();
    }

    // ---------------------------------------------------------
    // ORDENAÇÃO POR SECÇÃO
    // ---------------------------------------------------------

    if (_filtroAtual == 'alfabetica') {
      resultados.sort(
        (a, b) {
          final categoriaA = a.categoria.trim();
          final categoriaB = b.categoria.trim();

          final comparacao =
              categoriaA.compareTo(categoriaB);

          if (comparacao != 0) {
            return comparacao;
          }

          return _numeroComoInteiro(a).compareTo(
            _numeroComoInteiro(b),
          );
        },
      );
    }

    // ---------------------------------------------------------
    // ORDEM NUMÉRICA
    // ---------------------------------------------------------

    if (_filtroAtual == 'ordem') {
      resultados.sort(
        (a, b) => _numeroComoInteiro(a).compareTo(
          _numeroComoInteiro(b),
        ),
      );
    }

    return resultados;
  }

  // =========================================================
  // CONVERTER NÚMERO PARA INTEIRO
  // =========================================================

  int _numeroComoInteiro(
    Invocatoria invocatoria,
  ) {
    return int.tryParse(
          invocatoria.numero,
        ) ??
        invocatoria.id;
  }

  // =========================================================
// ABRIR INVOCATÓRIA
// =========================================================

void _abrirInvocatoria(Invocatoria invocatoria) {
  final lista = _resultados;

  // Descobre o índice da invocatória clicada
  final indice = lista.indexWhere(
    (i) => i.id == invocatoria.id,
  );

  // Constrói a lista de navegação
  final listaNavegacao = lista
      .map((i) => LeituraItem(invocatoria: i))
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
  // NAVEGAÇÃO PRINCIPAL
  // =========================================================

  void _selecionarNavegacao(int indice) {
  if (!mounted) return;

  switch (indice) {
    case 0:
      // Já estamos na Home.
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
          builder: (_) => const InformacoesIecaTela(),
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
  // ÍCONE DA SECÇÃO
  // =========================================================

  IconData _iconeSecao(String nome) {
    switch (nome) {
      case 'Advento':
        return Icons.brightness_5_rounded;

      case 'Natal':
        return Icons.star_rounded;

      case 'Epifania':
        return Icons.light_mode_rounded;

      case 'Quaresma':
        return Icons.church_rounded;

      case 'Domingo de Ramos':
        return Icons.park_rounded;

      case 'Páscoa':
        return Icons.wb_sunny_rounded;

      case 'Pentecostes':
        return Icons.local_fire_department_rounded;

      default:
        return Icons.auto_awesome_rounded;
    }
  }

  // =========================================================
  // CABEÇALHO DA SECÇÃO
  // =========================================================

  Widget _cabecalhoSecao(String nome) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 18,
        bottom: 10,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: TemaHinario.corPrimaria.withValues(
                alpha: 0.09,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Icon(
              _iconeSecao(nome),
              size: 21,
              color: TemaHinario.corPrimaria,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  nome,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                    color: TemaHinario.corTexto,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'PERÍODO LITÚRGICO',
                  style: TextStyle(
                    fontSize: 10,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                    color:
                        TemaHinario.corTextoSecundario,
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
  // CARD DA INVOCATÓRIA
  // =========================================================

  Widget _cardInvocatoria(
    Invocatoria invocatoria,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _abrirInvocatoria(invocatoria),
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
              color: TemaHinario.corTextoSecundario
                  .withValues(alpha: 0.30),
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
                            invocatoria.numero,
                            style: const TextStyle(
                              color: TemaHinario.corTexto,
                              fontSize: 19,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
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
                                invocatoria.categoria,
                                maxLines: 1,
                                overflow:
                                    TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: TemaHinario
                                      .corTextoSecundario,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  height: 1.4,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                invocatoria.titulo,
                                maxLines: 2,
                                overflow:
                                    TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color:
                                      TemaHinario.corTexto,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  height: 1.4,
                                ),
                              ),

                              const SizedBox(height: 6),

                              const Text(
                                'LER INVOCATÓRIA',
                                style: TextStyle(
                                  color:
                                      TemaHinario.corPrimaria,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 4),

                        // =========================================
                        // SETA
                        // =========================================

                        Icon(
                          Icons.chevron_right,
                          size: 22,
                          color: TemaHinario
                              .corTextoSecundario
                              .withValues(alpha: 0.40),
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

  Widget _estadoVazio() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        30,
        70,
        30,
        120,
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: TemaHinario.corSuperficieAlta,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.search_off_rounded,
              size: 32,
              color: TemaHinario.corTextoSecundario,
            ),
          ),

          const SizedBox(height: 18),

          const Text(
            'Nenhuma invocatória encontrada',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: TemaHinario.corTexto,
              fontSize: 17,
              height: 24 / 17,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 7),

          const Text(
            'Tente pesquisar por outro número ou '
            'altere o filtro selecionado.',
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
  // ESTADO DE CARREGAMENTO
  // =========================================================

  Widget _estadoCarregando() {
    return const Padding(
      padding: EdgeInsets.only(
        top: 80,
        bottom: 120,
      ),
      child: Center(
        child: CircularProgressIndicator(
          color: TemaHinario.corPrimaria,
        ),
      ),
    );
  }

  // =========================================================
  // ESTADO DE ERRO
  // =========================================================

  Widget _estadoErro() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        30,
        70,
        30,
        120,
      ),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: TemaHinario.corSuperficieAlta,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.error_outline_rounded,
                size: 32,
                color: TemaHinario.corTextoSecundario,
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'Não foi possível carregar as invocatórias',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                height: 1.4,
                fontWeight: FontWeight.w700,
                color: TemaHinario.corTexto,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              _erro ??
                  'Verifique se o ficheiro invocatorias.json está nos assets.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                height: 1.55,
                color: TemaHinario.corTextoSecundario,
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: _carregarInvocatorias,
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
              ),
            ),
          ],
        ),
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
        child: CustomScrollView(
          slivers: [
            // ===================================================
            // INTRODUÇÃO
            // ===================================================

            SliverToBoxAdapter(
              child: Padding(
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
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        size: 30,
                        color:
                            TemaHinario.corPrimaria,
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Invocatórias',
                            style: TextStyle(
                              color:
                                  TemaHinario.corTexto,
                              fontSize: 24,
                              fontWeight:
                                  FontWeight.w700,
                              height: 1.25,
                            ),
                          ),

                          const SizedBox(height: 4),

                          const Text(
                            'Invocações organizadas por número e pelos diferentes períodos litúrgicos.',
                            style: TextStyle(
                              color: TemaHinario
                                  .corTextoSecundario,
                              fontSize: 13,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ===================================================
            // PESQUISA E FILTROS
            // ===================================================

            SliverToBoxAdapter(
              child: Container(
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
                    // =========================================
                    // PESQUISA
                    // =========================================

                    Container(
                      height: 50,
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 14,
                      ),
                      decoration: BoxDecoration(
                        color: TemaHinario.corSecundaria
                            .withValues(alpha: 0.10),
                        borderRadius:
                            BorderRadius.circular(999),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.search_rounded,
                            size: 24,
                            color: TemaHinario
                                .corTextoSecundario,
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: TextField(
                              controller:
                                  _pesquisaController,
                              onChanged: (_) {
                                setState(() {});
                              },
                              style: const TextStyle(
                                color:
                                    TemaHinario.corTexto,
                                fontSize: 15,
                              ),
                              decoration:
                                  const InputDecoration(
                                border: InputBorder.none,
                                hintText:
                                    'Pesquisar invocatória...',
                                hintStyle: TextStyle(
                                  color: TemaHinario
                                      .corTextoSecundario,
                                  fontSize: 15,
                                ),
                                isCollapsed: true,
                              ),
                            ),
                          ),

                          if (_pesquisaController
                              .text
                              .isNotEmpty)
                            Material(
                              color: TemaHinario
                                  .corSuperficieAlta,
                              shape:
                                  const CircleBorder(),
                              child: InkWell(
                                customBorder:
                                    const CircleBorder(),
                                onTap: () {
                                  _pesquisaController
                                      .clear();

                                  setState(() {});
                                },
                                child: const SizedBox(
                                  width: 32,
                                  height: 32,
                                  child: Icon(
                                    Icons.close,
                                    size: 19,
                                    color: TemaHinario
                                        .corTextoSecundario,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // =========================================
                    // FILTROS
                    // =========================================

                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _FiltroBotao(
                            icone: Icons
                                .format_list_numbered,
                            texto: 'Ordem',
                            ativo:
                                _filtroAtual == 'ordem',
                            onTap: () {
                              setState(() {
                                _filtroAtual = 'ordem';
                              });
                            },
                          ),

                          const SizedBox(width: 8),

                          _FiltroBotao(
                            icone: Icons.sort_by_alpha,
                            texto: 'Secção',
                            ativo: _filtroAtual ==
                                'alfabetica',
                            onTap: () {
                              setState(() {
                                _filtroAtual =
                                    'alfabetica';
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ===================================================
            // ESTADOS / CONTEÚDO
            // ===================================================

            if (_carregando)
              SliverToBoxAdapter(
                child: _estadoCarregando(),
              )
            else if (_erro != null)
              SliverToBoxAdapter(
                child: _estadoErro(),
              )
            else ...[
              // =================================================
              // CONTADOR
              // =================================================

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    4,
                    20,
                    4,
                  ),
                  child: Text(
                    '${resultados.length} ${resultados.length == 1 ? 'invocatória' : 'invocatórias'}',
                    style: const TextStyle(
                      color: TemaHinario
                          .corTextoSecundario,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              // =================================================
              // LISTA VAZIA
              // =================================================

              if (resultados.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _estadoVazio(),
                )

              // =================================================
              // LISTA
              // =================================================

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
                      (
                        context,
                        index,
                      ) {
                        final item = resultados[index];

                        final secao = item.categoria;

                        final secaoAnterior =
                            index > 0
                                ? resultados[index - 1]
                                    .categoria
                                : null;

                        final mostrarSecao =
                            index == 0 ||
                                secao != secaoAnterior;

                        return Column(
                          children: [
                            if (mostrarSecao)
                              _cabecalhoSecao(secao),

                            _cardInvocatoria(item),
                          ],
                        );
                      },
                      childCount: resultados.length,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),

      // =======================================================
      // RODAPÉ PADRÃO IECA
      // =======================================================

      bottomNavigationBar:
          NavegacaoInferiorIeca(
        indiceSelecionado: 1,
        onDestinationSelected:
            _selecionarNavegacao,
      ),
    );
  }
}

// =============================================================
// FILTRO
// =============================================================

class _FiltroBotao extends StatelessWidget {
  final IconData icone;
  final String texto;
  final bool ativo;
  final VoidCallback onTap;

  const _FiltroBotao({
    required this.icone,
    required this.texto,
    required this.ativo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 200,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: ativo
              ? TemaHinario.corPrimaria
              : TemaHinario.corSuperficieAlta,
          borderRadius: BorderRadius.circular(999),
          boxShadow: ativo
              ? const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 6,
                    offset: Offset(0, 2),
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
                  : TemaHinario.corTextoSecundario,
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
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}