import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../componentes/navegacao_inferior_ieca.dart';
import '../../../modelos/hino.dart';
import '../../biblia/biblia_tela.dart';
import '../../home/home_tela.dart';
import '../../informacoes_ieca/informacoes_ieca_tela.dart';
import '../../sobre/sobre_tela.dart';
import 'hinos_categoria_tela.dart';

class HinosPortuguesTela extends StatefulWidget {
  const HinosPortuguesTela({super.key});

  @override
  State<HinosPortuguesTela> createState() =>
      _HinosPortuguesTelaState();
}

class _HinosPortuguesTelaState extends State<HinosPortuguesTela> {
  final TextEditingController _pesquisaController =
      TextEditingController();

  String _filtroAtual = 'Número';

  // =========================================================
  // ESTADO DOS DADOS
  // =========================================================

  List<Hino> _hinos = [];

  bool _carregando = true;

  String? _erro;

  // =========================================================
  // CORES
  // =========================================================

  static const Color surface = Color(0xFFF8F9FF);

  static const Color surfaceContainer = Color(0xFFE6EEFF);

  static const Color surfaceVariant = Color(0xFFD9E3F6);

  static const Color primary = Color(0xFF9E0027);

  static const Color primaryContainer = Color(0xFFC41E3A);

  static const Color secondary = Color(0xFF855400);

  static const Color secondaryContainer = Color(0xFFFFA504);

  static const Color onSurface = Color(0xFF121C2A);

  static const Color onSurfaceVariant = Color(0xFF5B4040);

  static const Color outlineVariant = Color(0xFFE3BEBD);

  // =========================================================
  // CICLO DE VIDA
  // =========================================================

  @override
  void initState() {
    super.initState();

    _pesquisaController.addListener(_atualizarPesquisa);

    _carregarHinos();
  }

  @override
  void dispose() {
    _pesquisaController.removeListener(_atualizarPesquisa);

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
  // CARREGAR HINOS
  // =========================================================
  //
  // IMPORTANTE:
  // Esta tela é exclusiva do Kimbundo.
  //
  // Não usamos HinosServico aqui porque o serviço continua
  // exatamente como está e carrega os dados padrão.
  //
  // O idioma é definido pelo próprio arquivo JSON.
  //
  // =========================================================

  Future<void> _carregarHinos() async {
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/dados/hinos/hinos_cokwe.json',
      );

      final dynamic dados = json.decode(jsonString);

      final List<dynamic> lista;

      // -------------------------------------------------------
      // SUPORTA:
      //
      // [
      //   {...},
      //   {...}
      // ]
      //
      // OU:
      //
      // {
      //   "hinos": [
      //     {...},
      //     {...}
      //   ]
      // }
      // -------------------------------------------------------

      if (dados is List) {
        lista = dados;
      } else if (dados is Map<String, dynamic> &&
          dados['hinos'] is List) {
        lista = dados['hinos'] as List<dynamic>;
      } else {
        throw const FormatException(
          'Formato inválido do arquivo de hinos.',
        );
      }

      final List<Hino> hinos = lista
          .map(
            (item) => Hino.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();

      if (!mounted) {
        return;
      }

      setState(() {
        _hinos = hinos;

        _carregando = false;

        _erro = null;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _carregando = false;

        _erro = 'Não foi possível carregar os hinos em Kimbundo.';
      });
    }
  }

  // =========================================================
  // CATEGORIAS DINÂMICAS
  // =========================================================
  //
  // As categorias são criadas automaticamente a partir
  // dos hinos existentes no JSON do Kimbundo.
  //
  // Não existe nenhuma lista manual de categorias.
  //
  // =========================================================

  List<Map<String, dynamic>> get _categorias {
    final Map<String, List<Hino>> agrupadas = {};

    // ---------------------------------------------------------
    // AGRUPAR HINOS POR CATEGORIA
    // ---------------------------------------------------------

    for (final hino in _hinos) {
      final String categoria = hino.categoria.trim();

      if (categoria.isEmpty) {
        continue;
      }

      agrupadas.putIfAbsent(
        categoria,
        () => [],
      );

      agrupadas[categoria]!.add(hino);
    }

    // ---------------------------------------------------------
    // CONSTRUIR LISTA DE CATEGORIAS
    // ---------------------------------------------------------

    final List<Map<String, dynamic>> categorias = [];

    for (final entrada in agrupadas.entries) {
      final List<Hino> lista = List<Hino>.from(
        entrada.value,
      );

      // -------------------------------------------------------
      // ORDENAR HINOS PELO NÚMERO
      // -------------------------------------------------------

      lista.sort(
        (a, b) => a.numero.compareTo(
          b.numero,
        ),
      );

      if (lista.isEmpty) {
        continue;
      }

      // -------------------------------------------------------
      // PRIMEIRO E ÚLTIMO HINO
      // -------------------------------------------------------

      final int inicio = lista.first.numero;

      final int fim = lista.last.numero;

      // -------------------------------------------------------
      // ADICIONAR CATEGORIA
      // -------------------------------------------------------

      categorias.add({
        'inicio': inicio,
        'fim': fim,
        'titulo': entrada.key,
        'quantidade': lista.length,
        'hinos': lista,
      });
    }

    // ---------------------------------------------------------
    // ORDENAR CATEGORIAS PELO PRIMEIRO HINO
    // ---------------------------------------------------------

    categorias.sort(
      (a, b) => (a['inicio'] as int).compareTo(
        b['inicio'] as int,
      ),
    );

    return categorias;
  }

  // =========================================================
  // CATEGORIAS FILTRADAS
  // =========================================================

  List<Map<String, dynamic>> get _categoriasFiltradas {
    final String pesquisa = _pesquisaController.text
        .trim()
        .toLowerCase();

    final List<Map<String, dynamic>> categorias =
        _categorias;

    // ---------------------------------------------------------
    // SEM PESQUISA
    // ---------------------------------------------------------

    if (pesquisa.isEmpty) {
      return categorias;
    }

    // ---------------------------------------------------------
    // FILTRO POR NOME
    // ---------------------------------------------------------

    if (_filtroAtual == 'Nome') {
      return categorias.where(
        (categoria) {
          final String titulo = categoria['titulo']
              .toString()
              .toLowerCase();

          return titulo.contains(pesquisa);
        },
      ).toList();
    }

    // ---------------------------------------------------------
    // FILTRO POR NÚMERO
    // ---------------------------------------------------------

    final int? numero = int.tryParse(pesquisa);

    if (numero != null) {
      return categorias.where(
        (categoria) {
          final List<Hino> hinos =
              categoria['hinos'] as List<Hino>;

          return hinos.any(
            (hino) => hino.numero == numero,
          );
        },
      ).toList();
    }

    // ---------------------------------------------------------
    // PESQUISA POR TEXTO
    // ---------------------------------------------------------

    return categorias.where(
      (categoria) {
        final String titulo = categoria['titulo']
            .toString()
            .toLowerCase();

        return titulo.contains(pesquisa);
      },
    ).toList();
  }

  // =========================================================
  // ABRIR CATEGORIA
  // =========================================================

  void _abrirCategoria(
    Map<String, dynamic> categoria,
  ) {
    final String titulo =
        categoria['titulo'] as String;

    final int inicio =
        categoria['inicio'] as int;

    final int fim =
        categoria['fim'] as int;

    final int quantidade =
        categoria['quantidade'] as int;

    // ---------------------------------------------------------
    // INTERVALO
    // ---------------------------------------------------------

    final String intervalo = inicio == fim
        ? '$inicio'
        : '$inicio-$fim';

    // ---------------------------------------------------------
    // DESCRIÇÃO
    // ---------------------------------------------------------

    final String descricao = quantidade == 1
        ? 'Ekovongo $intervalo • 1 ekovongo'
        : 'Ekovongo $intervalo • $quantidade ekovongo';

    // ---------------------------------------------------------
    // NAVEGAÇÃO
    // ---------------------------------------------------------

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HinosCategoriaTela(
          categoria: titulo,
          descricao: descricao,
        ),
      ),
    );
  }

  // =========================================================
  // NAVEGAÇÃO INFERIOR
  // =========================================================

  void _selecionarNavegacao(int indice) {
    if (!mounted) {
      return;
    }

    switch (indice) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute<void>(
            builder: (_) => const HomeTela(),
          ),
        );
        break;

      case 1:
        // Já estamos dentro do Hinário.
        break;

      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute<void>(
            builder: (_) => const BibliaTela(),
          ),
        );
        break;

      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute<void>(
            builder: (_) => const InformacoesIecaTela(),
          ),
        );
        break;

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
    return Scaffold(
      backgroundColor: surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildCabecalho(),

            Expanded(
              child: _buildConteudo(),
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

  // =========================================================
  // CONTEÚDO
  // =========================================================

  Widget _buildConteudo() {
    // ---------------------------------------------------------
    // CARREGANDO
    // ---------------------------------------------------------

    if (_carregando) {
      return const Center(
        child: CircularProgressIndicator(
          color: primary,
        ),
      );
    }

    // ---------------------------------------------------------
    // ERRO
    // ---------------------------------------------------------

    if (_erro != null) {
      return _buildErro();
    }

    // ---------------------------------------------------------
    // LISTA
    // ---------------------------------------------------------

    return CustomScrollView(
      slivers: [
        // =====================================================
        // PESQUISA FIXA
        // =====================================================

        SliverPersistentHeader(
          pinned: true,
          delegate: _PesquisaDelegate(
            child: _buildPesquisa(),
          ),
        ),

        // =====================================================
        // LISTA DE CATEGORIAS
        // =====================================================

        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            24,
            24,
            24,
            100,
          ),
          sliver: _categoriasFiltradas.isEmpty
              ? SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildNenhumResultado(),
                )
              : SliverList(
                  delegate:
                      SliverChildBuilderDelegate(
                    (
                      context,
                      index,
                    ) {
                      final categoria =
                          _categoriasFiltradas[index];

                      return Padding(
                        padding:
                            const EdgeInsets.only(
                          bottom: 16,
                        ),
                        child: _buildCategoria(
                          categoria,
                        ),
                      );
                    },
                    childCount:
                        _categoriasFiltradas.length,
                  ),
                ),
        ),
      ],
    );
  }

  // =========================================================
  // NENHUM RESULTADO
  // =========================================================

  Widget _buildNenhumResultado() {
    return const Column(
      mainAxisAlignment:
          MainAxisAlignment.center,
      children: [
        Icon(
          Icons.search_off,
          size: 56,
          color: onSurfaceVariant,
        ),
        SizedBox(
          height: 16,
        ),
        Text(
          'Nenhuma categoria encontrada.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: onSurface,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
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
            const Icon(
              Icons.error_outline,
              size: 48,
              color: primary,
            ),

            const SizedBox(
              height: 16,
            ),

            Text(
              _erro!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            ElevatedButton(
              onPressed: _carregarHinos,
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
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

  // =========================================================
  // CABEÇALHO
  // =========================================================

  Widget _buildCabecalho() {
    return Container(
      width: double.infinity,
      height: 64,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
      ),
      decoration: BoxDecoration(
        color: surface.withOpacity(0.95),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // ===================================================
          // LOGO
          // ===================================================

          Image.asset(
            'assets/images/logoieca.png',
            height: 32,
            width: 32,
            fit: BoxFit.contain,
            errorBuilder: (
              context,
              error,
              stackTrace,
            ) {
              return const SizedBox(
                width: 32,
                height: 32,
              );
            },
          ),

          const SizedBox(
            width: 12,
          ),

          // ===================================================
          // TÍTULO
          // ===================================================

          const Text(
            'IECA',
            style: TextStyle(
              color: onSurface,
              fontSize: 26,
              height: 1,
              fontWeight: FontWeight.w700,
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
    final bool temTexto =
        _pesquisaController.text.isNotEmpty;

    return Container(
      width: double.infinity,
      color: surface,
      padding: const EdgeInsets.fromLTRB(
        24,
        12,
        24,
        24,
      ),
      child: Column(
        children: [
          // ===================================================
          // CAMPO DE PESQUISA
          // ===================================================

          Container(
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0x1A855400),
              borderRadius:
                  BorderRadius.circular(999),
            ),
            child: Row(
              children: [
                // =============================================
                // ÍCONE
                // =============================================

                const Padding(
                  padding: EdgeInsets.only(
                    left: 16,
                  ),
                  child: Icon(
                    Icons.search,
                    size: 24,
                    color: Color(0x805B4040),
                  ),
                ),

                const SizedBox(
                  width: 12,
                ),

                // =============================================
                // CAMPO
                // =============================================

                Expanded(
                  child: TextField(
                    controller:
                        _pesquisaController,
                    textInputAction:
                        TextInputAction.search,
                    decoration:
                        const InputDecoration(
                      hintText:
                          'Buscar ekovongo...',
                      hintStyle: TextStyle(
                        color: Color(0x805B4040),
                        fontSize: 16,
                      ),
                      border:
                          InputBorder.none,
                      isCollapsed: true,
                    ),
                    style: const TextStyle(
                      color: onSurface,
                      fontSize: 16,
                    ),
                  ),
                ),

                // =============================================
                // LIMPAR
                // =============================================

                if (temTexto)
                  IconButton(
                    tooltip: 'Limpar',
                    onPressed: () {
                      _pesquisaController
                          .clear();
                    },
                    icon: const Icon(
                      Icons.close,
                      size: 20,
                      color:
                          onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(
            height: 16,
          ),

          // ===================================================
          // FILTROS
          // ===================================================

          SingleChildScrollView(
            scrollDirection:
                Axis.horizontal,
            child: Row(
              children: [
                _buildFiltro(
                  icone:
                      Icons.format_list_numbered,
                  texto: 'Número',
                ),

                const SizedBox(
                  width: 8,
                ),

                _buildFiltro(
                  icone:
                      Icons.sort_by_alpha,
                  texto: 'Nome',
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

  Widget _buildFiltro({
    required IconData icone,
    required String texto,
  }) {
    final bool ativo =
        _filtroAtual == texto;

    return Material(
      color: ativo
          ? primary
          : surfaceContainer,
      borderRadius:
          BorderRadius.circular(999),
      child: InkWell(
        borderRadius:
            BorderRadius.circular(999),
        onTap: () {
          setState(() {
            _filtroAtual = texto;
          });
        },
        child: Padding(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          child: Row(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              Icon(
                icone,
                size: 16,
                color: ativo
                    ? Colors.white
                    : onSurfaceVariant,
              ),

              const SizedBox(
                width: 4,
              ),

              Text(
                texto,
                style: TextStyle(
                  color: ativo
                      ? Colors.white
                      : onSurfaceVariant,
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
  // CATEGORIA
  // =========================================================

  Widget _buildCategoria(
    Map<String, dynamic> categoria,
  ) {
    final int inicio =
        categoria['inicio'] as int;

    final int fim =
        categoria['fim'] as int;

    final String titulo =
        categoria['titulo'] as String;

    final int quantidade =
        categoria['quantidade'] as int;

    // ---------------------------------------------------------
    // INTERVALO
    // ---------------------------------------------------------

    final String intervalo =
        inicio == fim
            ? '$inicio'
            : '$inicio-$fim';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius:
            BorderRadius.circular(12),

        // =====================================================
        // TODAS AS CATEGORIAS SÃO CLICÁVEIS
        // =====================================================

        onTap: () {
          _abrirCategoria(categoria);
        },

        child: Container(
          width: double.infinity,
          padding:
              const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color:
                const Color(0x99F8F9FF),
            borderRadius:
                BorderRadius.circular(12),
            border: Border.all(
              color:
                  const Color(0x4DE3BEBD),
            ),
            boxShadow: const [
              BoxShadow(
                color:
                    Color(0x0D000000),
                blurRadius: 20,
                offset:
                    Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.center,
            children: [
              // =================================================
              // NÚMERO / INTERVALO
              // =================================================

              Container(
                width: 70,
                height: 70,
                margin:
                    const EdgeInsets.only(
                  right: 16,
                ),
                decoration:
                    const BoxDecoration(
                  shape:
                      BoxShape.circle,
                  color:
                      Color(0x1A9E0027),
                ),
                alignment:
                    Alignment.center,
                child: Text(
                  intervalo,
                  textAlign:
                      TextAlign.center,
                  style:
                      const TextStyle(
                    color: primary,
                    fontSize: 14,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
              ),

              // =================================================
              // INFORMAÇÕES
              // =================================================

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
                      style:
                          const TextStyle(
                        color: onSurface,
                        fontSize: 20,
                        height: 1.6,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),

                    const SizedBox(
                      height: 4,
                    ),

                    Text(
                      quantidade == 1
                          ? '1 ekovongo'
                          : '$quantidade ekovongo',
                      overflow:
                          TextOverflow.ellipsis,
                      style:
                          const TextStyle(
                        color:
                            onSurfaceVariant,
                        fontSize: 14,
                        height: 1.4,
                        letterSpacing: 0.7,
                        fontWeight:
                            FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // =================================================
              // SETA
              // =================================================

              const Icon(
                Icons.chevron_right,
                color:
                    onSurfaceVariant,
                size: 24,
              ),
            ],
          ),
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

  _PesquisaDelegate({
    required this.child,
  });

  @override
  double get minExtent => 135;

  @override
  double get maxExtent => 135;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(
    covariant _PesquisaDelegate oldDelegate,
  ) {
    return true;
  }
}