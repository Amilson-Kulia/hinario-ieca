import 'package:flutter/material.dart';

import '../../app/tema.dart';
import '../../componentes/cabecalho_ieca.dart';
import '../../componentes/navegacao_inferior_ieca.dart';

import '../biblia/biblia_tela.dart';
import '../home/home_tela.dart';
import '../sobre/sobre_tela.dart';
import '../informacoes_ieca/informacoes_ieca_tela.dart';

import 'portugues_tela.dart';
import 'umbundo/umbundo_tela.dart';
import 'kimbundo/kimbundo_tela.dart';
import 'nganguela/nganguela_tela.dart';
import 'cokwe/cokwe_tela.dart';
import 'fiote/fiote_tela.dart';
import 'kikongo/hinos_kikongo_tela.dart';
import 'kwanyama/hinos_kwanyama_tela.dart';

class IdiomasTela extends StatelessWidget {
  const IdiomasTela({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TemaHinario.corSuperficie,

      // =========================================================
      // CABEÇALHO PADRÃO
      // =========================================================

      appBar: const CabecalhoIeca(),

      // =========================================================
      // CORPO DA TELA
      // =========================================================

      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            20,
            24,
            20,
            24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // =================================================
              // TÍTULO
              // =================================================

              const Text(
                'Idiomas',
                style: TextStyle(
                  fontSize: 26,
                  height: 1.23,
                  fontWeight: FontWeight.w700,
                  color: TemaHinario.corTexto,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Selecione o idioma do hinário',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  fontWeight: FontWeight.w400,
                  color: TemaHinario.corTextoSecundario,
                ),
              ),

              const SizedBox(height: 24),

              // =================================================
              // GRID DOS IDIOMAS
              // =================================================

              LayoutBuilder(
                builder: (
                  context,
                  constraints,
                ) {
                  final bool duasColunas =
                      constraints.maxWidth >= 600;

                  final double larguraCard =
                      duasColunas
                          ? (constraints.maxWidth - 16) / 2
                          : constraints.maxWidth;

                  return Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      // =========================================
                      // PORTUGUÊS
                      // =========================================

                      _CardIdioma(
                        largura: larguraCard,
                        nome: 'Português',
                        cor: TemaHinario.corPrimaria,
                        corFundo: TemaHinario.corPrimaria
                            .withValues(
                          alpha: 0.10,
                        ),
                        disponivel: true,
                        aoPressionar: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const PortuguesTela(),
                            ),
                          );
                        },
                      ),

                      // =========================================
                      // UMBUNDO
                      // =========================================

                      _CardIdioma(
                        largura: larguraCard,
                        nome: 'Umbundo',
                        cor: TemaHinario.corTerciaria,
                        corFundo: TemaHinario.corTerciaria
                            .withValues(
                          alpha: 0.10,
                        ),
                        disponivel: true,
                        aoPressionar: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const UmbundoTela(),
                            ),
                          );
                        },
                      ),

                      // =========================================
                      // KIMBUNDO
                      // =========================================

                      _CardIdioma(
                        largura: larguraCard,
                        nome: 'Kimbundo',
                        cor: TemaHinario.corSecundaria,
                        corFundo: TemaHinario.corSecundaria
                            .withValues(
                          alpha: 0.10,
                        ),
                        disponivel: true,
                        aoPressionar: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const KimbundoTela(),
                            ),
                          );
                        },
                      ),

                      // =========================================
                      // NGANGELA
                      // =========================================

                      _CardIdioma(
                        largura: larguraCard,
                        nome: 'Ngangela',
                        cor: TemaHinario.corPrimaria,
                        corFundo: TemaHinario.corPrimaria
                            .withValues(
                          alpha: 0.10,
                        ),
                        disponivel: true,
                        aoPressionar: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const NganguelaTela(),
                            ),
                          );
                        },
                      ),

                      // =========================================
                      // COKWE
                      // =========================================

                      _CardIdioma(
                        largura: larguraCard,
                        nome: 'Cokwe',
                        cor: TemaHinario.corTerciaria,
                        corFundo: TemaHinario.corTerciaria
                            .withValues(
                          alpha: 0.10,
                        ),
                        disponivel: true,
                        aoPressionar: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const CokweTela(),
                            ),
                          );
                        },
                      ),

                      // =========================================
                      // FIOTE
                      // =========================================

                      _CardIdioma(
                        largura: larguraCard,
                        nome: 'Fiote',
                        cor: TemaHinario.corSecundaria,
                        corFundo: TemaHinario.corSecundaria
                            .withValues(
                          alpha: 0.10,
                        ),
                        disponivel: true,
                        aoPressionar: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const FioteTela(),
                            ),
                          );
                        },
                      ),

                      // =========================================
                      // KIKONGO
                      // =========================================

                      _CardIdioma(
                        largura: larguraCard,
                        nome: 'Kikongo',
                        cor: TemaHinario.corPrimaria,
                        corFundo: TemaHinario.corPrimaria.withValues(alpha: 0.10),
                        disponivel: true,
                        aoPressionar: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HinosKikongoTela(),
                            ),
                          );
                        },
                      ),
                      // =========================================
                      // KWANYAMA
                      // =========================================

                     _CardIdioma(
                        largura: larguraCard,
                        nome: 'Kwanyama',
                        cor: TemaHinario.corTerciaria,
                        corFundo: TemaHinario.corTerciaria
                            .withValues(
                          alpha: 0.10,
                        ),
                        disponivel: true,
                        aoPressionar: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HinosKwanyamaTela(),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),

      // =========================================================
      // NAVEGAÇÃO INFERIOR PADRÃO
      //
      // 0 = Home
      // 1 = Hinário
      // 2 = Programa
      // 3 = Bíblia
      // 4 = Sobre
      //
      // Nesta tela:
      // Hinário = ATIVO
      // =========================================================

      bottomNavigationBar: NavegacaoInferiorIeca(
        indiceSelecionado: 1,
        onDestinationSelected: (indice) {
          // -----------------------------------------------------
          // HOME
          // -----------------------------------------------------

          if (indice == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute<void>(
                builder: (context) => const HomeTela(),
              ),
            );

            return;
          }

          // -----------------------------------------------------
          // HINÁRIO
          // -----------------------------------------------------

          if (indice == 1) {
            return;
          }

          // -----------------------------------------------------
          // BIBLIA
          // -----------------------------------------------------

          if (indice == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute<void>(
                builder: (context) =>
                    const BibliaTela(),
              ),
            );

            return;
          }

          // -----------------------------------------------------
          // BÍBLIA
          // -----------------------------------------------------

          if (indice == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute<void>(
                builder: (context) => const InformacoesIecaTela(),
              ),
            );

            return;
          }

          // -----------------------------------------------------
          // SOBRE
          // -----------------------------------------------------

          if (indice == 4) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute<void>(
                builder: (context) => const SobreTela(),
              ),
            );
          }
        },
      ),
    );
  }
}

// =============================================================
// CARD DO IDIOMA
// =============================================================

class _CardIdioma extends StatelessWidget {
  final double largura;
  final String nome;
  final Color cor;
  final Color corFundo;
  final bool disponivel;
  final VoidCallback? aoPressionar;

  const _CardIdioma({
    required this.largura,
    required this.nome,
    required this.cor,
    required this.corFundo,
    required this.disponivel,
    this.aoPressionar,
  });

  // =============================================================
  // ABRIR IDIOMA
  // =============================================================

  void _abrirIdioma(BuildContext context) {
    if (!disponivel) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'O hinário em $nome ainda não está disponível.',
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(
            milliseconds: 1200,
          ),
        ),
      );

      return;
    }

    if (aoPressionar != null) {
      aoPressionar!();
    }
  }

  // =============================================================
  // BUILD
  // =============================================================

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: largura,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _abrirIdioma(context),
          borderRadius: BorderRadius.circular(12),
          splashColor: cor.withValues(
            alpha: 0.08,
          ),
          highlightColor: cor.withValues(
            alpha: 0.04,
          ),
          child: Ink(
            height: 112,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: 0.55,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x08000000),
                  blurRadius: 16,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // =================================================
                // ÍCONE
                // =================================================

                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: corFundo,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.language_rounded,
                    size: 24,
                    color: disponivel
                        ? cor
                        : cor.withValues(
                            alpha: 0.45,
                          ),
                  ),
                ),

                const SizedBox(width: 16),

                // =================================================
                // NOME
                // =================================================

                Expanded(
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        nome,
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 18,
                          height: 1.55,
                          fontWeight: FontWeight.w500,
                          color: disponivel
                              ? TemaHinario.corTexto
                              : TemaHinario.corTexto
                                  .withValues(
                                  alpha: 0.55,
                                ),
                        ),
                      ),

                      if (!disponivel) ...[
                        const SizedBox(height: 2),

                        Text(
                          'Em breve',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: TemaHinario
                                .corTextoSecundario
                                .withValues(
                              alpha: 0.65,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // =================================================
                // SETA
                // =================================================

                Icon(
                  Icons.chevron_right_rounded,
                  size: 26,
                  color: disponivel
                      ? const Color(0x805B4040)
                      : const Color(0x405B4040),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}