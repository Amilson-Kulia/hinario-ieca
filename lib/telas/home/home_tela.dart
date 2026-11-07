import 'package:flutter/material.dart';

import '../../app/tema.dart';
import '../../componentes/cabecalho_ieca.dart';
import '../../componentes/navegacao_inferior_ieca.dart';
import '../../modelos/hino.dart';
import '../../modelos/versiculo.dart';
import '../../servicos/servico_hinos.dart';
import '../../servicos/versiculos_servico.dart';
import '../../servicos/palavra_do_dia_servico.dart';

import '../hinario/idiomas_tela.dart';
import '../hinario/leitura_tela.dart';
import '../sobre/sobre_tela.dart';
import '../favoritos/favoritos_tela.dart';
import '../marcados/marcados_tela.dart';
import '../programa_culto/criar_programa_tela.dart';
import '../programa_culto/meus_programas_tela.dart';
import '../constancia/minha_constancia_tela.dart';

import '../biblia/biblia_tela.dart';
import '../informacoes_ieca/informacoes_ieca_tela.dart';
import '../lecionario/lecionario_tela.dart';

class HomeTela extends StatefulWidget {
  const HomeTela({super.key});

  @override
  State<HomeTela> createState() => _HomeTelaState();
}

class _HomeTelaState extends State<HomeTela> {
  // =============================================================
  // NAVEGAÇÃO
  //
  // 0 = Home
  // 1 = Hinário
  // 2 = Bíblia
  // 3 = Informações
  // 4 = Sobre
  // =============================================================

  int itemSelecionado = 0;

  Hino? hinoDoDia;
  bool carregandoHino = true;

  Versiculo? palavraDoDia;
  bool carregandoPalavra = true;

  @override
  void initState() {
    super.initState();

    carregarHinoDoDia();
    carregarPalavraDoDia();
  }

  // =============================================================
  // HINO DO DIA
  // =============================================================

  Future<void> carregarHinoDoDia() async {
    try {
      final servico = ServicoHinos();

      final hino = await servico.obterHinoDoDia();

      if (!mounted) {
        return;
      }

      setState(() {
        hinoDoDia = hino;
        carregandoHino = false;
      });
    } catch (e) {
      debugPrint(
        'ERRO AO CARREGAR HINO DO DIA: $e',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        hinoDoDia = null;
        carregandoHino = false;
      });
    }
  }

  // =============================================================
  // PALAVRA DO DIA
  // =============================================================

  Future<void> carregarPalavraDoDia() async {
    try {
      final versiculo =
          await PalavraDoDiaServico.obterPalavraDoDia();

      if (!mounted) {
        return;
      }

      setState(() {
        palavraDoDia = versiculo;
        carregandoPalavra = false;
      });
    } catch (e) {
      debugPrint(
        'ERRO AO CARREGAR PALAVRA DO DIA: $e',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        carregandoPalavra = false;
        palavraDoDia = null;
      });
    }
  }

  // =============================================================
  // NAVEGAÇÃO INFERIOR
  // =============================================================

  void selecionarNavegacao(int indice) {
    // -----------------------------------------------------------
    // HOME
    // -----------------------------------------------------------

    if (indice == 0) {
      setState(() {
        itemSelecionado = 0;
      });

      return;
    }

    // -----------------------------------------------------------
    // HINÁRIO
    // -----------------------------------------------------------

    if (indice == 1) {
      setState(() {
        itemSelecionado = 1;
      });

      Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (context) => const IdiomasTela(),
        ),
      ).then((_) {
        if (!mounted) {
          return;
        }

        setState(() {
          itemSelecionado = 0;
        });
      });

      return;
    }

    // -----------------------------------------------------------
    // BÍBLIA
    // -----------------------------------------------------------

    if (indice == 2) {
      setState(() {
        itemSelecionado = 2;
      });

      Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (context) => const BibliaTela(),
        ),
      ).then((_) {
        if (!mounted) {
          return;
        }

        setState(() {
          itemSelecionado = 0;
        });
      });

      return;
    }

    // -----------------------------------------------------------
    // INFORMAÇÕES DA IECA
    // -----------------------------------------------------------

    if (indice == 3) {
      setState(() {
        itemSelecionado = 3;
      });

      Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (context) => const InformacoesIecaTela(),
        ),
      ).then((_) {
        if (!mounted) {
          return;
        }

        setState(() {
          itemSelecionado = 0;
        });
      });

      return;
    }

    // -----------------------------------------------------------
    // SOBRE
    // -----------------------------------------------------------

    if (indice == 4) {
      setState(() {
        itemSelecionado = 4;
      });

      Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (context) => const SobreTela(),
        ),
      ).then((_) {
        if (!mounted) {
          return;
        }

        setState(() {
          itemSelecionado = 0;
        });
      });

      return;
    }
  }

  // =============================================================
  // BUILD
  // =============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TemaHinario.corSuperficie,

      // =========================================================
      // CABEÇALHO
      // =========================================================

      appBar: const CabecalhoIeca(),

      // =========================================================
      // CORPO
      // =========================================================

      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              24,
              0,
              24,
              96,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  _construirSaudacao(),

                  const SizedBox(height: 24),

                  _construirHinoDoDia(),

                  const SizedBox(height: 24),

                  _construirAcessosRapidos(),

                  const SizedBox(height: 24),

                  _construirAcoesPrincipais(),

                  const SizedBox(height: 24),

                  _construirPalavraDoDia(),
                ],
              ),
            ),
          ),
        ],
      ),

      // =========================================================
      // NAVEGAÇÃO INFERIOR
      // =========================================================

      bottomNavigationBar: NavegacaoInferiorIeca(
        indiceSelecionado: itemSelecionado,
        onDestinationSelected: selecionarNavegacao,
      ),
    );
  }

  // =============================================================
  // SAUDAÇÃO
  // =============================================================

  Widget _construirSaudacao() {
    final hora = DateTime.now().hour;

    String saudacao;
    IconData icone;

    if (hora >= 5 && hora < 12) {
      saudacao = 'BOM DIA, IRMÃO/Ã';
      icone = Icons.wb_sunny_outlined;
    } else if (hora >= 12 && hora < 18) {
      saudacao = 'BOA TARDE, IRMÃO/Ã';
      icone = Icons.wb_twilight;
    } else {
      saudacao = 'BOA NOITE, IRMÃO/Ã';
      icone = Icons.nights_stay_outlined;
    }

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icone,
                size: 14,
                color: TemaHinario.corPrimaria,
              ),
              const SizedBox(width: 6),
              Text(
                saudacao,
                style: const TextStyle(
                  fontSize: 12,
                  height: 16 / 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.96,
                  color: TemaHinario.corPrimaria,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          const Text(
            'IECA para Cristo,\nCristo para todos!',
            style: TextStyle(
              fontSize: 26,
              height: 32 / 26,
              fontWeight: FontWeight.w700,
              color: TemaHinario.corTexto,
            ),
          ),
        ],
      ),
    );
  }

  // =============================================================
  // HINO DO DIA
  // =============================================================

  Widget _construirHinoDoDia() {
    if (carregandoHino) {
      return Container(
        height: 180,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(),
      );
    }

    if (hinoDoDia == null) {
      return const SizedBox();
    }

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        minHeight: 180,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: TemaHinario.corSuperficieAlta,
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0x1A9E0027),
                    Color(0x00FFFFFF),
                  ],
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'HINO DO DIA',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.96,
                              color:
                                  TemaHinario.corPrimaria,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            hinoDoDia!.titulo,
                            maxLines: 2,
                            overflow:
                                TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: TemaHinario.corTexto,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 16),

                    Container(
                      width: 48,
                      height: 48,
                      decoration:
                          const BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            TemaHinario.corPrimaria,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        hinoDoDia!.numero.toString(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                _botaoPrimario(
                  icone: Icons.menu_book_outlined,
                  texto: 'Cantar Agora',
                  aoPressionar: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            LeituraTela(
                          hino: hinoDoDia!,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =============================================================
  // BOTÃO PRIMÁRIO
  // =============================================================

  Widget _botaoPrimario({
    required IconData icone,
    required String texto,
    required VoidCallback aoPressionar,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: aoPressionar,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 11,
          ),
          decoration: BoxDecoration(
            color: TemaHinario.corPrimaria,
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: TemaHinario.corPrimaria.withValues(alpha: 0.30),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icone,
                size: 18,
                color: Colors.white,
              ),

              const SizedBox(width: 8),

              Text(
                texto,
                style: const TextStyle(
                  fontSize: 13,
                  height: 16 / 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =============================================================
  // ACESSOS RÁPIDOS
  // =============================================================

  Widget _construirAcessosRapidos() {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
      children: [
        // ---------------------------------------------------------
        // FAVORITOS
        // ---------------------------------------------------------

        _atalho(
          icone: Icons.favorite,
          texto: 'Favoritos',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (context) =>
                    const FavoritosTela(),
              ),
            );
          },
        ),

        // ---------------------------------------------------------
        // MARCADOS
        // ---------------------------------------------------------

        _atalho(
          icone: Icons.bookmark,
          texto: 'Marcados',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (context) =>
                    const MarcadosTela(),
              ),
            );
          },
        ),

        // ---------------------------------------------------------
        // PROGRAMAS
        // ---------------------------------------------------------

        _atalho(
          icone: Icons.event_note,
          texto: 'Acessar\nProgramas',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (context) =>
                    const MeusProgramasTela(),
              ),
            );
          },
        ),

        // ---------------------------------------------------------
        // MINHA CONSTÂNCIA
        // ---------------------------------------------------------

        _atalho(
          icone: Icons.local_fire_department_outlined,
          texto: 'Minha\nConstância',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (context) =>
                    const MinhaConstanciaTela(),
              ),
            );
          },
        ),
      ],
    );
  }

  // =============================================================
  // ATALHO
  // =============================================================

  Widget _atalho({
    required IconData icone,
    required String texto,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap ??
              () {
                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  SnackBar(
                    content: Text(
                      '$texto será implementado.',
                    ),
                  ),
                );
              },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color:
                        TemaHinario.corSuperficieMedia,
                    borderRadius:
                        BorderRadius.circular(18),
                    border: Border.all(
                      color: TemaHinario.corPrimaria
                          .withValues(alpha: 0.10),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0A000000),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    icone,
                    size: 24,
                    color: TemaHinario.corPrimaria,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  texto,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 10,
                    height: 14 / 10,
                    fontWeight: FontWeight.w600,
                    color: TemaHinario.corTexto,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =============================================================
  // AÇÕES PRINCIPAIS
  // =============================================================

  Widget _construirAcoesPrincipais() {
    return Column(
      children: [
        // ---------------------------------------------------------
        // HINÁRIO
        // ---------------------------------------------------------

        _cartaoAcao(
          titulo: 'Hinário',
          descricao: 'Acessar todos os hinos',
          icone: Icons.menu_book,
          corFundo: TemaHinario.corSecundariaContainer,
          corTexto: const Color(0xFF684100),
          aoPressionar: () {
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (context) => const IdiomasTela(),
              ),
            );
          },
        ),

        const SizedBox(height: 16),

        // ---------------------------------------------------------
        // BÍBLIA
        // ---------------------------------------------------------

        _cartaoAcao(
          titulo: 'Bíblia',
          descricao: 'Ler a Palavra de Deus',
          icone: Icons.menu_book_outlined,
          corFundo: TemaHinario.corPrimaria,
          corTexto: Colors.white,
          aoPressionar: () {
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (context) => const BibliaTela(),
              ),
            );
          },
        ),

        const SizedBox(height: 16),

        // ---------------------------------------------------------
        // LECIONÁRIO
        // ---------------------------------------------------------

        _cartaoAcao(
            titulo: 'Lecionário',
            descricao: 'Guia para elaboração dos Cultos',
            icone: Icons.auto_stories,
            corFundo: const Color(0xFF6A4C93),
            corTexto: Colors.white,
            aoPressionar: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (context) => const LecionarioScreen(),
                ),
              );
            },
          ),

        const SizedBox(height: 16),

        // ---------------------------------------------------------
        // CRIAR PROGRAMA
        // ---------------------------------------------------------

        _cartaoAcao(
          titulo: 'Criar Programa do Culto',
          descricao: 'Preparar culto litúrgico',
          icone: Icons.add,
          corFundo: TemaHinario.corTerciariaContainer,
          corTexto: Colors.white,
          aoPressionar: () {
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (context) => const CriarProgramaTela(),
              ),
            );
          },
        ),
      ],
    );
  }

  // =============================================================
  // CARTÃO DE AÇÃO
  // =============================================================

  Widget _cartaoAcao({
    required String titulo,
    required String descricao,
    required IconData icone,
    required Color corFundo,
    required Color corTexto,
    VoidCallback? aoPressionar,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: aoPressionar ??
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$titulo será implementado.'),
                ),
              );
            },
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(
            minHeight: 96,
          ),
          padding: const EdgeInsets.all(20),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: corFundo,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: corFundo.withValues(alpha: 0.30),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              // ---------------------------------------------------
              // ÍCONE DECORATIVO
              // ---------------------------------------------------

              Positioned(
                right: -18,
                bottom: -28,
                child: Icon(
                  icone,
                  size: 120,
                  color: Colors.black.withValues(alpha: 0.10),
                ),
              ),

              // ---------------------------------------------------
              // CONTEÚDO
              // ---------------------------------------------------

              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withValues(alpha: 0.08),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      icone,
                      size: 28,
                      color: corTexto,
                    ),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          titulo,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 20,
                            height: 24 / 20,
                            fontWeight: FontWeight.w700,
                            color: corTexto,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          descricao,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            height: 20 / 13,
                            fontWeight: FontWeight.w500,
                            color: corTexto.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ---------------------------------------------------
                  // SETA
                  // ---------------------------------------------------

                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: corTexto.withValues(alpha: 0.6),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =============================================================
  // PALAVRA DO DIA
  // =============================================================

  Widget _construirPalavraDoDia() {
    if (carregandoPalavra) {
      return Container(
        height: 180,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: TemaHinario.corSuperficieAlta,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: const CircularProgressIndicator(),
      );
    }

    if (palavraDoDia == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        minHeight: 180,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: TemaHinario.corSuperficieAlta,
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // =====================================================
          // FUNDO DECORATIVO
          // =====================================================

          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0x1A9E0027),
                    Color(0x00FFFFFF),
                  ],
                ),
              ),
            ),
          ),

          // =====================================================
          // ÍCONE DECORATIVO
          // =====================================================

          Positioned(
            right: -8,
            bottom: -12,
            child: Icon(
              Icons.auto_stories,
              size: 110,
              color: TemaHinario.corTexto.withValues(
                alpha: 0.05,
              ),
            ),
          ),

          // =====================================================
          // CONTEÚDO
          // =====================================================

          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'PALAVRA DO DIA',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.96,
                              color:
                                  TemaHinario.corPrimaria,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            palavraDoDia!.referencia,
                            maxLines: 2,
                            overflow:
                                TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 24,
                              height: 30 / 24,
                              fontWeight: FontWeight.w700,
                              color: TemaHinario.corTexto,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 16),

                    Container(
                      width: 48,
                      height: 48,
                      decoration:
                          const BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            TemaHinario.corPrimaria,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.auto_stories,
                        size: 23,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                _construirVersiculosPalavraDoDia(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =============================================================
  // SEPARAR VERSÍCULOS DA PALAVRA DO DIA
  // =============================================================

  Widget _construirVersiculosPalavraDoDia() {
    final texto = palavraDoDia!.texto.trim();

    if (texto.isEmpty) {
      return const SizedBox.shrink();
    }

    final linhas = texto
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .split('\n')
        .map((linha) => linha.trim())
        .where((linha) => linha.isNotEmpty)
        .toList();

    final versiculos = <_VersiculoExibicao>[];

    for (final linha in linhas) {
      final correspondencia = RegExp(
        r'^(\d{1,3})[\.\)\-:\s]+(.+)$',
      ).firstMatch(linha);

      if (correspondencia != null) {
        final numero = correspondencia.group(1);
        final conteudo = correspondencia.group(2)?.trim();

        if (numero != null &&
            conteudo != null &&
            conteudo.isNotEmpty) {
          versiculos.add(
            _VersiculoExibicao(
              numero: numero,
              texto: conteudo,
            ),
          );
        }
      }
    }

    if (versiculos.isEmpty) {
      return Text(
        '"$texto"',
        style: const TextStyle(
          fontSize: 18,
          height: 1.7,
          fontStyle: FontStyle.italic,
          color: TemaHinario.corTexto,
        ),
      );
    }

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < versiculos.length; i++)
          Padding(
            padding: EdgeInsets.only(
              bottom:
                  i == versiculos.length - 1 ? 0 : 14,
            ),
            child: _construirVersiculo(
              versiculos[i],
            ),
          ),
      ],
    );
  }

  // =============================================================
  // VERSÍCULO INDIVIDUAL
  // =============================================================

  Widget _construirVersiculo(
    _VersiculoExibicao versiculo,
  ) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '${versiculo.numero} ',
            style: const TextStyle(
              fontSize: 13,
              height: 1.7,
              fontWeight: FontWeight.w700,
              color: TemaHinario.corPrimaria,
            ),
          ),
          TextSpan(
            text: versiculo.texto,
            style: const TextStyle(
              fontSize: 18,
              height: 1.7,
              fontStyle: FontStyle.italic,
              color: TemaHinario.corTexto,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.left,
    );
  }
}

// =================================================================
// MODELO AUXILIAR PARA EXIBIÇÃO DOS VERSÍCULOS
// =================================================================

class _VersiculoExibicao {
  final String numero;
  final String texto;

  const _VersiculoExibicao({
    required this.numero,
    required this.texto,
  });
}