import 'package:flutter/material.dart';

import '../../app/tema.dart';
import '../../componentes/cabecalho_ieca.dart';
import '../../componentes/navegacao_inferior_ieca.dart';
import '../../componentes/referencias_ieca.dart';
import '../../modelos/historia_ieca.dart';
import '../biblia/biblia_tela.dart';
import '../hinario/idiomas_tela.dart';
import '../home/home_tela.dart';
import '../sobre/sobre_tela.dart';

class LeituraHistoriaIecaTela extends StatelessWidget {
  final HistoriaIeca historia;

  const LeituraHistoriaIecaTela({
    super.key,
    required this.historia,
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
        titulo: 'Historial da IECA',
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
            // CABEÇALHO DA LEITURA
            // =================================================

            _CabecalhoHistoria(
              titulo: historia.titulo,
              resumo: historia.resumo,
            ),

            const SizedBox(height: 28),

            // =================================================
            // INDICADOR DE LEITURA
            // =================================================

            const _IndicadorLeitura(),

            const SizedBox(height: 20),

            // =================================================
            // CONTEÚDO DA HISTÓRIA
            // =================================================

            _TextoHistoria(
              texto: historia.texto,
            ),

            const SizedBox(height: 8),

            // =================================================
            // REFERÊNCIAS
            // =================================================

            ReferenciasIeca(
              referencias: historia.referencias,
            ),

            const SizedBox(height: 16),

            // =================================================
            // FINAL
            // =================================================

            const _RodapeHistoria(),
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
// CABEÇALHO DA HISTÓRIA
// =============================================================

class _CabecalhoHistoria extends StatelessWidget {
  final String titulo;
  final String resumo;

  const _CabecalhoHistoria({
    required this.titulo,
    required this.resumo,
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
          // Ícone decorativo grande de fundo
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              Icons.menu_book_rounded,
              size: 140,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.history_edu_rounded,
                        color: Colors.white,
                        size: 27,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'HISTÓRIA',
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

                const SizedBox(height: 20),

                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 24,
                    height: 1.2,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  resumo,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.55,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.92),
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
// TEXTO DA HISTÓRIA
// =============================================================

class _TextoHistoria extends StatelessWidget {
  final String texto;

  const _TextoHistoria({
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
                      color: TemaHinario.corPrimaria.withValues(
                        alpha: 0.18,
                      ),
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
// RODAPÉ DA HISTÓRIA
// =============================================================

class _RodapeHistoria extends StatelessWidget {
  const _RodapeHistoria();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 20,
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
            child: const Icon(
              Icons.church_outlined,
              color: TemaHinario.corPrimaria,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'Conhecer a nossa história também é preservar a memória da Igreja.',
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