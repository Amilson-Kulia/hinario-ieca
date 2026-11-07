import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/tema.dart';
import '../../componentes/cabecalho_ieca.dart';
import '../../componentes/navegacao_inferior_ieca.dart';
import '../../modelos/favorito.dart';
import '../../servicos/marcados_servico.dart';
import '../biblia/biblia_tela.dart';
import '../home/home_tela.dart';
import '../hinario/idiomas_tela.dart';
import '../hinario/leitura_tela.dart';
import '../sobre/sobre_tela.dart';
import '../informacoes_ieca/informacoes_ieca_tela.dart';

class MarcadosTela extends StatefulWidget {
  const MarcadosTela({super.key});

  @override
  State<MarcadosTela> createState() => _MarcadosTelaState();
}

class _MarcadosTelaState extends State<MarcadosTela> {
  final MarcadosServico _marcadosServico =
      MarcadosServico.instancia;

  final TextEditingController _pesquisaController =
      TextEditingController();

  List<MarcadoItem> _marcados = [];

  bool _carregando = true;

  String _pesquisa = '';
  String _categoria = 'todos';
  String _cor = 'todas';
  String _ordem = 'recente';

  int _paginaAtual = 1;

  static const int _itensPorPagina = 8;

  static const Map<String, Color> cores = {
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
    _pesquisaController.addListener(() {
      if (!mounted) return;
      setState(() {
        _pesquisa = _pesquisaController.text.trim();
        _paginaAtual = 1;
      });
    });
    _carregar();
  }

  @override
  void dispose() {
    _pesquisaController.dispose();
    super.dispose();
  }

  // ============================================================
  // CARREGAR
  // ============================================================

  Future<void> _carregar() async {
    if (mounted) setState(() => _carregando = true);

    try {
      final marcados =
          await _marcadosServico.carregarMarcados();

      if (!mounted) return;

      setState(() {
        _marcados = marcados;
        _carregando = false;
        if (_paginaAtual > _totalPaginas) {
          _paginaAtual = _totalPaginas;
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _marcados = [];
        _carregando = false;
      });
    }
  }

  // ============================================================
  // FILTRAR
  // ============================================================

  List<MarcadoItem> get _filtrados {
    var resultado = List<MarcadoItem>.from(_marcados);

    if (_pesquisa.isNotEmpty) {
      final termo = _pesquisa.toLowerCase();
      resultado = resultado.where((item) {
        return item.titulo.toLowerCase().contains(termo) ||
            item.tipo.toLowerCase().contains(termo) ||
            item.categoria.toLowerCase().contains(termo) ||
            item.numero.toLowerCase().contains(termo);
      }).toList();
    }

    if (_categoria != 'todos') {
      resultado = resultado
          .where((item) => _normalizarTipo(item.tipo) == _categoria)
          .toList();
    }

    if (_cor != 'todas') {
      final corSelecionada = cores[_cor];
      if (corSelecionada != null) {
        resultado = resultado
            .where((item) => item.cor == corSelecionada.value)
            .toList();
      }
    }

    switch (_ordem) {
      case 'recente':
        resultado.sort((a, b) => b.data.compareTo(a.data));
        break;
      case 'antigo':
        resultado.sort((a, b) => a.data.compareTo(b.data));
        break;
      case 'titulo':
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

  int get _totalPaginas {
    if (_filtrados.isEmpty) return 1;
    return (_filtrados.length / _itensPorPagina).ceil();
  }

  List<MarcadoItem> get _pagina {
    final inicio = (_paginaAtual - 1) * _itensPorPagina;
    if (inicio >= _filtrados.length) return [];

    final fim = (inicio + _itensPorPagina).clamp(0, _filtrados.length);
    return _filtrados.sublist(inicio, fim);
  }

  bool get _temFiltrosAtivos {
    return _pesquisa.isNotEmpty ||
        _categoria != 'todos' ||
        _cor != 'todas';
  }

  void _limparFiltros() {
    _pesquisaController.clear();
    setState(() {
      _pesquisa = '';
      _categoria = 'todos';
      _cor = 'todas';
      _ordem = 'recente';
      _paginaAtual = 1;
    });
  }

  // ============================================================
  // UTILITÁRIOS
  // ============================================================

  String _normalizarTipo(String tipo) {
    final valor = tipo
        .toLowerCase()
        .trim()
        .replaceAll('ó', 'o')
        .replaceAll('á', 'a')
        .replaceAll('í', 'i')
        .replaceAll('é', 'e');

    switch (valor) {
      case 'hino':
        return 'hino';
      case 'salmo':
        return 'salmo';
      case 'litania':
        return 'litania';
      case 'doxologia':
        return 'doxologia';
      case 'invocatoria':
        return 'invocatoria';
      case 'credo':
        return 'credo';
      case 'oracao':
        return 'oracao';
      default:
        return valor;
    }
  }

  String _capitalizar(String texto) {
    if (texto.isEmpty) return texto;
    return texto[0].toUpperCase() + texto.substring(1);
  }

  String _nomeCor(int valor) {
    for (final entrada in cores.entries) {
      if (entrada.value.value == valor) {
        return _capitalizar(entrada.key);
      }
    }
    return 'Cinzento';
  }

  String _nomeCategoria(String tipo) {
    switch (_normalizarTipo(tipo)) {
      case 'hino':
        return 'Hino';
      case 'salmo':
        return 'Salmo';
      case 'litania':
        return 'Litania';
      case 'doxologia':
        return 'Doxologia';
      case 'invocatoria':
        return 'Invocatória';
      case 'credo':
        return 'Credo Apostólico';
      case 'oracao':
        return 'Oração do Senhor';
      default:
        return 'Conteúdo';
    }
  }

  IconData _iconeTipo(String tipo) {
    switch (_normalizarTipo(tipo)) {
      case 'hino':
        return Icons.music_note_rounded;
      case 'salmo':
        return Icons.menu_book_rounded;
      case 'litania':
        return Icons.format_list_bulleted_rounded;
      case 'doxologia':
        return Icons.auto_awesome_rounded;
      case 'invocatoria':
        return Icons.wb_sunny_rounded;
      case 'credo':
        return Icons.church_rounded;
      case 'oracao':
        return Icons.volunteer_activism_rounded;
      default:
        return Icons.bookmark_rounded;
    }
  }

  String _formatarData(DateTime data) {
    const meses = [
      'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez',
    ];
    return '${data.day} ${meses[data.month - 1]} ${data.year}';
  }

  // ============================================================
  // AÇÕES
  // ============================================================

  Future<void> _abrirConteudo(MarcadoItem item) async {
    final favorito = FavoritoItem(
      id: item.id,
      tipo: item.tipo,
      titulo: item.titulo,
      subtitulo: item.subtitulo,
      numero: item.numero,
      referencia: item.referencia,
      categoria: item.categoria,
      idioma: item.idioma,
      texto: item.texto,
      data: item.data,
      icone: _iconeTipo(item.tipo).codePoint,
    );

    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => LeituraTela(favorito: favorito),
      ),
    );

    await _carregar();
  }

  Future<void> _partilhar(MarcadoItem item) async {
    final textoCompartilhar = [
      item.titulo,
      if (item.numero.isNotEmpty) item.numero,
      _nomeCategoria(item.tipo),
      'Marcado com a cor ${_nomeCor(item.cor)}.',
    ].join('\n');

    await Clipboard.setData(
      ClipboardData(text: textoCompartilhar),
    );

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
                  'Informações copiadas.',
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

  Future<void> _alterarCor(MarcadoItem item) async {
    final novaCor = await showModalBottomSheet<Color?>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _ModalCores(
        corAtual: Color(item.cor),
        cores: cores,
      ),
    );

    if (novaCor == null) return;

    final sucesso = await _marcadosServico.alterarCor(
      id: item.id,
      tipo: item.tipo,
      cor: novaCor,
    );

    if (!mounted || !sucesso) return;

    await _carregar();

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
              Icon(Icons.palette_rounded, color: Colors.white),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Cor alterada.',
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

  Future<void> _remover(MarcadoItem item) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: const Text('Remover marcação?'),
        content: Text('Deseja remover a marcação de "${item.titulo}"?'),
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
            child: const Text('Remover'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    final sucesso = await _marcadosServico.remover(
      id: item.id,
      tipo: item.tipo,
    );

    if (!mounted || !sucesso) return;

    await _carregar();

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
              Icon(Icons.bookmark_remove_rounded, color: Colors.white),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Marcação removida.',
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

  // ============================================================
  // NAVEGAÇÃO
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
                  : _filtrados.isEmpty
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
    final total = _marcados.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 14),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: TemaHinario.corPrimaria.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.bookmark_rounded,
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
                  'Marcados',
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
                      ? 'Sem marcações'
                      : total == 1
                          ? '1 conteúdo marcado'
                          : '$total conteúdos marcados',
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
  // PESQUISA + FILTROS
  // ============================================================

  Widget _buildPesquisaEFiltros() {
    final temTexto = _pesquisaController.text.isNotEmpty;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Column(
        children: [
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
                      hintText: 'Pesquisar marcações...',
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

          SizedBox(
            height: 34,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _chipFiltro(
                  texto: _categoria == 'todos'
                      ? 'Todas as categorias'
                      : _nomeCategoria(_categoria),
                  selecionado: _categoria != 'todos',
                  icone: Icons.category_outlined,
                  onTap: _abrirFiltroCategoria,
                ),
                const SizedBox(width: 8),
                _chipFiltro(
                  texto: _cor == 'todas'
                      ? 'Todas as cores'
                      : _capitalizar(_cor),
                  selecionado: _cor != 'todas',
                  icone: Icons.palette_outlined,
                  corPonto: _cor == 'todas' ? null : cores[_cor],
                  onTap: _abrirFiltroCor,
                ),
                const SizedBox(width: 8),
                _chipFiltro(
                  texto: _nomeOrdemCurto(_ordem),
                  selecionado: _ordem != 'recente',
                  icone: Icons.sort_rounded,
                  onTap: _abrirFiltroOrdem,
                ),
                if (_temFiltrosAtivos) ...[
                  const SizedBox(width: 8),
                  Material(
                    color: TemaHinario.corPrimaria.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(999),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(999),
                      onTap: _limparFiltros,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.close_rounded,
                              size: 14,
                              color: TemaHinario.corPrimaria,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Limpar',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: TemaHinario.corPrimaria,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chipFiltro({
    required String texto,
    required bool selecionado,
    required IconData icone,
    required VoidCallback onTap,
    Color? corPonto,
  }) {
    return Material(
      color: selecionado
          ? TemaHinario.corPrimaria
          : TemaHinario.corSuperficieMedia,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (corPonto != null)
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: corPonto,
                    shape: BoxShape.circle,
                  ),
                )
              else
                Icon(
                  icone,
                  size: 14,
                  color: selecionado
                      ? Colors.white
                      : TemaHinario.corTextoSecundario,
                ),
              const SizedBox(width: 6),
              Text(
                texto,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: selecionado
                      ? Colors.white
                      : TemaHinario.corTextoSecundario,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 14,
                color: selecionado
                    ? Colors.white
                    : TemaHinario.corTextoSecundario,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _nomeOrdemCurto(String valor) {
    switch (valor) {
      case 'antigo':
        return 'Mais antigos';
      case 'titulo':
        return 'Título';
      case 'categoria':
        return 'Categoria';
      default:
        return 'Mais recentes';
    }
  }

  // ============================================================
  // LISTA
  // ============================================================

  Widget _buildLista() {
    return RefreshIndicator(
      color: TemaHinario.corPrimaria,
      onRefresh: _carregar,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
        itemCount: _pagina.length + 2,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Conteúdos marcados',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: TemaHinario.corTexto,
                      ),
                    ),
                  ),
                  Text(
                    '${_filtrados.length} '
                    '${_filtrados.length == 1 ? 'resultado' : 'resultados'}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: TemaHinario.corTextoSecundario,
                    ),
                  ),
                ],
              ),
            );
          }

          if (index == _pagina.length + 1) {
            if (_filtrados.length > _itensPorPagina) {
              return Padding(
                padding: const EdgeInsets.only(top: 12),
                child: _buildPaginacao(),
              );
            }
            return const SizedBox.shrink();
          }

          final item = _pagina[index - 1];
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _CartaoMarcado(
              item: item,
              nomeCor: _nomeCor(item.cor),
              nomeCategoria: _nomeCategoria(item.tipo),
              icone: _iconeTipo(item.tipo),
              dataFormatada: _formatarData(item.data),
              onAbrir: () => _abrirConteudo(item),
              onPartilhar: () => _partilhar(item),
              onAlterarCor: () => _alterarCor(item),
              onRemover: () => _remover(item),
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
  // VAZIO
  // ============================================================

  Widget _buildVazio() {
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
                color: TemaHinario.corPrimaria.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.bookmark_border_rounded,
                size: 42,
                color: TemaHinario.corPrimaria,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _temFiltrosAtivos
                  ? 'Nenhuma marcação encontrada'
                  : 'Ainda não tem marcações',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: TemaHinario.corTexto,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _temFiltrosAtivos
                  ? 'Tente alterar os filtros ou a pesquisa.'
                  : 'Os conteúdos que marcar aparecerão aqui.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13.5,
                height: 1.5,
                color: TemaHinario.corTextoSecundario,
              ),
            ),
            if (_temFiltrosAtivos) ...[
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _limparFiltros,
                icon: const Icon(Icons.filter_alt_off_rounded),
                label: const Text('Limpar filtros'),
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
          ],
        ),
      ),
    );
  }

  // ============================================================
  // MODAIS DE FILTRO
  // ============================================================

  Future<void> _abrirFiltroCategoria() async {
    final resultado = await _abrirSeletor(
      titulo: 'Categoria',
      valorAtual: _categoria,
      opcoes: const {
        'todos': 'Todas',
        'hino': 'Hinos',
        'salmo': 'Salmos',
        'litania': 'Litanias',
        'doxologia': 'Doxologias',
        'invocatoria': 'Invocatórias',
        'credo': 'Credo Apostólico',
        'oracao': 'Oração do Senhor',
      },
    );

    if (resultado == null) return;
    setState(() {
      _categoria = resultado;
      _paginaAtual = 1;
    });
  }

  Future<void> _abrirFiltroCor() async {
    final resultado = await _abrirSeletor(
      titulo: 'Cor',
      valorAtual: _cor,
      opcoes: const {
        'todas': 'Todas',
        'vermelho': 'Vermelho',
        'laranja': 'Laranja',
        'amarelo': 'Amarelo',
        'verde': 'Verde',
        'azul': 'Azul',
        'roxo': 'Roxo',
        'rosa': 'Rosa',
        'cinzento': 'Cinzento',
      },
    );

    if (resultado == null) return;
    setState(() {
      _cor = resultado;
      _paginaAtual = 1;
    });
  }

  Future<void> _abrirFiltroOrdem() async {
    final resultado = await _abrirSeletor(
      titulo: 'Ordenar por',
      valorAtual: _ordem,
      opcoes: const {
        'recente': 'Mais recentes',
        'antigo': 'Mais antigos',
        'titulo': 'Título',
        'categoria': 'Categoria',
      },
    );

    if (resultado == null) return;
    setState(() {
      _ordem = resultado;
      _paginaAtual = 1;
    });
  }

  Future<String?> _abrirSeletor({
    required String titulo,
    required String valorAtual,
    required Map<String, String> opcoes,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: TemaHinario.corSuperficie,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(26),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
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
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: TemaHinario.corTexto,
                  ),
                ),
                const SizedBox(height: 10),
                ...opcoes.entries.map((entry) {
                  final selecionado = entry.key == valorAtual;

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      entry.value,
                      style: TextStyle(
                        fontWeight: selecionado
                            ? FontWeight.w800
                            : FontWeight.w500,
                        color: selecionado
                            ? TemaHinario.corPrimaria
                            : TemaHinario.corTexto,
                      ),
                    ),
                    trailing: selecionado
                        ? const Icon(
                            Icons.check_circle_rounded,
                            color: TemaHinario.corPrimaria,
                          )
                        : null,
                    onTap: () => Navigator.pop(context, entry.key),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================
// CARTÃO DE MARCADO
// =============================================================

class _CartaoMarcado extends StatelessWidget {
  final MarcadoItem item;
  final String nomeCor;
  final String nomeCategoria;
  final IconData icone;
  final String dataFormatada;
  final VoidCallback onAbrir;
  final VoidCallback onPartilhar;
  final VoidCallback onAlterarCor;
  final VoidCallback onRemover;

  const _CartaoMarcado({
    required this.item,
    required this.nomeCor,
    required this.nomeCategoria,
    required this.icone,
    required this.dataFormatada,
    required this.onAbrir,
    required this.onPartilhar,
    required this.onAlterarCor,
    required this.onRemover,
  });

  @override
  Widget build(BuildContext context) {
    final cor = Color(item.cor);

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
              left: BorderSide(color: cor, width: 4),
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
            padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: cor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Icon(icone, size: 18, color: cor),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nomeCategoria.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                              color: cor,
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
                    if (item.numero.isNotEmpty)
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
                          item.numero,
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

                Text(
                  item.titulo,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                    color: TemaHinario.corTexto,
                  ),
                ),

                if (item.subtitulo.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.subtitulo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: TemaHinario.corTextoSecundario,
                    ),
                  ),
                ],

                const SizedBox(height: 12),

                Row(
                  children: [
                    Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: cor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        nomeCor,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: TemaHinario.corTextoSecundario,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _botaoAcao(
                      icone: Icons.visibility_outlined,
                      texto: 'Ver',
                      onTap: onAbrir,
                      cor: TemaHinario.corPrimaria,
                    ),
                    const SizedBox(width: 6),
                    _botaoAcao(
                      icone: Icons.share_outlined,
                      texto: 'Partilhar',
                      onTap: onPartilhar,
                    ),
                    _menuOpcoes(context, cor),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _menuOpcoes(BuildContext context, Color cor) {
    return PopupMenuButton<String>(
      tooltip: 'Mais opções',
      icon: const Icon(
        Icons.more_vert_rounded,
        color: TemaHinario.corTextoSecundario,
        size: 20,
      ),
      onSelected: (valor) {
        switch (valor) {
          case 'cor':
            onAlterarCor();
            break;
          case 'remover':
            onRemover();
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'cor',
          child: Row(
            children: [
              Icon(
                Icons.palette_outlined,
                size: 20,
                color: TemaHinario.corTextoSecundario,
              ),
              SizedBox(width: 10),
              Text('Alterar cor'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'remover',
          child: Row(
            children: [
              Icon(
                Icons.bookmark_remove_outlined,
                size: 20,
                color: Color(0xFFD32F2F),
              ),
              SizedBox(width: 10),
              Text(
                'Remover marcação',
                style: TextStyle(color: Color(0xFFD32F2F)),
              ),
            ],
          ),
        ),
      ],
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
            horizontal: 8,
            vertical: 6,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icone, size: 14, color: c),
              const SizedBox(width: 4),
              Text(
                texto,
                style: TextStyle(
                  fontSize: 11.5,
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

// =============================================================
// MODAL DE CORES
// =============================================================

class _ModalCores extends StatelessWidget {
  final Color corAtual;
  final Map<String, Color> cores;

  const _ModalCores({
    required this.corAtual,
    required this.cores,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: TemaHinario.corSuperficie,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
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
              'Escolher cor',
              style: TextStyle(
                color: TemaHinario.corTexto,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Escolha uma cor para destacar este conteúdo.',
              style: TextStyle(
                color: TemaHinario.corTextoSecundario,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: cores.entries.map((entry) {
                final selecionada =
                    entry.value.value == corAtual.value;

                return InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => Navigator.pop(context, entry.value),
                  child: Container(
                    width: 82,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    decoration: BoxDecoration(
                      color: TemaHinario.corSuperficieAlta,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: selecionada
                            ? entry.value
                            : TemaHinario.corTextoSecundario
                                .withValues(alpha: 0.20),
                        width: selecionada ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: entry.value,
                            shape: BoxShape.circle,
                          ),
                          child: selecionada
                              ? const Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                  size: 19,
                                )
                              : null,
                        ),
                        const SizedBox(height: 7),
                        Text(
                          entry.key[0].toUpperCase() +
                              entry.key.substring(1),
                          style: const TextStyle(
                            color: TemaHinario.corTexto,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}