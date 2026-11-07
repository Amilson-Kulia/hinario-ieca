import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../../app/tema.dart';
import '../../componentes/cabecalho_ieca.dart';
import '../../componentes/navegacao_inferior_ieca.dart';
import '../../modelos/anotacao.dart';
import 'biblia_tela.dart';
import '../home/home_tela.dart';
import '../hinario/idiomas_tela.dart';
import '../sobre/sobre_tela.dart';
import '../informacoes_ieca/informacoes_ieca_tela.dart';

class AnotacoesTela extends StatefulWidget {
  const AnotacoesTela({super.key});

  @override
  State<AnotacoesTela> createState() => _AnotacoesTelaState();
}

class _AnotacoesTelaState extends State<AnotacoesTela> {
  static const String _keyAnotacoes = 'anotacoes_biblia_storage';

  List<Anotacao> _todasAnotacoes = [];
  List<Anotacao> _anotacoesFiltradas = [];
  bool _carregando = true;

  final TextEditingController _pesquisaController =
      TextEditingController();

  String? _livroFiltroSelecionado;
  List<String> _livrosDisponiveis = [];

  // Só uma nota expandida de cada vez
  String? _keyExpandida;

  @override
  void initState() {
    super.initState();

    _carregarAnotacoes();
    _pesquisaController.addListener(_aplicarFiltros);
  }

  @override
  void dispose() {
    _pesquisaController.dispose();
    super.dispose();
  }

  // ============================================================
  // CARREGAMENTO
  // ============================================================

  Future<void> _carregarAnotacoes() async {
    setState(() => _carregando = true);

    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_keyAnotacoes);

    if (jsonString != null && jsonString.isNotEmpty) {
      final List<dynamic> listaJson = jsonDecode(jsonString);

      final carregadas =
          listaJson.map((e) => Anotacao.fromMap(e)).toList();

      carregadas.sort(
        (a, b) => b.dataCriacao.compareTo(a.dataCriacao),
      );

      if (!mounted) return;

      setState(() {
        _todasAnotacoes = carregadas;
        _extrairLivrosParaFiltro();
        _aplicarFiltros();
        _carregando = false;
      });
    } else {
      if (!mounted) return;

      setState(() {
        _todasAnotacoes = [];
        _anotacoesFiltradas = [];
        _livrosDisponiveis = [];
        _carregando = false;
      });
    }
  }

  void _extrairLivrosParaFiltro() {
    final livrosSet = _todasAnotacoes
        .map((a) => a.livroNome)
        .where((nome) => nome.isNotEmpty)
        .toSet();

    _livrosDisponiveis = livrosSet.toList()..sort();
  }

  void _aplicarFiltros() {
    final query = _pesquisaController.text.toLowerCase().trim();

    final filtradas = _todasAnotacoes.where((anotacao) {
      final bateuTexto = query.isEmpty ||
          anotacao.textoNota.toLowerCase().contains(query) ||
          anotacao.textoVersiculo.toLowerCase().contains(query) ||
          anotacao.livroNome.toLowerCase().contains(query);

      final bateuLivro = _livroFiltroSelecionado == null ||
          anotacao.livroNome == _livroFiltroSelecionado;

      return bateuTexto && bateuLivro;
    }).toList();

    if (!mounted) return;

    setState(() {
      _anotacoesFiltradas = filtradas;
    });
  }

  Future<void> _salvarListaStorage(List<Anotacao> lista) async {
    final prefs = await SharedPreferences.getInstance();

    final jsonString = jsonEncode(
      lista.map((e) => e.toMap()).toList(),
    );

    await prefs.setString(_keyAnotacoes, jsonString);
  }

  // ============================================================
  // ID ÚNICO DA ANOTAÇÃO (para expandir/colapsar)
  // ============================================================

  String _keyAnotacao(Anotacao a) =>
      '${a.livroId}_${a.capitulo}_${a.versiculoReferencia}_'
      '${a.dataCriacao.millisecondsSinceEpoch}';

  // ============================================================
  // EXPANDIR / COLAPSAR
  // ============================================================

  void _toggleExpandir(Anotacao a) {
    final key = _keyAnotacao(a);
    setState(() {
      _keyExpandida = _keyExpandida == key ? null : key;
    });
  }

  // ============================================================
  // ELIMINAR
  // ============================================================

  Future<void> _eliminarAnotacao(Anotacao anotacao) async {
    final confirma = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: const Text('Eliminar Anotação'),
        content: const Text(
          'Tem certeza que deseja eliminar esta anotação? '
          'Esta ação não pode ser desfeita.',
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
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirma == true) {
      _todasAnotacoes.removeWhere(
        (a) =>
            a.livroId == anotacao.livroId &&
            a.capitulo == anotacao.capitulo &&
            a.versiculoReferencia == anotacao.versiculoReferencia &&
            a.dataCriacao == anotacao.dataCriacao,
      );

      await _salvarListaStorage(_todasAnotacoes);
      await _carregarAnotacoes();

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
                Icon(Icons.delete_outline_rounded,
                    color: Colors.white),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Anotação eliminada.',
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
  }

  // ============================================================
  // MODAL DE ANOTAÇÃO (Nova / Editar)
  // ============================================================

  void _abrirModalAnotacao({Anotacao? anotacaoParaEditar}) {
    final isEdicao = anotacaoParaEditar != null;

    final controllerLivro = TextEditingController(
      text: anotacaoParaEditar?.livroNome ?? '',
    );

    final controllerCapitulo = TextEditingController(
      text: anotacaoParaEditar?.capitulo.toString() ?? '',
    );

    final controllerRef = TextEditingController(
      text: anotacaoParaEditar?.versiculoReferencia ?? '',
    );

    final controllerVersiculo = TextEditingController(
      text: anotacaoParaEditar?.textoVersiculo ?? '',
    );

    final controllerNota = TextEditingController(
      text: anotacaoParaEditar?.textoNota ?? '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: TemaHinario.corSuperficie,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cabeçalho do modal
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: TemaHinario.corPrimaria
                            .withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Icon(
                        Icons.edit_note_rounded,
                        color: TemaHinario.corPrimaria,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEdicao
                                ? 'Editar Anotação'
                                : 'Nova Anotação',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: TemaHinario.corTexto,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isEdicao
                                ? 'Atualize a sua nota'
                                : 'Registe os seus pensamentos',
                            style: const TextStyle(
                              fontSize: 12,
                              color:
                                  TemaHinario.corTextoSecundario,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        color: TemaHinario.corTextoSecundario,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                if (!isEdicao) ...[
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: controllerLivro,
                          decoration: const InputDecoration(
                            labelText: 'Livro',
                            hintText: 'Ex: João',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 1,
                        child: TextField(
                          controller: controllerCapitulo,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Cap.',
                            hintText: '3',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 1,
                        child: TextField(
                          controller: controllerRef,
                          decoration: const InputDecoration(
                            labelText: 'Vers.',
                            hintText: '16',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  TextField(
                    controller: controllerVersiculo,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Texto do Versículo (Opcional)',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),

                  const SizedBox(height: 12),
                ],

                TextField(
                  controller: controllerNota,
                  maxLines: 5,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Sua Anotação',
                    hintText:
                        'Escreva seus pensamentos ou reflexões...',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 18),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TemaHinario.corPrimaria,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.check_rounded, size: 20),
                    label: Text(
                      isEdicao ? 'Atualizar' : 'Guardar',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    onPressed: () async {
                      final textoNota =
                          controllerNota.text.trim();

                      if (textoNota.isEmpty) return;

                      if (isEdicao) {
                        final index =
                            _todasAnotacoes.indexWhere(
                          (a) =>
                              a.livroId ==
                                  anotacaoParaEditar.livroId &&
                              a.capitulo ==
                                  anotacaoParaEditar.capitulo &&
                              a.versiculoReferencia ==
                                  anotacaoParaEditar
                                      .versiculoReferencia &&
                              a.dataCriacao ==
                                  anotacaoParaEditar.dataCriacao,
                        );

                        if (index != -1) {
                          _todasAnotacoes[index] = Anotacao(
                            livroId: anotacaoParaEditar.livroId,
                            livroNome: anotacaoParaEditar.livroNome,
                            capitulo: anotacaoParaEditar.capitulo,
                            versiculoReferencia:
                                anotacaoParaEditar
                                    .versiculoReferencia,
                            textoVersiculo:
                                anotacaoParaEditar.textoVersiculo,
                            textoNota: textoNota,
                            dataCriacao:
                                anotacaoParaEditar.dataCriacao,
                          );
                        }
                      } else {
                        final livroNome =
                            controllerLivro.text.trim().isEmpty
                                ? 'Geral'
                                : controllerLivro.text.trim();

                        final cap =
                            int.tryParse(
                                  controllerCapitulo.text.trim(),
                                ) ??
                                1;

                        final ref =
                            controllerRef.text.trim().isEmpty
                                ? '1'
                                : controllerRef.text.trim();

                        final novaAnotacao = Anotacao(
                          livroId: livroNome
                              .toLowerCase()
                              .replaceAll(' ', '_'),
                          livroNome: livroNome,
                          capitulo: cap,
                          versiculoReferencia: ref,
                          textoVersiculo:
                              controllerVersiculo.text.trim(),
                          textoNota: textoNota,
                          dataCriacao: DateTime.now(),
                        );

                        _todasAnotacoes.add(novaAnotacao);
                      }

                      await _salvarListaStorage(_todasAnotacoes);
                      await _carregarAnotacoes();

                      if (!mounted) return;

                      Navigator.pop(context);

                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                            behavior: SnackBarBehavior.floating,
                            margin: const EdgeInsets.fromLTRB(
                                16, 0, 16, 16),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(14),
                            ),
                            backgroundColor:
                                TemaHinario.corPrimaria,
                            content: Row(
                              children: [
                                Icon(
                                  isEdicao
                                      ? Icons.check_rounded
                                      : Icons.bookmark_added_rounded,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    isEdicao
                                        ? 'Nota atualizada.'
                                        : 'Nota guardada.',
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
  // PARTILHAR / COPIAR
  // ============================================================

  void _partilharAnotacao(Anotacao anotacao) {
    final buffer = StringBuffer();
    buffer.writeln(
      '${anotacao.livroNome} '
      '${anotacao.capitulo}:${anotacao.versiculoReferencia}',
    );

    if (anotacao.textoVersiculo.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('"${anotacao.textoVersiculo}"');
    }

    buffer.writeln();
    buffer.writeln(anotacao.textoNota);
    buffer.writeln();
    buffer.writeln('APP IECA - Bíblia');

    SharePlus.instance.share(
      ShareParams(
        text: buffer.toString().trim(),
        subject:
            '${anotacao.livroNome} ${anotacao.capitulo}:${anotacao.versiculoReferencia}',
      ),
    );
  }

  void _copiarAnotacao(Anotacao anotacao) {
    final buffer = StringBuffer();
    buffer.write(
      '${anotacao.livroNome} '
      '${anotacao.capitulo}:${anotacao.versiculoReferencia}',
    );

    if (anotacao.textoVersiculo.isNotEmpty) {
      buffer.write('\n"${anotacao.textoVersiculo}"');
    }

    buffer.write('\n\n${anotacao.textoNota}');

    Clipboard.setData(ClipboardData(text: buffer.toString()));

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
                  'Anotação copiada.',
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
  // NAVEGAÇÃO INFERIOR
  // ============================================================

  void _selecionarNavegacao(int indice) {
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

  String _dataRelativa(DateTime data) {
    final agora = DateTime.now();
    final diff = agora.difference(data);

    if (diff.inMinutes < 1) return 'Agora mesmo';
    if (diff.inMinutes < 60) {
      return 'Há ${diff.inMinutes} min';
    }
    if (diff.inHours < 24) {
      return 'Há ${diff.inHours} h';
    }
    if (diff.inDays < 7) {
      return 'Há ${diff.inDays} ${diff.inDays == 1 ? 'dia' : 'dias'}';
    }

    final dateFormat = DateFormat('dd/MM/yyyy');
    return dateFormat.format(data);
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TemaHinario.corSuperficie,

      // CABEÇALHO PADRÃO DO IECA
      appBar: const CabecalhoIeca(),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: TemaHinario.corPrimaria,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        onPressed: () => _abrirModalAnotacao(),
        icon: const Icon(Icons.add_comment_rounded),
        label: const Text(
          'Nova Nota',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),

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
            // PESQUISA E FILTROS
            // =====================================================

            _buildPesquisaEFiltros(),

            // =====================================================
            // LISTA
            // =====================================================

            Expanded(
              child: _carregando
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: TemaHinario.corPrimaria,
                      ),
                    )
                  : _anotacoesFiltradas.isEmpty
                      ? _buildVazio()
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(
                            16,
                            8,
                            16,
                            100,
                          ),
                          itemCount: _anotacoesFiltradas.length,
                          itemBuilder: (context, index) {
                            final item =
                                _anotacoesFiltradas[index];
                            final key = _keyAnotacao(item);
                            final expandido =
                                _keyExpandida == key;

                            return Padding(
                              padding: const EdgeInsets.only(
                                bottom: 10,
                              ),
                              child: _CartaoAnotacao(
                                anotacao: item,
                                expandido: expandido,
                                dataRelativa:
                                    _dataRelativa(item.dataCriacao),
                                onToggle: () =>
                                    _toggleExpandir(item),
                                onCopiar: () =>
                                    _copiarAnotacao(item),
                                onPartilhar: () =>
                                    _partilharAnotacao(item),
                                onEditar: () => _abrirModalAnotacao(
                                  anotacaoParaEditar: item,
                                ),
                                onEliminar: () =>
                                    _eliminarAnotacao(item),
                              ),
                            );
                          },
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
    final total = _todasAnotacoes.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
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
              Icons.sticky_note_2_rounded,
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
                  'Anotações',
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
                      ? 'Sem anotações'
                      : total == 1
                          ? '1 anotação guardada'
                          : '$total anotações guardadas',
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
  // PESQUISA E FILTROS
  // ============================================================

  Widget _buildPesquisaEFiltros() {
    final temTexto = _pesquisaController.text.isNotEmpty;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        children: [
          // Campo de pesquisa
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
                      hintText: 'Pesquisar anotações...',
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
                    onPressed: () {
                      _pesquisaController.clear();
                      _aplicarFiltros();
                    },
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

          // Filtros por livro
          if (_livrosDisponiveis.isNotEmpty) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 34,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _chipLivro(
                    texto: 'Todos',
                    selecionado: _livroFiltroSelecionado == null,
                    onTap: () {
                      setState(() {
                        _livroFiltroSelecionado = null;
                      });
                      _aplicarFiltros();
                    },
                  ),
                  ..._livrosDisponiveis.map((livro) {
                    return _chipLivro(
                      texto: livro,
                      selecionado:
                          _livroFiltroSelecionado == livro,
                      onTap: () {
                        setState(() {
                          _livroFiltroSelecionado =
                              _livroFiltroSelecionado == livro
                                  ? null
                                  : livro;
                        });
                        _aplicarFiltros();
                      },
                    );
                  }),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _chipLivro({
    required String texto,
    required bool selecionado,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: selecionado
            ? TemaHinario.corPrimaria
            : TemaHinario.corSuperficieMedia,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onTap,
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
                  texto,
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
  // VAZIO
  // ============================================================

  Widget _buildVazio() {
    final temItens = _todasAnotacoes.isNotEmpty;
    final filtroAtivo = _livroFiltroSelecionado != null ||
        _pesquisaController.text.isNotEmpty;

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
                filtroAtivo
                    ? Icons.search_off_rounded
                    : Icons.sticky_note_2_outlined,
                size: 36,
                color: TemaHinario.corPrimaria,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              filtroAtivo && temItens
                  ? 'Sem resultados'
                  : 'Nenhuma anotação',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: TemaHinario.corTexto,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              filtroAtivo && temItens
                  ? 'Experimente outro filtro ou limpe a pesquisa.'
                  : 'Crie a sua primeira anotação tocando no botão '
                      '"Nova Nota" em baixo.',
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
// CARTÃO DE ANOTAÇÃO
// =============================================================

class _CartaoAnotacao extends StatelessWidget {
  final Anotacao anotacao;
  final bool expandido;
  final String dataRelativa;
  final VoidCallback onToggle;
  final VoidCallback onCopiar;
  final VoidCallback onPartilhar;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;

  const _CartaoAnotacao({
    required this.anotacao,
    required this.expandido,
    required this.dataRelativa,
    required this.onToggle,
    required this.onCopiar,
    required this.onPartilhar,
    required this.onEditar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onToggle,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: TemaHinario.corSuperficieAlta,
            borderRadius: BorderRadius.circular(16),
            border: Border(
              left: BorderSide(
                color: TemaHinario.corPrimaria,
                width: 5,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // =================================================
                // CABEÇALHO (sempre visível)
                // =================================================

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
                        Icons.edit_note_rounded,
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
                            '${anotacao.livroNome} '
                            '${anotacao.capitulo}:'
                            '${anotacao.versiculoReferencia}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: TemaHinario.corTexto,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 12,
                                color: TemaHinario
                                    .corTextoSecundario
                                    .withValues(alpha: 0.7),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                dataRelativa,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: TemaHinario
                                      .corTextoSecundario
                                      .withValues(alpha: 0.85),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: expandido ? 0.5 : 0,
                      duration:
                          const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: TemaHinario.corTextoSecundario,
                        size: 22,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Pré-visualização da nota (só quando fechado)
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 200),
                  crossFadeState: expandido
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  firstChild: Text(
                    anotacao.textoNota,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13.5,
                      height: 1.5,
                      color: TemaHinario.corTextoSecundario,
                    ),
                  ),
                  secondChild: const SizedBox(
                    width: double.infinity,
                    height: 0,
                  ),
                ),

                // =================================================
                // CONTEÚDO EXPANDIDO
                // =================================================

                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 200),
                  crossFadeState: expandido
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  firstChild: const SizedBox(
                    width: double.infinity,
                    height: 0,
                  ),
                  secondChild: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Texto do versículo (se existir)
                        if (anotacao.textoVersiculo.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.fromLTRB(
                              14, 12, 14, 12,
                            ),
                            decoration: BoxDecoration(
                              color: TemaHinario.corPrimaria
                                  .withValues(alpha: 0.06),
                              borderRadius:
                                  BorderRadius.circular(12),
                              border: Border(
                                left: BorderSide(
                                  color: TemaHinario.corPrimaria,
                                  width: 3,
                                ),
                              ),
                            ),
                            child: Text(
                              '"${anotacao.textoVersiculo}"',
                              style: TextStyle(
                                fontSize: 13.5,
                                height: 1.55,
                                fontStyle: FontStyle.italic,
                                color: TemaHinario.corTexto
                                    .withValues(alpha: 0.85),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],

                        // Anotação completa
                        Row(
                          children: [
                            Icon(
                              Icons.sticky_note_2_rounded,
                              size: 14,
                              color: TemaHinario.corPrimaria,
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'ANOTAÇÃO',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                                color: TemaHinario.corPrimaria,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SelectableText(
                          anotacao.textoNota,
                          style: const TextStyle(
                            fontSize: 14.5,
                            height: 1.55,
                            color: TemaHinario.corTexto,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Ações
                        Row(
                          children: [
                            _botaoAcao(
                              icone: Icons.copy_rounded,
                              texto: 'Copiar',
                              onTap: onCopiar,
                            ),
                            const SizedBox(width: 8),
                            _botaoAcao(
                              icone: Icons.share_rounded,
                              texto: 'Partilhar',
                              onTap: onPartilhar,
                            ),
                            const Spacer(),
                            _botaoAcao(
                              icone: Icons.edit_rounded,
                              texto: 'Editar',
                              onTap: onEditar,
                              cor: TemaHinario.corPrimaria,
                            ),
                            const SizedBox(width: 8),
                            _botaoAcao(
                              icone: Icons.delete_outline_rounded,
                              texto: 'Eliminar',
                              onTap: onEliminar,
                              cor: const Color(0xFFD32F2F),
                            ),
                          ],
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
            vertical: 8,
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