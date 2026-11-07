import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/tema.dart';
import '../../componentes/cabecalho_ieca.dart';
import '../../componentes/navegacao_inferior_ieca.dart';
import '../../modelos/favorito.dart';
import '../../servicos/favoritos_servico.dart';
import '../biblia/biblia_tela.dart';
import '../hinario/idiomas_tela.dart';
import '../hinario/leitura_tela.dart';
import '../home/home_tela.dart';
import '../sobre/sobre_tela.dart';
import '../informacoes_ieca/informacoes_ieca_tela.dart';

class FavoritosTela extends StatefulWidget {
  const FavoritosTela({super.key});

  @override
  State<FavoritosTela> createState() => _FavoritosTelaState();
}

class _FavoritosTelaState extends State<FavoritosTela> {
  final FavoritosServico _favoritosServico =
      FavoritosServico.instancia;

  final TextEditingController _pesquisaController =
      TextEditingController();

  List<FavoritoItem> _favoritos = [];

  bool _carregando = true;
  String? _erro;

  String _categoriaSelecionada = 'Todas';
  String _ordemSelecionada = 'recentes';

  int _paginaAtual = 1;

  static const int _itensPorPagina = 10;

  @override
  void initState() {
    super.initState();

    _pesquisaController.addListener(_atualizarPesquisa);

    _carregarFavoritos();
  }

  @override
  void dispose() {
    _pesquisaController.removeListener(_atualizarPesquisa);
    _pesquisaController.dispose();
    super.dispose();
  }

  // ============================================================
  // CARREGAR
  // ============================================================

  Future<void> _carregarFavoritos() async {
    if (mounted) {
      setState(() {
        _carregando = true;
        _erro = null;
      });
    }

    try {
      final favoritos =
          await _favoritosServico.carregarFavoritos();

      if (!mounted) return;

      setState(() {
        _favoritos = favoritos;
        _carregando = false;
        _paginaAtual = 1;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _carregando = false;
        _erro = 'Não foi possível carregar os favoritos.';
      });
    }
  }

  void _atualizarPesquisa() {
    if (!mounted) return;
    setState(() => _paginaAtual = 1);
  }

  // ============================================================
  // CATEGORIAS
  // ============================================================

  List<String> get _categorias {
    final categorias = <String>{'Todas'};

    for (final favorito in _favoritos) {
      categorias.add(favorito.nomeCategoria);
    }

    final resultado = categorias.toList();
    resultado.remove('Todas');
    resultado.sort();

    return ['Todas', ...resultado];
  }

  // ============================================================
  // FILTRAR
  // ============================================================

  List<FavoritoItem> get _favoritosFiltrados {
    final pesquisa =
        _pesquisaController.text.trim().toLowerCase();

    var resultado = List<FavoritoItem>.from(_favoritos);

    if (pesquisa.isNotEmpty) {
      resultado = resultado.where((favorito) {
        final campos = [
          favorito.titulo,
          favorito.subtitulo,
          favorito.numero,
          favorito.referencia,
          favorito.categoria,
          favorito.tipo,
          favorito.idioma,
          favorito.texto,
          favorito.nomeCategoria,
        ];

        return campos.any(
          (campo) => campo.toLowerCase().contains(pesquisa),
        );
      }).toList();
    }

    if (_categoriaSelecionada != 'Todas') {
      resultado = resultado.where(
        (favorito) =>
            favorito.nomeCategoria == _categoriaSelecionada,
      ).toList();
    }

    switch (_ordemSelecionada) {
      case 'recentes':
        resultado.sort((a, b) => b.data.compareTo(a.data));
        break;
      case 'antigos':
        resultado.sort((a, b) => a.data.compareTo(b.data));
        break;
      case 'nome':
        resultado.sort(
          (a, b) => a.titulo
              .toLowerCase()
              .compareTo(b.titulo.toLowerCase()),
        );
        break;
      case 'categoria':
        resultado.sort(
          (a, b) => a.nomeCategoria
              .toLowerCase()
              .compareTo(b.nomeCategoria.toLowerCase()),
        );
        break;
    }

    return resultado;
  }

  List<FavoritoItem> get _favoritosDaPagina {
    final todos = _favoritosFiltrados;
    if (todos.isEmpty) return [];

    final inicio = (_paginaAtual - 1) * _itensPorPagina;
    if (inicio >= todos.length) return [];

    final fim = (inicio + _itensPorPagina).clamp(0, todos.length);
    return todos.sublist(inicio, fim);
  }

  int get _totalPaginas {
    if (_favoritosFiltrados.isEmpty) return 1;
    return (_favoritosFiltrados.length / _itensPorPagina).ceil();
  }

  bool get _temFiltrosAtivos {
    return _pesquisaController.text.trim().isNotEmpty ||
        _categoriaSelecionada != 'Todas';
  }

  void _limparFiltros() {
    _pesquisaController.clear();
    setState(() {
      _categoriaSelecionada = 'Todas';
      _ordemSelecionada = 'recentes';
      _paginaAtual = 1;
    });
  }

  // ============================================================
  // AÇÕES
  // ============================================================

  Future<void> _abrirFavorito(FavoritoItem favorito) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LeituraTela(favorito: favorito),
      ),
    );
    await _carregarFavoritos();
  }

  Future<void> _copiarFavorito(FavoritoItem favorito) async {
    await Clipboard.setData(ClipboardData(text: favorito.texto));

    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          backgroundColor: TemaHinario.corPrimaria,
          content: const Row(
            children: [
              Icon(Icons.check_rounded, color: Colors.white),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Conteúdo copiado.',
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

  Future<void> _removerFavorito(FavoritoItem favorito) async {
    await _favoritosServico.removerFavorito(
      id: favorito.id,
      tipo: favorito.tipo,
    );

    await _carregarFavoritos();

    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          backgroundColor: TemaHinario.corPrimaria,
          content: const Row(
            children: [
              Icon(Icons.favorite_border_rounded, color: Colors.white),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Removido dos favoritos.',
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

  Future<void> _confirmarRemoverTodos() async {
    if (_favoritos.isEmpty) return;

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: const Text('Remover todos os favoritos?'),
        content: const Text(
          'Todos os conteúdos guardados nos favoritos serão '
          'removidos. Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: TemaHinario.corPrimaria,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remover todos'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    await _favoritosServico.removerTodos();

    if (!mounted) return;

    setState(() {
      _favoritos = [];
      _paginaAtual = 1;
    });

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          backgroundColor: TemaHinario.corPrimaria,
          content: const Row(
            children: [
              Icon(Icons.delete_sweep_rounded, color: Colors.white),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Todos os favoritos foram removidos.',
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

  void _explorarHinario() {
    Navigator.pushReplacementNamed(context, '/idiomas');
  }

  // ============================================================
  // NAVEGAÇÃO INFERIOR
  // ============================================================

  void _selecionarNavegacao(int indice) {
  if (!mounted) return;

  Widget tela;

  switch (indice) {
    case 0:
      tela = const HomeTela();
      break;

    case 1:
      tela = const IdiomasTela();
      break;

    case 2:
      tela = const BibliaTela();
      break;

    case 3:
      tela = const InformacoesIecaTela();
      break;

    case 4:
      tela = const SobreTela();
      break;

    default:
      return;
  }

  Navigator.pushReplacement(
    context,
    MaterialPageRoute<void>(builder: (_) => tela),
  );
}

  // ============================================================
  // DATA RELATIVA
  // ============================================================

  String _formatarData(DateTime data) {
    final agora = DateTime.now();
    final diferenca = agora.difference(data);

    if (diferenca.inSeconds < 60) return 'Agora mesmo';
    if (diferenca.inMinutes < 60) {
      return 'Há ${diferenca.inMinutes} min';
    }
    if (diferenca.inHours < 24) {
      return 'Há ${diferenca.inHours} h';
    }
    if (diferenca.inDays == 1) return 'Ontem';
    if (diferenca.inDays < 7) {
      return 'Há ${diferenca.inDays} dias';
    }

    return '${data.day.toString().padLeft(2, '0')}/'
        '${data.month.toString().padLeft(2, '0')}/'
        '${data.year}';
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
            _buildCabecalhoPagina(),
            _buildPesquisaEFiltros(),
            Expanded(
              child: _carregando
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: TemaHinario.corPrimaria,
                      ),
                    )
                  : _erro != null
                      ? _buildErro()
                      : _favoritosFiltrados.isEmpty
                          ? _buildVazio()
                          : _buildLista(),
            ),
          ],
        ),
      ),

      bottomNavigationBar: NavegacaoInferiorIeca(
        indiceSelecionado: 0,
        onDestinationSelected: _selecionarNavegacao,
      ),
    );
  }

  // ============================================================
  // CABEÇALHO
  // ============================================================

  Widget _buildCabecalhoPagina() {
    final total = _favoritos.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 14),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFD81B60).withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.favorite_rounded,
              color: Color(0xFFD81B60),
              size: 25,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Favoritos',
                  style: TextStyle(
                    fontSize: 22,
                    height: 1.15,
                    fontWeight: FontWeight.w800,
                    color: TemaHinario.corTexto,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  total == 0
                      ? 'Sem favoritos'
                      : total == 1
                          ? '1 conteúdo guardado'
                          : '$total conteúdos guardados',
                  style: const TextStyle(
                    fontSize: 13,
                    color: TemaHinario.corTextoSecundario,
                  ),
                ),
              ],
            ),
          ),
          if (_favoritos.isNotEmpty)
            IconButton(
              tooltip: 'Remover todos',
              onPressed: _confirmarRemoverTodos,
              icon: const Icon(
                Icons.delete_sweep_rounded,
                color: TemaHinario.corTextoSecundario,
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // PESQUISA E FILTROS
  // ============================================================

  Widget _buildPesquisaEFiltros() {
    final temTexto = _pesquisaController.text.isNotEmpty;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Column(
        children: [
          // Pesquisa
          Container(
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
                      hintText: 'Pesquisar favoritos...',
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

          const SizedBox(height: 10),

          // Categorias em chips
          SizedBox(
            height: 34,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _categorias.map((categoria) {
                return _chipCategoria(categoria);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chipCategoria(String categoria) {
    final selecionado = _categoriaSelecionada == categoria;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: selecionado
            ? TemaHinario.corPrimaria
            : TemaHinario.corSuperficieMedia,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: () {
            setState(() {
              _categoriaSelecionada = categoria;
              _paginaAtual = 1;
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 6,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (selecionado) ...[
                  const Icon(
                    Icons.check_rounded,
                    size: 14,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 5),
                ],
                Text(
                  categoria,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: selecionado
                        ? Colors.white
                        : TemaHinario.corTextoSecundario,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // LISTA
  // ============================================================

  Widget _buildLista() {
    return RefreshIndicator(
      color: TemaHinario.corPrimaria,
      onRefresh: _carregarFavoritos,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
        itemCount: _favoritosDaPagina.length + 2,
        itemBuilder: (context, index) {
          // Cabeçalho de contagem
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Conteúdos guardados',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: TemaHinario.corTexto,
                      ),
                    ),
                  ),
                  Text(
                    '${_favoritosFiltrados.length} '
                    '${_favoritosFiltrados.length == 1 ? 'resultado' : 'resultados'}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: TemaHinario.corTextoSecundario,
                    ),
                  ),
                  if (_temFiltrosAtivos) ...[
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: _limparFiltros,
                      borderRadius: BorderRadius.circular(8),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 4,
                        ),
                        child: Text(
                          'Limpar',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: TemaHinario.corPrimaria,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }

          // Paginação no fim
          if (index == _favoritosDaPagina.length + 1) {
            if (_favoritosFiltrados.length > _itensPorPagina) {
              return Padding(
                padding: const EdgeInsets.only(top: 12),
                child: _buildPaginacao(),
              );
            }
            return const SizedBox.shrink();
          }

          final favorito = _favoritosDaPagina[index - 1];
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _CartaoFavorito(
              favorito: favorito,
              dataFormatada: _formatarData(favorito.data),
              onAbrir: () => _abrirFavorito(favorito),
              onCopiar: () => _copiarFavorito(favorito),
              onRemover: () => _removerFavorito(favorito),
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // PAGINAÇÃO
  // ============================================================

  Widget _buildPaginacao() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: _paginaAtual > 1
              ? () => setState(() => _paginaAtual--)
              : null,
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: TemaHinario.corPrimaria.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$_paginaAtual / $_totalPaginas',
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: TemaHinario.corTexto,
            ),
          ),
        ),
        IconButton(
          onPressed: _paginaAtual < _totalPaginas
              ? () => setState(() => _paginaAtual++)
              : null,
          icon: const Icon(Icons.chevron_right_rounded),
        ),
      ],
    );
  }

  // ============================================================
  // ERRO
  // ============================================================

  Widget _buildErro() {
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
              child: const Icon(
                Icons.error_outline_rounded,
                size: 38,
                color: TemaHinario.corPrimaria,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              _erro ?? 'Ocorreu um erro.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: TemaHinario.corTexto,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _carregarFavoritos,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Tentar novamente'),
              style: FilledButton.styleFrom(
                backgroundColor: TemaHinario.corPrimaria,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // VAZIO
  // ============================================================

  Widget _buildVazio() {
    final possuiFiltros = _temFiltrosAtivos;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                color: const Color(0xFFD81B60).withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_border_rounded,
                size: 42,
                color: Color(0xFFD81B60),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              possuiFiltros
                  ? 'Nenhum favorito encontrado'
                  : 'Ainda não tem favoritos',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: TemaHinario.corTexto,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              possuiFiltros
                  ? 'Tente alterar a pesquisa ou os filtros utilizados.'
                  : 'Os conteúdos que marcar como favoritos aparecerão aqui.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13.5,
                height: 1.5,
                color: TemaHinario.corTextoSecundario,
              ),
            ),
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: possuiFiltros
                  ? _limparFiltros
                  : _explorarHinario,
              icon: Icon(
                possuiFiltros
                    ? Icons.filter_alt_off_rounded
                    : Icons.explore_rounded,
              ),
              label: Text(
                possuiFiltros ? 'Limpar filtros' : 'Explorar Hinário',
              ),
              style: FilledButton.styleFrom(
                backgroundColor: TemaHinario.corPrimaria,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
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
// CARTÃO DE FAVORITO
// =============================================================

class _CartaoFavorito extends StatelessWidget {
  final FavoritoItem favorito;
  final String dataFormatada;
  final VoidCallback onAbrir;
  final VoidCallback onCopiar;
  final VoidCallback onRemover;

  const _CartaoFavorito({
    required this.favorito,
    required this.dataFormatada,
    required this.onAbrir,
    required this.onCopiar,
    required this.onRemover,
  });

  IconData get _iconeTipo {
    switch (favorito.tipo.toLowerCase()) {
      case 'hino':
        return Icons.music_note_rounded;
      case 'salmo':
        return Icons.menu_book_rounded;
      case 'litania':
        return Icons.format_list_bulleted_rounded;
      case 'doxologia':
        return Icons.auto_awesome_rounded;
      case 'invocatoria':
      case 'invocatória':
        return Icons.wb_sunny_rounded;
      case 'credo':
        return Icons.church_rounded;
      case 'oracao':
      case 'oração':
        return Icons.volunteer_activism_rounded;
      default:
        return Icons.description_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onAbrir,
        child: Ink(
          decoration: BoxDecoration(
            color: TemaHinario.corSuperficieAlta,
            borderRadius: BorderRadius.circular(16),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Linha de topo: ícone + categoria + número
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: TemaHinario.corPrimaria
                            .withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        _iconeTipo,
                        size: 18,
                        color: TemaHinario.corPrimaria,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            favorito.nomeCategoria.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                              color: TemaHinario.corPrimaria,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            dataFormatada,
                            style: TextStyle(
                              fontSize: 11,
                              color: TemaHinario.corTextoSecundario
                                  .withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (favorito.numero.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: TemaHinario.corSuperficieMedia,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          favorito.numero,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: TemaHinario.corTextoSecundario,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 10),

                // Título
                Text(
                  favorito.titulo,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                    color: TemaHinario.corTexto,
                  ),
                ),

                if (favorito.subtitulo.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    favorito.subtitulo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: TemaHinario.corTextoSecundario,
                    ),
                  ),
                ],

                const SizedBox(height: 12),

                // Ações
                Row(
                  children: [
                    _botaoAcao(
                      icone: Icons.menu_book_rounded,
                      texto: 'Abrir',
                      onTap: onAbrir,
                      cor: TemaHinario.corPrimaria,
                    ),
                    const SizedBox(width: 8),
                    _botaoAcao(
                      icone: Icons.copy_rounded,
                      texto: 'Copiar',
                      onTap: onCopiar,
                    ),
                    const Spacer(),
                    _botaoAcao(
                      icone: Icons.delete_outline_rounded,
                      texto: 'Remover',
                      onTap: onRemover,
                      cor: const Color(0xFFD32F2F),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _botaoAcao({
    required IconData icone,
    required String texto,
    required VoidCallback onTap,
    Color? cor,
  }) {
    final c = cor ?? TemaHinario.corTextoSecundario;

    return Material(
      color: c.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 7,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icone, size: 15, color: c),
              const SizedBox(width: 5),
              Text(
                texto,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: c,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}