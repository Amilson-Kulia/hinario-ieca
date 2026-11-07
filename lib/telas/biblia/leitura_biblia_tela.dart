import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/tema.dart';
import '../../componentes/cabecalho_ieca.dart';
import '../../componentes/navegacao_inferior_ieca.dart';
import '../../modelos/anotacao.dart';
import '../../modelos/biblia_capitulo.dart';
import '../../modelos/biblia_livro.dart';
import '../../modelos/versiculo.dart';
import '../../servicos/constancia_servico.dart';
import '../home/home_tela.dart';
import '../biblia/biblia_tela.dart';
import '../hinario/idiomas_tela.dart';
import '../sobre/sobre_tela.dart';

// =============================================================
// MODELO AUXILIAR DE DESTAQUE
// =============================================================

class DestaqueInfo {
  final Color cor;
  final String texto;
  final String livroNome;
  final int capitulo;
  final String referencia;
  final String grupoId;

  DestaqueInfo({
    required this.cor,
    required this.texto,
    required this.livroNome,
    required this.capitulo,
    required this.referencia,
    required this.grupoId,
  });

  Map<String, dynamic> toMap() => {
        'cor': cor.value,
        'texto': texto,
        'livroNome': livroNome,
        'capitulo': capitulo,
        'referencia': referencia,
        'grupoId': grupoId,
      };

  static DestaqueInfo fromMap(Map<String, dynamic> map) {
    return DestaqueInfo(
      cor: Color(map['cor'] as int),
      texto: (map['texto'] as String?) ?? '',
      livroNome: (map['livroNome'] as String?) ?? '',
      capitulo: (map['capitulo'] as int?) ?? 0,
      referencia: (map['referencia'] as String?) ?? '',
      grupoId: (map['grupoId'] as String?) ??
          DateTime.now().microsecondsSinceEpoch.toString(),
    );
  }
}

class LeituraBibliaTela extends StatefulWidget {
  final BibliaLivro livro;
  final int capituloNumero;

  const LeituraBibliaTela({
    Key? key,
    required this.livro,
    required this.capituloNumero,
  }) : super(key: key);

  @override
  State<LeituraBibliaTela> createState() => _LeituraBibliaTelaState();
}

class _LeituraBibliaTelaState extends State<LeituraBibliaTela> {
  late BibliaCapitulo _capituloAtual;

  double _tamanhoFonte = 16.0;
  bool _modoEscuro = false;

  bool _modoSelecao = false;

  final Set<String> _selecionados = {};

  final Map<String, DestaqueInfo> _versiculosDestacados = {};

  final Map<String, Anotacao> _notasCapitulo = {};

  static const String _keyAnotacoes = 'anotacoes_biblia_storage';
  static const String _keyDestaques = 'destaques_biblia_storage';

  static const String _keyLivroRecenteId = 'biblia_livro_recente_id';
  static const String _keyLivroRecenteNome = 'biblia_livro_recente_nome';
  static const String _keyCapituloRecente = 'biblia_capitulo_recente';

  static const Color _corSelecaoAzul = Color(0xFF1976D2);

  @override
  void initState() {
    super.initState();

    _carregarDestaquesDoStorage();
    _mudarCapitulo(widget.capituloNumero);
    _registrarConstanciaBiblia();
  }

  Future<void> _registrarConstanciaBiblia() async {
    try {
      await ConstanciaServico.instancia.registrarUsoBiblia();

      debugPrint('Constância da Bíblia registada.');
    } catch (e, stackTrace) {
      debugPrint('Erro ao registar constância da Bíblia: $e');
      debugPrint('$stackTrace');
    }
  }

  Future<void> _salvarLeituraRecente() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_keyLivroRecenteId, widget.livro.id);
    await prefs.setString(_keyLivroRecenteNome, widget.livro.nome);
    await prefs.setInt(_keyCapituloRecente, _capituloAtual.numero);
  }

  // =============================================================
  // STORAGE — DESTAQUES
  // =============================================================

  Future<void> _carregarDestaquesDoStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_keyDestaques);

    if (jsonString == null || jsonString.isEmpty) return;

    final Map<String, dynamic> mapaJson = jsonDecode(jsonString);

    if (!mounted) return;

    setState(() {
      _versiculosDestacados.clear();

      mapaJson.forEach((key, value) {
        if (value is Map) {
          _versiculosDestacados[key] =
              DestaqueInfo.fromMap(Map<String, dynamic>.from(value));
        } else if (value is int) {
          _versiculosDestacados[key] = DestaqueInfo(
            cor: Color(value),
            texto: '',
            livroNome: '',
            capitulo: 0,
            referencia: '',
            grupoId: 'antigo_$key',
          );
        }
      });
    });
  }

  Future<void> _salvarDestaquesNoStorage() async {
    final prefs = await SharedPreferences.getInstance();

    final Map<String, dynamic> mapaParaSalvar = _versiculosDestacados.map(
      (key, info) => MapEntry(key, info.toMap()),
    );

    await prefs.setString(_keyDestaques, jsonEncode(mapaParaSalvar));
  }

  // =============================================================
  // STORAGE — NOTAS
  // =============================================================

  Future<void> _carregarNotasDoStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_keyAnotacoes);

    if (jsonString != null && jsonString.isNotEmpty) {
      final List<dynamic> listaJson = jsonDecode(jsonString);

      final todasNotas =
          listaJson.map((e) => Anotacao.fromMap(e)).toList();

      final notasDoCapitulo = todasNotas.where(
        (a) =>
            a.livroId == widget.livro.id &&
            a.capitulo == _capituloAtual.numero,
      );

      if (!mounted) return;

      setState(() {
        _notasCapitulo.clear();

        for (final nota in notasDoCapitulo) {
          _notasCapitulo[nota.versiculoReferencia] = nota;
        }
      });
    } else {
      if (!mounted) return;

      setState(() {
        _notasCapitulo.clear();
      });
    }
  }

  Future<void> _salvarOuRemoverNotaStorage({
    required Versiculo versiculo,
    String? novoTexto,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final String? jsonString = prefs.getString(_keyAnotacoes);

    List<Anotacao> listaNotas = [];

    if (jsonString != null && jsonString.isNotEmpty) {
      final List<dynamic> listaJson = jsonDecode(jsonString);

      listaNotas = listaJson.map((e) => Anotacao.fromMap(e)).toList();
    }

    listaNotas.removeWhere(
      (a) =>
          a.livroId == widget.livro.id &&
          a.capitulo == _capituloAtual.numero &&
          a.versiculoReferencia == versiculo.referencia,
    );

    if (novoTexto != null && novoTexto.trim().isNotEmpty) {
      final novaNota = Anotacao(
        livroId: widget.livro.id,
        livroNome: widget.livro.nome,
        capitulo: _capituloAtual.numero,
        versiculoReferencia: versiculo.referencia,
        textoVersiculo: versiculo.texto,
        textoNota: novoTexto.trim(),
        dataCriacao: DateTime.now(),
      );

      listaNotas.add(novaNota);
    }

    final novaListaJson = jsonEncode(
      listaNotas.map((e) => e.toMap()).toList(),
    );

    await prefs.setString(_keyAnotacoes, novaListaJson);

    await _carregarNotasDoStorage();
  }

  // =============================================================
  // CAPÍTULOS
  // =============================================================

  void _mudarCapitulo(int numeroCapitulo) {
    if (widget.livro.capitulos.isEmpty) return;

    setState(() {
      _capituloAtual = widget.livro.capitulos.firstWhere(
        (c) => c.numero == numeroCapitulo,
        orElse: () => widget.livro.capitulos.first,
      );
      _modoSelecao = false;
      _selecionados.clear();
    });

    _carregarNotasDoStorage();
    _salvarLeituraRecente();
  }

  void _capituloAnterior() {
    if (_capituloAtual.numero > 1) {
      _mudarCapitulo(_capituloAtual.numero - 1);
    }
  }

  void _proximoCapitulo() {
    if (_capituloAtual.numero < widget.livro.capitulos.length) {
      _mudarCapitulo(_capituloAtual.numero + 1);
    }
  }

  // =============================================================
  // MODO DE SELEÇÃO — LÓGICA
  // =============================================================

  void _entrarModoSelecao(String referencia) {
    setState(() {
      _modoSelecao = true;
      _selecionados
        ..clear()
        ..add(referencia);
    });
  }

  void _sairModoSelecao() {
    setState(() {
      _modoSelecao = false;
      _selecionados.clear();
    });
  }

  void _toggleSelecao(String referencia) {
    setState(() {
      if (_selecionados.contains(referencia)) {
        _selecionados.remove(referencia);
        if (_selecionados.isEmpty) {
          _modoSelecao = false;
        }
      } else {
        _selecionados.add(referencia);
      }
    });
  }

  void _selecionarTudo() {
    setState(() {
      _selecionados
        ..clear()
        ..addAll(
          _capituloAtual.versiculos.map((v) => v.referencia),
        );
      _modoSelecao = true;
    });
  }

  String get _keyVersiculoAtual =>
      '${widget.livro.id}_${_capituloAtual.numero}_';

  Future<void> _destacarSelecionados(Color cor) async {
    final grupoId = DateTime.now().microsecondsSinceEpoch.toString();

    setState(() {
      for (final ref in _selecionados) {
        final versiculo = _capituloAtual.versiculos.firstWhere(
          (v) => v.referencia == ref,
          orElse: () => Versiculo(referencia: ref, texto: ''),
        );

        _versiculosDestacados['$_keyVersiculoAtual$ref'] = DestaqueInfo(
          cor: cor,
          texto: versiculo.texto,
          livroNome: widget.livro.nome,
          capitulo: _capituloAtual.numero,
          referencia: ref,
          grupoId: grupoId,
        );
      }
    });

    await _salvarDestaquesNoStorage();

    if (!mounted) return;

    final quantidade = _selecionados.length;
    _sairModoSelecao();

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: TemaHinario.corPrimaria,
          content: Text(
            '$quantidade ${quantidade == 1 ? 'versículo destacado' : 'versículos destacados'}',
          ),
        ),
      );
  }

  Future<void> _removerDestaqueSelecionados() async {
    setState(() {
      for (final ref in _selecionados) {
        _versiculosDestacados.remove('$_keyVersiculoAtual$ref');
      }
    });

    await _salvarDestaquesNoStorage();

    if (!mounted) return;

    final quantidade = _selecionados.length;
    _sairModoSelecao();

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: TemaHinario.corPrimaria,
          content: Text(
            'Destaque removido de $quantidade ${quantidade == 1 ? 'versículo' : 'versículos'}',
          ),
        ),
      );
  }

  // =============================================================
  // REFERÊNCIA AGRUPADA
  // =============================================================

  String _construirReferenciaAgrupada() {
    final numeros = _selecionados
        .map((r) => int.tryParse(r))
        .whereType<int>()
        .toList()
      ..sort();

    if (numeros.isEmpty) return '';

    final partes = <String>[];
    int inicio = numeros.first;
    int anterior = numeros.first;

    for (int i = 1; i < numeros.length; i++) {
      final atual = numeros[i];

      if (atual == anterior + 1) {
        anterior = atual;
      } else {
        partes.add(inicio == anterior ? '$inicio' : '$inicio-$anterior');
        inicio = atual;
        anterior = atual;
      }
    }

    partes.add(inicio == anterior ? '$inicio' : '$inicio-$anterior');

    return partes.join(',');
  }

  List<Versiculo> _versiculosSelecionadosOrdenados() {
    final lista = _capituloAtual.versiculos
        .where((v) => _selecionados.contains(v.referencia))
        .toList()
      ..sort((a, b) {
        final aNum = int.tryParse(a.referencia) ?? 0;
        final bNum = int.tryParse(b.referencia) ?? 0;
        return aNum.compareTo(bNum);
      });
    return lista;
  }

  Future<void> _copiarSelecionados() async {
    final versiculos = _versiculosSelecionadosOrdenados();

    if (versiculos.isEmpty) return;

    final referencia = _construirReferenciaAgrupada();

    final buffer = StringBuffer();
    buffer.writeln(
      '${widget.livro.nome} ${_capituloAtual.numero}:$referencia',
    );

    for (final v in versiculos) {
      buffer.writeln('${v.referencia} ${v.texto}');
    }

    await Clipboard.setData(ClipboardData(text: buffer.toString().trim()));

    if (!mounted) return;

    final quantidade = versiculos.length;
    _sairModoSelecao();

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: TemaHinario.corPrimaria,
          content: Text(
            '$quantidade ${quantidade == 1 ? 'versículo copiado' : 'versículos copiados'}',
          ),
        ),
      );
  }

  Future<void> _partilharSelecionados() async {
    final versiculos = _versiculosSelecionadosOrdenados();

    if (versiculos.isEmpty) return;

    final referencia = _construirReferenciaAgrupada();

    final buffer = StringBuffer();
    buffer.writeln(
      '${widget.livro.nome} ${_capituloAtual.numero}:$referencia',
    );
    buffer.writeln();

    for (final v in versiculos) {
      buffer.writeln('${v.referencia} ${v.texto}');
    }

    buffer.writeln();
    buffer.writeln('APP IECA - Bíblia');

    final texto = buffer.toString().trim();

    _sairModoSelecao();

    try {
      await SharePlus.instance.share(
        ShareParams(
          text: texto,
          subject:
              '${widget.livro.nome} ${_capituloAtual.numero}:$referencia',
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            backgroundColor: TemaHinario.corPrimaria,
            content: Text('Não foi possível partilhar.'),
          ),
        );
    }
  }

  // =============================================================
  // NAVEGAÇÃO PRINCIPAL
  // =============================================================

  void _selecionarNavegacao(int indice) {
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
            builder: (_) => const BibliaTela(),
          ),
        );
        break;

      case 3:
        break;

      case 4:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SobreTela()),
        );
        break;
    }
  }

  // =============================================================
  // CONTROLOS DA LEITURA
  // =============================================================

  Widget _buildControlesLeitura() {
    final corFundo = _modoEscuro
        ? Colors.grey[900]!
        : TemaHinario.corSuperficie;

    final corTexto = _modoEscuro ? Colors.white : TemaHinario.corTexto;

    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: corFundo,
        border: Border(
          bottom: BorderSide(
            color: _modoEscuro
                ? Colors.grey[800]!
                : TemaHinario.corTextoSecundario.withValues(alpha: 0.10),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _buildBotaoControle(
            tooltip: _modoEscuro ? 'Modo claro' : 'Modo escuro',
            icon: _modoEscuro
                ? Icons.light_mode_rounded
                : Icons.dark_mode_rounded,
            corTexto: corTexto,
            onPressed: () {
              setState(() {
                _modoEscuro = !_modoEscuro;
              });
            },
          ),

          const SizedBox(width: 4),

          _buildBotaoControle(
            tooltip: 'Aumentar texto',
            icon: Icons.text_increase_rounded,
            corTexto: corTexto,
            onPressed: () {
              if (_tamanhoFonte < 30) {
                setState(() {
                  _tamanhoFonte += 2;
                });
              }
            },
          ),

          const SizedBox(width: 4),

          _buildBotaoControle(
            tooltip: 'Diminuir texto',
            icon: Icons.text_decrease_rounded,
            corTexto: corTexto,
            onPressed: () {
              if (_tamanhoFonte > 12) {
                setState(() {
                  _tamanhoFonte -= 2;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBotaoControle({
    required String tooltip,
    required IconData icon,
    required Color corTexto,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 44,
      height: 44,
      child: IconButton(
        tooltip: tooltip,
        padding: EdgeInsets.zero,
        splashRadius: 22,
        onPressed: onPressed,
        icon: Icon(icon, color: corTexto, size: 22),
      ),
    );
  }

  // =============================================================
  // BARRA DE SELEÇÃO
  // =============================================================

  Widget _buildBarraSelecao() {
    final corFundo = _modoEscuro
        ? Colors.grey[900]!
        : TemaHinario.corSuperficie;

    final corTexto = _modoEscuro ? Colors.white : TemaHinario.corTexto;

    final quantidade = _selecionados.length;

    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: corFundo,
        border: Border(
          bottom: BorderSide(
            color: _corSelecaoAzul.withValues(alpha: 0.30),
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Sair do modo de seleção',
            onPressed: _sairModoSelecao,
            icon: Icon(Icons.close_rounded, color: corTexto),
          ),

          Expanded(
            child: Text(
              '$quantidade ${quantidade == 1 ? 'selecionado' : 'selecionados'}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: corTexto,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          IconButton(
            tooltip: 'Selecionar tudo',
            onPressed: _selecionarTudo,
            icon: Icon(
              Icons.select_all_rounded,
              color: corTexto,
            ),
          ),

          IconButton(
            tooltip: 'Destacar',
            onPressed: _abrirPaletaDestaque,
            icon: const Icon(
              Icons.brush_rounded,
              color: _corSelecaoAzul,
            ),
          ),

          IconButton(
            tooltip: 'Copiar',
            onPressed: _copiarSelecionados,
            icon: Icon(Icons.copy_rounded, color: corTexto),
          ),

          IconButton(
            tooltip: 'Partilhar',
            onPressed: _partilharSelecionados,
            icon: Icon(Icons.share_rounded, color: corTexto),
          ),

          PopupMenuButton<String>(
            tooltip: 'Mais opções',
            icon: Icon(Icons.more_vert_rounded, color: corTexto),
            onSelected: (valor) {
              if (valor == 'remover_destaque') {
                _removerDestaqueSelecionados();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'remover_destaque',
                child: Row(
                  children: [
                    Icon(
                      Icons.format_color_reset_rounded,
                      size: 20,
                    ),
                    SizedBox(width: 10),
                    Text('Remover destaque'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =============================================================
  // PALETA DE DESTAQUE EM LOTE
  // =============================================================

  void _abrirPaletaDestaque() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _modoEscuro
          ? Colors.grey[900]
          : TemaHinario.corSuperficie,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final corTexto = _modoEscuro ? Colors.white : TemaHinario.corTexto;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _corSelecaoAzul.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Icon(
                        Icons.brush_rounded,
                        color: _corSelecaoAzul,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Destacar ${_selecionados.length} '
                        '${_selecionados.length == 1 ? 'versículo' : 'versículos'}',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: corTexto,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _botaoCorLote(Colors.yellow.shade200),
                    _botaoCorLote(Colors.green.shade200),
                    _botaoCorLote(Colors.lightBlue.shade200),
                    _botaoCorLote(Colors.pink.shade200),
                    _botaoCorLote(Colors.orange.shade200),
                    IconButton(
                      tooltip: 'Remover destaque',
                      icon: const Icon(
                        Icons.format_color_reset_rounded,
                        color: TemaHinario.corPrimaria,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _removerDestaqueSelecionados();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _botaoCorLote(Color cor) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        _destacarSelecionados(cor);
      },
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: cor,
          shape: BoxShape.circle,
          border: Border.all(
            color: TemaHinario.corTextoSecundario.withValues(alpha: 0.18),
          ),
        ),
      ),
    );
  }

  // =============================================================
  // SELETOR DE CAPÍTULOS
  // =============================================================

  void _mostrarSeletorCapitulos() {
    showModalBottomSheet(
      context: context,
      backgroundColor:
          _modoEscuro ? Colors.grey[900] : TemaHinario.corSuperficie,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final corTexto = _modoEscuro ? Colors.white : TemaHinario.corTexto;

        final corTextoSecundario = _modoEscuro
            ? Colors.grey[400]
            : TemaHinario.corTextoSecundario;

        return Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          height: MediaQuery.of(context).size.height * 0.55,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color:
                          TemaHinario.corPrimaria.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.menu_book_rounded,
                      color: TemaHinario.corPrimaria,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selecionar capítulo',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: corTexto,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.livro.nome,
                          style: TextStyle(
                            fontSize: 12,
                            color: corTextoSecundario,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.only(bottom: 8),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1,
                  ),
                  itemCount: widget.livro.capitulos.length,
                  itemBuilder: (context, index) {
                    final capNumero =
                        widget.livro.capitulos[index].numero;

                    final isAtual = capNumero == _capituloAtual.numero;

                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          _mudarCapitulo(capNumero);
                          Navigator.pop(context);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          decoration: BoxDecoration(
                            color: isAtual
                                ? TemaHinario.corPrimaria
                                : (_modoEscuro
                                    ? Colors.grey[800]
                                    : TemaHinario.corSuperficieAlta),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isAtual
                                  ? TemaHinario.corPrimaria
                                  : TemaHinario.corTextoSecundario
                                      .withValues(alpha: 0.15),
                            ),
                            boxShadow: isAtual
                                ? [
                                    BoxShadow(
                                      color: TemaHinario.corPrimaria
                                          .withValues(alpha: 0.18),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              '$capNumero',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: isAtual ? Colors.white : corTexto,
                              ),
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
        );
      },
    );
  }

  // =============================================================
  // OPÇÕES DO VERSÍCULO
  // =============================================================

  void _mostrarOpcoesVersiculo(Versiculo versiculo) {
    final keyVersiculo =
        '${widget.livro.id}_${_capituloAtual.numero}_${versiculo.referencia}';

    showModalBottomSheet(
      context: context,
      backgroundColor:
          _modoEscuro ? Colors.grey[900] : TemaHinario.corSuperficie,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final corTexto = _modoEscuro ? Colors.white : TemaHinario.corTexto;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Wrap(
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color:
                            TemaHinario.corPrimaria.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Icon(
                        Icons.menu_book_rounded,
                        color: TemaHinario.corPrimaria,
                        size: 23,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${widget.livro.nome} '
                        '${_capituloAtual.numero}:'
                        '${versiculo.referencia}',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: corTexto,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                Text(
                  'Destacar versículo',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _modoEscuro
                        ? Colors.grey[400]
                        : TemaHinario.corTextoSecundario,
                  ),
                ),

                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _botaoCor(keyVersiculo, Colors.yellow.shade200),
                    _botaoCor(keyVersiculo, Colors.green.shade200),
                    _botaoCor(keyVersiculo, Colors.lightBlue.shade200),
                    _botaoCor(keyVersiculo, Colors.pink.shade200),
                    _botaoCor(keyVersiculo, Colors.orange.shade200),
                    IconButton(
                      tooltip: 'Remover destaque',
                      icon: const Icon(
                        Icons.format_color_reset_rounded,
                        color: TemaHinario.corPrimaria,
                      ),
                      onPressed: () async {
                        setState(
                          () => _versiculosDestacados.remove(keyVersiculo),
                        );

                        await _salvarDestaquesNoStorage();

                        if (mounted) {
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Divider(
                  height: 24,
                  color: _modoEscuro
                      ? Colors.grey[800]
                      : TemaHinario.corTextoSecundario
                          .withValues(alpha: 0.15),
                ),

                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                  leading: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: _corSelecaoAzul.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.checklist_rounded,
                      color: _corSelecaoAzul,
                    ),
                  ),
                  title: Text(
                    'Selecionar vários',
                    style: TextStyle(
                      color: corTexto,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _entrarModoSelecao(versiculo.referencia);
                  },
                ),

                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                  leading: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: TemaHinario.corSecundaria.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.copy_rounded,
                      color: _modoEscuro
                          ? Colors.white
                          : TemaHinario.corSecundaria,
                    ),
                  ),
                  title: Text(
                    'Copiar Versículo',
                    style: TextStyle(
                      color: corTexto,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    final textoCopia =
                        '${widget.livro.nome} '
                        '${_capituloAtual.numero}:'
                        '${versiculo.referencia} - '
                        '"${versiculo.texto}"';

                    Clipboard.setData(ClipboardData(text: textoCopia));

                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: TemaHinario.corPrimaria,
                        content: const Text('Versículo copiado!'),
                      ),
                    );
                  },
                ),

                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                  leading: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: TemaHinario.corSecundaria.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.share_rounded,
                      color: _modoEscuro
                          ? Colors.white
                          : TemaHinario.corSecundaria,
                    ),
                  ),
                  title: Text(
                    'Partilhar Versículo',
                    style: TextStyle(
                      color: corTexto,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    final textoPartilha =
                        '${widget.livro.nome} '
                        '${_capituloAtual.numero}:'
                        '${versiculo.referencia}\n'
                        '"${versiculo.texto}"\n\n'
                        'APP IECA - Bíblia';

                    Share.share(textoPartilha);

                    Navigator.pop(context);
                  },
                ),

                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                  leading: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color:
                          TemaHinario.corPrimaria.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _notasCapitulo.containsKey(versiculo.referencia)
                          ? Icons.edit_note_rounded
                          : Icons.note_add_rounded,
                      color: _modoEscuro
                          ? Colors.white
                          : TemaHinario.corPrimaria,
                    ),
                  ),
                  title: Text(
                    _notasCapitulo.containsKey(versiculo.referencia)
                        ? 'Editar Nota'
                        : 'Escrever Nota',
                    style: TextStyle(
                      color: corTexto,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _mostrarDialogoNota(versiculo);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // =============================================================
  // BOTÃO DE COR (INDIVIDUAL)
  // =============================================================

  Widget _botaoCor(String keyVersiculo, Color cor) {
    return GestureDetector(
      onTap: () async {
        final partes = keyVersiculo.split('_');
        final referencia = partes.last;

        final versiculo = _capituloAtual.versiculos.firstWhere(
          (v) => v.referencia == referencia,
          orElse: () => Versiculo(referencia: referencia, texto: ''),
        );

        // Cada marcação individual tem o seu próprio grupo
        final grupoId = DateTime.now().microsecondsSinceEpoch.toString();

        setState(() {
          _versiculosDestacados[keyVersiculo] = DestaqueInfo(
            cor: cor,
            texto: versiculo.texto,
            livroNome: widget.livro.nome,
            capitulo: _capituloAtual.numero,
            referencia: referencia,
            grupoId: grupoId,
          );
        });

        await _salvarDestaquesNoStorage();

        if (mounted) {
          Navigator.pop(context);
        }
      },
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: cor,
          shape: BoxShape.circle,
          border: Border.all(
            color: TemaHinario.corTextoSecundario.withValues(alpha: 0.18),
          ),
        ),
      ),
    );
  }

  // =============================================================
  // NOTAS
  // =============================================================

  void _mostrarDialogoNota(Versiculo versiculo) {
    final notaExistente = _notasCapitulo[versiculo.referencia];

    final controller = TextEditingController(
      text: notaExistente?.textoNota ?? '',
    );

    showDialog(
      context: context,
      builder: (context) {
        final corTexto = _modoEscuro ? Colors.white : TemaHinario.corTexto;

        final corTextoSecundario = _modoEscuro
            ? Colors.grey[400]
            : TemaHinario.corTextoSecundario;

        return AlertDialog(
          backgroundColor:
              _modoEscuro ? Colors.grey[900] : TemaHinario.corSuperficie,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: TemaHinario.corPrimaria.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.edit_note_rounded,
                  color: TemaHinario.corPrimaria,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Nota do Versículo '
                  '${versiculo.referencia}',
                  style: TextStyle(
                    color: corTexto,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          content: TextField(
            controller: controller,
            maxLines: 4,
            style: TextStyle(color: corTexto),
            decoration: InputDecoration(
              hintText: 'Escreva a sua anotação aqui...',
              hintStyle: TextStyle(color: corTextoSecundario),
              filled: true,
              fillColor: _modoEscuro
                  ? Colors.grey[850]
                  : TemaHinario.corSuperficieAlta,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: TemaHinario.corTextoSecundario
                      .withValues(alpha: 0.18),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: TemaHinario.corTextoSecundario
                      .withValues(alpha: 0.18),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: TemaHinario.corPrimaria,
                  width: 1.5,
                ),
              ),
            ),
          ),
          actions: [
            if (notaExistente != null)
              TextButton(
                onPressed: () async {
                  await _salvarOuRemoverNotaStorage(
                    versiculo: versiculo,
                    novoTexto: null,
                  );

                  if (mounted) {
                    Navigator.pop(context);
                  }
                },
                child: const Text(
                  'Eliminar',
                  style: TextStyle(color: TemaHinario.corPrimaria),
                ),
              ),

            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Cancelar',
                style: TextStyle(
                  color: _modoEscuro
                      ? Colors.grey[300]
                      : TemaHinario.corTextoSecundario,
                ),
              ),
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
              onPressed: () async {
                await _salvarOuRemoverNotaStorage(
                  versiculo: versiculo,
                  novoTexto: controller.text,
                );

                if (mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  // =============================================================
  // SELETOR DO CAPÍTULO NO CONTEÚDO
  // =============================================================

  Widget _buildSeletorCapitulo() {
    final corTexto = _modoEscuro ? Colors.white : TemaHinario.corTexto;

    return Material(
      color: _modoEscuro ? Colors.grey[900] : TemaHinario.corSuperficie,
      child: InkWell(
        onTap: _mostrarSeletorCapitulos,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 16, 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: _modoEscuro
                    ? Colors.grey[800]!
                    : TemaHinario.corTextoSecundario
                        .withValues(alpha: 0.12),
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: TemaHinario.corPrimaria.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  color: TemaHinario.corPrimaria,
                  size: 21,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.livro.nome,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: _modoEscuro
                            ? Colors.grey[400]
                            : TemaHinario.corTextoSecundario,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Capítulo ${_capituloAtual.numero}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: corTexto,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: TemaHinario.corSuperficieAlta,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: TemaHinario.corPrimaria,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =============================================================
  // NAVEGAÇÃO ANTERIOR / PRÓXIMO
  // =============================================================

  Widget _buildNavegacaoCapitulo() {
    final corTexto = _modoEscuro ? Colors.white : TemaHinario.corTexto;

    final podeAnterior = _capituloAtual.numero > 1;

    final podeProximo =
        _capituloAtual.numero < widget.livro.capitulos.length;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: BoxDecoration(
        color: _modoEscuro ? Colors.grey[900] : TemaHinario.corSuperficie,
        border: Border(
          top: BorderSide(
            color: _modoEscuro
                ? Colors.grey[800]!
                : TemaHinario.corTextoSecundario
                    .withValues(alpha: 0.12),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: podeAnterior ? _capituloAnterior : null,
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: const Text('Anterior'),
              style: OutlinedButton.styleFrom(
                foregroundColor: TemaHinario.corPrimaria,
                disabledForegroundColor: TemaHinario.corTextoSecundario
                    .withValues(alpha: 0.35),
                side: BorderSide(
                  color: podeAnterior
                      ? TemaHinario.corPrimaria.withValues(alpha: 0.35)
                      : TemaHinario.corTextoSecundario
                          .withValues(alpha: 0.15),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 11),
              ),
            ),
          ),

          const SizedBox(width: 10),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 9,
            ),
            decoration: BoxDecoration(
              color: TemaHinario.corPrimaria.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_capituloAtual.numero} / '
              '${widget.livro.capitulos.length}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: corTexto,
              ),
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: ElevatedButton.icon(
              onPressed: podeProximo ? _proximoCapitulo : null,
              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              label: const Text('Próximo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: TemaHinario.corPrimaria,
                foregroundColor: Colors.white,
                disabledBackgroundColor: TemaHinario.corSuperficieAlta,
                disabledForegroundColor: TemaHinario.corTextoSecundario
                    .withValues(alpha: 0.35),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 11),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =============================================================
  // BUILD
  // =============================================================

  @override
  Widget build(BuildContext context) {
    final corFundo = _modoEscuro
        ? Colors.grey[900]!
        : TemaHinario.corSuperficie;

    final corTexto = _modoEscuro ? Colors.white : TemaHinario.corTexto;

    return PopScope(
      canPop: !_modoSelecao,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_modoSelecao) {
          _sairModoSelecao();
        }
      },
      child: Scaffold(
        backgroundColor: corFundo,

        appBar: const PreferredSize(
          preferredSize: Size.fromHeight(72),
          child: CabecalhoIeca(),
        ),

        body: Column(
          children: [
            _modoSelecao ? _buildBarraSelecao() : _buildControlesLeitura(),

            _buildSeletorCapitulo(),

            Expanded(
              child: _capituloAtual.versiculos.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color: TemaHinario.corSuperficieAlta,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.menu_book_outlined,
                                size: 32,
                                color: TemaHinario.corTextoSecundario,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Nenhum versículo encontrado.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: corTexto,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                      itemCount: _capituloAtual.versiculos.length,
                      separatorBuilder: (context, index) => Divider(
                        color: _modoEscuro
                            ? Colors.grey[800]
                            : TemaHinario.corTextoSecundario
                                .withValues(alpha: 0.14),
                        height: 24,
                        thickness: 1,
                      ),
                      itemBuilder: (context, index) {
                        final versiculo = _capituloAtual.versiculos[index];

                        final keyVersiculo =
                            '${widget.livro.id}_'
                            '${_capituloAtual.numero}_'
                            '${versiculo.referencia}';

                        final destaqueInfo =
                            _versiculosDestacados[keyVersiculo];

                        final anotacao =
                            _notasCapitulo[versiculo.referencia];

                        final selecionado = _modoSelecao &&
                            _selecionados.contains(versiculo.referencia);

                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              if (_modoSelecao) {
                                _toggleSelecao(versiculo.referencia);
                              } else {
                                _mostrarOpcoesVersiculo(versiculo);
                              }
                            },
                            onLongPress: () {
                              if (!_modoSelecao) {
                                _entrarModoSelecao(versiculo.referencia);
                              } else {
                                _toggleSelecao(versiculo.referencia);
                              }
                            },
                            borderRadius: BorderRadius.circular(14),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 160),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: selecionado
                                    ? _corSelecaoAzul.withValues(alpha: 0.12)
                                    : destaqueInfo?.cor,
                                borderRadius: BorderRadius.circular(14),
                                border: selecionado
                                    ? const Border(
                                        left: BorderSide(
                                          color: _corSelecaoAzul,
                                          width: 4,
                                        ),
                                      )
                                    : null,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: '${versiculo.referencia} ',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: selecionado
                                                ? _corSelecaoAzul
                                                : TemaHinario.corPrimaria,
                                            fontSize: _tamanhoFonte - 2,
                                          ),
                                        ),
                                        TextSpan(
                                          text: versiculo.texto,
                                          style: TextStyle(
                                            color: destaqueInfo != null
                                                ? Colors.black87
                                                : corTexto,
                                            fontSize: _tamanhoFonte,
                                            height: 1.55,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  if (anotacao != null) ...[
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: TemaHinario.corSecundaria
                                            .withValues(alpha: 0.10),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: TemaHinario.corSecundaria
                                              .withValues(alpha: 0.30),
                                        ),
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Icon(
                                            Icons.sticky_note_2_rounded,
                                            size: 17,
                                            color: TemaHinario.corSecundaria,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              anotacao.textoNota,
                                              style: TextStyle(
                                                fontSize: 12,
                                                height: 1.4,
                                                color: destaqueInfo != null
                                                    ? Colors.black87
                                                    : (_modoEscuro
                                                        ? Colors.white
                                                        : TemaHinario
                                                            .corTexto),
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),

            _buildNavegacaoCapitulo(),
          ],
        ),

        bottomNavigationBar: NavegacaoInferiorIeca(
          indiceSelecionado: 2,
          onDestinationSelected: _selecionarNavegacao,
        ),
      ),
    );
  }
}