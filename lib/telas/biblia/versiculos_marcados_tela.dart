import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/tema.dart';
import '../../componentes/cabecalho_ieca.dart';
import '../../componentes/navegacao_inferior_ieca.dart';
import '../home/home_tela.dart';
import '../hinario/idiomas_tela.dart';
import '../sobre/sobre_tela.dart';
import '../informacoes_ieca/informacoes_ieca_tela.dart';

// =============================================================
// MODELOS AUXILIARES
// =============================================================

class VersiculoNoGrupo {
  final String referencia;
  final String texto;

  VersiculoNoGrupo({required this.referencia, required this.texto});
}

class VersiculoDestacadoItem {
  final String grupoId;
  final String livroId;
  final String livroNome;
  final int capitulo;
  final Color cor;
  final List<VersiculoNoGrupo> versiculos;

  VersiculoDestacadoItem({
    required this.grupoId,
    required this.livroId,
    required this.livroNome,
    required this.capitulo,
    required this.cor,
    required this.versiculos,
  });

  /// Referência agrupada: "Gênesis 1:1-3" ou "Gênesis 1:1,3,5".
  String get referenciaCompleta {
    final nums = versiculos
        .map((v) => int.tryParse(v.referencia) ?? 0)
        .where((n) => n > 0)
        .toList()
      ..sort();

    if (nums.isEmpty) {
      return '$livroNome $capitulo';
    }

    final partes = <String>[];
    int inicio = nums.first;
    int anterior = nums.first;

    for (int i = 1; i < nums.length; i++) {
      final atual = nums[i];
      if (atual == anterior + 1) {
        anterior = atual;
      } else {
        partes.add(inicio == anterior ? '$inicio' : '$inicio-$anterior');
        inicio = atual;
        anterior = atual;
      }
    }
    partes.add(inicio == anterior ? '$inicio' : '$inicio-$anterior');

    return '$livroNome $capitulo:${partes.join(',')}';
  }
}

// =============================================================
// TELA
// =============================================================

class VersiculosMarcadosTela extends StatefulWidget {
  const VersiculosMarcadosTela({Key? key}) : super(key: key);

  @override
  State<VersiculosMarcadosTela> createState() =>
      _VersiculosMarcadosTelaState();
}

class _VersiculosMarcadosTelaState
    extends State<VersiculosMarcadosTela> {
  static const String _keyDestaques = 'destaques_biblia_storage';

  List<VersiculoDestacadoItem> _listaItens = [];
  List<VersiculoDestacadoItem> _listaFiltrada = [];

  bool _carregando = true;

  Color? _corFiltroSelecionada;

  String? _keyExpandida;

  final List<Color> _coresDisponiveis = [
    Colors.yellow.shade200,
    Colors.green.shade200,
    Colors.lightBlue.shade200,
    Colors.pink.shade200,
    Colors.orange.shade200,
  ];

  // =============================================================
  // MAPA DE NOMES DOS LIVROS
  // =============================================================

  static const Map<String, String> _nomesLivros = {
    'gen': 'Gênesis',
    'genesis': 'Gênesis',
    'exo': 'Êxodo',
    'exodo': 'Êxodo',
    'lev': 'Levítico',
    'levitico': 'Levítico',
    'num': 'Números',
    'numeros': 'Números',
    'deu': 'Deuteronômio',
    'deuteronomio': 'Deuteronômio',
    'jos': 'Josué',
    'josue': 'Josué',
    'jdg': 'Juízes',
    'juizes': 'Juízes',
    'rut': 'Rute',
    'rute': 'Rute',
    '1sa': '1 Samuel',
    '2sa': '2 Samuel',
    '1re': '1 Reis',
    '2re': '2 Reis',
    '1cr': '1 Crônicas',
    '2cr': '2 Crônicas',
    'esd': 'Esdras',
    'esdras': 'Esdras',
    'nee': 'Neemias',
    'neemias': 'Neemias',
    'est': 'Ester',
    'ester': 'Ester',
    'job': 'Jó',
    'jó': 'Jó',
    'slm': 'Salmos',
    'salmos': 'Salmos',
    'pro': 'Provérbios',
    'proverbios': 'Provérbios',
    'ecl': 'Eclesiastes',
    'eclesiastes': 'Eclesiastes',
    'can': 'Cânticos',
    'cantares': 'Cânticos',
    'isa': 'Isaías',
    'isaias': 'Isaías',
    'jer': 'Jeremias',
    'jeremias': 'Jeremias',
    'lam': 'Lamentações',
    'lamentacoes': 'Lamentações',
    'eze': 'Ezequiel',
    'ezequiel': 'Ezequiel',
    'dan': 'Daniel',
    'daniel': 'Daniel',
    'ose': 'Oséias',
    'oseias': 'Oséias',
    'joe': 'Joel',
    'joel': 'Joel',
    'amo': 'Amós',
    'amos': 'Amós',
    'oba': 'Obadias',
    'obadias': 'Obadias',
    'jon': 'Jonas',
    'jonas': 'Jonas',
    'miq': 'Miquéias',
    'miqueias': 'Miquéias',
    'naa': 'Naum',
    'naum': 'Naum',
    'hab': 'Habacuque',
    'habacuque': 'Habacuque',
    'sof': 'Sofonias',
    'sofonias': 'Sofonias',
    'age': 'Ageu',
    'ageu': 'Ageu',
    'zac': 'Zacarias',
    'zacarias': 'Zacarias',
    'mal': 'Malaquias',
    'malaquias': 'Malaquias',
    'mat': 'Mateus',
    'mateus': 'Mateus',
    'mar': 'Marcos',
    'marcos': 'Marcos',
    'luc': 'Lucas',
    'lucas': 'Lucas',
    'joa': 'João',
    'joao': 'João',
    'ato': 'Atos',
    'atos': 'Atos',
    'rom': 'Romanos',
    'romanos': 'Romanos',
    '1co': '1 Coríntios',
    '2co': '2 Coríntios',
    'gal': 'Gálatas',
    'galatas': 'Gálatas',
    'efe': 'Efésios',
    'efesios': 'Efésios',
    'fil': 'Filipenses',
    'filipenses': 'Filipenses',
    'col': 'Colossenses',
    'colossenses': 'Colossenses',
    '1ts': '1 Tessalonicenses',
    '2ts': '2 Tessalonicenses',
    '1ti': '1 Timóteo',
    '2ti': '2 Timóteo',
    'tit': 'Tito',
    'tito': 'Tito',
    'flm': 'Filemom',
    'filemom': 'Filemom',
    'heb': 'Hebreus',
    'hebreus': 'Hebreus',
    'tia': 'Tiago',
    'tiago': 'Tiago',
    '1pe': '1 Pedro',
    '2pe': '2 Pedro',
    '1jo': '1 João',
    '2jo': '2 João',
    '3jo': '3 João',
    'jud': 'Judas',
    'judas': 'Judas',
    'rev': 'Apocalipse',
    'apocalipse': 'Apocalipse',
  };

  // =============================================================
  // CICLO DE VIDA
  // =============================================================

  @override
  void initState() {
    super.initState();
    _carregarDestaques();
  }

  // =============================================================
  // CARREGAR DESTAQUES (agrupados por grupoId)
  // =============================================================

  Future<void> _carregarDestaques() async {
    setState(() => _carregando = true);

    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_keyDestaques);

    final Map<String, List<VersiculoNoGrupo>> grupos = {};
    final Map<String, Color> coresGrupos = {};
    final Map<String, String> nomesGrupos = {};
    final Map<String, int> capsGrupos = {};
    final Map<String, String> livroIdsGrupos = {};

    if (jsonString != null && jsonString.isNotEmpty) {
      final Map<String, dynamic> mapaJson = jsonDecode(jsonString);

      mapaJson.forEach((key, value) {
        final partes = key.split('_');
        if (partes.length < 3) return;

        final livroId = partes[0];
        final referencia = partes.sublist(2).join('_');

        Color cor;
        String texto = '';
        String livroNome = '';
        int capitulo = int.tryParse(partes[1]) ?? 1;
        String grupoId;

        if (value is Map) {
          cor = Color(value['cor'] as int);
          texto = (value['texto'] as String?) ?? '';
          livroNome = (value['livroNome'] as String?) ?? '';
          capitulo = (value['capitulo'] as int?) ?? capitulo;
          grupoId = (value['grupoId'] as String?) ?? key;
        } else if (value is int) {
          cor = Color(value);
          grupoId = key;
        } else {
          return;
        }

        if (livroNome.isEmpty) {
          livroNome = _nomeLivroPortugues(livroId);
        }

        grupos.putIfAbsent(grupoId, () => []);
        grupos[grupoId]!.add(
          VersiculoNoGrupo(referencia: referencia, texto: texto),
        );

        coresGrupos[grupoId] = cor;
        nomesGrupos[grupoId] = livroNome;
        capsGrupos[grupoId] = capitulo;
        livroIdsGrupos[grupoId] = livroId;
      });
    }

    final List<VersiculoDestacadoItem> lista = [];

    grupos.forEach((grupoId, versiculos) {
      versiculos.sort((a, b) {
        final aNum = int.tryParse(a.referencia) ?? 0;
        final bNum = int.tryParse(b.referencia) ?? 0;
        return aNum.compareTo(bNum);
      });

      lista.add(VersiculoDestacadoItem(
        grupoId: grupoId,
        livroId: livroIdsGrupos[grupoId] ?? '',
        livroNome: nomesGrupos[grupoId] ?? '',
        capitulo: capsGrupos[grupoId] ?? 0,
        cor: coresGrupos[grupoId] ?? Colors.yellow.shade200,
        versiculos: versiculos,
      ));
    });

    lista.sort((a, b) {
      final cmpLivro = a.livroNome.compareTo(b.livroNome);
      if (cmpLivro != 0) return cmpLivro;

      final cmpCap = a.capitulo.compareTo(b.capitulo);
      if (cmpCap != 0) return cmpCap;

      final aNum = a.versiculos.isEmpty
          ? 0
          : int.tryParse(a.versiculos.first.referencia) ?? 0;
      final bNum = b.versiculos.isEmpty
          ? 0
          : int.tryParse(b.versiculos.first.referencia) ?? 0;
      return aNum.compareTo(bNum);
    });

    setState(() {
      _listaItens = lista;
      _aplicarFiltro();
      _carregando = false;
    });
  }

  /// Retorna o nome do livro em português.
  String _nomeLivroPortugues(String livroId) {
    final id = livroId.toLowerCase().trim();
    if (_nomesLivros.containsKey(id)) {
      return _nomesLivros[id]!;
    }

    final palavras = livroId.split('_');
    return palavras
        .map(
          (p) => p.isNotEmpty
              ? '${p[0].toUpperCase()}${p.substring(1)}'
              : '',
        )
        .join(' ');
  }

  // =============================================================
  // FILTRO
  // =============================================================

  void _aplicarFiltro() {
    setState(() {
      if (_corFiltroSelecionada == null) {
        _listaFiltrada = List.from(_listaItens);
      } else {
        _listaFiltrada = _listaItens
            .where(
              (item) =>
                  item.cor.value == _corFiltroSelecionada!.value,
            )
            .toList();
      }
    });
  }

  // =============================================================
  // EXPANDIR / RECOLHER
  // =============================================================

  void _toggleExpandir(String chave) {
    setState(() {
      _keyExpandida = _keyExpandida == chave ? null : chave;
    });
  }

  // =============================================================
  // REMOVER DESTAQUE (remove só os versículos deste grupo)
  // =============================================================

  Future<void> _removerDestaque(
    VersiculoDestacadoItem item,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_keyDestaques);

    if (jsonString == null || jsonString.isEmpty) return;

    final Map<String, dynamic> mapaJson = jsonDecode(jsonString);

    final chavesARemover = <String>[];

    mapaJson.forEach((key, value) {
      String grupoId;
      if (value is Map) {
        grupoId = (value['grupoId'] as String?) ?? key;
      } else {
        grupoId = key;
      }

      if (grupoId == item.grupoId) {
        chavesARemover.add(key);
      }
    });

    for (final k in chavesARemover) {
      mapaJson.remove(k);
    }

    await prefs.setString(_keyDestaques, jsonEncode(mapaJson));

    await _carregarDestaques();

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
              Icon(Icons.bookmark_remove_rounded,
                  color: Colors.white),
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

  // =============================================================
  // PARTILHAR
  // =============================================================

  void _partilharMarcacao(VersiculoDestacadoItem item) {
    final buffer = StringBuffer();
    buffer.writeln(item.referenciaCompleta);
    buffer.writeln();

    for (final v in item.versiculos) {
      if (v.texto.isNotEmpty) {
        buffer.writeln('${v.referencia} ${v.texto}');
      }
    }

    buffer.writeln();
    buffer.writeln('APP IECA - Bíblia');

    SharePlus.instance.share(
      ShareParams(
        text: buffer.toString().trim(),
        subject: item.referenciaCompleta,
      ),
    );
  }

  // =============================================================
  // COPIAR
  // =============================================================

  void _copiarReferencia(VersiculoDestacadoItem item) {
    final buffer = StringBuffer();
    buffer.write(item.referenciaCompleta);
    buffer.writeln();

    for (final v in item.versiculos) {
      if (v.texto.isNotEmpty) {
        buffer.writeln('${v.referencia} ${v.texto}');
      }
    }

    Clipboard.setData(ClipboardData(text: buffer.toString().trim()));

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
                  'Copiado!',
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

  // =============================================================
  // NAVEGAÇÃO INFERIOR
  // =============================================================

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
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const InformacoesIecaTela(),
          ),
        );
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
  // BUILD
  // =============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TemaHinario.corSuperficie,

      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(72),
        child: CabecalhoIeca(),
      ),

      body: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          children: [
            _buildCabecalhoPagina(),

            _buildFiltroCores(),

            Expanded(
              child: _carregando
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: TemaHinario.corPrimaria,
                      ),
                    )
                  : _listaFiltrada.isEmpty
                      ? _buildVazio()
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(
                            16,
                            12,
                            16,
                            24,
                          ),
                          itemCount: _listaFiltrada.length,
                          itemBuilder: (context, index) {
                            final item = _listaFiltrada[index];
                            final expandido =
                                _keyExpandida == item.grupoId;

                            return Padding(
                              padding: const EdgeInsets.only(
                                bottom: 10,
                              ),
                              child: _CartaoVersiculo(
                                item: item,
                                expandido: expandido,
                                onToggle: () =>
                                    _toggleExpandir(item.grupoId),
                                onCopiar: () =>
                                    _copiarReferencia(item),
                                onPartilhar: () =>
                                    _partilharMarcacao(item),
                                onRemover: () =>
                                    _removerDestaque(item),
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

  // =============================================================
  // CABEÇALHO DA PÁGINA
  // =============================================================

  Widget _buildCabecalhoPagina() {
    final total = _listaItens.fold<int>(
      0,
      (soma, item) => soma + item.versiculos.length,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 14),
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
                  'Versículos Marcados',
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
                      ? '1 versículo guardado'
                      : '$total versículos guardados',
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

  // =============================================================
  // FILTRO POR COR
  // =============================================================

  Widget _buildFiltroCores() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
      child: Row(
        children: [
          const Text(
            'Filtrar:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: TemaHinario.corTextoSecundario,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _corFiltroSelecionada = null;
                        _aplicarFiltro();
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: _corFiltroSelecionada == null
                            ? TemaHinario.corPrimaria
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: TemaHinario.corPrimaria,
                          width: 1.2,
                        ),
                      ),
                      child: Text(
                        'Todas',
                        style: TextStyle(
                          color: _corFiltroSelecionada == null
                              ? Colors.white
                              : TemaHinario.corPrimaria,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),

                  ..._coresDisponiveis.map((cor) {
                    final selecionado =
                        _corFiltroSelecionada?.value == cor.value;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _corFiltroSelecionada =
                              selecionado ? null : cor;
                          _aplicarFiltro();
                        });
                      },
                      child: AnimatedContainer(
                        duration:
                            const Duration(milliseconds: 180),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selecionado
                                ? TemaHinario.corTexto
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: cor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.black
                                  .withValues(alpha: 0.08),
                            ),
                          ),
                          child: selecionado
                              ? const Icon(
                                  Icons.check_rounded,
                                  size: 14,
                                  color: Colors.black87,
                                )
                              : null,
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =============================================================
  // VAZIO
  // =============================================================

  Widget _buildVazio() {
    final filtroAtivo = _corFiltroSelecionada != null;
    final temItens = _listaItens.isNotEmpty;

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
                    ? Icons.filter_alt_off_rounded
                    : Icons.bookmark_border_rounded,
                size: 36,
                color: TemaHinario.corPrimaria,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              filtroAtivo && temItens
                  ? 'Sem resultados para esta cor'
                  : 'Nenhum versículo marcado',
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
                  ? 'Experimente escolher outra cor ou ver "Todas".'
                  : 'Marque versículos na Bíblia para os ver aqui.',
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
// CARTÃO DO VERSÍCULO (agrupado por marcação)
// =============================================================

class _CartaoVersiculo extends StatelessWidget {
  final VersiculoDestacadoItem item;
  final bool expandido;
  final VoidCallback onToggle;
  final VoidCallback onCopiar;
  final VoidCallback onPartilhar;
  final VoidCallback onRemover;

  const _CartaoVersiculo({
    required this.item,
    required this.expandido,
    required this.onToggle,
    required this.onCopiar,
    required this.onPartilhar,
    required this.onRemover,
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
              left: BorderSide(color: item.cor, width: 5),
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
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.referenciaCompleta,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: TemaHinario.corTexto,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.versiculos.length == 1
                                ? '1 versículo'
                                : '${item.versiculos.length} versículos',
                            style: const TextStyle(
                              fontSize: 12,
                              color: TemaHinario.corTextoSecundario,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: expandido ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: TemaHinario.corTextoSecundario,
                        size: 22,
                      ),
                    ),
                  ],
                ),

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
                    padding: const EdgeInsets.only(top: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...item.versiculos.map((v) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: '${v.referencia} ',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: TemaHinario.corPrimaria,
                                    ),
                                  ),
                                  TextSpan(
                                    text: v.texto.isNotEmpty
                                        ? v.texto
                                        : '(texto não disponível)',
                                    style: TextStyle(
                                      fontSize: 15,
                                      height: 1.55,
                                      color: v.texto.isNotEmpty
                                          ? TemaHinario.corTexto
                                          : TemaHinario.corTextoSecundario,
                                      fontStyle: v.texto.isNotEmpty
                                          ? FontStyle.normal
                                          : FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),

                        const SizedBox(height: 4),

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
                              icone: Icons.delete_outline_rounded,
                              texto: 'Remover',
                              onTap: onRemover,
                              destrutivo: true,
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
    bool destrutivo = false,
  }) {
    final cor = destrutivo
        ? const Color(0xFFD32F2F)
        : TemaHinario.corTextoSecundario;

    return Material(
      color: cor.withValues(alpha: 0.08),
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
              Icon(icone, size: 15, color: cor),
              const SizedBox(width: 5),
              Text(
                texto,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: cor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}