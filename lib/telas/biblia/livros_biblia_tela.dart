import 'package:flutter/material.dart';

import '../../app/tema.dart';
import '../../componentes/cabecalho_ieca.dart';
import '../../componentes/navegacao_inferior_ieca.dart';
import '../../modelos/biblia_livro.dart';

import '../home/home_tela.dart';
import '../hinario/idiomas_tela.dart';
import '../sobre/sobre_tela.dart';
import '../informacoes_ieca/informacoes_ieca_tela.dart';

import 'leitura_biblia_tela.dart';

class LivrosBibliaTela extends StatefulWidget {
  final List<BibliaLivro> livros;

  const LivrosBibliaTela({
    super.key,
    required this.livros,
  });

  @override
  State<LivrosBibliaTela> createState() => _LivrosBibliaTelaState();
}

class _LivrosBibliaTelaState extends State<LivrosBibliaTela>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final TextEditingController _pesquisaController =
      TextEditingController();

  String _filtro = '';

  // ============================================================
  // SEPARAÇÃO DOS LIVROS
  // ============================================================

  List<BibliaLivro> get antigoTestamento {
    if (widget.livros.length >= 39) {
      return widget.livros.sublist(0, 39);
    }
    return widget.livros;
  }

  List<BibliaLivro> get novoTestamento {
    if (widget.livros.length >= 66) {
      return widget.livros.sublist(39, 66);
    } else if (widget.livros.length > 39) {
      return widget.livros.sublist(39);
    }
    return [];
  }

  // ============================================================
  // CICLO DE VIDA
  // ============================================================

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: 3,
      vsync: this,
    );

    _pesquisaController.addListener(_atualizarFiltro);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pesquisaController.removeListener(_atualizarFiltro);
    _pesquisaController.dispose();
    super.dispose();
  }

  void _atualizarFiltro() {
    if (mounted) {
      setState(() {
        _filtro = _pesquisaController.text;
      });
    }
  }

  // ============================================================
  // FILTRO
  // ============================================================

  List<BibliaLivro> _filtrarLivros(List<BibliaLivro> lista) {
    if (_filtro.trim().isEmpty) return lista;

    final termo = _filtro.toLowerCase().trim();

    return lista
        .where((livro) => livro.nome.toLowerCase().contains(termo))
        .toList();
  }

  // ============================================================
  // NAVEGAÇÃO PRINCIPAL
  // ============================================================

  void _selecionarNavegacao(int indice) {
    if (!mounted) return;

    switch (indice) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeTela()),
        );
        break;

      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const IdiomasTela()),
        );
        break;

      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const InformacoesIecaTela(),
          ),
        );
        break;

      case 3:
        // Já estamos na seção Bíblia.
        break;

      case 4:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SobreTela()),
        );
        break;
    }
  }

  // ============================================================
  // MODAL DE CAPÍTULOS
  // ============================================================

  void _abrirSelecaoCapitulo(BibliaLivro livro) {
    showModalBottomSheet(
      context: context,
      backgroundColor: TemaHinario.corSuperficie,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                // =================================================
                // CABEÇALHO DO MODAL
                // =================================================

                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 12, 8),
                  child: Column(
                    children: [
                      // Handle
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

                      const SizedBox(height: 14),

                      Row(
                        children: [
                          // Sigla do livro
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: TemaHinario.corPrimaria
                                  .withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(13),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _siglaLivro(livro.id),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: TemaHinario.corPrimaria,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  livro.nome,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w800,
                                    color: TemaHinario.corTexto,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  livro.capitulos.length == 1
                                      ? '1 capítulo'
                                      : '${livro.capitulos.length} capítulos',
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    color: TemaHinario
                                        .corTextoSecundario,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          IconButton(
                            tooltip: 'Fechar',
                            onPressed: () =>
                                Navigator.pop(context),
                            icon: const Icon(
                              Icons.close_rounded,
                              color:
                                  TemaHinario.corTextoSecundario,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // =================================================
                // GRELHA DE CAPÍTULOS
                // =================================================

                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      8,
                      20,
                      20,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1,
                    ),
                    itemCount: livro.capitulos.length,
                    itemBuilder: (context, index) {
                      final capituloNum = index + 1;

                     return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            Navigator.pop(context);

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LeituraBibliaTela(
                                  livro: livro,
                                  capituloNumero: capituloNum,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: TemaHinario.corSuperficieAlta,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: TemaHinario.corPrimaria
                                    .withValues(alpha: 0.12),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '$capituloNum',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: TemaHinario.corTexto,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // SIGLA DO LIVRO
  // ============================================================

  String _siglaLivro(String id) {
    if (id.length <= 3) return id.toUpperCase();
    return id.substring(0, 3).toUpperCase();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TemaHinario.corSuperficie,

      appBar: const CabecalhoIeca(),

      body: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          children: [
            // =====================================================
            // CABEÇALHO DA PÁGINA
            // =====================================================

            _buildCabecalhoPagina(),

            // =====================================================
            // ABAS
            // =====================================================

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: TemaHinario.corSuperficieMedia,
                borderRadius: BorderRadius.circular(14),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: Colors.white,
                unselectedLabelColor:
                    TemaHinario.corTextoSecundario,
                indicator: BoxDecoration(
                  color: TemaHinario.corPrimaria,
                  borderRadius: BorderRadius.circular(12),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: const EdgeInsets.all(4),
                dividerColor: Colors.transparent,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12.5,
                ),
                tabs: const [
                  Tab(text: 'Todos', height: 40),
                  Tab(text: 'A. Testamento', height: 40),
                  Tab(text: 'N. Testamento', height: 40),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // =====================================================
            // PESQUISA
            // =====================================================

            _buildPesquisa(),

            const SizedBox(height: 12),

            // =====================================================
            // LISTAS
            // =====================================================

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _construirListaLivros(
                    _filtrarLivros(widget.livros),
                  ),
                  _construirListaLivros(
                    _filtrarLivros(antigoTestamento),
                  ),
                  _construirListaLivros(
                    _filtrarLivros(novoTestamento),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: NavegacaoInferiorIeca(
        indiceSelecionado: 2,
        onDestinationSelected: _selecionarNavegacao,
      ),
    );
  }

  // ============================================================
  // CABEÇALHO DA PÁGINA
  // ============================================================

  Widget _buildCabecalhoPagina() {
    final total = widget.livros.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: TemaHinario.corPrimaria.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: TemaHinario.corPrimaria,
              size: 25,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bíblia Sagrada',
                  style: TextStyle(
                    fontSize: 22,
                    height: 1.15,
                    fontWeight: FontWeight.w800,
                    color: TemaHinario.corTexto,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  total == 1
                      ? '1 livro'
                      : '$total livros',
                  style: const TextStyle(
                    fontSize: 13,
                    color: TemaHinario.corTextoSecundario,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PESQUISA
  // ============================================================

  Widget _buildPesquisa() {
    final temTexto = _pesquisaController.text.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: TemaHinario.corSuperficieAlta,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: TemaHinario.corTextoSecundario
                .withValues(alpha: 0.15),
          ),
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            const Icon(
              Icons.search_rounded,
              size: 20,
              color: TemaHinario.corTextoSecundario,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _pesquisaController,
                textInputAction: TextInputAction.search,
                decoration: const InputDecoration(
                  hintText: 'Buscar livro...',
                  hintStyle: TextStyle(
                    color: TemaHinario.corTextoSecundario,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  isCollapsed: true,
                ),
                style: const TextStyle(
                  fontSize: 14,
                  color: TemaHinario.corTexto,
                ),
              ),
            ),
            if (temTexto)
              IconButton(
                tooltip: 'Limpar',
                onPressed: () => _pesquisaController.clear(),
                icon: const Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: TemaHinario.corTextoSecundario,
                ),
              )
            else
              const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // LISTA DE LIVROS
  // ============================================================

  Widget _construirListaLivros(List<BibliaLivro> lista) {
    if (lista.isEmpty) {
      return _buildVazio();
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      itemCount: lista.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final livro = lista[index];

        return _CardLivro(
          livro: livro,
          onTap: () => _abrirSelecaoCapitulo(livro),
        );
      },
    );
  }

  // ============================================================
  // VAZIO
  // ============================================================

  Widget _buildVazio() {
    final filtroAtivo = _filtro.trim().isNotEmpty;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                color: TemaHinario.corPrimaria.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                filtroAtivo
                    ? Icons.search_off_rounded
                    : Icons.menu_book_outlined,
                size: 36,
                color: TemaHinario.corPrimaria,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              filtroAtivo
                  ? 'Nenhum livro encontrado'
                  : 'Nenhum livro disponível',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: TemaHinario.corTexto,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              filtroAtivo
                  ? 'Experimente pesquisar por outro nome.'
                  : 'Verifique os ficheiros de dados.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13.5,
                height: 1.5,
                color: TemaHinario.corTextoSecundario,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================
// CARTÃO DE LIVRO
// =============================================================

class _CardLivro extends StatelessWidget {
  final BibliaLivro livro;
  final VoidCallback onTap;

  const _CardLivro({
    required this.livro,
    required this.onTap,
  });

  String _sigla(String id) {
    if (id.length <= 3) return id.toUpperCase();
    return id.substring(0, 3).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: TemaHinario.corSuperficieAlta,
            borderRadius: BorderRadius.circular(14),
            border: Border(
              left: BorderSide(
                color: TemaHinario.corPrimaria,
                width: 4,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
            child: Row(
              children: [
                // -------------------------------------------------
                // SIGLA
                // -------------------------------------------------

                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: TemaHinario.corPrimaria
                        .withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _sigla(livro.id),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: TemaHinario.corPrimaria,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),

                const SizedBox(width: 14),

                // -------------------------------------------------
                // INFORMAÇÕES
                // -------------------------------------------------

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        livro.nome,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: TemaHinario.corTexto,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        livro.capitulos.length == 1
                            ? '1 capítulo'
                            : '${livro.capitulos.length} capítulos',
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: TemaHinario.corTextoSecundario,
                        ),
                      ),
                    ],
                  ),
                ),

                // -------------------------------------------------
                // SETA
                // -------------------------------------------------

                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: TemaHinario.corSuperficieMedia,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 13,
                    color: TemaHinario.corTextoSecundario,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}