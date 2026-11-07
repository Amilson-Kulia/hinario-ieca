import 'package:flutter/material.dart';

import '../../app/tema.dart';
import '../../componentes/cabecalho_ieca.dart';
import '../../componentes/navegacao_inferior_ieca.dart';
import '../../componentes/referencias_ieca.dart';
import '../../modelos/missao_ieca.dart';
import '../biblia/biblia_tela.dart';
import '../hinario/idiomas_tela.dart';
import '../home/home_tela.dart';
import '../sobre/sobre_tela.dart';

class LeituraMissaoIecaTela extends StatelessWidget {
  final MissaoIeca missao;

  const LeituraMissaoIecaTela({
    super.key,
    required this.missao,
  });

  void _navegar(
    BuildContext context,
    int indice,
  ) {
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

      // =====================================================
      // CABEÇALHO
      // =====================================================

      appBar: const CabecalhoIeca(
        titulo: 'Informações da IECA',
      ),

      // =====================================================
      // CONTEÚDO
      // =====================================================

      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          20,
          20,
          20,
          32,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =================================================
            // IMAGEM COM OVERLAY
            // =================================================

            if (missao.imagem != null) ...[
              _ImagemMissao(
                imagem: missao.imagem!,
                localizacao: missao.localizacao,
              ),
              const SizedBox(height: 24),
            ],

            // =================================================
            // CABEÇALHO
            // =================================================

            _CabecalhoMissao(
              titulo: missao.titulo,
              nomeAlternativo: missao.nomeAlternativo,
            ),

            const SizedBox(height: 22),

            // =================================================
            // INFORMAÇÕES
            // =================================================

            _InformacoesMissao(
              localizacao: missao.localizacao,
              dataFundacao: missao.dataFundacao,
            ),

            const SizedBox(height: 26),

            // =================================================
            // RESUMO
            // =================================================

            _CardResumo(
              texto: missao.resumo,
            ),

            const SizedBox(height: 28),

            // =================================================
            // INDICADOR DE LEITURA
            // =================================================

            const _IndicadorLeitura(),

            const SizedBox(height: 20),

            // =================================================
            // CONTEÚDO
            // =================================================

            _TextoMissao(
              texto: missao.texto,
            ),

            const SizedBox(height: 8),

            // =================================================
            // CURIOSIDADE
            // =================================================

            _CardSabiasQue(
              texto: missao.curiosidade,
            ),

            const SizedBox(height: 4),

            // =================================================
            // REFERÊNCIAS
            // =================================================

            ReferenciasIeca(
              referencias: missao.referencias,
            ),

            const SizedBox(height: 24),

            // =================================================
            // RODAPÉ DA LEITURA
            // =================================================

            const _RodapeMissao(),
          ],
        ),
      ),

      // =====================================================
      // RODAPÉ / NAVEGAÇÃO
      // =====================================================

      bottomNavigationBar: NavegacaoInferiorIeca(
        indiceSelecionado: 3,
        onDestinationSelected: (indice) {
          _navegar(context, indice);
        },
      ),
    );
  }
}

// =============================================================
// IMAGEM DA MISSÃO (com overlay + badge de localização)
// =============================================================

class _ImagemMissao extends StatelessWidget {
  final String imagem;
  final String localizacao;

  const _ImagemMissao({
    required this.imagem,
    required this.localizacao,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        children: [
          Image.asset(
            imagem,
            width: double.infinity,
            height: 240,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const SizedBox.shrink();
            },
          ),

          // Overlay escuro no fundo
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    TemaHinario.corPrimaria.withValues(alpha: 0.75),
                  ],
                ),
              ),
            ),
          ),

          // Badge de localização por baixo
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: Colors.white,
                        size: 15,
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          localizacao,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
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
// CABEÇALHO DA MISSÃO
// =============================================================

class _CabecalhoMissao extends StatelessWidget {
  final String titulo;
  final String? nomeAlternativo;

  const _CabecalhoMissao({
    required this.titulo,
    required this.nomeAlternativo,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: TemaHinario.corPrimaria.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(15),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.church_rounded,
                color: TemaHinario.corPrimaria,
                size: 27,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'MISSÃO',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                  color: TemaHinario.corPrimaria.withValues(alpha: 0.85),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        Text(
          titulo,
          style: const TextStyle(
            fontSize: 24,
            height: 1.25,
            fontWeight: FontWeight.w800,
            color: TemaHinario.corTexto,
          ),
        ),

        if (nomeAlternativo != null) ...[
          const SizedBox(height: 8),
          Text(
            nomeAlternativo!,
            style: const TextStyle(
              fontSize: 14,
              height: 1.45,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w500,
              color: TemaHinario.corTextoSecundario,
            ),
          ),
        ],
      ],
    );
  }
}

// =============================================================
// INFORMAÇÕES DA MISSÃO
// =============================================================

class _InformacoesMissao extends StatelessWidget {
  final String localizacao;
  final String? dataFundacao;

  const _InformacoesMissao({
    required this.localizacao,
    required this.dataFundacao,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: TemaHinario.corSuperficieAlta,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: TemaHinario.corPrimaria.withValues(alpha: 0.10),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: TemaHinario.corPrimaria.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _InformacaoMissao(
            icone: Icons.location_on_outlined,
            titulo: 'Localização',
            valor: localizacao,
          ),

          if (dataFundacao != null) ...[
            const SizedBox(height: 16),
            Divider(
              height: 1,
              color: TemaHinario.corPrimaria.withValues(alpha: 0.10),
            ),
            const SizedBox(height: 16),
            _InformacaoMissao(
              icone: Icons.event_outlined,
              titulo: 'Fundação',
              valor: dataFundacao!,
            ),
          ],
        ],
      ),
    );
  }
}

// =============================================================
// ITEM DE INFORMAÇÃO
// =============================================================

class _InformacaoMissao extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String valor;

  const _InformacaoMissao({
    required this.icone,
    required this.titulo,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
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
          child: Icon(
            icone,
            size: 20,
            color: TemaHinario.corPrimaria,
          ),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: TemaHinario.corTextoSecundario,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                valor,
                style: const TextStyle(
                  fontSize: 14.5,
                  height: 1.4,
                  fontWeight: FontWeight.w700,
                  color: TemaHinario.corTexto,
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
// CARD DE RESUMO
// =============================================================

class _CardResumo extends StatelessWidget {
  final String texto;

  const _CardResumo({
    required this.texto,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            TemaHinario.corPrimaria.withValues(alpha: 0.08),
            TemaHinario.corPrimaria.withValues(alpha: 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: TemaHinario.corPrimaria.withValues(alpha: 0.14),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.format_quote_rounded,
                size: 26,
                color: TemaHinario.corPrimaria,
              ),
              const SizedBox(width: 8),
              Text(
                'RESUMO',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                  color: TemaHinario.corPrimaria,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            texto,
            style: const TextStyle(
              fontSize: 15,
              height: 1.65,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w500,
              color: TemaHinario.corTexto,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================
// INDICADOR DE LEITURA
// =============================================================

class _IndicadorLeitura extends StatelessWidget {
  const _IndicadorLeitura();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: TemaHinario.corPrimaria.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.auto_stories_rounded,
            size: 17,
            color: TemaHinario.corPrimaria,
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Text(
            'Leitura',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: TemaHinario.corTexto,
            ),
          ),
        ),
        Container(
          width: 60,
          height: 1,
          color: TemaHinario.corPrimaria.withValues(alpha: 0.30),
        ),
      ],
    );
  }
}

// =============================================================
// TEXTO DA MISSÃO
// =============================================================

class _TextoMissao extends StatelessWidget {
  final String texto;

  const _TextoMissao({
    required this.texto,
  });

  @override
  Widget build(BuildContext context) {
    final paragrafos = texto
        .split('\n\n')
        .where(
          (paragrafo) => paragrafo.trim().isNotEmpty,
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: paragrafos.asMap().entries.map((entry) {
        final int indice = entry.key;
        final String paragrafo = entry.value.trim();

        return Padding(
          padding: const EdgeInsets.only(bottom: 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // =============================================
              // PARÁGRAFO COM CAPITULAR NO PRIMEIRO
              // =============================================

              if (indice == 0)
                _ParagrafoCapitular(texto: paragrafo)
              else
                Text(
                  paragrafo,
                  textAlign: TextAlign.justify,
                  style: const TextStyle(
                    fontSize: 15.5,
                    height: 1.85,
                    letterSpacing: 0.1,
                    color: TemaHinario.corTexto,
                  ),
                ),

              // =============================================
              // SEPARADOR VISUAL (exceto no último)
              // =============================================

              if (indice < paragrafos.length - 1) ...[
                const SizedBox(height: 16),
                Center(
                  child: Container(
                    width: 40,
                    height: 3,
                    decoration: BoxDecoration(
                      color: TemaHinario.corPrimaria.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }
}

// =============================================================
// PARÁGRAFO COM CAPITULAR
// =============================================================

class _ParagrafoCapitular extends StatelessWidget {
  final String texto;

  const _ParagrafoCapitular({
    required this.texto,
  });

  @override
  Widget build(BuildContext context) {
    if (texto.isEmpty) {
      return const SizedBox.shrink();
    }

    final letraInicial = texto[0];
    final restante = texto.length > 1 ? texto.substring(1) : '';

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: letraInicial,
            style: const TextStyle(
              fontSize: 26,
              height: 1.4,
              fontWeight: FontWeight.w800,
              color: TemaHinario.corPrimaria,
            ),
          ),
          TextSpan(
            text: restante,
            style: const TextStyle(
              fontSize: 15.5,
              height: 1.85,
              letterSpacing: 0.1,
              color: TemaHinario.corTexto,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.justify,
    );
  }
}

// =============================================================
// CARD "SABIAS QUE?"
// =============================================================

class _CardSabiasQue extends StatelessWidget {
  final String texto;

  const _CardSabiasQue({
    required this.texto,
  });

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
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: TemaHinario.corPrimaria.withValues(alpha: 0.22),
            blurRadius: 18,
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
              Icons.lightbulb_outline_rounded,
              size: 130,
              color: Colors.white.withValues(alpha: 0.08),
            ),
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
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(13),
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
                          letterSpacing: 1.0,
                          color: Colors.white.withValues(alpha: 0.92),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  texto,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.65,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.96),
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
// RODAPÉ DA LEITURA
// =============================================================

class _RodapeMissao extends StatelessWidget {
  const _RodapeMissao();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 20,
      ),
      decoration: BoxDecoration(
        color: TemaHinario.corPrimaria.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
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
              Icons.church_outlined,
              color: TemaHinario.corPrimaria,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'Conhecer a missão da IECA é conhecer também parte da sua presença e do seu propósito em Angola.',
              style: TextStyle(
                fontSize: 13.5,
                height: 1.55,
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