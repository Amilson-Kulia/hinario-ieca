import 'package:flutter/material.dart';

import '../../../app/tema.dart';
import '../../../componentes/cabecalho_ieca.dart';
import '../../../componentes/navegacao_inferior_ieca.dart';

import 'invocatorias_tela.dart'; 
import 'litanias_tela.dart';
import 'hinos_portugues_tela.dart';
import 'salmos_tela.dart';
import '../leitura_tela.dart';

import '../../home/home_tela.dart';
import '../../biblia/biblia_tela.dart';
import '../../sobre/sobre_tela.dart';
import '../../informacoes_ieca/informacoes_ieca_tela.dart';



class NganguelaTela extends StatelessWidget {
  const NganguelaTela({super.key});

   // =============================================================
  // NAVEGAÇÃO INFERIOR
  // =============================================================

  void _selecionarNavegacao(
  BuildContext context,
  int indice,
) {
  switch (indice) {
    // ---------------------------------------------------------
    // HOME
    // ---------------------------------------------------------
    case 0:
      Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(
          builder: (_) => const HomeTela(),
        ),
      );
      break;

    // ---------------------------------------------------------
    // HINÁRIO
    // ---------------------------------------------------------
    case 1:
      // Já estamos dentro do Hinário.
      break;

    // ---------------------------------------------------------
    // BÍBLIA
    // ---------------------------------------------------------
    case 2:
      Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(
          builder: (_) => const BibliaTela(),
        ),
      );
      break;

    // ---------------------------------------------------------
    // INFORMAÇÕES
    // ---------------------------------------------------------
    case 3:
      Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(
          builder: (_) => const InformacoesIecaTela(),
        ),
      );
      break;

    // ---------------------------------------------------------
    // SOBRE
    // ---------------------------------------------------------
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

      // =========================================================
      // CABEÇALHO PADRÃO IECA
      // =========================================================

      appBar: const CabecalhoIeca(),

      // =========================================================
      // CORPO
      // =========================================================

      body: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(
                  bottom: 40,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    // -------------------------------------------------
                    // CABEÇALHO
                    // -------------------------------------------------

                    _CabecalhoPagina(),

                    // -------------------------------------------------
                    // CARTÃO DE ESTATÍSTICAS
                    // -------------------------------------------------

                    _CartaoEstatisticas(),

                    // -------------------------------------------------
                    // CATEGORIAS
                    // -------------------------------------------------

                    _Categorias(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // =========================================================
      // NAVEGAÇÃO INFERIOR
      // =========================================================

      bottomNavigationBar: NavegacaoInferiorIeca(
        indiceSelecionado: 1,
        onDestinationSelected: (indice) {
          _selecionarNavegacao(
            context,
            indice,
          );
        },
      ),
    );
  }
}

// =============================================================
// CABEÇALHO DA PÁGINA
// =============================================================

class _CabecalhoPagina extends StatelessWidget {
  const _CabecalhoPagina();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        24,
        24,
        24,
        24,
      ),
      decoration: BoxDecoration(
        color: TemaHinario.corSuperficie.withValues(
          alpha: 0.90,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Expanded(
            child: Text(
              'Nganguela',
              style: TextStyle(
                fontSize: 32,
                height: 40 / 32,
                letterSpacing: -0.64,
                fontWeight: FontWeight.w700,
                color: TemaHinario.corTexto,
              ),
            ),
          ),

          const SizedBox(
            width: 16,
          ),

          Icon(
            Icons.translate_rounded,
            size: 28,
            color: TemaHinario.corPrimaria,
          ),
        ],
      ),
    );
  }
}

// =============================================================
// CARTÃO DE ESTATÍSTICAS
// =============================================================

class _CartaoEstatisticas extends StatelessWidget {
  const _CartaoEstatisticas();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        24,
        0,
        24,
        40,
      ),
      child: Container(
        width: double.infinity,
        height: 96,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: TemaHinario.corSuperficieMedia,
          borderRadius: BorderRadius.circular(16),
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
            // ===================================================
            // DECORAÇÃO
            // ===================================================

            Positioned(
              right: -32,
              bottom: -32,
              child: Opacity(
                opacity: 0.10,
                child: Icon(
                  Icons.auto_stories_rounded,
                  size: 120,
                  color: TemaHinario.corPrimaria,
                ),
              ),
            ),

            // ===================================================
            // CONTEÚDO
            // ===================================================

            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // -------------------------------------------------
                  // ÍCONE
                  // -------------------------------------------------

                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: TemaHinario.corPrimariaContainer,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.menu_book_rounded,
                      size: 24,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(
                    width: 16,
                  ),

                  // -------------------------------------------------
                  // TEXTO
                  // -------------------------------------------------

                  const Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Conteúdos da Secção em  NGANGUELA',
                          style: TextStyle(
                            fontSize: 12,
                            height: 16 / 12,
                            letterSpacing: 0.6,
                            fontWeight: FontWeight.w500,
                            color:
                                TemaHinario.corTextoSecundario,
                          ),
                        ),

                        SizedBox(
                          height: 4,
                        ),

                        Text(
                          '107 Elementos',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 18,
                            height: 32 / 18,
                            fontWeight: FontWeight.w600,
                            color: TemaHinario.corTexto,
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
      ),
    );
  }
}

// =============================================================
// CATEGORIAS
// =============================================================

class _Categorias extends StatelessWidget {
  const _Categorias();

  @override
  Widget build(BuildContext context) {
    final List<_Categoria> categorias = [

      // =========================================================
      // INVOCATÓRIAS
      // =========================================================

      _Categoria(
        titulo: 'Invocatórias',
        quantidade: '9 Invocatórias ',
        icone: Icons.wb_sunny_rounded,
        tipoCor: _TipoCor.secundaria,
        disponivel: true,
        aoPressionar: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const InvocatoriasTela(),
            ),
          );
        },
      ),

      // =========================================================
      // MITAMBI
      // =========================================================

      _Categoria(
        titulo: 'Hinos',
        quantidade: '85 Hinos',
        icone: Icons.music_note_rounded,
        tipoCor: _TipoCor.primaria,
        disponivel: true,
        aoPressionar: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const HinosPortuguesTela(),
            ),
          );
        },
      ),

      // =========================================================
      // NOHA
      // =========================================================

      _Categoria(
        titulo: 'Litanias',
        quantidade: '6 Litanias',
        icone: Icons.format_list_bulleted_rounded,
        tipoCor: _TipoCor.terciaria,
        disponivel: true,
        aoPressionar: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const LitaniasTela(),
            ),
          );
        },
      ),

      // =========================================================
      // MIASO
      // =========================================================

      _Categoria(
        titulo: 'Salmos',
        quantidade: '6 Salmos',
        icone: Icons.auto_awesome_rounded,
        tipoCor: _TipoCor.secundaria,
        disponivel: true,
        aoPressionar: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const SalmosTela(),
            ),
          );
        },
      ),

      // =========================================================
      // ORAÇÃO DO SENHOR
      // =========================================================

      _Categoria(
        titulo: 'Oração do Senhor',
        quantidade: 'Oração do Senhor',
        icone: Icons.volunteer_activism_rounded,
        tipoCor: _TipoCor.primaria,
        disponivel: true,
        aoPressionar: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const LeituraTela(
                titulo: 'Oração do Senhor',
                subtitulo: 'Oração do Senhor — adaptação em Nganguela',
                icone: Icons.volunteer_activism_rounded,
                textoLivre: '''
Tata yetu, u li ku mwilu,

Lizana lyove li lemeswe.

Vunanga vuove vuize.

Kusua kwove ku lingwe
mu mavu ngana mu mwilu.

Tu pe lelo ciakulya cietu ca lusuku.

Tu lekelele mizhimo yetu,
ngana netu tu lekelela vaze va tu zhimile.

Kati tu tuale mu ku lingiwa,

kaha tu kuluule ku vubi.

Muomu vunanga vuove,
na ngolo,
na kasingimiko,
vi li kuove
ku myaka yose.

Amen.
''',
              ),
            ),
          );
        },
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        24,
        0,
        24,
        40,
      ),
      child: Container(
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0x4DE3BEBD),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: List.generate(
            categorias.length,
            (index) {
              final _Categoria categoria =
                  categorias[index];

              return Column(
                children: [
                  _ItemCategoria(
                    categoria: categoria,
                  ),

                  if (index != categorias.length - 1)
                    const _Divisoria(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// =============================================================
// MODELO DA CATEGORIA
// =============================================================

enum _TipoCor {
  primaria,
  secundaria,
  terciaria,
}

class _Categoria {
  final String titulo;
  final String quantidade;
  final IconData icone;
  final _TipoCor tipoCor;
  final bool disponivel;
  final VoidCallback? aoPressionar;

  _Categoria({
    required this.titulo,
    required this.quantidade,
    required this.icone,
    required this.tipoCor,
    required this.disponivel,
    this.aoPressionar,
  });
}

// =============================================================
// ITEM DA CATEGORIA
// =============================================================

class _ItemCategoria extends StatelessWidget {
  final _Categoria categoria;

  const _ItemCategoria({
    required this.categoria,
  });

  // ===========================================================
  // COR PRINCIPAL
  // ===========================================================

  Color get cor {
    switch (categoria.tipoCor) {
      case _TipoCor.primaria:
        return TemaHinario.corPrimaria;

      case _TipoCor.secundaria:
        return TemaHinario.corSecundaria;

      case _TipoCor.terciaria:
        return TemaHinario.corTerciaria;
    }
  }

  // ===========================================================
  // COR DE FUNDO DO ÍCONE
  // ===========================================================

  Color get corFundo {
    switch (categoria.tipoCor) {
      case _TipoCor.primaria:
        return TemaHinario.corPrimaria.withValues(
          alpha: 0.20,
        );

      case _TipoCor.secundaria:
        return TemaHinario.corSecundariaContainer.withValues(
          alpha: 0.20,
        );

      case _TipoCor.terciaria:
        return TemaHinario.corTerciariaContainer.withValues(
          alpha: 0.20,
        );
    }
  }

  // ===========================================================
  // ABRIR CATEGORIA
  // ===========================================================

  void _abrirCategoria(BuildContext context) {
    if (categoria.aoPressionar != null) {
      categoria.aoPressionar!();
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${categoria.titulo} será implementado nesta etapa.',
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(
          milliseconds: 1200,
        ),
      ),
    );
  }

  // ===========================================================
  // BUILD
  // ===========================================================

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _abrirCategoria(context),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // -------------------------------------------------
              // ÍCONE
              // -------------------------------------------------

              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: corFundo,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  categoria.icone,
                  size: 20,
                  color: cor,
                ),
              ),

              const SizedBox(
                width: 12,
              ),

              // -------------------------------------------------
              // INFORMAÇÕES
              // -------------------------------------------------

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      categoria.titulo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        height: 1.375,
                        fontWeight: FontWeight.w500,
                        color: TemaHinario.corTexto,
                      ),
                    ),

                    const SizedBox(
                      height: 2,
                    ),

                    Text(
                      categoria.quantidade,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 16 / 12,
                        fontWeight: FontWeight.w600,
                        color:
                            TemaHinario.corTextoSecundario,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                width: 8,
              ),

              // -------------------------------------------------
              // SETA
              // -------------------------------------------------

              const Icon(
                Icons.chevron_right_rounded,
                size: 26,
                color: Color(0x805B4040),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================
// DIVISÓRIA
// =============================================================

class _Divisoria extends StatelessWidget {
  const _Divisoria();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.only(
        left: 72,
      ),
      color: const Color(0x33E3BEBD),
    );
  }
}