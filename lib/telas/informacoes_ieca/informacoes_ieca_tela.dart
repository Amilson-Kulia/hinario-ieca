import 'package:flutter/material.dart';

import '../../app/tema.dart';
import '../../componentes/cabecalho_ieca.dart';
import '../../componentes/navegacao_inferior_ieca.dart';
import '../../modelos/historia_ieca.dart';
import '../../modelos/missao_ieca.dart';
import '../../servicos/informacoes_ieca_servico.dart';
import '../biblia/biblia_tela.dart';
import '../hinario/idiomas_tela.dart';
import '../home/home_tela.dart';
import '../sobre/sobre_tela.dart';
import 'leitura_historia_ieca_tela.dart';
import 'leitura_missao_ieca_tela.dart';

class InformacoesIecaTela extends StatefulWidget {
  const InformacoesIecaTela({super.key});

  @override
  State<InformacoesIecaTela> createState() =>
      _InformacoesIecaTelaState();
}

class _InformacoesIecaTelaState
    extends State<InformacoesIecaTela> {
  final InformacoesIecaServico _servico =
      InformacoesIecaServico.instancia;

  late Future<_DadosInformacoes> _dadosFuture;

  // Índice da missão seleccionada na grelha de números
  int _missaoSelecionada = 0;

  @override
  void initState() {
    super.initState();
    _dadosFuture = _carregarDados();
  }

  Future<_DadosInformacoes> _carregarDados() async {
    final HistoriaIeca historia =
        await _servico.carregarHistoria();

    final MissaoIeca missaoAtual =
        await _servico.obterMissaoAtual();

    final List<MissaoIeca> todasMissoes =
        await _servico.carregarMissoes();

    return _DadosInformacoes(
      historia: historia,
      missaoAtual: missaoAtual,
      todasMissoes: todasMissoes,
    );
  }

  void _recarregar() {
    setState(() {
      _dadosFuture = _carregarDados();
      _missaoSelecionada = 0;
    });
  }

  // =========================================================
  // NAVEGAÇÃO
  // =========================================================

  void _navegar(int indice) {
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
        return;
      case 4:
        destino = const SobreTela();
        break;
      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(
        builder: (_) => destino,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TemaHinario.corSuperficie,

      appBar: const CabecalhoIeca(
        titulo: 'IECA',
      ),

      body: FutureBuilder<_DadosInformacoes>(
        future: _dadosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return _ErroInformacoes(
              onTentarNovamente: _recarregar,
            );
          }

          final _DadosInformacoes? dados = snapshot.data;

          if (dados == null) {
            return _ErroInformacoes(
              onTentarNovamente: _recarregar,
            );
          }

          return RefreshIndicator(
            color: TemaHinario.corPrimaria,
            onRefresh: () async {
              _recarregar();
              await _dadosFuture;
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                20,
                20,
                20,
                32,
              ),
              children: [
                // =================================================
                // CABEÇALHO COMPACTO
                // =================================================

                const _CabecalhoInformacoes(),

                const SizedBox(height: 26),

                // =================================================
                // SECÇÃO HISTÓRIA
                // =================================================

                const _SecaoCabecalho(
                  titulo: 'Conheça a IECA',
                  subtitulo: 'História e raízes',
                  icone: Icons.auto_stories_rounded,
                ),

                const SizedBox(height: 14),

                _CardHistoria(
                  titulo: dados.historia.titulo,
                  resumo: dados.historia.resumo,
                  onLerMais: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            LeituraHistoriaIecaTela(
                          historia: dados.historia,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 30),

                // =================================================
                // CURIOSIDADE ROTATIVA
                // =================================================

                const _SecaoCabecalho(
                  titulo: 'Sabias que?',
                  subtitulo: 'Curiosidades da IECA',
                  icone: Icons.lightbulb_outline_rounded,
                ),

                const SizedBox(height: 14),

                _CardCuriosidade(
                  missao: dados.missaoAtual,
                  onLerMais: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            LeituraMissaoIecaTela(
                          missao: dados.missaoAtual,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 30),

                // =================================================
                // GRELHA DE NÚMEROS + CARD DA MISSÃO SELECIONADA
                // =================================================

                const _SecaoCabecalho(
                  titulo: 'Mais sobre a IECA',
                  subtitulo: 'Escolhe um número para ler',
                  icone: Icons.explore_rounded,
                ),

                const SizedBox(height: 14),

                _SeletorNumerosMissoes(
                  total: dados.todasMissoes.length,
                  selecionado: _missaoSelecionada,
                  onSelecionar: (indice) {
                    setState(() {
                      _missaoSelecionada = indice;
                    });
                  },
                ),

                const SizedBox(height: 14),

                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 280),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (
                    Widget child,
                    Animation<double> animation,
                  ) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.05, 0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: _CardMissaoSelecionada(
                    key: ValueKey<int>(_missaoSelecionada),
                    missao:
                        dados.todasMissoes[_missaoSelecionada],
                    posicao: _missaoSelecionada + 1,
                    total: dados.todasMissoes.length,
                    onLerMais: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              LeituraMissaoIecaTela(
                            missao: dados
                                .todasMissoes[_missaoSelecionada],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 28),

                // =================================================
                // FRASE FINAL
                // =================================================

                const _RodapeInformacoes(),
              ],
            ),
          );
        },
      ),

      bottomNavigationBar: NavegacaoInferiorIeca(
        indiceSelecionado: 3,
        onDestinationSelected: _navegar,
      ),
    );
  }
}

// =============================================================
// DADOS
// =============================================================

class _DadosInformacoes {
  final HistoriaIeca historia;
  final MissaoIeca missaoAtual;
  final List<MissaoIeca> todasMissoes;

  const _DadosInformacoes({
    required this.historia,
    required this.missaoAtual,
    required this.todasMissoes,
  });
}

// =============================================================
// CABEÇALHO INTERNO (mais compacto)
// =============================================================

class _CabecalhoInformacoes extends StatelessWidget {
  const _CabecalhoInformacoes();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            TemaHinario.corPrimaria,
            const Color(0xFF6A001A),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: TemaHinario.corPrimaria.withValues(
              alpha: 0.22,
            ),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              Icons.church_rounded,
              size: 140,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(22),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.church_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'A nossa Igreja',
                        style: TextStyle(
                          fontSize: 21,
                          height: 1.15,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Conhece a IECA, a sua história '
                        'e as suas raízes em Angola.',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(
                            alpha: 0.90,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================
// CABEÇALHO DE SECÇÃO
// =============================================================

class _SecaoCabecalho extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final IconData icone;

  const _SecaoCabecalho({
    required this.titulo,
    required this.subtitulo,
    required this.icone,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: TemaHinario.corPrimaria.withValues(
              alpha: 0.10,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Icon(
            icone,
            size: 20,
            color: TemaHinario.corPrimaria,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 19,
                  height: 1.2,
                  fontWeight: FontWeight.w800,
                  color: TemaHinario.corTexto,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitulo,
                style: const TextStyle(
                  fontSize: 12.5,
                  height: 1.3,
                  fontWeight: FontWeight.w500,
                  color: TemaHinario.corTextoSecundario,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// =============================================================
// CARD HISTÓRIA
// =============================================================

class _CardHistoria extends StatelessWidget {
  final String titulo;
  final String resumo;
  final VoidCallback onLerMais;

  const _CardHistoria({
    required this.titulo,
    required this.resumo,
    required this.onLerMais,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onLerMais,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: TemaHinario.corSuperficieAlta,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: TemaHinario.corPrimaria.withValues(
                alpha: 0.14,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: TemaHinario.corPrimaria.withValues(
                  alpha: 0.06,
                ),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          TemaHinario.corPrimaria,
                          const Color(0xFF6A001A),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: TemaHinario.corPrimaria
                              .withValues(alpha: 0.22),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.menu_book_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      titulo,
                      style: const TextStyle(
                        fontSize: 17,
                        height: 1.3,
                        fontWeight: FontWeight.w800,
                        color: TemaHinario.corTexto,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Text(
                resumo,
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.55,
                  fontWeight: FontWeight.w500,
                  color: TemaHinario.corTextoSecundario,
                ),
              ),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Ler mais',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: TemaHinario.corPrimaria,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: TemaHinario.corPrimaria,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================
// CARD CURIOSIDADE
// =============================================================

class _CardCuriosidade extends StatelessWidget {
  final MissaoIeca missao;
  final VoidCallback onLerMais;

  const _CardCuriosidade({
    required this.missao,
    required this.onLerMais,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onLerMais,
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                TemaHinario.corPrimaria,
                const Color(0xFF6A001A),
              ],
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: TemaHinario.corPrimaria.withValues(
                  alpha: 0.25,
                ),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (missao.imagem != null)
                Stack(
                  children: [
                    Image.asset(
                      missao.imagem!,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (
                        context,
                        error,
                        stackTrace,
                      ) {
                        return const SizedBox.shrink();
                      },
                    ),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              TemaHinario.corPrimaria.withValues(
                                alpha: 0.65,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(
                              alpha: 0.16,
                            ),
                            borderRadius:
                                BorderRadius.circular(13),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.lightbulb_outline_rounded,
                            color: Colors.white,
                            size: 23,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'SABIAS QUE?',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.9,
                              color: Colors.white.withValues(
                                alpha: 0.92,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    Text(
                      missao.titulo,
                      style: const TextStyle(
                        fontSize: 20,
                        height: 1.25,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(
                          alpha: 0.14,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            color: Colors.white70,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              missao.localizacao,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      missao.curiosidade,
                      style: TextStyle(
                        fontSize: 14.5,
                        height: 1.6,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(
                          alpha: 0.94,
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Ler mais',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white.withValues(
                              alpha: 0.95,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 18,
                          color: Colors.white.withValues(
                            alpha: 0.95,
                          ),
                        ),
                      ],
                    ),
                  ],
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
// SELETOR DE NÚMEROS (SCROLL HORIZONTAL MELHORADO)
// =============================================================

class _SeletorNumerosMissoes extends StatefulWidget {
  final int total;
  final int selecionado;
  final ValueChanged<int> onSelecionar;

  const _SeletorNumerosMissoes({
    required this.total,
    required this.selecionado,
    required this.onSelecionar,
  });

  @override
  State<_SeletorNumerosMissoes> createState() =>
      _SeletorNumerosMissoesState();
}

class _SeletorNumerosMissoesState
    extends State<_SeletorNumerosMissoes> {
  late final ScrollController _scrollController;

  static const double _larguraItem = 46;
  static const double _espaco = 8;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    // Garante que o item selecionado fica visível após o primeiro frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _centrarItem(widget.selecionado);
    });
  }

  @override
  void didUpdateWidget(
    covariant _SeletorNumerosMissoes oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.selecionado != widget.selecionado) {
      _centrarItem(widget.selecionado);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _centrarItem(int indice) {
    if (!_scrollController.hasClients) return;

    final double larguraEcra =
        MediaQuery.of(context).size.width;

    final double posicaoCentro =
        indice * (_larguraItem + _espaco) +
        (_larguraItem / 2);

    double destino = posicaoCentro - (larguraEcra / 2);

    destino = destino.clamp(
      _scrollController.position.minScrollExtent,
      _scrollController.position.maxScrollExtent,
    );

    _scrollController.animateTo(
      destino,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  void _avancar() {
    final novo = (widget.selecionado + 1)
        .clamp(0, widget.total - 1);
    widget.onSelecionar(novo);
  }

  void _recuar() {
    final novo = (widget.selecionado - 1)
        .clamp(0, widget.total - 1);
    widget.onSelecionar(novo);
  }

  @override
  Widget build(BuildContext context) {
    final bool mostrarSetas = widget.total > 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            // Botão recuar (desktop-friendly)
            if (mostrarSetas)
              _BotaoSeta(
                icone: Icons.chevron_left_rounded,
                ativo: widget.selecionado > 0,
                onTap: _recuar,
              ),

            const SizedBox(width: 6),

            // Lista com scroll horizontal
            Expanded(
              child: SizedBox(
                height: 52,
                child: Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  thickness: 4,
                  radius: const Radius.circular(4),
                  child: ListView.separated(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 4,
                    ),
                    itemCount: widget.total,
                    separatorBuilder: (_, __) =>
                        const SizedBox(width: _espaco),
                    itemBuilder: (context, indice) {
                      final ativo =
                          indice == widget.selecionado;

                      return _BotaoNumero(
                        numero: indice + 1,
                        ativo: ativo,
                        onTap: () =>
                            widget.onSelecionar(indice),
                      );
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(width: 6),

            // Botão avançar (desktop-friendly)
            if (mostrarSetas)
              _BotaoSeta(
                icone: Icons.chevron_right_rounded,
                ativo: widget.selecionado < widget.total - 1,
                onTap: _avancar,
              ),
          ],
        ),

        const SizedBox(height: 8),

        // Indicador "X de Y"
        Center(
          child: Text(
            '${widget.selecionado + 1} de ${widget.total}',
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
              color: TemaHinario.corTextoSecundario,
            ),
          ),
        ),
      ],
    );
  }
}

// =============================================================
// BOTÃO DE SETA (para navegação no desktop)
// =============================================================

class _BotaoSeta extends StatelessWidget {
  final IconData icone;
  final bool ativo;
  final VoidCallback onTap;

  const _BotaoSeta({
    required this.icone,
    required this.ativo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: ativo ? onTap : null,
        child: Container(
          width: 36,
          height: 44,
          decoration: BoxDecoration(
            color: ativo
                ? TemaHinario.corPrimaria.withValues(alpha: 0.10)
                : TemaHinario.corPrimaria.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: TemaHinario.corPrimaria.withValues(
                alpha: ativo ? 0.20 : 0.08,
              ),
            ),
          ),
          alignment: Alignment.center,
          child: Icon(
            icone,
            size: 22,
            color: ativo
                ? TemaHinario.corPrimaria
                : TemaHinario.corTextoSecundario
                    .withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }
}

// =============================================================
// BOTÃO DE NÚMERO (compacto e elegante)
// =============================================================

class _BotaoNumero extends StatelessWidget {
  final int numero;
  final bool ativo;
  final VoidCallback onTap;

  const _BotaoNumero({
    required this.numero,
    required this.ativo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          width: 46,
          height: 44,
          decoration: BoxDecoration(
            gradient: ativo
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      TemaHinario.corPrimaria,
                      const Color(0xFF6A001A),
                    ],
                  )
                : null,
            color: ativo
                ? null
                : TemaHinario.corSuperficieAlta,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: ativo
                  ? Colors.transparent
                  : TemaHinario.corPrimaria.withValues(
                      alpha: 0.12,
                    ),
              width: 1,
            ),
            boxShadow: ativo
                ? [
                    BoxShadow(
                      color: TemaHinario.corPrimaria
                          .withValues(alpha: 0.28),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            '$numero',
            style: TextStyle(
              fontSize: 15,
              height: 1.0,
              fontWeight: FontWeight.w800,
              color: ativo
                  ? Colors.white
                  : TemaHinario.corTexto,
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================
// CARD DA MISSÃO SELECIONADA
// =============================================================

class _CardMissaoSelecionada extends StatelessWidget {
  final MissaoIeca missao;
  final int posicao;
  final int total;
  final VoidCallback onLerMais;

  const _CardMissaoSelecionada({
    super.key,
    required this.missao,
    required this.posicao,
    required this.total,
    required this.onLerMais,
  });

  @override
  Widget build(BuildContext context) {
    final temImagem =
        missao.imagem != null && missao.imagem!.isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onLerMais,
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: TemaHinario.corSuperficieAlta,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: TemaHinario.corPrimaria.withValues(
                alpha: 0.14,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: TemaHinario.corPrimaria.withValues(
                  alpha: 0.08,
                ),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // =================================================
              // IMAGEM (opcional)
              // =================================================

              if (temImagem)
                Stack(
                  children: [
                    Image.asset(
                      missao.imagem!,
                      width: double.infinity,
                      height: 170,
                      fit: BoxFit.cover,
                      errorBuilder: (
                        context,
                        error,
                        stackTrace,
                      ) {
                        return const SizedBox.shrink();
                      },
                    ),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(
                                alpha: 0.30,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Badge tipo
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: TemaHinario.corPrimaria
                              .withValues(alpha: 0.92),
                          borderRadius:
                              BorderRadius.circular(8),
                        ),
                        child: Text(
                          missao.tipo.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.9,
                          ),
                        ),
                      ),
                    ),

                    // Badge posição (canto superior direito)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(
                            alpha: 0.45,
                          ),
                          borderRadius:
                              BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$posicao / $total',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              else
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    18,
                    16,
                    18,
                    0,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: TemaHinario.corPrimaria
                              .withValues(alpha: 0.10),
                          borderRadius:
                              BorderRadius.circular(8),
                        ),
                        child: Text(
                          missao.tipo.toUpperCase(),
                          style: const TextStyle(
                            color: TemaHinario.corPrimaria,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.9,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: TemaHinario.corPrimaria
                              .withValues(alpha: 0.10),
                          borderRadius:
                              BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$posicao / $total',
                          style: const TextStyle(
                            color: TemaHinario.corPrimaria,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // =================================================
              // CONTEÚDO
              // =================================================

              Padding(
                padding: const EdgeInsets.fromLTRB(
                  18,
                  16,
                  18,
                  16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      missao.titulo,
                      style: const TextStyle(
                        fontSize: 17,
                        height: 1.3,
                        fontWeight: FontWeight.w800,
                        color: TemaHinario.corTexto,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 14,
                                color: TemaHinario
                                    .corTextoSecundario,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  missao.localizacao,
                                  maxLines: 1,
                                  overflow:
                                      TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: TemaHinario
                                        .corTextoSecundario,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (missao.anoFundacao != null) ...[
                          const SizedBox(width: 10),
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_outlined,
                                size: 13,
                                color: TemaHinario
                                    .corTextoSecundario,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${missao.anoFundacao}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: TemaHinario
                                      .corTextoSecundario,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 14),

                    Text(
                      missao.resumo,
                      style: const TextStyle(
                        fontSize: 13.5,
                        height: 1.55,
                        fontWeight: FontWeight.w500,
                        color: TemaHinario.corTextoSecundario,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Ler mais',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: TemaHinario.corPrimaria,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 18,
                          color: TemaHinario.corPrimaria,
                        ),
                      ],
                    ),
                  ],
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
// RODAPÉ DA INFORMAÇÃO
// =============================================================

class _RodapeInformacoes extends StatelessWidget {
  const _RodapeInformacoes();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 18,
      ),
      decoration: BoxDecoration(
        color: TemaHinario.corPrimaria.withValues(
          alpha: 0.06,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: TemaHinario.corPrimaria.withValues(
            alpha: 0.10,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: TemaHinario.corPrimaria.withValues(
                alpha: 0.10,
              ),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.church_outlined,
              color: TemaHinario.corPrimaria,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'IECA para Cristo, Cristo para todos.',
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                fontWeight: FontWeight.w600,
                color: TemaHinario.corTexto,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================
// ERRO
// =============================================================

class _ErroInformacoes extends StatelessWidget {
  final VoidCallback onTentarNovamente;

  const _ErroInformacoes({
    required this.onTentarNovamente,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: TemaHinario.corPrimaria.withValues(
                  alpha: 0.10,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 38,
                color: TemaHinario.corPrimaria,
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'Não foi possível carregar as informações da IECA.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: TemaHinario.corTexto,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Verifique os ficheiros de dados e tente novamente.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.45,
                color: TemaHinario.corTextoSecundario,
              ),
            ),

            const SizedBox(height: 20),

            FilledButton.icon(
              onPressed: onTentarNovamente,
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
}