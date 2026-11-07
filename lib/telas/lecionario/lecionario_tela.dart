import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/tema.dart';
import '../../componentes/cabecalho_ieca.dart';
import '../../componentes/navegacao_inferior_ieca.dart';
import '../../modelos/lecionario_modelo.dart';
import '../../servicos/lecionario_servico.dart';
import 'leitura_dia_tela.dart';
import 'sobre_lecionario_tela.dart';

import '../hinario/idiomas_tela.dart';
import '../sobre/sobre_tela.dart';
import '../biblia/biblia_tela.dart';
import '../informacoes_ieca/informacoes_ieca_tela.dart';

class LecionarioScreen extends StatefulWidget {
  const LecionarioScreen({super.key});

  @override
  State<LecionarioScreen> createState() => _LecionarioScreenState();
}

class _LecionarioScreenState extends State<LecionarioScreen> {
  static const List<String> _mesesDoAno = [
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro',
  ];

  final LecionarioServico _service = LecionarioServico.instancia;

  late int _mesSelecionado;

  int _itemSelecionado = 1;

  @override
  void initState() {
    super.initState();
    _mesSelecionado = DateTime.now().month;
  }

  // =============================================================
  // NAVEGAÇÃO INFERIOR
  // =============================================================

  void _selecionarNavegacao(int indice) {
    if (!mounted) return;

    if (indice == 0) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    }

    Widget? tela;

    switch (indice) {
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
    }

    if (tela == null) return;

    setState(() {
      _itemSelecionado = indice;
    });

    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => tela!,
      ),
    ).then((_) {
      if (!mounted) return;

      setState(() {
        _itemSelecionado = 1;
      });
    });
  }

  // =============================================================
  // SELEÇÃO DO MÊS
  // =============================================================

  Future<void> _selecionarMes() async {
    final resultado = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Escolher mês',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Selecione o mês que deseja consultar.',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: 14),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _mesesDoAno.length,
                    itemBuilder: (context, index) {
                      final numeroMes = index + 1;
                      final selecionado = numeroMes == _mesSelecionado;

                      return ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        leading: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: selecionado
                                ? colorScheme.primary
                                : colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '$numeroMes',
                            style: TextStyle(
                              color: selecionado
                                  ? Colors.white
                                  : colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        title: Text(
                          _mesesDoAno[index],
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 14,
                            fontWeight: selecionado
                                ? FontWeight.w800
                                : FontWeight.w600,
                          ),
                        ),
                        trailing: selecionado
                            ? Icon(
                                Icons.check_circle_rounded,
                                color: colorScheme.primary,
                              )
                            : null,
                        onTap: () {
                          Navigator.pop(context, numeroMes);
                        },
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

    if (!mounted || resultado == null) return;

    setState(() {
      _mesSelecionado = resultado;
    });
  }

  // =============================================================
  // PESQUISA
  // =============================================================

  void _abrirPesquisa() {
    showSearch<void>(
      context: context,
      delegate: _PesquisaLecionarioDelegate(
        service: _service,
        meses: _mesesDoAno,
      ),
    );
  }

  // =============================================================
  // FAVORITOS
  // =============================================================

  Future<void> _abrirFavoritos() async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => _FavoritosTela(
          service: _service,
          meses: _mesesDoAno,
        ),
      ),
    );

    if (!mounted) return;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,

      appBar: CabecalhoIeca(
        titulo: 'Lecionário',
        actions: [
          IconButton(
            tooltip: 'Pesquisar',
            onPressed: _abrirPesquisa,
            icon: const Icon(
              Icons.search_rounded,
              color: TemaHinario.corTexto,
              size: 22,
            ),
          ),
          IconButton(
            tooltip: 'Favoritos',
            onPressed: _abrirFavoritos,
            icon: const Icon(
              Icons.star_outline_rounded,
              color: TemaHinario.corTexto,
              size: 22,
            ),
          ),
          IconButton(
            tooltip: 'Sobre o Lecionário',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => const SobreLecionarioTela(),
                ),
              );
            },
            icon: const Icon(
              Icons.info_outline_rounded,
              color: TemaHinario.corTexto,
              size: 22,
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          const _VersiculoDoAno(),

          const SizedBox(height: 2),

          _SeletorMes(
            nomeMes: _mesesDoAno[_mesSelecionado - 1],
            numeroMes: _mesSelecionado,
            onTap: _selecionarMes,
          ),

          Expanded(
            child: _ConteudoMesView(
              key: ValueKey(_mesSelecionado),
              numeroMes: _mesSelecionado,
              nomeMes: _mesesDoAno[_mesSelecionado - 1],
              service: _service,
            ),
          ),
        ],
      ),

      bottomNavigationBar: NavegacaoInferiorIeca(
        indiceSelecionado: _itemSelecionado,
        onDestinationSelected: _selecionarNavegacao,
      ),
    );
  }
}

// =================================================================
// VERSÍCULO DO ANO
// =================================================================

class _VersiculoDoAno extends StatelessWidget {
  const _VersiculoDoAno();

  static const String _texto =
      'Deixemos todo o embaraço, e o pecado, e corramos, '
      'com paciência, olhando para Jesus.';

  static const String _referencia = 'Hebreus 12:1b-2a';

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary.withOpacity(0.10),
            colorScheme.primary.withOpacity(0.025),
          ],
        ),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.16),
          width: 0.8,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.13),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.format_quote_rounded,
              size: 18,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TEMA DO ANO 2026',
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.7,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '“$_texto”',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 12.5,
                    height: 1.4,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _referencia,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
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

// =================================================================
// SELETOR DO MÊS
// =================================================================

class _SeletorMes extends StatelessWidget {
  final String nomeMes;
  final int numeroMes;
  final VoidCallback onTap;

  const _SeletorMes({
    required this.nomeMes,
    required this.numeroMes,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 11,
          ),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withOpacity(0.55),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: colorScheme.outlineVariant,
              width: 0.7,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(9),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$numeroMes',
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MÊS DO LECIONÁRIO',
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 8.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.7,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      nomeMes,
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =================================================================
// CONTEÚDO DO MÊS
// =================================================================

class _ConteudoMesView extends StatelessWidget {
  final int numeroMes;
  final String nomeMes;
  final LecionarioServico service;

  const _ConteudoMesView({
    super.key,
    required this.numeroMes,
    required this.nomeMes,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<LecionarioMes?>(
      future: service.obterMes(numeroMes),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _EstadoCarregamento();
        }

        if (snapshot.hasError) {
          return _EstadoErro(
            mes: nomeMes,
            erro: snapshot.error,
          );
        }

        final dados = snapshot.data;

        if (dados == null) {
          return _EstadoErro(
            mes: nomeMes,
          );
        }

        return _ConteudoMesCarregado(
          dados: dados,
          nomeMes: nomeMes,
          numeroMes: numeroMes,
          service: service,
        );
      },
    );
  }
}

// =================================================================
// CONTEÚDO CARREGADO
// =================================================================

class _ConteudoMesCarregado extends StatelessWidget {
  final LecionarioMes dados;
  final String nomeMes;
  final int numeroMes;
  final LecionarioServico service;

  const _ConteudoMesCarregado({
    required this.dados,
    required this.nomeMes,
    required this.numeroMes,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    final agora = DateTime.now();

    return RefreshIndicator(
      onRefresh: () async {
        service.limparCache();
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _HojeNoLecionario(
            dados: dados,
            numeroMes: numeroMes,
            nomeMes: nomeMes,
            agora: agora,
          ),

          const SizedBox(height: 12),

          _CabecalhoMes(
            dados: dados,
          ),

          // Aviso de observação (PDF em branco, etc.)
          if (dados.observacao != null &&
              dados.observacao!.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            _AvisoObservacao(texto: dados.observacao!),
          ],

          const SizedBox(height: 12),

          if (dados.introducaoMensal.trim().isNotEmpty)
            _InformacaoRecolhivel(
              titulo: 'Introdução do mês',
              icone: Icons.menu_book_outlined,
              texto: dados.introducaoMensal,
            ),

          if (dados.datasImportantes.isNotEmpty) ...[
            const SizedBox(height: 8),
            _DatasImportantes(
              dados: dados,
            ),
          ],

          const SizedBox(height: 20),

          const _TituloSecao(
            titulo: 'Semanas',
            subtitulo: 'Abra uma semana para ver os dias.',
            icone: Icons.calendar_month_outlined,
          ),

          const SizedBox(height: 10),

          ...dados.semanas.asMap().entries.map(
                (entry) => _CardSemana(
                  semana: entry.value,
                  numeroSemana: entry.key + 1,
                  nomeMes: nomeMes,
                  ano: dados.ano,
                  numeroMes: numeroMes,
                  service: service,
                ),
              ),
        ],
      ),
    );
  }
}

// =================================================================
// AVISO DE OBSERVAÇÃO
// =================================================================

class _AvisoObservacao extends StatelessWidget {
  final String texto;

  const _AvisoObservacao({required this.texto});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.tertiaryContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.tertiary.withOpacity(0.3),
          width: 0.7,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: colorScheme.tertiary,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              texto,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 11.5,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =================================================================
// HOJE NO LECIONÁRIO
// =================================================================

class _HojeNoLecionario extends StatelessWidget {
  final LecionarioMes dados;
  final int numeroMes;
  final String nomeMes;
  final DateTime agora;

  const _HojeNoLecionario({
    required this.dados,
    required this.numeroMes,
    required this.nomeMes,
    required this.agora,
  });

  DiaLecionario? _encontrarDiaAtual() {
    if (numeroMes != agora.month || dados.ano != agora.year) {
      return null;
    }

    for (final semana in dados.semanas) {
      for (final dia in semana.dias) {
        final numeroDia = int.tryParse(
          dia.data.replaceAll(RegExp(r'[^0-9]'), ''),
        );

        if (numeroDia == agora.day) {
          return dia;
        }
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dia = _encontrarDiaAtual();

    if (dia == null) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withOpacity(0.45),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(
              Icons.today_outlined,
              color: colorScheme.primary,
              size: 22,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Consulte o conteúdo de $nomeMes.',
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            colorScheme.primaryContainer,
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.15),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(13),
            ),
            alignment: Alignment.center,
            child: Text(
              '${agora.day}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'HOJE NO LECIONÁRIO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  dia.titulo,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => LeituraDiaTela(
                    dia: dia,
                    mes: nomeMes,
                    ano: dados.ano,
                  ),
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: colorScheme.primary,
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 9,
              ),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Ler',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =================================================================
// CABEÇALHO DO MÊS
// =================================================================

class _CabecalhoMes extends StatelessWidget {
  final LecionarioMes dados;

  const _CabecalhoMes({
    required this.dados,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary,
            colorScheme.primaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.all(17),
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.menu_book_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dados.mes,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Tema do mês',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.72),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  dados.temaMensal.trim().isEmpty
                      ? 'Sem tema definido'
                      : dados.temaMensal,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${dados.ano}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.78),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// =================================================================
// INFORMAÇÃO RECOLHÍVEL
// =================================================================

class _InformacaoRecolhivel extends StatefulWidget {
  final String titulo;
  final IconData icone;
  final String texto;

  const _InformacaoRecolhivel({
    required this.titulo,
    required this.icone,
    required this.texto,
  });

  @override
  State<_InformacaoRecolhivel> createState() =>
      _InformacaoRecolhivelState();
}

class _InformacaoRecolhivelState
    extends State<_InformacaoRecolhivel> {
  bool _aberto = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.38),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.outlineVariant,
          width: 0.6,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              setState(() {
                _aberto = !_aberto;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 13,
                vertical: 11,
              ),
              child: Row(
                children: [
                  Icon(
                    widget.icone,
                    size: 19,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      widget.titulo,
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Icon(
                    _aberto
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
          if (_aberto)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                13,
                0,
                13,
                13,
              ),
              child: Text(
                widget.texto,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 12,
                  height: 1.55,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// =================================================================
// DATAS IMPORTANTES
// =================================================================

class _DatasImportantes extends StatefulWidget {
  final LecionarioMes dados;

  const _DatasImportantes({
    required this.dados,
  });

  @override
  State<_DatasImportantes> createState() =>
      _DatasImportantesState();
}

class _DatasImportantesState
    extends State<_DatasImportantes> {
  bool _aberto = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.38),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.outlineVariant,
          width: 0.6,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              setState(() {
                _aberto = !_aberto;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 13,
                vertical: 11,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.event_note_outlined,
                    size: 19,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      'Datas importantes',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Text(
                      '${widget.dados.datasImportantes.length}',
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _aberto
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
          if (_aberto)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                13,
                0,
                13,
                10,
              ),
              child: Column(
                children: widget.dados.datasImportantes
                    .map(
                      (data) => Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 5,
                        ),
                        child: Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              data.data,
                              style: TextStyle(
                                color: colorScheme.primary,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(width: 9),
                            Expanded(
                              child: Text(
                                data.evento,
                                style: TextStyle(
                                  color:
                                      colorScheme.onSurfaceVariant,
                                  fontSize: 11.5,
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}

// =================================================================
// TÍTULO DE SECÇÃO
// =================================================================

class _TituloSecao extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final IconData icone;

  const _TituloSecao({
    required this.titulo,
    required this.subtitulo,
    required this.icone,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Icon(
            icone,
            size: 19,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitulo,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 10.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// =================================================================
// CARD DA SEMANA
// =================================================================

class _CardSemana extends StatefulWidget {
  final Semana semana;
  final int numeroSemana;
  final String nomeMes;
  final int ano;
  final int numeroMes;
  final LecionarioServico service;

  const _CardSemana({
    required this.semana,
    required this.numeroSemana,
    required this.nomeMes,
    required this.ano,
    required this.numeroMes,
    required this.service,
  });

  @override
  State<_CardSemana> createState() => _CardSemanaState();
}

class _CardSemanaState extends State<_CardSemana> {
  bool _aberta = false;

  int _calcularSemanaAtual() {
    final agora = DateTime.now();

    if (agora.month != widget.numeroMes ||
        agora.year != widget.ano) {
      return -1;
    }

    return ((agora.day - 1) ~/ 7) + 1;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final semanaAtual = _calcularSemanaAtual();
    final isSemanaAtual =
        widget.numeroSemana == semanaAtual;

    final temEventoEspecial =
        widget.semana.eventoEspecial != null &&
            widget.semana.eventoEspecial!.trim().isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isSemanaAtual
              ? colorScheme.primary.withOpacity(0.65)
              : colorScheme.outlineVariant,
          width: isSemanaAtual ? 1.2 : 0.7,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: () {
              setState(() {
                _aberta = !_aberta;
              });
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                12,
                11,
                10,
                11,
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isSemanaAtual
                          ? colorScheme.primary
                          : colorScheme.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${widget.numeroSemana}',
                      style: TextStyle(
                        color: isSemanaAtual
                            ? Colors.white
                            : colorScheme.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                widget.semana.periodo,
                                maxLines: 1,
                                overflow:
                                    TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: colorScheme.onSurface,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            if (isSemanaAtual) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary
                                      .withOpacity(0.10),
                                  borderRadius:
                                      BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'ATUAL',
                                  style: TextStyle(
                                    color:
                                        colorScheme.primary,
                                    fontSize: 8,
                                    fontWeight:
                                        FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          widget.semana.temaSemanal,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color:
                                colorScheme.onSurfaceVariant,
                            fontSize: 11.5,
                            height: 1.35,
                          ),
                        ),
                        // Evento especial da semana
                        if (temEventoEspecial) ...[
                          const SizedBox(height: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.secondaryContainer,
                              borderRadius:
                                  BorderRadius.circular(6),
                            ),
                            child: Text(
                              widget.semana.eventoEspecial!,
                              maxLines: 1,
                              overflow:
                                  TextOverflow.ellipsis,
                              style: TextStyle(
                                color: colorScheme
                                    .onSecondaryContainer,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 4),
                        Text(
                          '${widget.semana.dias.length} ${widget.semana.dias.length == 1 ? 'dia' : 'dias'}',
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    _aberta
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),

          if (_aberta) ...[
            Divider(
              height: 1,
              color: colorScheme.outlineVariant,
            ),

            if (widget.semana.introducaoSemanal != null &&
                widget.semana.introducaoSemanal!
                    .trim()
                    .isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  13,
                  11,
                  13,
                  4,
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest
                        .withOpacity(0.40),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Text(
                    widget.semana.introducaoSemanal!,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 11.5,
                      height: 1.5,
                    ),
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.only(
                top: 5,
                bottom: 7,
              ),
              child: Column(
                children: widget.semana.dias
                    .asMap()
                    .entries
                    .map(
                      (entry) => _ItemDiaLecionario(
                        dia: entry.value,
                        nomeMes: widget.nomeMes,
                        ano: widget.ano,
                        numeroMes: widget.numeroMes,
                        numeroSemana: widget.numeroSemana,
                        numeroDiaNaSemana: entry.key,
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// =================================================================
// ITEM DO DIA
// =================================================================

class _ItemDiaLecionario extends StatefulWidget {
  final DiaLecionario dia;
  final String nomeMes;
  final int ano;
  final int numeroMes;
  final int numeroSemana;
  final int numeroDiaNaSemana;

  const _ItemDiaLecionario({
    required this.dia,
    required this.nomeMes,
    required this.ano,
    required this.numeroMes,
    required this.numeroSemana,
    required this.numeroDiaNaSemana,
  });

  @override
  State<_ItemDiaLecionario> createState() =>
      _ItemDiaLecionarioState();
}

class _ItemDiaLecionarioState
    extends State<_ItemDiaLecionario> {
  bool _favorito = false;
  bool _carregandoFavorito = true;

  String get _chaveFavorito =>
      'lecionario_favorito_${widget.ano}_'
      '${widget.numeroMes}_'
      '${widget.numeroSemana}_'
      '${widget.numeroDiaNaSemana}';

  @override
  void initState() {
    super.initState();
    _carregarFavorito();
  }

  Future<void> _carregarFavorito() async {
    final prefs = await SharedPreferences.getInstance();
    final favorito = prefs.getBool(_chaveFavorito) ?? false;

    if (!mounted) return;

    setState(() {
      _favorito = favorito;
      _carregandoFavorito = false;
    });
  }

  Future<void> _alternarFavorito() async {
    final novoValor = !_favorito;

    setState(() {
      _favorito = novoValor;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_chaveFavorito, novoValor);

    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(milliseconds: 1300),
        content: Text(
          novoValor
              ? 'Adicionado aos favoritos.'
              : 'Removido dos favoritos.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final agora = DateTime.now();
    final numeroDia = int.tryParse(
      widget.dia.data.replaceAll(RegExp(r'[^0-9]'), ''),
    );

    final isHoje = widget.ano == agora.year &&
        widget.numeroMes == agora.month &&
        numeroDia == agora.day;

    final destaque = widget.dia.isDomingo || isHoje;

    final possuiLeituras = _possuiLeituras(widget.dia);
    final possuiLiturgia = widget.dia.liturgia != null;
    final possuiPalavras = _possuiPalavras(widget.dia);
    final possuiOracao = widget.dia.possuiOracao;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => LeituraDiaTela(
              dia: widget.dia,
              mes: widget.nomeMes,
              ano: widget.ano,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 5,
          vertical: 2,
        ),
        padding: const EdgeInsets.fromLTRB(
          8,
          10,
          7,
          10,
        ),
        decoration: BoxDecoration(
          color: isHoje
              ? colorScheme.primary.withOpacity(0.06)
              : widget.dia.isDomingo
                  ? colorScheme.primary.withOpacity(0.035)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isHoje
              ? Border.all(
                  color: colorScheme.primary.withOpacity(0.25),
                  width: 0.8,
                )
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _MarcadorDia(
              data: widget.dia.data,
              destaque: destaque,
              hoje: isHoje,
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.dia.evento != null &&
                      widget.dia.evento!.trim().isNotEmpty) ...[
                    _EtiquetaEvento(
                      texto: widget.dia.evento!,
                    ),
                    const SizedBox(height: 4),
                  ],

                  Text(
                    widget.dia.titulo,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 13,
                      height: 1.3,
                      fontWeight: destaque
                          ? FontWeight.w800
                          : FontWeight.w700,
                    ),
                  ),

                  if (_possuiReferenciaPrincipal(widget.dia)) ...[
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.menu_book_outlined,
                          size: 14,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _referenciasPrincipais(widget.dia),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],

                  if (widget.dia.reflexao.trim().isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Text(
                      widget.dia.reflexao,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 11,
                        height: 1.4,
                      ),
                    ),
                  ],

                  // Oração (quando existir)
                  if (possuiOracao) ...[
                    const SizedBox(height: 5),
                    Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.volunteer_activism_outlined,
                          size: 13,
                          color: colorScheme.tertiary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            widget.dia.oracao!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: colorScheme.tertiary,
                              fontSize: 10.5,
                              height: 1.4,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],

                  if (possuiLeituras ||
                      possuiLiturgia ||
                      possuiPalavras ||
                      possuiOracao) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 5,
                      runSpacing: 4,
                      children: [
                        if (possuiLeituras)
                          const _Indicador(
                            icone: Icons.menu_book_outlined,
                            texto: 'Leituras',
                          ),
                        if (possuiLiturgia)
                          const _Indicador(
                            icone: Icons.church_outlined,
                            texto: 'Liturgia',
                          ),
                        if (possuiPalavras)
                          const _Indicador(
                            icone:
                                Icons.record_voice_over_outlined,
                            texto: '7 Palavras',
                          ),
                        if (possuiOracao)
                          const _Indicador(
                            icone: Icons
                                .volunteer_activism_outlined,
                            texto: 'Oração',
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 3),

            Column(
              children: [
                if (!_carregandoFavorito)
                  IconButton(
                    onPressed: _alternarFavorito,
                    tooltip: _favorito
                        ? 'Remover dos favoritos'
                        : 'Adicionar aos favoritos',
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 30,
                      minHeight: 30,
                    ),
                    icon: Icon(
                      _favorito
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      size: 18,
                      color: _favorito
                          ? colorScheme.secondary
                          : colorScheme.onSurfaceVariant
                              .withOpacity(0.65),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    size: 19,
                    color: colorScheme.onSurfaceVariant
                        .withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool _possuiLeituras(DiaLecionario dia) {
    return (dia.textoBiblico != null &&
            dia.textoBiblico!.trim().isNotEmpty) ||
        dia.textosBiblicos.isNotEmpty ||
        (dia.liturgia != null &&
            dia.liturgia!.leiturasBiblicas.isNotEmpty);
  }

  bool _possuiReferenciaPrincipal(DiaLecionario dia) {
    return (dia.textoBiblico != null &&
            dia.textoBiblico!.trim().isNotEmpty) ||
        dia.textosBiblicos.isNotEmpty;
  }

  String _referenciasPrincipais(DiaLecionario dia) {
    if (dia.textoBiblico != null &&
        dia.textoBiblico!.trim().isNotEmpty) {
      return dia.textoBiblico!;
    }

    return dia.textosBiblicos.join(' • ');
  }

  bool _possuiPalavras(DiaLecionario dia) {
    return dia.palavras.isNotEmpty;
  }
}

// =================================================================
// MARCADOR DO DIA
// =================================================================

class _MarcadorDia extends StatelessWidget {
  final String data;
  final bool destaque;
  final bool hoje;

  const _MarcadorDia({
    required this.data,
    required this.destaque,
    required this.hoje,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Container(
          width: 48,
          padding: const EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color: destaque
                ? colorScheme.primary
                : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            data,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: destaque
                  ? Colors.white
                  : colorScheme.onSurfaceVariant,
              fontSize: 9.5,
              height: 1.2,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        if (hoje)
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Text(
              'HOJE',
              style: TextStyle(
                color: colorScheme.primary,
                fontSize: 7.5,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.3,
              ),
            ),
          ),
      ],
    );
  }
}

// =================================================================
// ETIQUETA DE EVENTO
// =================================================================

class _EtiquetaEvento extends StatelessWidget {
  final String texto;

  const _EtiquetaEvento({
    required this.texto,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        texto,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: colorScheme.onSecondaryContainer,
          fontSize: 8.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

// =================================================================
// INDICADOR
// =================================================================

class _Indicador extends StatelessWidget {
  final IconData icone;
  final String texto;

  const _Indicador({
    required this.icone,
    required this.texto,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest
            .withOpacity(0.55),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icone,
            size: 11,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 3),
          Text(
            texto,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 8.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// =================================================================
// PESQUISA
// =================================================================

class _PesquisaLecionarioDelegate extends SearchDelegate<void> {
  final LecionarioServico service;
  final List<String> meses;

  _PesquisaLecionarioDelegate({
    required this.service,
    required this.meses,
  });

  @override
  String get searchFieldLabel => 'Pesquisar no lecionário';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          tooltip: 'Limpar',
          onPressed: () {
            query = '';
          },
          icon: const Icon(Icons.clear_rounded),
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      tooltip: 'Voltar',
      onPressed: () {
        close(context, null);
      },
      icon: const Icon(Icons.arrow_back_rounded),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _ResultadosPesquisaLecionario(
      service: service,
      meses: meses,
      pesquisa: query.trim(),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.trim().isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_rounded,
                size: 46,
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withOpacity(0.45),
              ),
              const SizedBox(height: 12),
              Text(
                'Pesquisar no Lecionário',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Procure por temas, datas, eventos ou referências bíblicas.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 12,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return buildResults(context);
  }
}

// =================================================================
// RESULTADOS DA PESQUISA
// =================================================================

class _ResultadosPesquisaLecionario
    extends StatefulWidget {
  final LecionarioServico service;
  final List<String> meses;
  final String pesquisa;

  const _ResultadosPesquisaLecionario({
    required this.service,
    required this.meses,
    required this.pesquisa,
  });

  @override
  State<_ResultadosPesquisaLecionario> createState() =>
      _ResultadosPesquisaLecionarioState();
}

class _ResultadosPesquisaLecionarioState
    extends State<_ResultadosPesquisaLecionario> {
  late Future<List<_ResultadoPesquisa>> _future;

  @override
  void initState() {
    super.initState();
    _future = _pesquisar();
  }

  Future<List<_ResultadoPesquisa>> _pesquisar() async {
    final resultados = <_ResultadoPesquisa>[];
    final termo = widget.pesquisa.toLowerCase();

    for (int i = 1; i <= widget.meses.length; i++) {
      final mes = await widget.service.obterMes(i);

      if (mes == null) continue;

      for (int semanaIndex = 0;
          semanaIndex < mes.semanas.length;
          semanaIndex++) {
        final semana = mes.semanas[semanaIndex];

        final textoSemana =
            '${semana.periodo} '
            '${semana.temaSemanal} '
            '${semana.eventoEspecial ?? ''} '
            '${semana.introducaoSemanal ?? ''}'
                .toLowerCase();

        if (textoSemana.contains(termo)) {
          resultados.add(
            _ResultadoPesquisa(
              mes: mes,
              semana: semana,
              dia: null,
              numeroMes: i,
              numeroSemana: semanaIndex + 1,
            ),
          );
        }

        for (int diaIndex = 0;
            diaIndex < semana.dias.length;
            diaIndex++) {
          final dia = semana.dias[diaIndex];

          final textoDia =
              '${dia.data} '
              '${dia.titulo} '
              '${dia.evento ?? ''} '
              '${dia.reflexao} '
              '${dia.oracao ?? ''} '
              '${dia.textoBiblico ?? ''} '
              '${dia.textosBiblicos.join(' ')} '
              '${dia.palavras.join(' ')}'
                  .toLowerCase();

          if (textoDia.contains(termo)) {
            resultados.add(
              _ResultadoPesquisa(
                mes: mes,
                semana: semana,
                dia: dia,
                numeroMes: i,
                numeroSemana: semanaIndex + 1,
                numeroDia: diaIndex,
              ),
            );
          }
        }
      }
    }

    return resultados;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return FutureBuilder<List<_ResultadoPesquisa>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const _EstadoCarregamento(
            texto: 'A pesquisar no lecionário...',
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Não foi possível realizar a pesquisa.',
              style: TextStyle(
                color: colorScheme.error,
              ),
            ),
          );
        }

        final resultados = snapshot.data ?? [];

        if (resultados.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off_rounded,
                    size: 48,
                    color: colorScheme.onSurfaceVariant
                        .withOpacity(0.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Nenhum resultado encontrado',
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tenta pesquisar por outra palavra ou referência.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: resultados.length,
          itemBuilder: (context, index) {
            final resultado = resultados[index];

            return _ResultadoPesquisaCard(
              resultado: resultado,
              nomeMes: widget.meses[
                  resultado.numeroMes - 1],
            );
          },
        );
      },
    );
  }
}

class _ResultadoPesquisa {
  final LecionarioMes mes;
  final Semana semana;
  final DiaLecionario? dia;
  final int numeroMes;
  final int numeroSemana;
  final int? numeroDia;

  const _ResultadoPesquisa({
    required this.mes,
    required this.semana,
    required this.dia,
    required this.numeroMes,
    required this.numeroSemana,
    this.numeroDia,
  });
}

class _ResultadoPesquisaCard extends StatelessWidget {
  final _ResultadoPesquisa resultado;
  final String nomeMes;

  const _ResultadoPesquisaCard({
    required this.resultado,
    required this.nomeMes,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final dia = resultado.dia;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.outlineVariant,
          width: 0.7,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 13,
          vertical: 5,
        ),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.09),
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Icon(
            dia != null
                ? Icons.menu_book_outlined
                : Icons.calendar_month_outlined,
            color: colorScheme.primary,
            size: 20,
          ),
        ),
        title: Text(
          dia?.titulo ?? resultado.semana.temaSemanal,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            dia != null
                ? '${dia.data} • $nomeMes'
                : '${resultado.semana.periodo} • $nomeMes',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 10.5,
            ),
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
        ),
        onTap: dia == null
            ? null
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => LeituraDiaTela(
                      dia: dia,
                      mes: nomeMes,
                      ano: resultado.mes.ano,
                    ),
                  ),
                );
              },
      ),
    );
  }
}

// =================================================================
// FAVORITOS
// =================================================================

class _FavoritosTela extends StatefulWidget {
  final LecionarioServico service;
  final List<String> meses;

  const _FavoritosTela({
    required this.service,
    required this.meses,
  });

  @override
  State<_FavoritosTela> createState() => _FavoritosTelaState();
}

class _FavoritosTelaState extends State<_FavoritosTela> {
  late Future<List<_FavoritoLecionario>> _future;

  @override
  void initState() {
    super.initState();
    _future = _carregarFavoritos();
  }

  Future<List<_FavoritoLecionario>> _carregarFavoritos() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritos = <_FavoritoLecionario>[];

    for (int mesIndex = 1;
        mesIndex <= widget.meses.length;
        mesIndex++) {
      final mes = await widget.service.obterMes(mesIndex);

      if (mes == null) continue;

      for (int semanaIndex = 0;
          semanaIndex < mes.semanas.length;
          semanaIndex++) {
        final semana = mes.semanas[semanaIndex];

        for (int diaIndex = 0;
            diaIndex < semana.dias.length;
            diaIndex++) {
          final chave =
              'lecionario_favorito_${mes.ano}_'
              '${mesIndex}_'
              '${semanaIndex + 1}_'
              '$diaIndex';

          if (prefs.getBool(chave) == true) {
            favoritos.add(
              _FavoritoLecionario(
                dia: semana.dias[diaIndex],
                mes: widget.meses[mesIndex - 1],
                ano: mes.ano,
                numeroMes: mesIndex,
                numeroSemana: semanaIndex + 1,
                numeroDia: diaIndex,
              ),
            );
          }
        }
      }
    }

    return favoritos;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Favoritos',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: FutureBuilder<List<_FavoritoLecionario>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const _EstadoCarregamento(
              texto: 'A carregar favoritos...',
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Não foi possível carregar os favoritos.',
              ),
            );
          }

          final favoritos = snapshot.data ?? [];

          if (favoritos.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.star_outline_rounded,
                      size: 55,
                      color: colorScheme.primary
                          .withOpacity(0.45),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Ainda não tens favoritos',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      'Toca na estrela de um dia para guardá-lo aqui.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 12,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: favoritos.length,
            itemBuilder: (context, index) {
              final favorito = favoritos[index];

              return Container(
                margin: const EdgeInsets.only(bottom: 9),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: colorScheme.outlineVariant,
                    width: 0.7,
                  ),
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 4,
                  ),
                  leading: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color:
                          colorScheme.primary.withOpacity(0.09),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.star_rounded,
                      color: colorScheme.secondary,
                      size: 21,
                    ),
                  ),
                  title: Text(
                    favorito.dia.titulo,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '${favorito.dia.data} • ${favorito.mes}',
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 10.5,
                      ),
                    ),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => LeituraDiaTela(
                          dia: favorito.dia,
                          mes: favorito.mes,
                          ano: favorito.ano,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _FavoritoLecionario {
  final DiaLecionario dia;
  final String mes;
  final int ano;
  final int numeroMes;
  final int numeroSemana;
  final int numeroDia;

  const _FavoritoLecionario({
    required this.dia,
    required this.mes,
    required this.ano,
    required this.numeroMes,
    required this.numeroSemana,
    required this.numeroDia,
  });
}

// =================================================================
// ESTADO DE CARREGAMENTO
// =================================================================

class _EstadoCarregamento extends StatelessWidget {
  final String texto;

  const _EstadoCarregamento({
    this.texto = 'A carregar o lecionário...',
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 29,
            height: 29,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 13),
          Text(
            texto,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }
}

// =================================================================
// ESTADO DE ERRO
// =================================================================

class _EstadoErro extends StatelessWidget {
  final String mes;
  final Object? erro;

  const _EstadoErro({
    required this.mes,
    this.erro,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: colorScheme.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.menu_book_outlined,
                size: 29,
                color: colorScheme.onErrorContainer,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              'Não foi possível carregar o lecionário',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Verifica os dados do mês de $mes e tenta novamente.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 12,
                height: 1.4,
              ),
            ),
            if (erro != null) ...[
              const SizedBox(height: 9),
              Text(
                erro.toString(),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colorScheme.error,
                  fontSize: 9.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}