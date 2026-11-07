import 'package:flutter/material.dart';

import '../../app/tema.dart';
import '../../servicos/onboarding_servico.dart';
import '../home/home_tela.dart';

class OnboardingTela extends StatefulWidget {
  const OnboardingTela({super.key});

  @override
  State<OnboardingTela> createState() => _OnboardingTelaState();
}

class _OnboardingTelaState extends State<OnboardingTela> {
  final PageController _controller = PageController();

  int _paginaAtual = 0;

  static const List<_Passo> _passos = [
    _Passo(
      imagemAsset: 'assets/images/logoieca.png',
      etiqueta: 'HINÁRIO IECA',
      titulo: 'Bem-vindo',
      descricao:
          'Uma experiência simples e completa para acompanhar a '
          'adoração, a leitura da Palavra e a vida da Igreja.',
      destaque:
          'Tudo reunido num único aplicativo, disponível mesmo sem internet.',
      cor: TemaHinario.corPrimaria,
      tipo: _TipoVisual.logo,
    ),

    _Passo(
      icone: Icons.home_rounded,
      etiqueta: 'HOME',
      titulo: 'Tudo começa aqui',
      descricao:
          'A página inicial foi pensada para colocar os recursos mais '
          'importantes ao seu alcance desde o primeiro momento.',
      itens: [
        _ItemRecurso(
          icone: Icons.auto_stories_rounded,
          titulo: 'Palavra do Dia',
          descricao: 'Uma mensagem para a sua caminhada diária.',
        ),
        _ItemRecurso(
          icone: Icons.grid_view_rounded,
          titulo: 'Acesso rápido',
          descricao: 'Entre facilmente nos principais recursos.',
        ),
        _ItemRecurso(
          icone: Icons.explore_rounded,
          titulo: 'Navegação simples',
          descricao: 'Encontre o que procura sem complicação.',
        ),
      ],
      cor: TemaHinario.corPrimaria,
      tipo: _TipoVisual.recursos,
    ),

    _Passo(
      icone: Icons.library_music_rounded,
      etiqueta: 'HINÁRIO',
      titulo: 'O Hinário da IECA',
      descricao:
          'Tenha acesso organizado aos conteúdos do hinário e encontre '
          'rapidamente aquilo que precisa para o culto ou para a sua '
          'devoção pessoal.',
      itens: [
        _ItemRecurso(
          icone: Icons.music_note_rounded,
          titulo: 'Hinos',
          descricao: 'Consulte os hinos por número ou título.',
        ),
        _ItemRecurso(
          icone: Icons.translate_rounded,
          titulo: 'Vários idiomas',
          descricao: 'Acesse conteúdos nos idiomas disponíveis.',
        ),
        _ItemRecurso(
          icone: Icons.search_rounded,
          titulo: 'Pesquisa rápida',
          descricao: 'Encontre um conteúdo em poucos segundos.',
        ),
      ],
      cor: TemaHinario.corPrimaria,
      tipo: _TipoVisual.recursos,
    ),

    _Passo(
      icone: Icons.menu_book_rounded,
      etiqueta: 'BÍBLIA',
      titulo: 'A Palavra de Deus',
      descricao:
          'Leia a Bíblia diretamente no aplicativo e mantenha as suas '
          'leituras ao alcance durante o estudo, a devoção ou o culto.',
      itens: [
        _ItemRecurso(
          icone: Icons.menu_book_rounded,
          titulo: 'Livros e capítulos',
          descricao: 'Navegue facilmente por toda a Bíblia.',
        ),
        _ItemRecurso(
          icone: Icons.bookmark_rounded,
          titulo: 'Marcações',
          descricao: 'Guarde passagens importantes para consultar depois.',
        ),
        _ItemRecurso(
          icone: Icons.edit_note_rounded,
          titulo: 'Notas',
          descricao: 'Registe pensamentos e observações durante o estudo.',
        ),
      ],
      cor: TemaHinario.corTerciaria,
      tipo: _TipoVisual.recursos,
    ),

    _Passo(
      icone: Icons.calendar_month_rounded,
      etiqueta: 'LECIONÁRIO',
      titulo: 'Caminhe com o Lecionário',
      descricao:
          'Acompanhe as leituras e orientações organizadas para cada '
          'período, facilitando a preparação espiritual e litúrgica.',
      itens: [
        _ItemRecurso(
          icone: Icons.calendar_today_rounded,
          titulo: 'Por datas',
          descricao: 'Consulte rapidamente o conteúdo de cada dia.',
        ),
        _ItemRecurso(
          icone: Icons.menu_book_rounded,
          titulo: 'Leituras bíblicas',
          descricao: 'Tenha as referências necessárias para cada momento.',
        ),
        _ItemRecurso(
          icone: Icons.church_rounded,
          titulo: 'Liturgia',
          descricao: 'Consulte elementos relacionados ao culto.',
        ),
      ],
      cor: TemaHinario.corTerciaria,
      tipo: _TipoVisual.recursos,
    ),

    _Passo(
      icone: Icons.description_rounded,
      etiqueta: 'PROGRAMA DO CULTO',
      titulo: 'Prepare o culto',
      descricao:
          'Crie programas de culto de forma organizada, reunindo os '
          'elementos necessários para conduzir cada momento.',
      itens: [
        _ItemRecurso(
          icone: Icons.add_circle_outline_rounded,
          titulo: 'Monte o programa',
          descricao: 'Adicione os elementos que farão parte do culto.',
        ),
        _ItemRecurso(
          icone: Icons.library_music_rounded,
          titulo: 'Escolha conteúdos',
          descricao: 'Inclua hinos, leituras e outros elementos.',
        ),
        _ItemRecurso(
          icone: Icons.picture_as_pdf_rounded,
          titulo: 'Organize e partilhe',
          descricao: 'Prepare o programa final para utilização.',
        ),
      ],
      cor: TemaHinario.corSecundaria,
      tipo: _TipoVisual.recursos,
    ),

    _Passo(
      icone: Icons.auto_awesome_rounded,
      etiqueta: 'RECURSOS',
      titulo: 'Tudo conectado',
      descricao:
          'Os recursos do aplicativo foram pensados para trabalhar em '
          'conjunto e facilitar a preparação, o estudo e a realização do culto.',
      itens: [
        _ItemRecurso(
          icone: Icons.search_rounded,
          titulo: 'Pesquisa',
          descricao: 'Encontre rapidamente hinos e outros conteúdos.',
        ),
        _ItemRecurso(
          icone: Icons.bookmark_rounded,
          titulo: 'Marcações',
          descricao: 'Mantenha conteúdos importantes sempre por perto.',
        ),
        _ItemRecurso(
          icone: Icons.offline_bolt_rounded,
          titulo: 'Sem internet',
          descricao: 'Grande parte dos conteúdos está disponível offline.',
        ),
      ],
      cor: TemaHinario.corPrimaria,
      tipo: _TipoVisual.recursos,
    ),

    _Passo(
      icone: Icons.church_rounded,
      etiqueta: 'INFORMAÇÕES IECA',
      titulo: 'Conheça a Igreja',
      descricao:
          'Descubra mais sobre a história da IECA, as suas missões e '
          'curiosidades que ajudam a preservar a memória da Igreja.',
      destaque:
          'Uma forma simples de conhecer, valorizar e preservar a história da IECA.',
      cor: TemaHinario.corTerciaria,
      tipo: _TipoVisual.destaque,
    ),

    _Passo(
      imagemAsset: 'assets/images/logoieca.png',
      etiqueta: 'ESTÁ TUDO PRONTO',
      titulo: 'Vamos começar?',
      descricao:
          'Agora já conhece os principais recursos do Hinário IECA.',
      destaque:
          'Que este aplicativo seja uma ferramenta útil para a adoração, '
          'o estudo da Palavra e o fortalecimento da fé.',
      cor: TemaHinario.corPrimaria,
      tipo: _TipoVisual.finalizacao,
    ),
  ];

  bool get _ehUltima => _paginaAtual == _passos.length - 1;

  Future<void> _concluir() async {
    await OnboardingServico.marcarComoConcluido();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(
        builder: (_) => const HomeTela(),
      ),
    );
  }

  void _proximo() {
    if (_ehUltima) {
      _concluir();
      return;
    }

    _controller.nextPage(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
  }

  void _anterior() {
    if (_paginaAtual == 0) return;

    _controller.previousPage(
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tamanho = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: TemaHinario.corSuperficie,
      body: SafeArea(
        child: Column(
          children: [
            _CabecalhoOnboarding(
              paginaAtual: _paginaAtual,
              totalPaginas: _passos.length,
              ehUltima: _ehUltima,
              onSaltar: _concluir,
            ),

            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _passos.length,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (pagina) {
                  setState(() {
                    _paginaAtual = pagina;
                  });
                },
                itemBuilder: (_, indice) {
                  return _PassoPagina(
                    passo: _passos[indice],
                    alturaDisponivel: tamanho.height,
                  );
                },
              ),
            ),

            _RodapeOnboarding(
              paginaAtual: _paginaAtual,
              totalPaginas: _passos.length,
              ehUltima: _ehUltima,
              onAnterior: _anterior,
              onProximo: _proximo,
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================
// CABEÇALHO
// =============================================================

class _CabecalhoOnboarding extends StatelessWidget {
  final int paginaAtual;
  final int totalPaginas;
  final bool ehUltima;
  final VoidCallback onSaltar;

  const _CabecalhoOnboarding({
    required this.paginaAtual,
    required this.totalPaginas,
    required this.ehUltima,
    required this.onSaltar,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 12, 18, 0),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: TemaHinario.corPrimaria.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.church_rounded,
              size: 21,
              color: TemaHinario.corPrimaria,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Hinário IECA',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: TemaHinario.corTexto,
              ),
            ),
          ),
          if (!ehUltima)
            TextButton(
              onPressed: onSaltar,
              style: TextButton.styleFrom(
                foregroundColor: TemaHinario.corTextoSecundario,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
              ),
              child: const Text(
                'Saltar',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// =============================================================
// PÁGINA
// =============================================================

class _PassoPagina extends StatelessWidget {
  final _Passo passo;
  final double alturaDisponivel;

  const _PassoPagina({
    required this.passo,
    required this.alturaDisponivel,
  });

  @override
  Widget build(BuildContext context) {
    final bool telaPequena = alturaDisponivel < 700;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        26,
        telaPequena ? 18 : 28,
        26,
        12,
      ),
      child: Column(
        children: [
          SizedBox(
            height: telaPequena ? 12 : 20,
          ),

          _VisualPrincipal(
            passo: passo,
            compacto: telaPequena,
          ),

          SizedBox(
            height: telaPequena ? 24 : 32,
          ),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: passo.cor.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              passo.etiqueta,
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 1.1,
                fontWeight: FontWeight.w800,
                color: passo.cor,
              ),
            ),
          ),

          const SizedBox(height: 14),

          Text(
            passo.titulo,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: telaPequena ? 25 : 29,
              height: 1.15,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
              color: TemaHinario.corTexto,
            ),
          ),

          const SizedBox(height: 13),

          ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 500,
            ),
            child: Text(
              passo.descricao,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: telaPequena ? 14 : 15,
                height: 1.55,
                fontWeight: FontWeight.w500,
                color: TemaHinario.corTextoSecundario,
              ),
            ),
          ),

          if (passo.itens != null) ...[
            const SizedBox(height: 24),
            _ListaRecursos(
              itens: passo.itens!,
              cor: passo.cor,
            ),
          ],

          if (passo.destaque != null) ...[
            const SizedBox(height: 24),
            _CaixaDestaque(
              texto: passo.destaque!,
              cor: passo.cor,
            ),
          ],
        ],
      ),
    );
  }
}

// =============================================================
// VISUAL PRINCIPAL
// =============================================================

class _VisualPrincipal extends StatelessWidget {
  final _Passo passo;
  final bool compacto;

  const _VisualPrincipal({
    required this.passo,
    required this.compacto,
  });

  @override
  Widget build(BuildContext context) {
    final double tamanho = compacto ? 130 : 154;

    if (passo.tipo == _TipoVisual.logo ||
        passo.tipo == _TipoVisual.finalizacao) {
      return Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: tamanho + 48,
            height: tamanho + 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: passo.cor.withValues(alpha: 0.045),
            ),
          ),
          Container(
            width: tamanho + 20,
            height: tamanho + 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: passo.cor.withValues(alpha: 0.07),
            ),
          ),
          Container(
            width: tamanho,
            height: tamanho,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: passo.cor.withValues(alpha: 0.15),
                  blurRadius: 32,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                passo.imagemAsset!,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: tamanho + 42,
          height: tamanho + 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: passo.cor.withValues(alpha: 0.045),
          ),
        ),
        Container(
          width: tamanho,
          height: tamanho,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: passo.cor.withValues(alpha: 0.13),
                blurRadius: 28,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: tamanho - 30,
                height: tamanho - 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: passo.cor.withValues(alpha: 0.09),
                ),
              ),
              Container(
                width: tamanho - 64,
                height: tamanho - 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: passo.cor.withValues(alpha: 0.14),
                ),
                child: Icon(
                  passo.icone,
                  size: compacto ? 46 : 52,
                  color: passo.cor,
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
// LISTA DE RECURSOS
// =============================================================

class _ListaRecursos extends StatelessWidget {
  final List<_ItemRecurso> itens;
  final Color cor;

  const _ListaRecursos({
    required this.itens,
    required this.cor,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: 520,
      ),
      child: Column(
        children: itens.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(17),
                border: Border.all(
                  color: Colors.black.withValues(alpha: 0.045),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.025),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: cor.withValues(alpha: 0.09),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      item.icone,
                      size: 20,
                      color: cor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.titulo,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: TemaHinario.corTexto,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.descricao,
                          style: const TextStyle(
                            fontSize: 12,
                            height: 1.35,
                            fontWeight: FontWeight.w500,
                            color:
                                TemaHinario.corTextoSecundario,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// =============================================================
// CAIXA DE DESTAQUE
// =============================================================

class _CaixaDestaque extends StatelessWidget {
  final String texto;
  final Color cor;

  const _CaixaDestaque({
    required this.texto,
    required this.cor,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: 500,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cor.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: cor.withValues(alpha: 0.10),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: cor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.auto_awesome_rounded,
                size: 17,
                color: cor,
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Text(
                texto,
                style: TextStyle(
                  fontSize: 12.5,
                  height: 1.45,
                  fontWeight: FontWeight.w600,
                  color: cor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================
// RODAPÉ
// =============================================================

class _RodapeOnboarding extends StatelessWidget {
  final int paginaAtual;
  final int totalPaginas;
  final bool ehUltima;
  final VoidCallback onAnterior;
  final VoidCallback onProximo;

  const _RodapeOnboarding({
    required this.paginaAtual,
    required this.totalPaginas,
    required this.ehUltima,
    required this.onAnterior,
    required this.onProximo,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 22),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              totalPaginas,
              (indice) {
                final bool ativo = indice == paginaAtual;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOut,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 3,
                  ),
                  width: ativo ? 24 : 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: ativo
                        ? TemaHinario.corPrimaria
                        : TemaHinario.corPrimaria
                            .withValues(alpha: 0.16),
                    borderRadius:
                        BorderRadius.circular(999),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 17),

          Row(
            children: [
              if (paginaAtual > 0)
                SizedBox(
                  width: 52,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: onAnterior,
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      foregroundColor:
                          TemaHinario.corTextoSecundario,
                      side: BorderSide(
                        color: Colors.black.withValues(
                          alpha: 0.08,
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(16),
                      ),
                    ),
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      size: 21,
                    ),
                  ),
                )
              else
                const SizedBox(width: 52),

              const SizedBox(width: 12),

              Expanded(
                child: SizedBox(
                  height: 52,
                  child: FilledButton(
                    onPressed: onProximo,
                    style: FilledButton.styleFrom(
                      backgroundColor:
                          TemaHinario.corPrimaria,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Text(
                          ehUltima
                              ? 'Entrar no Aplicativo'
                              : 'Próximo',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          ehUltima
                              ? Icons.arrow_forward_rounded
                              : Icons.arrow_forward_ios_rounded,
                          size: ehUltima ? 19 : 14,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// =============================================================
// MODELOS
// =============================================================

enum _TipoVisual {
  logo,
  recursos,
  destaque,
  finalizacao,
}

class _Passo {
  final IconData? icone;
  final String? imagemAsset;
  final String etiqueta;
  final String titulo;
  final String descricao;
  final String? destaque;
  final List<_ItemRecurso>? itens;
  final Color cor;
  final _TipoVisual tipo;

  const _Passo({
    this.icone,
    this.imagemAsset,
    required this.etiqueta,
    required this.titulo,
    required this.descricao,
    this.destaque,
    this.itens,
    required this.cor,
    required this.tipo,
  }) : assert(
          icone != null || imagemAsset != null,
          'Define icone ou imagemAsset.',
        );
}

class _ItemRecurso {
  final IconData icone;
  final String titulo;
  final String descricao;

  const _ItemRecurso({
    required this.icone,
    required this.titulo,
    required this.descricao,
  });
}