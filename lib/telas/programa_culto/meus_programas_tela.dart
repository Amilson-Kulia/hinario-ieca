import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/tema.dart';
import '../../componentes/cabecalho_ieca.dart';
import '../../componentes/navegacao_inferior_ieca.dart';
import '../../modelos/programa_culto.dart';
import '../../modelos/tipo_item_programa.dart';
import '../../servicos/programa_pdf_servico.dart';
import '../../servicos/programas_servico.dart';
import '../biblia/biblia_tela.dart';
import '../home/home_tela.dart';
import '../hinario/idiomas_tela.dart';
import '../sobre/sobre_tela.dart';
import 'criar_programa_tela.dart';
import '../informacoes_ieca/informacoes_ieca_tela.dart';

class MeusProgramasTela extends StatefulWidget {
  const MeusProgramasTela({super.key});

  @override
  State<MeusProgramasTela> createState() =>
      _MeusProgramasTelaState();
}

class _MeusProgramasTelaState
    extends State<MeusProgramasTela> {
  static const int _programasPorPagina = 10;

  final ProgramasServico _servico = ProgramasServico();

  List<ProgramaCulto> _programas = [];
  List<ProgramaCulto> _programasFiltrados = [];

  final TextEditingController _pesquisaController =
      TextEditingController();

  String _termoPesquisa = '';
  String _ordemAtual = 'recente';

  int _paginaAtual = 1;

  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarProgramas();
  }

  @override
  void dispose() {
    _pesquisaController.dispose();
    super.dispose();
  }

  // =========================================================
  // CARREGAR
  // =========================================================

  Future<void> _carregarProgramas() async {
    if (mounted) {
      setState(() => _carregando = true);
    }

    final programas = await _servico.listarProgramas();

    if (!mounted) return;

    setState(() {
      _programas = programas;
      _carregando = false;
    });

    _atualizarLista();
  }

  // =========================================================
  // DATA
  // =========================================================

  DateTime? _converterData(String data) {
    if (data.trim().isEmpty) return null;

    try {
      return DateTime.parse(data);
    } catch (_) {
      final partes = data.split('/');

      if (partes.length == 3) {
        final dia = int.tryParse(partes[0]);
        final mes = int.tryParse(partes[1]);
        final ano = int.tryParse(partes[2]);

        if (dia != null && mes != null && ano != null) {
          return DateTime(ano, mes, dia);
        }
      }

      return null;
    }
  }

  String _formatarData(String data) {
    final dataObj = _converterData(data);

    if (dataObj == null) return data;

    const meses = [
      'jan.', 'fev.', 'mar.', 'abr.', 'mai.', 'jun.',
      'jul.', 'ago.', 'set.', 'out.', 'nov.', 'dez.',
    ];

    return '${dataObj.day.toString().padLeft(2, '0')} '
        '${meses[dataObj.month - 1]} '
        '${dataObj.year}';
  }

  // =========================================================
  // PESQUISA E ORDENAÇÃO
  // =========================================================

  void _atualizarLista() {
    List<ProgramaCulto> resultado = List.from(_programas);

    final termo = _termoPesquisa.trim().toLowerCase();

    if (termo.isNotEmpty) {
      resultado = resultado.where((programa) {
        final titulo = programa.titulo.toLowerCase();
        final dirigente = programa.dirigente.toLowerCase();
        final data = programa.data.toLowerCase();
        final dataFormatada =
            _formatarData(programa.data).toLowerCase();

        return titulo.contains(termo) ||
            dirigente.contains(termo) ||
            data.contains(termo) ||
            dataFormatada.contains(termo);
      }).toList();
    }

    resultado.sort((a, b) {
      switch (_ordemAtual) {
        case 'recente':
          final dataA = _converterData(a.data);
          final dataB = _converterData(b.data);
          if (dataA == null && dataB == null) return 0;
          if (dataA == null) return 1;
          if (dataB == null) return -1;
          return dataB.compareTo(dataA);

        case 'antigo':
          final dataA = _converterData(a.data);
          final dataB = _converterData(b.data);
          if (dataA == null && dataB == null) return 0;
          if (dataA == null) return 1;
          if (dataB == null) return -1;
          return dataA.compareTo(dataB);

        case 'nome':
          return a.titulo
              .toLowerCase()
              .compareTo(b.titulo.toLowerCase());

        case 'responsavel':
          return a.dirigente
              .toLowerCase()
              .compareTo(b.dirigente.toLowerCase());

        default:
          return 0;
      }
    });

    final totalPaginas = resultado.isEmpty
        ? 1
        : (resultado.length / _programasPorPagina).ceil();

    if (_paginaAtual > totalPaginas) _paginaAtual = totalPaginas;
    if (_paginaAtual < 1) _paginaAtual = 1;

    setState(() {
      _programasFiltrados = resultado;
    });
  }

  // =========================================================
  // PAGINAÇÃO
  // =========================================================

  List<ProgramaCulto> get _programasDaPagina {
    if (_programasFiltrados.isEmpty) return [];

    final inicio =
        (_paginaAtual - 1) * _programasPorPagina;

    if (inicio >= _programasFiltrados.length) return [];

    final fim = (inicio + _programasPorPagina)
        .clamp(0, _programasFiltrados.length);

    return _programasFiltrados.sublist(inicio, fim);
  }

  int get _totalPaginas {
    if (_programasFiltrados.isEmpty) return 1;
    return (_programasFiltrados.length / _programasPorPagina)
        .ceil();
  }

  int get _inicioPagina {
    if (_programasFiltrados.isEmpty) return 0;
    return ((_paginaAtual - 1) * _programasPorPagina) + 1;
  }

  int get _fimPagina {
    if (_programasFiltrados.isEmpty) return 0;
    final fim = _paginaAtual * _programasPorPagina;
    return fim > _programasFiltrados.length
        ? _programasFiltrados.length
        : fim;
  }

  void _paginaAnterior() {
    if (_paginaAtual <= 1) return;
    setState(() => _paginaAtual--);
  }

  void _paginaProxima() {
    if (_paginaAtual >= _totalPaginas) return;
    setState(() => _paginaAtual++);
  }

  // =========================================================
  // LIMPAR PESQUISA
  // =========================================================

  void _limparPesquisa() {
    _pesquisaController.clear();

    setState(() {
      _termoPesquisa = '';
      _paginaAtual = 1;
    });

    _atualizarLista();
  }

  // =========================================================
  // NOVO
  // =========================================================

  Future<void> _novoPrograma() async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => const CriarProgramaTela(),
      ),
    );

    await _carregarProgramas();
  }

  // =========================================================
  // VER PDF
  // =========================================================

  Future<void> _verPrograma(ProgramaCulto programa) async {
    try {
      final pdfBytes =
          await ProgramaPdfServico.gerarPdf(programa);

      if (!mounted) return;

      await Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) => _VisualizadorPdfTela(
            pdfBytes: pdfBytes,
            titulo: programa.titulo,
          ),
        ),
      );
    } catch (e, stackTrace) {
      debugPrint(
        '================ PDF ERROR ================',
      );
      debugPrint(e.toString());
      debugPrint(stackTrace.toString());
      debugPrint(
        '===========================================',
      );

      if (!mounted) return;
      _mostrarMensagem('Erro ao gerar PDF:\n$e');
    }
  }

  // =========================================================
  // EDITAR
  // =========================================================

  Future<void> _editarPrograma(ProgramaCulto programa) async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => CriarProgramaTela(
          programaExistente: programa,
        ),
      ),
    );

    await _carregarProgramas();
  }

  // =========================================================
  // CONTAR HINOS
  // =========================================================

  int _contarHinos(ProgramaCulto programa) {
    return programa.itens
        .where((item) => item.tipo == TipoItemPrograma.hino)
        .length;
  }

  // =========================================================
  // DUPLICAR
  // =========================================================

  Future<void> _duplicarPrograma(ProgramaCulto programa) async {
    final novoId =
        '${DateTime.now().millisecondsSinceEpoch}';

    final copia = ProgramaCulto(
      id: novoId,
      titulo: '${programa.titulo} — Cópia',
      data: programa.data,
      hora: programa.hora,
      local: programa.local,
      dirigente: programa.dirigente,
      tipoCulto: programa.tipoCulto,
      itens: programa.itens
          .map(
            (item) => item.copyWith(
              id: '${item.id}_$novoId',
            ),
          )
          .toList(),
    );

    await _servico.guardarPrograma(copia);
    await _carregarProgramas();

    if (!mounted) return;
    _mostrarMensagem('Programa duplicado com sucesso.');
  }

  // =========================================================
  // ELIMINAR
  // =========================================================

  Future<void> _confirmarExclusao(ProgramaCulto programa) async {
    final confirmar = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _ModalExcluirPrograma(
        programa: programa,
      ),
    );

    if (confirmar != true) return;

    await _servico.eliminarPrograma(programa.id);
    await _carregarProgramas();

    if (!mounted) return;
    _mostrarMensagem('Programa eliminado.');
  }

  // =========================================================
  // PARTILHAR
  // =========================================================

  Future<void> _partilharPrograma(ProgramaCulto programa) async {
    try {
      final pdfBytes =
          await ProgramaPdfServico.gerarPdf(programa);

      await SharePlus.instance.share(
        ShareParams(
          title: programa.titulo.isEmpty
              ? 'Programa do Culto'
              : programa.titulo,
          text: 'Programa do culto — Hinário IECA',
          files: [
            XFile.fromData(
              pdfBytes,
              mimeType: 'application/pdf',
              name: _nomeArquivoPdf(programa),
            ),
          ],
        ),
      );
    } catch (e, stackTrace) {
      debugPrint(
        '================ PDF ERROR ================',
      );
      debugPrint(e.toString());
      debugPrint(stackTrace.toString());
      debugPrint(
        '===========================================',
      );

      if (!mounted) return;
      _mostrarMensagem('Erro ao partilhar PDF:\n$e');
    }
  }

  String _nomeArquivoPdf(ProgramaCulto programa) {
    var nome = programa.titulo.trim();

    if (nome.isEmpty) nome = 'programa_do_culto';

    nome = nome
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '')
        .replaceAll(RegExp(r'\s+'), '_');

    return '$nome.pdf';
  }

  // =========================================================
  // IMPRIMIR
  // =========================================================

  Future<void> _imprimirPrograma(ProgramaCulto programa) async {
    try {
      final pdfBytes =
          await ProgramaPdfServico.gerarPdf(programa);

      await Printing.layoutPdf(
        onLayout: (format) async => pdfBytes,
      );
    } catch (e, stackTrace) {
      debugPrint(
        '================ PDF ERROR ================',
      );
      debugPrint(e.toString());
      debugPrint(stackTrace.toString());
      debugPrint(
        '===========================================',
      );

      if (!mounted) return;
      _mostrarMensagem('Erro ao abrir impressão:\n$e');
    }
  }

  // =========================================================
  // NAVEGAÇÃO
  // =========================================================

  void _navegar(int indice) {
    if (indice == 1) return;

    Widget destino;

    switch (indice) {
      case 0:
        destino = const HomeTela();
        break;
        case 1:
        destino = const IdiomasTela();
        break;
      case 2:
        destino = const BibliaTela();
        break;
      case 3:
        destino = const InformacoesIecaTela();
        break;
      case 4:
        destino = const SobreTela();
        break;
      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(builder: (_) => destino),
    );
  }

  // =========================================================
  // MENSAGEM
  // =========================================================

  void _mostrarMensagem(String mensagem) {
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
          content: Row(
            children: [
              const Icon(
                Icons.check_rounded,
                color: Colors.white,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  mensagem,
                  style: const TextStyle(
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
                  : _programasFiltrados.isEmpty
                      ? _buildVazio()
                      : _buildLista(),
            ),
          ],
        ),
      ),

      bottomNavigationBar: NavegacaoInferiorIeca(
        indiceSelecionado: 1,
        onDestinationSelected: _navegar,
      ),
    );
  }

  // =========================================================
  // CABEÇALHO DA PÁGINA
  // =========================================================

  Widget _buildCabecalhoPagina() {
    final total = _programas.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 16, 14),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: TemaHinario.corPrimaria
                  .withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.event_note_rounded,
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
                  'Meus Programas',
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
                      ? 'Sem programas'
                      : total == 1
                          ? '1 programa guardado'
                          : '$total programas guardados',
                  style: const TextStyle(
                    fontSize: 13,
                    color: TemaHinario.corTextoSecundario,
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: TemaHinario.corPrimaria,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: _novoPrograma,
              child: const SizedBox(
                width: 44,
                height: 44,
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // PESQUISA E FILTROS
  // =========================================================

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
                    onChanged: (valor) {
                      setState(() {
                        _termoPesquisa = valor;
                        _paginaAtual = 1;
                      });
                      _atualizarLista();
                    },
                    decoration: const InputDecoration(
                      hintText: 'Pesquisar programa...',
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: TemaHinario.corTextoSecundario,
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
                    onPressed: _limparPesquisa,
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

          // Filtros em chips
          SizedBox(
            height: 34,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _chipFiltro(
                  texto: _nomeOrdemCurto(_ordemAtual),
                  icone: Icons.sort_rounded,
                  onTap: _abrirFiltroOrdem,
                ),
                const SizedBox(width: 8),
                if (temTexto)
                  Material(
                    color: TemaHinario.corPrimaria
                        .withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(999),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(999),
                      onTap: _limparPesquisa,
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
                const SizedBox(width: 8),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    '${_programasFiltrados.length} '
                    '${_programasFiltrados.length == 1 ? 'resultado' : 'resultados'}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: TemaHinario.corTextoSecundario,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chipFiltro({
    required String texto,
    required IconData icone,
    required VoidCallback onTap,
  }) {
    return Material(
      color: TemaHinario.corSuperficieMedia,
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
              Icon(
                icone,
                size: 14,
                color: TemaHinario.corTextoSecundario,
              ),
              const SizedBox(width: 6),
              Text(
                texto,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: TemaHinario.corTextoSecundario,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 14,
                color: TemaHinario.corTextoSecundario,
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
      case 'nome':
        return 'Nome';
      case 'responsavel':
        return 'Responsável';
      default:
        return 'Mais recentes';
    }
  }

  Future<void> _abrirFiltroOrdem() async {
    final resultado = await showModalBottomSheet<String>(
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
                const Text(
                  'Ordenar por',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: TemaHinario.corTexto,
                  ),
                ),
                const SizedBox(height: 10),
                ...{
                  'recente': 'Mais recentes',
                  'antigo': 'Mais antigos',
                  'nome': 'Nome do culto',
                  'responsavel': 'Responsável',
                }.entries.map((entry) {
                  final selecionado =
                      entry.key == _ordemAtual;

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
                    onTap: () =>
                        Navigator.pop(context, entry.key),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );

    if (resultado == null) return;

    setState(() {
      _ordemAtual = resultado;
      _paginaAtual = 1;
    });

    _atualizarLista();
  }

  // =========================================================
  // LISTA
  // =========================================================

  Widget _buildLista() {
    final programasPagina = _programasDaPagina;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
      children: [
        ...programasPagina.map(
          (programa) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _CartaoPrograma(
              programa: programa,
              hinos: _contarHinos(programa),
              dataFormatada: _formatarData(programa.data),
              onVer: () => _verPrograma(programa),
              onEditar: () => _editarPrograma(programa),
              onImprimir: () => _imprimirPrograma(programa),
              onPartilhar: () => _partilharPrograma(programa),
              onDuplicar: () => _duplicarPrograma(programa),
              onEliminar: () => _confirmarExclusao(programa),
            ),
          ),
        ),
        if (_programasFiltrados.length > _programasPorPagina) ...[
          const SizedBox(height: 10),
          _buildPaginacao(),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Mostrando $_inicioPagina–$_fimPagina '
              'de ${_programasFiltrados.length} programas',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                color: TemaHinario.corTextoSecundario,
              ),
            ),
          ),
        ],
      ],
    );
  }

  // =========================================================
  // PAGINAÇÃO
  // =========================================================

  Widget _buildPaginacao() {
    final anteriorAtivo = _paginaAtual > 1;
    final proximaAtiva = _paginaAtual < _totalPaginas;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: anteriorAtivo ? _paginaAnterior : null,
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: TemaHinario.corPrimaria
                .withValues(alpha: 0.08),
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
          onPressed: proximaAtiva ? _paginaProxima : null,
          icon: const Icon(Icons.chevron_right_rounded),
        ),
      ],
    );
  }

  // =========================================================
  // VAZIO
  // =========================================================

  Widget _buildVazio() {
    final temPesquisa = _termoPesquisa.trim().isNotEmpty;

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
                color: TemaHinario.corPrimaria
                    .withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                temPesquisa
                    ? Icons.search_off_rounded
                    : Icons.event_note_outlined,
                size: 36,
                color: TemaHinario.corPrimaria,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              temPesquisa
                  ? 'Nenhum programa encontrado'
                  : 'Ainda não tem programas',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: TemaHinario.corTexto,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              temPesquisa
                  ? 'Experimente pesquisar por outro título ou responsável.'
                  : 'Crie o seu primeiro programa do culto tocando no botão "+" em cima.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13.5,
                height: 1.5,
                color: TemaHinario.corTextoSecundario,
              ),
            ),
            if (temPesquisa) ...[
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _limparPesquisa,
                icon: const Icon(Icons.filter_alt_off_rounded),
                label: const Text('Limpar pesquisa'),
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
}

// =============================================================
// CARTÃO DO PROGRAMA
// =============================================================

class _CartaoPrograma extends StatelessWidget {
  final ProgramaCulto programa;
  final int hinos;
  final String dataFormatada;
  final VoidCallback onVer;
  final VoidCallback onEditar;
  final VoidCallback onImprimir;
  final VoidCallback onPartilhar;
  final VoidCallback onDuplicar;
  final VoidCallback onEliminar;

  const _CartaoPrograma({
    required this.programa,
    required this.hinos,
    required this.dataFormatada,
    required this.onVer,
    required this.onEditar,
    required this.onImprimir,
    required this.onPartilhar,
    required this.onDuplicar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onVer,
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
                // Linha de topo: ícone + título + data
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: TemaHinario.corPrimaria
                            .withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.event_note_rounded,
                        size: 20,
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
                            programa.titulo.isEmpty
                                ? 'Programa sem título'
                                : programa.titulo,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                              height: 1.25,
                              color: TemaHinario.corTexto,
                            ),
                          ),
                          if (programa.dirigente.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                const Icon(
                                  Icons.person_outline_rounded,
                                  size: 13,
                                  color: TemaHinario
                                      .corTextoSecundario,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    programa.dirigente,
                                    maxLines: 1,
                                    overflow:
                                        TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: TemaHinario
                                          .corTextoSecundario,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (programa.data.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: TemaHinario.corSuperficieMedia,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          dataFormatada,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: TemaHinario
                                .corTextoSecundario,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 12),

                // Metadados
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: [
                    if (programa.hora.isNotEmpty)
                      _meta(
                        Icons.schedule_rounded,
                        programa.hora,
                      ),
                    if (programa.local.isNotEmpty)
                      _meta(
                        Icons.location_on_outlined,
                        programa.local,
                      ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF4DF),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '$hinos ${hinos == 1 ? 'hino' : 'hinos'}',
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: TemaHinario.corSecundaria,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Ações
                Row(
                  children: [
                    _botaoAcao(
                      icone: Icons.visibility_outlined,
                      texto: 'Ver',
                      cor: TemaHinario.corPrimaria,
                      onTap: onVer,
                    ),
                    const SizedBox(width: 6),
                    _botaoAcao(
                      icone: Icons.edit_outlined,
                      texto: 'Editar',
                      onTap: onEditar,
                    ),
                    const SizedBox(width: 6),
                    _botaoAcao(
                      icone: Icons.ios_share_rounded,
                      texto: 'Partilhar',
                      onTap: onPartilhar,
                    ),
                    const Spacer(),
                    PopupMenuButton<String>(
                      tooltip: 'Mais opções',
                      icon: const Icon(
                        Icons.more_horiz_rounded,
                        color: TemaHinario.corTextoSecundario,
                      ),
                      onSelected: (valor) {
                        switch (valor) {
                          case 'imprimir':
                            onImprimir();
                            break;
                          case 'duplicar':
                            onDuplicar();
                            break;
                          case 'eliminar':
                            onEliminar();
                            break;
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: 'imprimir',
                          child: Row(
                            children: [
                              Icon(
                                Icons.print_outlined,
                                size: 20,
                              ),
                              SizedBox(width: 10),
                              Text('Imprimir'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'duplicar',
                          child: Row(
                            children: [
                              Icon(
                                Icons.content_copy_outlined,
                                size: 20,
                              ),
                              SizedBox(width: 10),
                              Text('Duplicar'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'eliminar',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline_rounded,
                                size: 20,
                                color: Color(0xFFC62828),
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Eliminar',
                                style: TextStyle(
                                  color: Color(0xFFC62828),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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

  Widget _meta(IconData icon, String texto) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 13,
          color: TemaHinario.corTextoSecundario,
        ),
        const SizedBox(width: 4),
        Text(
          texto,
          style: const TextStyle(
            fontSize: 11.5,
            color: TemaHinario.corTextoSecundario,
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

// =============================================================
// MODAL DE EXCLUSÃO
// =============================================================

class _ModalExcluirPrograma extends StatelessWidget {
  final ProgramaCulto programa;

  const _ModalExcluirPrograma({
    required this.programa,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.fromLTRB(22, 28, 22, 22),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(28),
            bottom: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x2E000000),
              blurRadius: 50,
              offset: Offset(0, 15),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.delete_rounded,
                size: 30,
                color: Color(0xFFC62828),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Eliminar programa?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                height: 1.3,
                fontWeight: FontWeight.w700,
                color: Color(0xFF121C2A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Esta ação não poderá ser desfeita.\n'
              'O programa "${programa.titulo}" '
              'será removido da lista.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                height: 1.54,
                color: Color(0xFF5B4040),
              ),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: TextButton(
                      onPressed: () =>
                          Navigator.pop(context, false),
                      style: TextButton.styleFrom(
                        backgroundColor:
                            const Color(0xFFE6EEFF),
                        foregroundColor:
                            const Color(0xFF5B4040),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(9999),
                        ),
                      ),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: TextButton(
                      onPressed: () =>
                          Navigator.pop(context, true),
                      style: TextButton.styleFrom(
                        backgroundColor:
                            const Color(0xFFC62828),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(9999),
                        ),
                      ),
                      child: const Text(
                        'Eliminar',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================
// VISUALIZADOR PDF
// =============================================================

class _VisualizadorPdfTela extends StatelessWidget {
  final Uint8List pdfBytes;
  final String titulo;

  const _VisualizadorPdfTela({
    required this.pdfBytes,
    required this.titulo,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TemaHinario.corSuperficie,
      appBar: AppBar(
        backgroundColor: TemaHinario.corSuperficie,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: TemaHinario.corTexto,
          ),
        ),
        title: Text(
          titulo.isEmpty ? 'Programa do Culto' : titulo,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: TemaHinario.corTexto,
          ),
        ),
      ),
      body: PdfPreview(
        build: (format) async => pdfBytes,
        allowPrinting: true,
        allowSharing: true,
        canChangePageFormat: false,
        canChangeOrientation: false,
        canDebug: false,
        pdfFileName: titulo.isEmpty
            ? 'programa_do_culto.pdf'
            : '${titulo.replaceAll(' ', '_')}.pdf',
        actions: const [],
      ),
    );
  }
}