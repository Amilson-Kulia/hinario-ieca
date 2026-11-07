import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/tema.dart';
import '../../componentes/cabecalho_ieca.dart';
import '../../componentes/navegacao_inferior_ieca.dart';
import '../biblia/biblia_tela.dart';
import '../home/home_tela.dart';
import '../hinario/idiomas_tela.dart';
import '../informacoes_ieca/informacoes_ieca_tela.dart';

class SobreTela extends StatelessWidget {
  const SobreTela({super.key});

  // =========================================================
  // NAVEGAÇÃO
  // =========================================================

  void _selecionarNavegacao(BuildContext context, int indice) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TemaHinario.corSuperficie,
      appBar: const CabecalhoIeca(),
      body: SafeArea(
        top: false,
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 110),
          child: const _Conteudo(),
        ),
      ),
      bottomNavigationBar: NavegacaoInferiorIeca(
        indiceSelecionado: 4,
        onDestinationSelected: (indice) {
          _selecionarNavegacao(context, indice);
        },
      ),
    );
  }
}

// =============================================================
// CONTEÚDO
// =============================================================

class _Conteudo extends StatelessWidget {
  const _Conteudo();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CabecalhoPagina(),
          const SizedBox(height: 24),
          const _IdentidadeCard(),
          const SizedBox(height: 24),
          const _BlocoProposito(),
          const SizedBox(height: 24),
          const _BlocoRecursos(),
          const SizedBox(height: 24),
          const _DesenvolvedorCard(),
          const SizedBox(height: 24),
          const _ColaboracoesCard(),
          const SizedBox(height: 24),
          const _TecnologiaCard(),
          const SizedBox(height: 24),
          const _MensagemCard(),
          const SizedBox(height: 24),
          const _BotaoDireitosLegais(),
          const SizedBox(height: 24),
          const _InformacoesVersao(),
        ],
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'INFORMAÇÕES',
          style: TextStyle(
            fontSize: 11,
            height: 16 / 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.88,
            color: TemaHinario.corTextoSecundario,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Sobre o App IECA',
          style: TextStyle(
            fontSize: 28,
            height: 36 / 28,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.56,
            color: TemaHinario.corTexto,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Conheça o propósito, a visão e os principais '
          'recursos deste aplicativo desenvolvido para '
          'apoiar a vida litúrgica e devocional da IECA.',
          style: TextStyle(
            fontSize: 15,
            height: 24 / 15,
            color: TemaHinario.corTextoSecundario,
          ),
        ),
      ],
    );
  }
}

// =============================================================
// IDENTIDADE
// =============================================================

class _IdentidadeCard extends StatelessWidget {
  const _IdentidadeCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            TemaHinario.corPrimaria.withValues(alpha: 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: TemaHinario.corPrimaria.withValues(alpha: 0.08),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 18,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 5,
              decoration: BoxDecoration(
                color: TemaHinario.corPrimaria,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 19),
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: TemaHinario.corPrimaria.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: Image.asset(
                'assets/images/logoieca.png',
                width: 52,
                height: 52,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 20),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'APLICATIVO IECA',
                    style: TextStyle(
                      fontSize: 10,
                      height: 14 / 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: TemaHinario.corPrimaria,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'App IECA',
                    style: TextStyle(
                      fontSize: 23,
                      height: 30 / 23,
                      fontWeight: FontWeight.w700,
                      color: TemaHinario.corTexto,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Uma plataforma digital criada para reunir, '
                    'num único espaço, conteúdos e recursos que '
                    'apoiam a vida litúrgica, devocional e '
                    'organizacional da Igreja Evangélica '
                    'Congregacional em Angola.',
                    style: TextStyle(
                      fontSize: 13,
                      height: 20 / 13,
                      color: TemaHinario.corTextoSecundario,
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
// BLOCO — PROPÓSITO
// =============================================================

class _BlocoProposito extends StatelessWidget {
  const _BlocoProposito();

  @override
  Widget build(BuildContext context) {
    return _BlocoInformacao(
      icone: Icons.lightbulb_outline_rounded,
      corIcone: TemaHinario.corPrimaria,
      fundoIcone: const Color(0x17A00027),
      label: 'PROPÓSITO',
      titulo: 'Por que este aplicativo foi desenvolvido?',
      filhos: const [
        Text(
          'O App IECA foi desenvolvido com o propósito de '
          'facilitar o acesso aos principais conteúdos e '
          'recursos utilizados na vida da igreja, reunindo '
          'diferentes ferramentas num único espaço digital, '
          'simples e organizado.',
          style: TextStyle(
            fontSize: 15,
            height: 25 / 15,
            color: TemaHinario.corTextoSecundario,
          ),
        ),
        SizedBox(height: 18),
        Text(
          'A aplicação integra o Hinário, a Bíblia, o Lecionário '
          'e outros recursos destinados à preparação e realização '
          'dos cultos, à leitura, consulta e devoção pessoal. '
          'A proposta é apoiar a comunidade sem substituir '
          'os conteúdos e práticas tradicionais da igreja.',
          style: TextStyle(
            fontSize: 15,
            height: 25 / 15,
            color: TemaHinario.corTextoSecundario,
          ),
        ),
      ],
    );
  }
}

// =============================================================
// BLOCO — RECURSOS
// =============================================================

class _BlocoRecursos extends StatelessWidget {
  const _BlocoRecursos();

  @override
  Widget build(BuildContext context) {
    return _BlocoInformacao(
      icone: Icons.apps_rounded,
      corIcone: TemaHinario.corSecundaria,
      fundoIcone: const Color(0x1A855400),
      label: 'RECURSOS',
      titulo: 'O que o aplicativo oferece?',
      filhos: const [
        _Recurso(
          icone: Icons.menu_book_rounded,
          titulo: 'Hinário',
          descricao:
              'Acesso aos hinos e demais conteúdos do '
              'hinário disponíveis no aplicativo.',
        ),
        _Recurso(
          icone: Icons.auto_stories_rounded,
          titulo: 'Bíblia',
          descricao:
              'Leitura e consulta das Escrituras, com '
              'pesquisa, navegação e recursos interativos.',
        ),
        _Recurso(
          icone: Icons.calendar_month_rounded,
          titulo: 'Lecionário',
          descricao:
              'Guia litúrgico anual com temas, semanas e '
              'reflexões diárias para apoio ao culto e devoção.',
        ),
        _Recurso(
          icone: Icons.favorite_rounded,
          titulo: 'Favoritos',
          descricao:
              'Guarde hinos, textos e outros conteúdos '
              'que deseja encontrar rapidamente.',
        ),
        _Recurso(
          icone: Icons.bookmark_rounded,
          titulo: 'Marcações',
          descricao:
              'Marque e organize conteúdos importantes '
              'para facilitar consultas futuras.',
        ),
        _Recurso(
          icone: Icons.event_note_rounded,
          titulo: 'Programas de Culto',
          descricao:
              'Crie e organize programas litúrgicos '
              'utilizando diferentes elementos do aplicativo.',
        ),
        _Recurso(
          icone: Icons.search_rounded,
          titulo: 'Pesquisa',
          descricao:
              'Encontre rapidamente hinos, textos bíblicos '
              'e outros conteúdos disponíveis.',
        ),
        _Recurso(
          icone: Icons.cloud_off_rounded,
          titulo: 'Funcionamento Offline',
          descricao:
              'Acesse os principais conteúdos e recursos '
              'sem depender de uma ligação à internet.',
        ),
      ],
    );
  }
}

// =============================================================
// BLOCO DE INFORMAÇÃO GENÉRICO
// =============================================================

class _BlocoInformacao extends StatelessWidget {
  final IconData icone;
  final Color corIcone;
  final Color fundoIcone;
  final String label;
  final String titulo;
  final List<Widget> filhos;

  const _BlocoInformacao({
    required this.icone,
    required this.corIcone,
    required this.fundoIcone,
    required this.label,
    required this.titulo,
    required this.filhos,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: fundoIcone,
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Icon(icone, size: 24, color: corIcone),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      height: 16 / 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.88,
                      color: TemaHinario.corTextoSecundario,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    titulo,
                    style: const TextStyle(
                      fontSize: 20,
                      height: 28 / 20,
                      fontWeight: FontWeight.w700,
                      color: TemaHinario.corTexto,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        ...filhos,
      ],
    );
  }
}

// =============================================================
// RECURSO
// =============================================================

class _Recurso extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String descricao;

  const _Recurso({
    required this.icone,
    required this.titulo,
    required this.descricao,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TemaHinario.corSuperficieBaixa,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Icon(
              icone,
              size: 22,
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
                    fontSize: 15,
                    height: 22 / 15,
                    fontWeight: FontWeight.w700,
                    color: TemaHinario.corTexto,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  descricao,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 18 / 12,
                    color: TemaHinario.corTextoSecundario,
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
// DESENVOLVEDOR
// =============================================================

class _DesenvolvedorCard extends StatelessWidget {
  const _DesenvolvedorCard();

  Future<void> _copiarTelefone(BuildContext context) async {
    await Clipboard.setData(
      const ClipboardData(text: '942560850'),
    );

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: Duration(milliseconds: 1500),
        content: Text('Número copiado: 942 560 850'),
      ),
    );
  }

  Future<void> _copiarEmail(BuildContext context) async {
    await Clipboard.setData(
      const ClipboardData(text: 'amilsonkulia10@gmail.com'),
    );

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: Duration(milliseconds: 1500),
        content: Text('Email copiado: amilsonkulia10@gmail.com'),
      ),
    );
  }

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
            color: TemaHinario.corPrimaria.withValues(alpha: 0.20),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // =====================================================
          // CABEÇALHO
          // =====================================================

          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.13),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.code_rounded,
                    size: 25,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DESENVOLVIMENTO',
                        style: TextStyle(
                          fontSize: 11,
                          height: 16 / 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.88,
                          color: Color(0xB8FFFFFF),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Sobre o desenvolvedor',
                        style: TextStyle(
                          fontSize: 20,
                          height: 28 / 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // =====================================================
          // FOTO
          // =====================================================

          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 18),
            child: Container(
              width: 122,
              height: 122,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.45),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(3),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/criador.png',
                  width: 126,
                  height: 126,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // =====================================================
          // NOME + DESCRIÇÃO
          // =====================================================

          const Padding(
            padding: EdgeInsets.fromLTRB(24, 0, 24, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Amilson Kulia',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 25,
                    height: 32 / 25,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Desenvolvedor de Software',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    height: 19 / 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xB8FFFFFF),
                  ),
                ),
                SizedBox(height: 14),
                Text(
                  'Desenvolvedor de Software com experiência na '
                  'criação de soluções digitais, aplicações web e '
                  'mobile. Focado no desenvolvimento de sistemas '
                  'funcionais, intuitivos e eficientes, alia '
                  'conhecimentos técnicos e boas práticas de '
                  'programação para transformar necessidades em '
                  'soluções tecnológicas que priorizam a '
                  'usabilidade, a organização e a qualidade.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    height: 21 / 13,
                    color: Color(0xE0FFFFFF),
                  ),
                ),
              ],
            ),
          ),

          // =====================================================
          // DETALHES
          // =====================================================

          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 22),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Color(0x1FFFFFFF),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _DetalheDesenvolvedor(
                  icone: Icons.school_rounded,
                  texto: 'Engenharia Informática',
                ),
                const SizedBox(height: 10),
                const _DetalheDesenvolvedor(
                  icone: Icons.code_rounded,
                  texto: 'Desenvolvimento de Software',
                ),
                const SizedBox(height: 10),
                const _DetalheDesenvolvedor(
                  icone: Icons.workspace_premium_rounded,
                  texto: 'CEO - Hubble AO',
                ),
                const SizedBox(height: 10),
                const _DetalheDesenvolvedor(
                  icone: Icons.church_rounded,
                  texto: 'Pastorado de Damasco',
                ),
                const SizedBox(height: 16),

                // =================================================
                // CONTACTOS
                // =================================================

                // ----- TELEFONE -----
                Material(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => _copiarTelefone(context),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.14),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.phone_rounded,
                              size: 19,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'CONTACTO',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.6,
                                    color: Color(0xB8FFFFFF),
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  '942 560 850',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.copy_rounded,
                            size: 18,
                            color: Color(0xB8FFFFFF),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // ----- EMAIL -----
                Material(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => _copiarEmail(context),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.14),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.email_rounded,
                              size: 19,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'EMAIL',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.6,
                                    color: Color(0xB8FFFFFF),
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'amilsonkulia10@gmail.com',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.copy_rounded,
                            size: 18,
                            color: Color(0xB8FFFFFF),
                          ),
                        ],
                      ),
                    ),
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
// DETALHE DO DESENVOLVEDOR
// =============================================================

class _DetalheDesenvolvedor extends StatelessWidget {
  final IconData icone;
  final String texto;

  const _DetalheDesenvolvedor({
    required this.icone,
    required this.texto,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icone, size: 19, color: const Color(0xB3FFFFFF)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            texto,
            style: const TextStyle(
              fontSize: 12,
              height: 18 / 12,
              color: Color(0xD1FFFFFF),
            ),
          ),
        ),
      ],
    );
  }
}

// =============================================================
// CONTRIBUIÇÕES
// =============================================================

class _ColaboracoesCard extends StatelessWidget {
  const _ColaboracoesCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 18,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: TemaHinario.corPrimaria.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.groups_rounded,
                  size: 24,
                  color: TemaHinario.corPrimaria,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CONTRIBUIÇÕES',
                      style: TextStyle(
                        fontSize: 11,
                        height: 16 / 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.88,
                        color: TemaHinario.corTextoSecundario,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Contribuições para a estruturação',
                      style: TextStyle(
                        fontSize: 20,
                        height: 28 / 20,
                        fontWeight: FontWeight.w700,
                        color: TemaHinario.corTexto,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            'A estruturação e evolução do App IECA também '
            'contou com a contribuição de irmãos que '
            'partilharam experiências, sugestões e '
            'orientações para tornar a aplicação mais '
            'adequada às necessidades da igreja e dos '
            'seus utilizadores.',
            style: TextStyle(
              fontSize: 14,
              height: 23 / 14,
              color: TemaHinario.corTextoSecundario,
            ),
          ),
          const SizedBox(height: 18),
          const _Colaborador(
            nome: 'Estanislau Kulia',
            funcao:
                'Vice-Diretor da Sociedade de Jovens do '
                'Pastorado de Damasco',
          ),
          const SizedBox(height: 12),
          const _Colaborador(
            nome: 'Jony Pena',
            funcao: 'Secretário do Pastorado de Emanuel',
          ),
          const SizedBox(height: 12),
          const _Colaborador(
            nome: 'Octávio Pessela',
            funcao: 'Tesoureiro do Pastorado de Nova Vida',
          ),
          const SizedBox(height: 12),
          const _Colaborador(
            nome: 'Evaristo Sawapinda',
            funcao: 'Diretor da Sociedade de Jovens de Damasco',
          ),
          const SizedBox(height: 12),
          const _Colaborador(
            nome: 'Victor Chilembo',
            funcao: 'Secretário do Pastorado de Damasco',
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: TemaHinario.corSuperficieBaixa,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.volunteer_activism_rounded,
                  size: 21,
                  color: TemaHinario.corPrimaria,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Agradço de coração pela disponibilidade, '
                    'pelas valiosas sugestões e pela contribuição '
                    'na reflexão sobre a organização e os recursos '
                    'do aplicativo. Que Deus abençoe a cada um por '
                    'este gesto de serviço e dedicação à Sua obra.',
                    style: TextStyle(
                      fontSize: 13,
                      height: 21 / 13,
                      color: TemaHinario.corTextoSecundario,
                    ),
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
// COLABORADOR
// =============================================================

class _Colaborador extends StatelessWidget {
  final String nome;
  final String funcao;

  const _Colaborador({
    required this.nome,
    required this.funcao,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TemaHinario.corSuperficieBaixa,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.person_rounded,
              size: 21,
              color: TemaHinario.corPrimaria,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nome,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 20 / 14,
                    fontWeight: FontWeight.w700,
                    color: TemaHinario.corTexto,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  funcao,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 19 / 12,
                    color: TemaHinario.corTextoSecundario,
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
// TECNOLOGIA
// =============================================================

class _TecnologiaCard extends StatelessWidget {
  const _TecnologiaCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: TemaHinario.corSuperficieBaixa,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: TemaHinario.corTerciaria.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(15),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.offline_bolt_rounded,
              size: 25,
              color: TemaHinario.corTerciaria,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TECNOLOGIA',
                  style: TextStyle(
                    fontSize: 11,
                    height: 16 / 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.88,
                    color: TemaHinario.corTerciaria,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Uma plataforma que funciona offline',
                  style: TextStyle(
                    fontSize: 17,
                    height: 24 / 17,
                    fontWeight: FontWeight.w700,
                    color: TemaHinario.corTexto,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'O App IECA foi concebido para permitir o acesso '
                  'aos seus principais conteúdos e recursos mesmo '
                  'sem ligação à internet. Dessa forma, pode ser '
                  'utilizado durante os cultos, momentos de devoção '
                  'e em diferentes contextos onde o acesso à internet '
                  'não esteja disponível.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 21 / 13,
                    color: TemaHinario.corTextoSecundario,
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
// MENSAGEM
// =============================================================

class _MensagemCard extends StatelessWidget {
  const _MensagemCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 28,
      ),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            TemaHinario.corSuperficieMedia,
            TemaHinario.corPrimaria.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -8,
            right: 0,
            child: Opacity(
              opacity: 0.08,
              child: Icon(
                Icons.format_quote_rounded,
                size: 64,
                color: TemaHinario.corPrimaria,
              ),
            ),
          ),
          Column(
            children: [
              const SizedBox(height: 4),
              const Text(
                '"IECA para Cristo, Cristo para todos!"',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  height: 28 / 18,
                  fontWeight: FontWeight.w700,
                  fontStyle: FontStyle.italic,
                  color: TemaHinario.corPrimaria,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Igreja Evangélica Congregacional em Angola',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  height: 17 / 11,
                  fontWeight: FontWeight.w600,
                  color: TemaHinario.corTextoSecundario,
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
// BOTÃO — DIREITOS E INFORMAÇÕES LEGAIS
// =============================================================

class _BotaoDireitosLegais extends StatelessWidget {
  const _BotaoDireitosLegais();

  void _abrirDireitos(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => const _DialogoDireitosLegais(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _abrirDireitos(context),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: TemaHinario.corPrimaria.withValues(alpha: 0.15),
              width: 1,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x08000000),
                blurRadius: 12,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: TemaHinario.corPrimaria.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.gavel_rounded,
                  size: 24,
                  color: TemaHinario.corPrimaria,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LEGAL',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: TemaHinario.corTextoSecundario,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Direitos e Informações Legais',
                      style: TextStyle(
                        fontSize: 16,
                        height: 22 / 16,
                        fontWeight: FontWeight.w700,
                        color: TemaHinario.corTexto,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Toque para consultar',
                      style: TextStyle(
                        fontSize: 12,
                        color: TemaHinario.corTextoSecundario,
                      ),
                    ),
                  ],
                ),
              ),
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
// DIÁLOGO DE DIREITOS E INFORMAÇÕES LEGAIS
// =============================================================

class _DialogoDireitosLegais extends StatelessWidget {
  const _DialogoDireitosLegais();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      backgroundColor: TemaHinario.corSuperficie,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 620,
          maxHeight: 720,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // =================================================
            // CABEÇALHO DO DIÁLOGO
            // =================================================

            Container(
              padding: const EdgeInsets.fromLTRB(20, 18, 12, 18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    TemaHinario.corPrimaria,
                    const Color(0xFF6A001A),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.gavel_rounded,
                      size: 22,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'LEGAL',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: Color(0xB8FFFFFF),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Direitos e Informações Legais',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Fechar',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),

            // =================================================
            // CONTEÚDO
            // =================================================

            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: const _TextoDireitosLegais(),
              ),
            ),

            // =================================================
            // BOTÃO FECHAR
            // =================================================

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  style: FilledButton.styleFrom(
                    backgroundColor: TemaHinario.corPrimaria,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Fechar',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
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
// TEXTO DOS DIREITOS LEGAIS
// =============================================================

class _TextoDireitosLegais extends StatelessWidget {
  const _TextoDireitosLegais();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        _TituloDireitos('Sobre o aplicativo'),
        _ParagrafoDireitos(
          'O App IECA é uma aplicação desenvolvida com o propósito '
          'de facilitar o acesso, a consulta e a utilização de '
          'conteúdos de apoio à vida cristã, ao culto, à comunhão '
          'e ao estudo da Palavra de Deus.',
        ),
        _ParagrafoDireitos(
          'A aplicação reúne, num único espaço digital, diferentes '
          'recursos relacionados com a vida e a prática da Igreja, '
          'incluindo conteúdos bíblicos, hinos, materiais '
          'litúrgicos, lecionário, programas de culto e outras '
          'ferramentas de apoio à comunidade cristã.',
        ),
        _ParagrafoDireitos(
          'A aplicação foi concebida para funcionar de forma '
          'simples, acessível e, sempre que possível, sem '
          'necessidade de ligação à Internet, permitindo que os '
          'seus conteúdos estejam disponíveis diretamente no '
          'dispositivo do utilizador.',
        ),

        SizedBox(height: 18),
        _TituloDireitos('Direitos de autor'),
        _ParagrafoDireitos(
          'O código-fonte, a estrutura da aplicação, a identidade '
          'visual, os elementos gráficos, a organização das '
          'funcionalidades e os componentes desenvolvidos '
          'especificamente para o App IECA são protegidos pela '
          'legislação aplicável sobre propriedade intelectual e '
          'direitos de autor.',
        ),
        _ParagrafoDireitos(
          'Salvo indicação expressa em contrário, não é permitida '
          'a reprodução, distribuição, modificação, '
          'comercialização ou utilização dos elementos exclusivos '
          'da aplicação para fins que violem os direitos dos '
          'respetivos titulares.',
        ),

        SizedBox(height: 18),
        _TituloDireitos('Conteúdos utilizados'),
        _ParagrafoDireitos(
          'A aplicação pode disponibilizar conteúdos provenientes '
          'de diferentes fontes, incluindo hinos, textos '
          'litúrgicos, passagens bíblicas, leituras, materiais do '
          'lecionário, programas de culto e outros conteúdos '
          'relacionados com a tradição, a doutrina e a prática '
          'cristã.',
        ),
        _ParagrafoDireitos(
          'Os direitos sobre cada conteúdo pertencem aos seus '
          'respetivos autores, compositores, tradutores, '
          'editores, instituições ou outros titulares de direitos, '
          'quando aplicável.',
        ),
        _ParagrafoDireitos(
          'A disponibilização desses conteúdos dentro da aplicação '
          'não significa, por si só, que os respetivos direitos '
          'tenham sido transferidos para o desenvolvedor da '
          'aplicação.',
        ),
        _ParagrafoDireitos(
          'Sempre que aplicável, os conteúdos são utilizados de '
          'acordo com as condições, permissões ou disposições '
          'legais correspondentes.',
        ),

        SizedBox(height: 18),
        _TituloDireitos('Bíblia'),
        _ParagrafoDireitos(
          'As traduções bíblicas disponibilizadas na aplicação '
          'permanecem sujeitas aos respetivos direitos de autor e '
          'condições de utilização.',
        ),
        _ParagrafoDireitos(
          'A aplicação não reivindica propriedade sobre o texto '
          'bíblico ou sobre traduções pertencentes a terceiros.',
        ),
        _ParagrafoDireitos(
          'A utilização das traduções disponibilizadas deve '
          'respeitar os direitos e as condições estabelecidas '
          'pelos respetivos titulares.',
        ),

        SizedBox(height: 18),
        _TituloDireitos('Hinário e conteúdos litúrgicos'),
        _ParagrafoDireitos(
          'Os hinos, cânticos, liturgias, invocatórias, litanias, '
          'salmos e demais conteúdos litúrgicos apresentados na '
          'aplicação podem estar sujeitos a direitos pertencentes '
          'à Igreja Evangélica Congregacional em Angola (IECA), '
          'aos seus autores, compositores, tradutores, editores '
          'ou outros titulares legítimos.',
        ),
        _ParagrafoDireitos(
          'A aplicação procura apresentar esses conteúdos de forma '
          'organizada, acessível e adequada ao uso devocional e '
          'congregacional, respeitando, dentro das possibilidades, '
          'os direitos e as atribuições correspondentes.',
        ),

        SizedBox(height: 18),
        _TituloDireitos('Utilização da aplicação'),
        _ParagrafoDireitos(
          'O App IECA destina-se ao uso pessoal, devocional, '
          'educativo e de apoio às atividades cristãs e '
          'congregacionais.',
        ),
        _ParagrafoDireitos(
          'A aplicação não substitui a Bíblia, a orientação '
          'pastoral, o ensino da Igreja, documentos oficiais ou '
          'outras fontes oficiais de informação.',
        ),
        _ParagrafoDireitos(
          'Os conteúdos devem ser utilizados de forma responsável '
          'e respeitosa, especialmente quando empregados em '
          'contextos de culto, ensino, estudo bíblico ou '
          'atividades congregacionais.',
        ),

        SizedBox(height: 18),
        _TituloDireitos('Sem garantia de conteúdo'),
        _ParagrafoDireitos(
          'Embora sejam realizados esforços para manter os '
          'conteúdos organizados, atualizados e corretos, podem '
          'existir erros de transcrição, formatação, numeração, '
          'tradução ou organização.',
        ),
        _ParagrafoDireitos(
          'Por esse motivo, em situações que exijam precisão '
          'oficial, recomenda-se a consulta das fontes, '
          'publicações e documentos oficiais correspondentes.',
        ),

        SizedBox(height: 18),
        _TituloDireitos('Privacidade'),
        _ParagrafoDireitos(
          'O App IECA foi concebido com foco na privacidade e no '
          'funcionamento local.',
        ),
        _ParagrafoDireitos(
          'As funcionalidades principais da aplicação não dependem '
          'de uma conta de utilizador, não exigem login e não '
          'necessitam de um servidor próprio para armazenar os '
          'dados pessoais do utilizador.',
        ),
        _ParagrafoDireitos(
          'As informações geradas durante a utilização de '
          'determinadas funcionalidades, como favoritos, '
          'marcações, notas, progresso e preferências, podem ser '
          'armazenadas localmente no dispositivo, de acordo com '
          'o funcionamento da aplicação.',
        ),
        _ParagrafoDireitos(
          'A aplicação procura limitar a recolha e o tratamento '
          'de informações ao que é necessário para o funcionamento '
          'das funcionalidades disponibilizadas.',
        ),

        SizedBox(height: 18),
        _TituloDireitos('Desenvolvimento'),
        _ParagrafoDireitos(
          'App IECA — Desenvolvido por Amilson Kulia.',
        ),
        _ParagrafoDireitos(
          'Concebido e desenvolvido com o propósito de reunir, num '
          'único espaço digital, recursos que contribuam para a '
          'leitura, o estudo da Palavra de Deus, o louvor, a '
          'preparação do culto e a vida cristã.',
        ),

        SizedBox(height: 18),
        _TituloDireitos('Contacto e direitos'),
        _ParagrafoDireitos(
          'Para questões relacionadas com direitos de autor, '
          'utilização de conteúdos, correções, atribuições ou '
          'outros assuntos relacionados com a aplicação, '
          'recomenda-se o contacto com o desenvolvedor da '
          'aplicação ou com os respetivos titulares dos conteúdos.',
        ),

        SizedBox(height: 22),
        _AvisoFinal(),
      ],
    );
  }
}

class _TituloDireitos extends StatelessWidget {
  final String texto;

  const _TituloDireitos(this.texto);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 5),
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: TemaHinario.corPrimaria,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              texto,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: TemaHinario.corTexto,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ParagrafoDireitos extends StatelessWidget {
  final String texto;

  const _ParagrafoDireitos(this.texto);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 14),
      child: Text(
        texto,
        textAlign: TextAlign.justify,
        style: const TextStyle(
          fontSize: 13.5,
          height: 1.6,
          color: TemaHinario.corTextoSecundario,
        ),
      ),
    );
  }
}

class _AvisoFinal extends StatelessWidget {
  const _AvisoFinal();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TemaHinario.corPrimaria.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border(
          left: BorderSide(
            color: TemaHinario.corPrimaria,
            width: 4,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 18,
                color: TemaHinario.corPrimaria,
              ),
              const SizedBox(width: 8),
              const Text(
                'AVISO',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: TemaHinario.corPrimaria,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'O App IECA é uma aplicação de apoio à leitura, estudo, '
            'louvor, preparação do culto e utilização de conteúdos '
            'cristãos.',
            style: TextStyle(
              fontSize: 12.5,
              height: 1.55,
              color: TemaHinario.corTextoSecundario,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Os nomes, marcas, textos, traduções, hinos, materiais '
            'litúrgicos e demais conteúdos pertencem aos seus '
            'respetivos titulares quando aplicável.',
            style: TextStyle(
              fontSize: 12.5,
              height: 1.55,
              color: TemaHinario.corTextoSecundario,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'A utilização da aplicação não implica a transferência '
            'de direitos sobre conteúdos pertencentes a terceiros.',
            style: TextStyle(
              fontSize: 12.5,
              height: 1.55,
              color: TemaHinario.corTextoSecundario,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            '© 2026 App IECA. Todos os direitos reservados.',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: TemaHinario.corPrimaria,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================
// INFORMAÇÕES DA VERSÃO
// =============================================================

class _InformacoesVersao extends StatelessWidget {
  const _InformacoesVersao();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(4, 0, 4, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'App IECA',
                  style: TextStyle(
                    fontSize: 11,
                    height: 16 / 11,
                    color: TemaHinario.corTextoSecundario,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Versão 1.0.0',
                  style: TextStyle(
                    fontSize: 13,
                    height: 18 / 13,
                    fontWeight: FontWeight.w700,
                    color: TemaHinario.corTexto,
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