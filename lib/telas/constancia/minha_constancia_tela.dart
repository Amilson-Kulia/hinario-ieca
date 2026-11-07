import 'package:flutter/material.dart';

import '../../app/tema.dart';
import '../../componentes/cabecalho_ieca.dart';
import '../../componentes/navegacao_inferior_ieca.dart';
import '../../servicos/constancia_servico.dart';
import '../../servicos/mensagens_constancia.dart';
import '../biblia/biblia_tela.dart';
import '../home/home_tela.dart';
import '../hinario/idiomas_tela.dart';
import '../sobre/sobre_tela.dart';
import '../informacoes_ieca/informacoes_ieca_tela.dart';

class MinhaConstanciaTela extends StatefulWidget { 
  const MinhaConstanciaTela({super.key});

  @override
  State<MinhaConstanciaTela> createState() => _MinhaConstanciaTelaState();
}

class _MinhaConstanciaTelaState extends State<MinhaConstanciaTela> {
  final ConstanciaServico _servico = ConstanciaServico.instancia;

  ResultadoConstancia? _constanciaGeral;
  ResultadoConstancia? _constanciaBiblia;
  ResultadoConstancia? _constanciaHinario;
  ResultadoConstancia? _constanciaLecionario;

  List<int> _marcosAlcancadosGeral = [];
  List<int> _marcosAlcancadosBiblia = [];
  List<int> _marcosAlcancadosHinario = [];
  List<int> _marcosAlcancadosLecionario = [];

  int? _marcoPendente;
  TipoConstancia? _tipoMarcoPendente;

  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarConstancia();
  }

  // =============================================================
  // CARREGAR CONSTÂNCIA (igual)
  // =============================================================
  Future<void> _carregarConstancia() async {
    try {
      final resultados = await Future.wait([
        _servico.obterEstado(TipoConstancia.geral),
        _servico.obterEstado(TipoConstancia.biblia),
        _servico.obterEstado(TipoConstancia.hinario),
        _servico.obterEstado(TipoConstancia.lecionario),

        _servico.obterMarcosAlcancados(TipoConstancia.geral),
        _servico.obterMarcosAlcancados(TipoConstancia.biblia),
        _servico.obterMarcosAlcancados(TipoConstancia.hinario),
        _servico.obterMarcosAlcancados(TipoConstancia.lecionario),

        _servico.obterMarcoPendente(TipoConstancia.geral),
        _servico.obterMarcoPendente(TipoConstancia.biblia),
        _servico.obterMarcoPendente(TipoConstancia.hinario),
        _servico.obterMarcoPendente(TipoConstancia.lecionario),
      ]);

      if (!mounted) return;

      final int? marcoGeral = resultados[8] as int?;
      final int? marcoBiblia = resultados[9] as int?;
      final int? marcoHinario = resultados[10] as int?;
      final int? marcoLecionario = resultados[11] as int?;

      TipoConstancia? tipoPendente;
      int? marcoPendente;

      if (marcoGeral != null) {
        tipoPendente = TipoConstancia.geral;
        marcoPendente = marcoGeral;
      } else if (marcoBiblia != null) {
        tipoPendente = TipoConstancia.biblia;
        marcoPendente = marcoBiblia;
      } else if (marcoHinario != null) {
        tipoPendente = TipoConstancia.hinario;
        marcoPendente = marcoHinario;
      } else if (marcoLecionario != null) {
        tipoPendente = TipoConstancia.lecionario;
        marcoPendente = marcoLecionario;
      }

      setState(() {
        _constanciaGeral = resultados[0] as ResultadoConstancia;
        _constanciaBiblia = resultados[1] as ResultadoConstancia;
        _constanciaHinario = resultados[2] as ResultadoConstancia;
        _constanciaLecionario = resultados[3] as ResultadoConstancia;

        _marcosAlcancadosGeral = resultados[4] as List<int>;
        _marcosAlcancadosBiblia = resultados[5] as List<int>;
        _marcosAlcancadosHinario = resultados[6] as List<int>;
        _marcosAlcancadosLecionario = resultados[7] as List<int>;

        _marcoPendente = marcoPendente;
        _tipoMarcoPendente = tipoPendente;

        _carregando = false;
      });

      if (_marcoPendente != null && _tipoMarcoPendente != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _mostrarReconhecimento(
            _marcoPendente!,
            _tipoMarcoPendente!,
          );
        });
      }
    } catch (e, stackTrace) {
      debugPrint('ERRO AO CARREGAR CONSTÂNCIA: $e');
      debugPrint('$stackTrace');

      if (!mounted) return;
      setState(() => _carregando = false);
    }
  }

  // =============================================================
  // RECONHECIMENTO DE MARCO (igual)
  // =============================================================
  Future<void> _mostrarReconhecimento(
    int marco,
    TipoConstancia tipo,
  ) async {
    final MensagemConstancia mensagem =
        MensagensConstancia.obter(tipo: tipo, marco: marco);

    final bool? resultado = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: TemaHinario.corSuperficieAlta,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
          actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: TemaHinario.corPrimaria,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: TemaHinario.corPrimaria.withValues(alpha: 0.22),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.emoji_events_outlined,
                  color: Colors.white,
                  size: 25,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Parabéns!',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: TemaHinario.corTextoSecundario,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      mensagem.titulo,
                      style: const TextStyle(
                        fontSize: 21,
                        height: 1.2,
                        fontWeight: FontWeight.w700,
                        color: TemaHinario.corTexto,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: TemaHinario.corSuperficieMedia,
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: TemaHinario.corPrimaria.withValues(
                            alpha: 0.10,
                          ),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.local_fire_department_outlined,
                          size: 21,
                          color: TemaHinario.corPrimaria,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '$marco ${marco == 1 ? 'dia' : 'dias'} de constância',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: TemaHinario.corTexto,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  mensagem.mensagem,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.55,
                    fontWeight: FontWeight.w500,
                    color: TemaHinario.corTextoSecundario,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: TemaHinario.corPrimaria.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(19),
                    border: Border.all(
                      color: TemaHinario.corPrimaria.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.format_quote_outlined,
                            size: 20,
                            color: TemaHinario.corPrimaria,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Palavra para a caminhada',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: TemaHinario.corPrimaria,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '“${mensagem.versiculo}”',
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w600,
                          color: TemaHinario.corTexto,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        mensagem.referencia,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: TemaHinario.corTextoSecundario,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  mensagem.encerramento,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    fontWeight: FontWeight.w600,
                    color: TemaHinario.corTexto,
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: FilledButton.styleFrom(
                  backgroundColor: TemaHinario.corPrimaria,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: const Text(
                  'Continuar',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    if (resultado != true || !mounted) return;

    await _servico.reconhecerProximoMarco(tipo);

    if (!mounted) return;

    setState(() {
      _marcoPendente = null;
      _tipoMarcoPendente = null;
    });

    final TipoConstancia? proximoTipo =
        await _obterProximoTipoPendente();

    if (!mounted) return;

    if (proximoTipo != null) {
      final int? proximoMarco =
          await _servico.obterMarcoPendente(proximoTipo);

      if (!mounted) return;

      if (proximoMarco != null) {
        setState(() {
          _marcoPendente = proximoMarco;
          _tipoMarcoPendente = proximoTipo;
        });

        await _mostrarReconhecimento(
          proximoMarco,
          proximoTipo,
        );
        return;
      }
    }

    Navigator.pushReplacementNamed(context, '/home');
  }

  // =============================================================
  // PRÓXIMO MARCO PENDENTE (igual)
  // =============================================================
  Future<TipoConstancia?> _obterProximoTipoPendente() async {
    final int? marcoGeral =
        await _servico.obterMarcoPendente(TipoConstancia.geral);
    if (marcoGeral != null) return TipoConstancia.geral;

    final int? marcoBiblia =
        await _servico.obterMarcoPendente(TipoConstancia.biblia);
    if (marcoBiblia != null) return TipoConstancia.biblia;

    final int? marcoHinario =
        await _servico.obterMarcoPendente(TipoConstancia.hinario);
    if (marcoHinario != null) return TipoConstancia.hinario;

    final int? marcoLecionario =
        await _servico.obterMarcoPendente(TipoConstancia.lecionario);
    if (marcoLecionario != null) return TipoConstancia.lecionario;

    return null;
  } 

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

  // =============================================================
  // BUILD
  // =============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TemaHinario.corSuperficie,
      appBar: const CabecalhoIeca(),
      body: Column(
        children: [
          Expanded(
            child: _carregando
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : RefreshIndicator(
                    color: TemaHinario.corPrimaria,
                    onRefresh: _atualizar,
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(
                            20,
                            24,
                            20,
                            40,
                          ),
                          sliver: SliverList(
                            delegate: SliverChildListDelegate(
                              [
                                _construirIntroducao(),
                                const SizedBox(height: 22),
                                _construirCartaoPrincipal(),
                                const SizedBox(height: 24),
                                _construirResumoAreas(),
                                const SizedBox(height: 24),
                                _construirProximoMarco(),
                                const SizedBox(height: 28),
                                _construirTituloSecao('Marcos alcançados'),
                                const SizedBox(height: 12),
                                _construirMarcos(),
                                const SizedBox(height: 24),
                                _construirMensagemFinal(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          NavegacaoInferiorIeca(
            indiceSelecionado: 1,
            onDestinationSelected: _selecionarNavegacao,
          ),
        ],
      ),
    );
  }

  Future<void> _atualizar() async {
    setState(() => _carregando = true);
    await _carregarConstancia();
  }

  // =============================================================
  // INTRODUÇÃO
  // =============================================================
  Widget _construirIntroducao() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: TemaHinario.corPrimaria.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.local_fire_department_rounded,
                size: 20,
                color: TemaHinario.corPrimaria,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Minha jornada',
                style: TextStyle(
                  fontSize: 27,
                  height: 1.15,
                  fontWeight: FontWeight.w800,
                  color: TemaHinario.corTexto,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          'Acompanhe sua constância na caminhada com a Palavra de Deus, '
          'o Hinário e o Lecionário.',
          style: TextStyle(
            fontSize: 14.5,
            height: 1.55,
            fontWeight: FontWeight.w500,
            color: TemaHinario.corTextoSecundario,
          ),
        ),
      ],
    );
  }

  // =============================================================
  // CARTÃO PRINCIPAL
  // =============================================================
  Widget _construirCartaoPrincipal() {
    final int sequencia = _constanciaGeral?.sequenciaAtual ?? 0;
    final int melhor = _constanciaGeral?.maiorSequencia ?? 0;
    final int total = _constanciaGeral?.totalDias ?? 0;

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
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: TemaHinario.corPrimaria.withValues(alpha: 0.25),
            blurRadius: 24,
            spreadRadius: 1,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Ícone decorativo de fundo
          Positioned(
            right: -30,
            bottom: -30,
            child: Icon(
              Icons.local_fire_department_rounded,
              size: 180,
              color: Colors.white.withValues(alpha: 0.06),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(26),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.local_fire_department_outlined,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Constância geral',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Sua caminhada diária',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                              color: Color(0xD9FFFFFF),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$sequencia',
                      style: const TextStyle(
                        fontSize: 68,
                        height: 0.9,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -2,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        sequencia == 1
                            ? 'dia consecutivo'
                            : 'dias consecutivos',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.90),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'Permaneça firme na caminhada diária com Deus.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.86),
                  ),
                ),
                const SizedBox(height: 26),
                Container(
                  height: 1,
                  color: Colors.white.withValues(alpha: 0.18),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _estatisticaPrincipal(
                        titulo: 'Melhor sequência',
                        valor: '$melhor',
                        icone: Icons.emoji_events_outlined,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 42,
                      color: Colors.white.withValues(alpha: 0.18),
                    ),
                    Expanded(
                      child: _estatisticaPrincipal(
                        titulo: 'Total de dias',
                        valor: '$total',
                        icone: Icons.calendar_today_outlined,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _estatisticaPrincipal({
    required String titulo,
    required String valor,
    required IconData icone,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icone,
              size: 16,
              color: Colors.white.withValues(alpha: 0.75),
            ),
            const SizedBox(width: 6),
            Text(
              valor,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          titulo,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            height: 1.3,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.78),
          ),
        ),
      ],
    );
  }

  // =============================================================
  // RESUMO DAS ÁREAS
  // =============================================================
  Widget _construirResumoAreas() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _construirTituloSecao('Suas áreas'),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _cartaoArea(
                titulo: 'Bíblia',
                icone: Icons.menu_book_outlined,
                cor: TemaHinario.corPrimaria,
                resultado: _constanciaBiblia,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _cartaoArea(
                titulo: 'Hinário',
                icone: Icons.library_music_outlined,
                cor: const Color(0xFFB87A00),
                resultado: _constanciaHinario,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _cartaoArea(
          titulo: 'Lecionário',
          icone: Icons.auto_stories_outlined,
          cor: const Color(0xFF2E7D32),
          resultado: _constanciaLecionario,
        ),
      ],
    );
  }

  // =============================================================
  // CARTÃO DE ÁREA (com cor temática)
  // =============================================================
  Widget _cartaoArea({
    required String titulo,
    required IconData icone,
    required Color cor,
    required ResultadoConstancia? resultado,
  }) {
    final int sequencia = resultado?.sequenciaAtual ?? 0;
    final int melhor = resultado?.maiorSequencia ?? 0;
    final int total = resultado?.totalDias ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: TemaHinario.corSuperficieAlta,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: cor.withValues(alpha: 0.14),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: cor.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: cor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Icon(icone, size: 22, color: cor),
          ),
          const SizedBox(height: 17),
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: TemaHinario.corTexto,
            ),
          ),
          const SizedBox(height: 11),
          Text(
            '$sequencia',
            style: TextStyle(
              fontSize: 34,
              height: 1,
              fontWeight: FontWeight.w800,
              color: cor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            sequencia == 1 ? 'dia consecutivo' : 'dias consecutivos',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: TemaHinario.corTextoSecundario,
            ),
          ),
          const SizedBox(height: 15),
          Container(
            height: 1,
            color: TemaHinario.corTexto.withValues(alpha: 0.06),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _estatisticaArea(titulo: 'Melhor', valor: '$melhor'),
              ),
              Container(
                width: 1,
                height: 26,
                color: TemaHinario.corTexto.withValues(alpha: 0.07),
              ),
              Expanded(
                child: _estatisticaArea(titulo: 'Total', valor: '$total'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _estatisticaArea({
    required String titulo,
    required String valor,
  }) {
    return Column(
      children: [
        Text(
          valor,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: TemaHinario.corTexto,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          titulo,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: TemaHinario.corTextoSecundario,
          ),
        ),
      ],
    );
  }

  // =============================================================
  // PRÓXIMO MARCO
  // =============================================================
  Widget _construirProximoMarco() {
    final int atual = _constanciaGeral?.sequenciaAtual ?? 0;
    final int? proximo = _obterProximoMarcoLocal(atual);

    if (proximo == null) {
      return _construirTodosMarcosAlcancados();
    }

    final int restantes = proximo - atual;
    final double progresso =
        atual <= 0 ? 0 : (atual / proximo).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: TemaHinario.corSuperficieAlta,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: const Color(0xFFB87A00).withValues(alpha: 0.18),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB87A00).withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: TemaHinario.corSecundariaContainer,
                  borderRadius: BorderRadius.circular(15),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.flag_rounded,
                  size: 23,
                  color: Color(0xFF684100),
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Próximo marco',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: TemaHinario.corTexto,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Continue avançando',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: TemaHinario.corTextoSecundario,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: TemaHinario.corSecundariaContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$proximo',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF684100),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'dias',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF684100),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Progresso',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: TemaHinario.corTextoSecundario,
                ),
              ),
              Text(
                '${(progresso * 100).round()}%',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: TemaHinario.corPrimaria,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progresso,
              minHeight: 9,
              backgroundColor: TemaHinario.corSuperficieMedia,
              valueColor: const AlwaysStoppedAnimation<Color>(
                TemaHinario.corPrimaria,
              ),
            ),
          ),
          const SizedBox(height: 13),
          Text(
            restantes == 1
                ? 'Falta apenas 1 dia para alcançar este marco.'
                : 'Faltam $restantes dias para alcançar este marco.',
            style: const TextStyle(
              fontSize: 13,
              height: 1.45,
              fontWeight: FontWeight.w500,
              color: TemaHinario.corTextoSecundario,
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirTodosMarcosAlcancados() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: TemaHinario.corTerciariaContainer,
        borderRadius: BorderRadius.circular(26),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.workspace_premium_outlined,
            size: 32,
            color: Color(0xFF9CF2ED),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Text(
              'Todos os marcos disponíveis foram alcançados.',
              style: TextStyle(
                fontSize: 14,
                height: 1.45,
                fontWeight: FontWeight.w600,
                color: Color(0xFF9CF2ED),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =============================================================
  // TÍTULO DE SECÇÃO
  // =============================================================
  Widget _construirTituloSecao(String titulo) {
    return Text(
      titulo,
      style: const TextStyle(
        fontSize: 19,
        height: 1.2,
        fontWeight: FontWeight.w800,
        color: TemaHinario.corTexto,
      ),
    );
  }

  // =============================================================
  // MARCOS
  // =============================================================
  Widget _construirMarcos() {
    final List<int> marcos = ConstanciaServico.marcos;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: TemaHinario.corSuperficieAlta,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: TemaHinario.corTexto.withValues(alpha: 0.035),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          for (final int marco in marcos)
            _construirMarco(
              marco,
              _marcosAlcancadosGeral.contains(marco),
            ),
        ],
      ),
    );
  }

  Widget _construirMarco(int marco, bool alcancado) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 11,
      ),
      decoration: BoxDecoration(
        gradient: alcancado
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  TemaHinario.corPrimaria,
                  const Color(0xFF6A001A),
                ],
              )
            : null,
        color: alcancado ? null : TemaHinario.corSuperficieMedia,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: alcancado
              ? TemaHinario.corPrimaria
              : TemaHinario.corTexto.withValues(alpha: 0.04),
        ),
        boxShadow: alcancado
            ? [
                BoxShadow(
                  color: TemaHinario.corPrimaria.withValues(alpha: 0.18),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            alcancado
                ? Icons.emoji_events_rounded
                : Icons.lock_outline_rounded,
            size: 16,
            color: alcancado
                ? Colors.white
                : TemaHinario.corTextoSecundario,
          ),
          const SizedBox(width: 7),
          Text(
            '$marco dias',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: alcancado
                  ? Colors.white
                  : TemaHinario.corTextoSecundario,
            ),
          ),
        ],
      ),
    );
  }

  // =============================================================
  // MENSAGEM FINAL
  // =============================================================
  Widget _construirMensagemFinal() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: TemaHinario.corPrimaria.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: TemaHinario.corPrimaria.withValues(alpha: 0.10),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: TemaHinario.corPrimaria.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.favorite_rounded,
              size: 21,
              color: TemaHinario.corPrimaria,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'A constância não é uma competição. '
              'É um convite para permanecer diariamente '
              'na Palavra de Deus e no louvor.',
              style: TextStyle(
                fontSize: 13,
                height: 1.55,
                fontWeight: FontWeight.w500,
                color: TemaHinario.corTextoSecundario,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =============================================================
  // PRÓXIMO MARCO LOCAL (igual)
  // =============================================================
  int? _obterProximoMarcoLocal(int atual) {
    for (final int marco in ConstanciaServico.marcos) {
      if (marco > atual) return marco;
    }
    return null;
  }
}