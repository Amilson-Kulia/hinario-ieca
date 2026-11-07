import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/tema.dart';
import '../../../componentes/cabecalho_ieca.dart';
import '../../../componentes/navegacao_inferior_ieca.dart';
import '../../../modelos/hino.dart';
import '../biblia/biblia_tela.dart';
import '../home/home_tela.dart';
import '../sobre/sobre_tela.dart';
import 'leitura_tela.dart';
import '../informacoes_ieca/informacoes_ieca_tela.dart';

class HinosAdicionaisTela extends StatefulWidget {
  const HinosAdicionaisTela({super.key});

  @override
  State<HinosAdicionaisTela> createState() =>
      _HinosAdicionaisTelaState();
}

class _HinosAdicionaisTelaState
    extends State<HinosAdicionaisTela> {
  final TextEditingController _pesquisaController =
      TextEditingController();

  String _filtroAtual = 'Número';

  // =========================================================
  // ESTADO DOS DADOS
  // =========================================================

  List<Hino> _hinos = [];

  bool _carregando = true;

  // =========================================================
  // CICLO DE VIDA
  // =========================================================

  @override
  void initState() {
    super.initState();

    _pesquisaController.addListener(
      _atualizarPesquisa,
    );

    _carregarHinos();
  }

  @override
  void dispose() {
    _pesquisaController.removeListener(
      _atualizarPesquisa,
    );

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

  // =============================================================
  // CONVERSÃO ROMANO → ÁRABE (para ordenação)
  // =============================================================

  int _romanoParaInteiro(String romano) {
    if (romano.isEmpty) return 0;

    const valores = {
      'I': 1, 'V': 5, 'X': 10, 'L': 50,
      'C': 100, 'D': 500, 'M': 1000,
    };

    int total = 0;
    int anterior = 0;

    for (int i = romano.length - 1; i >= 0; i--) {
      final valor =
          valores[romano[i].toUpperCase()] ?? 0;

      if (valor < anterior) {
        total -= valor;
      } else {
        total += valor;
        anterior = valor;
      }
    }

    return total;
  }

  int _numeroParaInteiro(dynamic numero) {
    final texto = numero.toString().trim();

    final numeroArabico = int.tryParse(texto);
    if (numeroArabico != null) return numeroArabico;

    return _romanoParaInteiro(texto);
  }

  // =============================================================
  // CARREGAR HINOS ADICIONAIS
  // =============================================================

  Future<void> _carregarHinos() async {
    try {
      final String jsonString =
          await rootBundle.loadString(
        'assets/dados/hinos_adicionais.json',
      );

      final dynamic dados = json.decode(jsonString);

      List<dynamic> lista;

      if (dados is List) {
        lista = dados;
      } else if (dados is Map<String, dynamic> &&
          dados['hinos'] is List) {
        lista = dados['hinos'] as List<dynamic>;
      } else {
        throw const FormatException(
          'Formato inválido do arquivo de hinos adicionais.',
        );
      }

      final List<Hino> hinos = [];

      for (final item in lista) {
        if (item is! Map) continue;

        try {
          final Map<String, dynamic> mapa =
              Map<String, dynamic>.from(item);

          hinos.add(Hino.fromJson(mapa));
        } catch (e) {
          debugPrint(
            'Erro ao converter hino adicional: $e',
          );
        }
      }

      hinos.sort((a, b) {
        return _numeroParaInteiro(a.numero)
            .compareTo(_numeroParaInteiro(b.numero));
      });

      if (!mounted) return;

      setState(() {
        _hinos = hinos;
        _carregando = false;
      });
    } catch (e) {
      debugPrint(
        'ERRO AO CARREGAR HINOS ADICIONAIS: $e',
      );

      if (!mounted) return;

      setState(() {
        _hinos = [];
        _carregando = false;
      });
    }
  }

  // =========================================================
  // HINOS FILTRADOS
  // =========================================================

  List<Hino> get _hinosFiltrados {
    final String pesquisa =
        _pesquisaController.text.trim().toLowerCase();

    if (pesquisa.isEmpty) {
      return _hinos;
    }

    if (_filtroAtual == 'Nome') {
      return _hinos.where((hino) {
        return hino.titulo
            .toLowerCase()
            .contains(pesquisa);
      }).toList();
    }

    // Filtro "Número" — aceita árabe ("12") ou romano ("XII")
    return _hinos.where((hino) {
      final numeroTexto =
          hino.numero.toString().toLowerCase();
      final numeroExibicao =
          hino.numeroExibicao.toLowerCase();
      final titulo = hino.titulo.toLowerCase();

      return numeroTexto.contains(pesquisa) ||
          numeroExibicao.contains(pesquisa) ||
          titulo.contains(pesquisa);
    }).toList();
  }

  // =========================================================
  // ABRIR HINO
  // =========================================================

  void _abrirHino(Hino hino) {
    final listaAtual = _hinosFiltrados;

    final int indice = listaAtual.indexWhere(
      (h) => h.numero == hino.numero,
    );

    final List<LeituraItem> listaNavegacao =
        listaAtual
            .map((h) => LeituraItem(hino: h))
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

  // =============================================================
  // NAVEGAÇÃO INFERIOR
  // =============================================================

  void _selecionarNavegacao(int indice) {
    if (!mounted) return;

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
        // Já estamos no Hinário.
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
    }
  }

  // =============================================================
  // BUILD
  // =============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TemaHinario.corSuperficie,

      appBar: const CabecalhoIeca(),

      body: SafeArea(
        top: false,
        bottom: false,
        child: _carregando
            ? const Center(
                child: CircularProgressIndicator(
                  color: TemaHinario.corPrimaria,
                ),
              )
            : _buildConteudo(),
      ),

      bottomNavigationBar: NavegacaoInferiorIeca(
        indiceSelecionado: 1,
        onDestinationSelected: _selecionarNavegacao,
      ),
    );
  }

  // =========================================================
  // CONTEÚDO
  // =========================================================

  Widget _buildConteudo() {
    final hinos = _hinosFiltrados;

    return CustomScrollView(
      slivers: [
        // =====================================================
        // CABEÇALHO DA PÁGINA
        // =====================================================

        SliverToBoxAdapter(
          child: _buildCabecalhoPagina(),
        ),

        // =====================================================
        // PESQUISA FIXA
        // =====================================================

        SliverPersistentHeader(
          pinned: true,
          delegate: _PesquisaDelegate(
            child: _buildPesquisa(hinos.length),
          ),
        ),

        // =====================================================
        // GRELHA DE CÍRCULOS
        // =====================================================

        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            20,
            20,
            20,
            32,
          ),
          sliver: hinos.isEmpty
              ? const SliverFillRemaining(
                  hasScrollBody: false,
                  child: _NenhumResultado(),
                )
              : SliverToBoxAdapter(
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: hinos
                        .map(
                          (hino) => _CirculoHino(
                            hino: hino,
                            onTap: () => _abrirHino(hino),
                          ),
                        )
                        .toList(),
                  ),
                ),
        ),
      ],
    );
  }

  // =========================================================
  // CABEÇALHO DA PÁGINA
  // =========================================================

  Widget _buildCabecalhoPagina() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        24,
        24,
        24,
        20,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: TemaHinario.corPrimaria
                  .withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.library_music_rounded,
              color: TemaHinario.corPrimaria,
              size: 27,
            ),
          ),

          const SizedBox(width: 14),

          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Hinos',
                  style: TextStyle(
                    fontSize: 28,
                    height: 1.15,
                    fontWeight: FontWeight.w800,
                    color: TemaHinario.corTexto,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Hinos Adicionais',
                  style: TextStyle(
                    fontSize: 14,
                    color: TemaHinario
                        .corTextoSecundario,
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

  Widget _buildPesquisa(int totalResultados) {
    final bool temTexto =
        _pesquisaController.text.isNotEmpty;

    return Container(
      width: double.infinity,
      color: TemaHinario.corSuperficie,
      padding: const EdgeInsets.fromLTRB(
        20,
        8,
        20,
        14,
      ),
      child: Column(
        children: [
          // Campo
          Container(
            height: 52,
            decoration: BoxDecoration(
              color: TemaHinario.corSuperficieMedia,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: TemaHinario
                    .corTextoSecundario
                    .withValues(alpha: 0.10),
              ),
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),

                const Icon(
                  Icons.search_rounded,
                  size: 23,
                  color:
                      TemaHinario.corTextoSecundario,
                ),

                const SizedBox(width: 11),

                Expanded(
                  child: TextField(
                    controller: _pesquisaController,
                    textInputAction:
                        TextInputAction.search,
                    decoration: const InputDecoration(
                      hintText:
                          'Pesquisar hino por número ou título...',
                      hintStyle: TextStyle(
                        color: TemaHinario
                            .corTextoSecundario,
                        fontSize: 15,
                      ),
                      border: InputBorder.none,
                      isCollapsed: true,
                    ),
                    style: const TextStyle(
                      color: TemaHinario.corTexto,
                      fontSize: 15,
                    ),
                  ),
                ),

                if (temTexto)
                  IconButton(
                    tooltip: 'Limpar pesquisa',
                    onPressed: () {
                      _pesquisaController.clear();
                    },
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: TemaHinario
                          .corTextoSecundario,
                    ),
                  )
                else
                  const SizedBox(width: 8),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Filtros
          Row(
            children: [
              _buildFiltro(
                icone:
                    Icons.format_list_numbered_rounded,
                texto: 'Número',
              ),

              const SizedBox(width: 8),

              _buildFiltro(
                icone: Icons.sort_by_alpha_rounded,
                texto: 'Nome',
              ),

              const Spacer(),

              Text(
                '$totalResultados '
                '${totalResultados == 1 ? 'hino' : 'hinos'}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color:
                      TemaHinario.corTextoSecundario,
                ),
              ),
            ],
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
    final bool ativo = _filtroAtual == texto;

    return Material(
      color: ativo
          ? TemaHinario.corPrimaria
          : TemaHinario.corSuperficieMedia,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: () {
          setState(() {
            _filtroAtual = texto;
          });
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 8,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icone,
                size: 16,
                color: ativo
                    ? Colors.white
                    : TemaHinario
                        .corTextoSecundario,
              ),
              const SizedBox(width: 5),
              Text(
                texto,
                style: TextStyle(
                  color: ativo
                      ? Colors.white
                      : TemaHinario
                          .corTextoSecundario,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
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
// CÍRCULO DO HINO
// =============================================================

class _CirculoHino extends StatelessWidget {
  final Hino hino;
  final VoidCallback onTap;

  const _CirculoHino({
    required this.hino,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Como os hinos adicionais podem ter números romanos
    // (I, II, III, IV...), usamos o `numeroExibicao` para
    // garantir que o círculo mostra o formato correto.
    final String texto = hino.numeroExibicao;

    // Círculos ligeiramente maiores para números romanos,
    // porque podem ter 2-4 caracteres (ex: "XVII").
    final bool textoLongo = texto.length > 2;

    return Material(
      color: TemaHinario.corPrimaria
          .withValues(alpha: 0.08),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: textoLongo ? 60 : 54,
          height: textoLongo ? 60 : 54,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: TemaHinario.corPrimaria
                  .withValues(alpha: 0.20),
            ),
          ),
          child: Text(
            texto,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: TemaHinario.corPrimaria,
              fontSize: textoLongo ? 13 : 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================
// NENHUM RESULTADO
// =============================================================

class _NenhumResultado extends StatelessWidget {
  const _NenhumResultado();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: TemaHinario.corPrimaria
                    .withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 34,
                color: TemaHinario.corPrimaria,
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'Nenhum hino encontrado',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: TemaHinario.corTexto,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 7),

            const Text(
              'Tente pesquisar por outro número '
              'ou título de hino.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color:
                    TemaHinario.corTextoSecundario,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],
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

  _PesquisaDelegate({required this.child});

  @override
  double get minExtent => 132;

  @override
  double get maxExtent => 132;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Material(
      color: TemaHinario.corSuperficie,
      elevation: overlapsContent ? 2 : 0,
      child: child,
    );
  }

  @override
  bool shouldRebuild(
    covariant _PesquisaDelegate oldDelegate,
  ) {
    return true;
  }
}