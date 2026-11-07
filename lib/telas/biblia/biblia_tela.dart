import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/tema.dart';
import '../../componentes/cabecalho_ieca.dart';
import '../../componentes/navegacao_inferior_ieca.dart';
import '../../modelos/biblia_livro.dart';
import '../../servicos/biblia_servico.dart';
 
import '../hinario/idiomas_tela.dart';
import '../home/home_tela.dart';
import '../sobre/sobre_tela.dart';
import 'anotacoes_tela.dart';
import 'leitura_biblia_tela.dart';
import 'livros_biblia_tela.dart';
import 'versiculos_marcados_tela.dart';
import '../informacoes_ieca/informacoes_ieca_tela.dart';

class BibliaTela extends StatefulWidget {
  const BibliaTela({super.key});

  @override
  State<BibliaTela> createState() => _BibliaTelaState();
}

class _BibliaTelaState extends State<BibliaTela> {
  // =============================================================
  // NAVEGAÇÃO
  // =============================================================

  int _itemSelecionado = 2;

  // =============================================================
  // DADOS DA BÍBLIA
  // =============================================================

  List<BibliaLivro> _livrosBiblia = [];
  bool _carregandoBiblia = true;
  bool _temErro = false;

  // =============================================================
  // LEITURA RECENTE
  // =============================================================

  String _livroRecenteId = 'JHN';
  String _livroRecenteNome = 'João';
  int _capituloRecente = 3;

  static const String _keyLivroRecenteId =
      'biblia_livro_recente_id';

  static const String _keyLivroRecenteNome =
      'biblia_livro_recente_nome';

  static const String _keyCapituloRecente =
      'biblia_capitulo_recente';

  // =============================================================
  // FRASES BÍBLICAS (rotativas)
  // =============================================================

  static const List<_FraseBiblica> _frases = [
    _FraseBiblica(
      texto:
          'Lâmpada para os meus pés é a tua palavra e luz para o meu caminho.',
      referencia: 'Salmos 119:105',
      icone: Icons.lightbulb_outline_rounded,
    ),
    _FraseBiblica(
      texto:
          'Porque a palavra de Deus é viva, e eficaz, e mais penetrante do que qualquer espada de dois fios.',
      referencia: 'Hebreus 4:12',
      icone: Icons.auto_awesome_rounded,
    ),
    _FraseBiblica(
      texto:
          'Toda a Escritura é divinamente inspirada, e proveitosa para ensinar, para redarguir, para corrigir, para instruir em justiça.',
      referencia: '2 Timóteo 3:16',
      icone: Icons.menu_book_rounded,
    ),
    _FraseBiblica(
      texto:
          'Não só de pão viverá o homem, mas de toda a palavra que procede da boca de Deus.',
      referencia: 'Mateus 4:4',
      icone: Icons.restaurant_rounded,
    ),
  ];

  _FraseBiblica get _fraseDoDia {
    final agora = DateTime.now();
    final indice = agora.day % _frases.length;
    return _frases[indice];
  }

  @override
  void initState() {
    super.initState();

    _carregarLeituraRecente();
    _carregarDadosBiblia();
  }

  // =============================================================
  // CARREGAR LEITURA RECENTE
  // =============================================================

  Future<void> _carregarLeituraRecente() async {
    final prefs = await SharedPreferences.getInstance();

    final livroId = prefs.getString(_keyLivroRecenteId);
    final livroNome = prefs.getString(_keyLivroRecenteNome);
    final capitulo = prefs.getInt(_keyCapituloRecente);

    if (!mounted) return;

    setState(() {
      if (livroId != null && livroId.isNotEmpty) {
        _livroRecenteId = livroId;
      }

      if (livroNome != null && livroNome.isNotEmpty) {
        _livroRecenteNome = livroNome;
      }

      if (capitulo != null && capitulo > 0) {
        _capituloRecente = capitulo;
      }
    });
  }

  // =============================================================
  // CARREGAR BÍBLIA
  // =============================================================

  Future<void> _carregarDadosBiblia() async {
    setState(() {
      _carregandoBiblia = true;
      _temErro = false;
    });

    try {
      final livros = await BibliaServico.carregarBiblia(
        'assets/dados/por-almeida.usfx.xml',
      );

      if (!mounted) return;

      setState(() {
        _livrosBiblia = livros;
        _carregandoBiblia = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _carregandoBiblia = false;
        _temErro = true;
      });

      _mostrarMensagem('Erro ao carregar os dados da Bíblia.');
    }
  }

  // =============================================================
  // NAVEGAÇÃO INFERIOR
  // =============================================================

  void _selecionarNavegacao(int indice) {
    if (indice == _itemSelecionado) return;

    setState(() {
      _itemSelecionado = indice;
    });

    switch (indice) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute<void>(builder: (_) => const HomeTela()),
        );
        break;

      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute<void>(builder: (_) => const IdiomasTela()),
        );
        break;

      case 2:
        break;

      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute<void>(
            builder: (_) => const InformacoesIecaTela(),
          ),
        );
        break;

      case 4:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute<void>(builder: (_) => const SobreTela()),
        );
        break;
    }
  }

  // =============================================================
  // MENSAGENS
  // =============================================================

  void _mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          mensagem,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        duration: const Duration(milliseconds: 1600),
        behavior: SnackBarBehavior.floating,
        backgroundColor: TemaHinario.corTexto,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  // =============================================================
  // CONTINUAR LEITURA
  // =============================================================

  Future<void> _continuarLeitura() async {
    if (_carregandoBiblia) {
      _mostrarMensagem('Carregando a Bíblia, aguarde...');
      return;
    }

    final livro = _livrosBiblia.firstWhere(
      (l) => l.id == _livroRecenteId || l.nome == _livroRecenteNome,
      orElse: () => _livrosBiblia.isNotEmpty
          ? _livrosBiblia.first
          : BibliaLivro(
              id: 'GEN',
              nome: 'Gênesis',
              capitulos: const [],
            ),
    );

    if (livro.capitulos.isEmpty) {
      _mostrarMensagem('Nenhum capítulo disponível para leitura.');
      return;
    }

    final capituloValido = livro.capitulos.any(
      (c) => c.numero == _capituloRecente,
    );

    final capitulo =
        capituloValido ? _capituloRecente : livro.capitulos.first.numero;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LeituraBibliaTela(
          livro: livro,
          capituloNumero: capitulo,
        ),
      ),
    );

    await _carregarLeituraRecente();
  }

  // =============================================================
  // ABRIR LIVROS
  // =============================================================

  Future<void> _abrirLivros() async {
    if (_carregandoBiblia) {
      _mostrarMensagem('Carregando a Bíblia, aguarde...');
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LivrosBibliaTela(livros: _livrosBiblia),
      ),
    );

    await _carregarLeituraRecente();
  }

  void _abrirMarcacoes() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const VersiculosMarcadosTela(),
      ),
    );
  }

  void _abrirNotas() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AnotacoesTela()),
    );
  }

  // =============================================================
  // BUILD
  // =============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TemaHinario.corSuperficie,

      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(72),
        child: CabecalhoIeca(),
      ),

      body: SafeArea(
        bottom: false,
        child: _construirCorpo(),
      ),

      bottomNavigationBar: NavegacaoInferiorIeca(
        indiceSelecionado: _itemSelecionado,
        onDestinationSelected: _selecionarNavegacao,
      ),
    );
  }

  // =============================================================
  // CORPO PRINCIPAL
  // =============================================================

  Widget _construirCorpo() {
    if (_carregandoBiblia) {
      return const Center(
        child: CircularProgressIndicator(color: TemaHinario.corPrimaria),
      );
    }

    if (_temErro) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: TemaHinario.corSuperficieMedia,
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.error_outline_rounded,
                  size: 34,
                  color: TemaHinario.corPrimaria,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Não foi possível carregar a Bíblia.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: TemaHinario.corTexto,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _carregarDadosBiblia,
                style: ElevatedButton.styleFrom(
                  backgroundColor: TemaHinario.corPrimaria,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Tentar Novamente',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ======================================================
          // TÍTULO DE BOAS-VINDAS
          // ======================================================

          const _TituloBoasVindas(),

          const SizedBox(height: 26),

          // ======================================================
          // CONTINUAR A LER
          // ======================================================

          const _TituloSecao(
            titulo: 'Continuar a ler',
            subtitulo: 'Retome a leitura de onde parou',
            icone: Icons.play_circle_outline_rounded,
          ),

          const SizedBox(height: 12),

          _cartaoLeituraRecente(),

          const SizedBox(height: 30),

          // ======================================================
          // ACESSO RÁPIDO
          // ======================================================

          const _TituloSecao(
            titulo: 'Acesso rápido',
            subtitulo: 'Ferramentas para o seu estudo',
            icone: Icons.dashboard_outlined,
          ),

          const SizedBox(height: 12),

          _gridAcessoRapido(),

          const SizedBox(height: 30),

          // ======================================================
          // FRASE BÍBLICA DO DIA
          // ======================================================

          _construirMensagemBiblica(),

          const SizedBox(height: 10),
        ],
      ),
    );
  }

  // =============================================================
  // CARTÃO DE LEITURA RECENTE
  // =============================================================

  Widget _cartaoLeituraRecente() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: _continuarLeitura,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
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
                color: TemaHinario.corPrimaria.withValues(alpha: 0.22),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -24,
                bottom: -30,
                child: Icon(
                  Icons.menu_book_rounded,
                  size: 140,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.menu_book_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.history_rounded,
                              size: 12,
                              color: Colors.white,
                            ),
                            SizedBox(width: 5),
                            Text(
                              'LEITURA RECENTE',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.7,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Text(
                    '$_livroRecenteNome $_capituloRecente',
                    style: const TextStyle(
                      fontSize: 28,
                      height: 32 / 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 7),
                  const Text(
                    'Continue a sua leitura de onde parou.',
                    style: TextStyle(
                      fontSize: 13,
                      height: 20 / 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 22),
                  _botaoContinuarLeitura(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =============================================================
  // BOTÃO CONTINUAR LEITURA
  // =============================================================

  Widget _botaoContinuarLeitura() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 11,
      ),
      decoration: BoxDecoration(
        color: TemaHinario.corSuperficieAlta,
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.menu_book_outlined,
            size: 18,
            color: TemaHinario.corPrimaria,
          ),
          SizedBox(width: 8),
          Text(
            'Continuar a ler',
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

  // =============================================================
  // GRID DE ACESSO RÁPIDO
  // =============================================================

  Widget _gridAcessoRapido() {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.0,
      children: [
        _cartaoAcessoRapido(
          icone: Icons.auto_stories_outlined,
          titulo: 'Livros',
          subtitulo: 'Explorar',
          corIcone: TemaHinario.corPrimaria,
          onTap: _abrirLivros,
        ),
        _cartaoAcessoRapido(
          icone: Icons.format_color_fill_outlined,
          titulo: 'Marcações',
          subtitulo: 'Destacados',
          corIcone: const Color(0xFF855400),
          onTap: _abrirMarcacoes,
        ),
        _cartaoAcessoRapido(
          icone: Icons.notes_outlined,
          titulo: 'Notas',
          subtitulo: 'Anotações',
          corIcone: const Color(0xFF00695C),
          onTap: _abrirNotas,
        ),
      ],
    );
  }

  // =============================================================
  // CARTÃO DE ACESSO RÁPIDO
  // =============================================================

  Widget _cartaoAcessoRapido({
    required IconData icone,
    required String titulo,
    required String subtitulo,
    required Color corIcone,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: TemaHinario.corSuperficieAlta,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: TemaHinario.corSuperficieMedia),
            boxShadow: const [
              BoxShadow(
                color: Color(0x08000000),
                blurRadius: 7,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: corIcone.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(icone, size: 20, color: corIcone),
              ),
              const SizedBox(height: 10),
              Text(
                titulo,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: TemaHinario.corTexto,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitulo,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10,
                  color: TemaHinario.corTextoSecundario,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =============================================================
  // MENSAGEM BÍBLICA FINAL (Frase do dia)
  // =============================================================

  Widget _construirMensagemBiblica() {
    final frase = _fraseDoDia;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            TemaHinario.corSecundariaContainer,
            TemaHinario.corSecundariaContainer.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: TemaHinario.corSecundaria.withValues(alpha: 0.16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: TemaHinario.corSuperficieAlta,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  frase.icone,
                  size: 20,
                  color: TemaHinario.corPrimaria,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'PALAVRA PARA HOJE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.9,
                    color: TemaHinario.corPrimaria,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            '"${frase.texto}"',
            style: const TextStyle(
              fontSize: 15,
              height: 24 / 15,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w600,
              color: TemaHinario.corTexto,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                width: 20,
                height: 2,
                decoration: BoxDecoration(
                  color: TemaHinario.corPrimaria,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                frase.referencia,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: TemaHinario.corPrimaria,
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
// TÍTULO DE BOAS-VINDAS
// =============================================================

class _TituloBoasVindas extends StatelessWidget {
  const _TituloBoasVindas();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'BÍBLIA SAGRADA',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.96,
              color: TemaHinario.corTextoSecundario,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Leia a Palavra de Deus',
            style: TextStyle(
              fontSize: 26,
              height: 32 / 26,
              fontWeight: FontWeight.w700,
              color: TemaHinario.corTexto,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Explore os livros, marque versículos e guarde notas para a sua caminhada.',
            style: TextStyle(
              fontSize: 14,
              height: 21 / 14,
              color: TemaHinario.corTextoSecundario,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================
// TÍTULO DE SECÇÃO
// =============================================================

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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: TemaHinario.corPrimaria.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Icon(
            icone,
            size: 18,
            color: TemaHinario.corPrimaria,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 18,
                  height: 24 / 18,
                  fontWeight: FontWeight.w700,
                  color: TemaHinario.corTexto,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitulo,
                style: const TextStyle(
                  fontSize: 12,
                  height: 16 / 12,
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
// MODELO AUXILIAR DE FRASE BÍBLICA
// =============================================================

class _FraseBiblica {
  final String texto;
  final String referencia;
  final IconData icone;

  const _FraseBiblica({
    required this.texto,
    required this.referencia,
    required this.icone,
  });
}