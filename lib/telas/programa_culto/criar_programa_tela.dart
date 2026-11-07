import 'package:flutter/material.dart';

import '../../componentes/cabecalho_ieca.dart';
import '../../componentes/navegacao_inferior_ieca.dart';

import '../../modelos/hino.dart';
import '../../modelos/invocatoria.dart';
import '../../modelos/litania.dart';
import '../../modelos/item_programa.dart';
import '../../modelos/programa_culto.dart';
import '../../modelos/tipo_item_programa.dart';
import '../../servicos/hinos_servico.dart';
import '../../servicos/invocatorias_servico.dart';
import '../../servicos/litanias_servico.dart';
import '../../servicos/programas_servico.dart';

import '../biblia/biblia_tela.dart';
import '../home/home_tela.dart';
import '../hinario/idiomas_tela.dart';
import '../sobre/sobre_tela.dart';
import '../../modelos/biblia_livro.dart';
import '../../modelos/biblia_capitulo.dart';
import '../../servicos/biblia_servico.dart';
import '../informacoes_ieca/informacoes_ieca_tela.dart';

class CriarProgramaTela extends StatefulWidget {
  final ProgramaCulto? programaExistente;

  const CriarProgramaTela({
    super.key,
    this.programaExistente,
  });

  @override
  State<CriarProgramaTela> createState() => _CriarProgramaTelaState();
}

class _CriarProgramaTelaState extends State<CriarProgramaTela> {
  static const Color corPrimaria = Color(0xFF9E0027);
  static const Color corPrimariaContainer = Color(0xFFC41E3A);
  static const Color corPrimariaClara = Color(0xFFFFDAD9);

  static const Color corSecundaria = Color(0xFF855400);
  static const Color corSecundariaContainer = Color(0xFFFFA504);

  static const Color corTerciaria = Color(0xFF005754);
  static const Color corTerciariaContainer = Color(0xFF00716E);

  static const Color corSuperficie = Color(0xFFF8F9FF);
  static const Color corSuperficieBaixa = Color(0xFFEFF4FF);
  static const Color corSuperficieMedia = Color(0xFFE6EEFF);
  static const Color corSuperficieAlta = Color(0xFFDEE9FC);

  static const Color corTexto = Color(0xFF121C2A);
  static const Color corTextoSecundario = Color(0xFF5B4040);
  static const Color corBranca = Colors.white;

  final _programasServico = ProgramasServico();

  final _tituloController = TextEditingController();
  final _dataController = TextEditingController();
  final _horaController = TextEditingController();
  final _localController = TextEditingController();
  final _sinodoController = TextEditingController();
  final _congregacaoController = TextEditingController();
  final _dirigenteController = TextEditingController();
  final _pregadorController = TextEditingController();
  final _oradorController = TextEditingController();

  bool _cultoEspecial = false;
  bool _salvando = false;

  List<ItemPrograma> _itens = [];

  @override
  void initState() {
    super.initState();

    if (widget.programaExistente != null) {
      final programa = widget.programaExistente!;

      _tituloController.text = programa.titulo;
      _dataController.text = programa.data;
      _horaController.text = programa.hora;
      _localController.text = programa.local;
      _sinodoController.text = programa.sinodo;
      _congregacaoController.text = programa.congregacao;
      _dirigenteController.text = programa.dirigente;
      _pregadorController.text = programa.pregador;
      _oradorController.text = programa.orador;

      _cultoEspecial = programa.cultoEspecial;
      _itens = programa.itens
          .map((item) => item.copyWith())
          .toList();
    } else {
      _criarEstruturaPadrao();
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _dataController.dispose();
    _horaController.dispose();
    _localController.dispose();
    _dirigenteController.dispose();
    _pregadorController.dispose();
    _oradorController.dispose();
    _sinodoController.dispose();
    _congregacaoController.dispose();
    super.dispose();
  }

  // =========================================================
  // HELPER — REMOVER FOCO
  // =========================================================
  //
  // Sem isto, ao fechar qualquer modal/dialog, o Flutter
  // devolve o foco ao primeiro TextField focável que encontra,
  // o que fazia o cursor saltar para o campo "Orador".

  void _removerFoco() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  // =========================================================
  // NAVEGAÇÃO INFERIOR
  // =========================================================

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
      MaterialPageRoute<void>(
        builder: (_) => tela,
      ),
    );
  }

  // =========================================================
  // ESTRUTURA PADRÃO
  // =========================================================

  void _criarEstruturaPadrao() {
    _itens = [
      ItemPrograma(
        id: 'preludio',
        tipo: TipoItemPrograma.fixo,
        titulo: 'Pré-lúdio',
        subtitulo: 'Entrada dos Grupos Corais',
        fixo: true,
      ),
      ItemPrograma(
        id: 'invocatoria',
        tipo: TipoItemPrograma.invocatoria,
        titulo: 'Invocatória',
        subtitulo: 'Nenhuma invocatória selecionada',
        fixo: false,
      ),
      ItemPrograma(
        id: 'oracao_dirigente',
        tipo: TipoItemPrograma.fixo,
        titulo: 'Oração do Dirigente',
        subtitulo: 'Momento de oração',
        fixo: true,
      ),
      ItemPrograma(
        id: 'primeiro_hino',
        tipo: TipoItemPrograma.hino,
        titulo: 'Primeiro Hino do Culto',
        subtitulo: 'Nenhum hino selecionado',
        fixo: false,
      ),
      ItemPrograma(
        id: 'litania',
        tipo: TipoItemPrograma.litania,
        titulo: 'Litania',
        subtitulo: 'Nenhuma litania selecionada',
        fixo: false,
      ),
      ItemPrograma(
        id: 'coral_1',
        tipo: TipoItemPrograma.coral,
        titulo: 'Momento de Louvor',
        subtitulo: 'Adicionar os três grupos Corais',
        fixo: false,
      ),
      ItemPrograma(
        id: 'anuncios_trabalho_igreja',
        tipo: TipoItemPrograma.fixo,
        titulo: 'Anúncios sobre o trabalho da Igreja',
        subtitulo: 'Apresentação de visitas e Aniversariantes',
        fixo: true,
      ),
      ItemPrograma(
        id: 'coral_2',
        tipo: TipoItemPrograma.coral,
        titulo: 'Momento de Louvor',
        subtitulo: 'Adicionar outros grupos corais',
        fixo: false,
      ),
      ItemPrograma(
        id: 'salmo',
        tipo: TipoItemPrograma.salmo,
        titulo: 'Leitura do Salmo',
        subtitulo: 'Selecionar o salmo',
        fixo: false,
      ),
      ItemPrograma(
        id: 'momento_ofertorio',
        tipo: TipoItemPrograma.fixo,
        titulo: 'Momento Ofertório',
        subtitulo: 'Seguido de Coros de Exaltação',
        fixo: true,
      ),
      ItemPrograma(
        id: 'oracao_intercessora',
        tipo: TipoItemPrograma.fixo,
        titulo: 'Oração Intercessora',
        subtitulo: 'Momento de intercessão',
        fixo: true,
      ),
      ItemPrograma(
        id: 'leitura_biblica',
        tipo: TipoItemPrograma.leituraBiblica,
        titulo: 'Leitura Bíblica com base ao Sermão',
        subtitulo: 'Selecionar referência',
        fixo: false,
      ),
      ItemPrograma(
        id: 'hino_final',
        tipo: TipoItemPrograma.hino,
        titulo: 'Hino Final',
        subtitulo: 'Nenhum hino selecionado',
        fixo: false,
      ),
      ItemPrograma(
        id: 'oracao_final',
        tipo: TipoItemPrograma.fixo,
        titulo: 'Oração Final',
        subtitulo: 'Momento de oração',
        fixo: true,
      ),
      ItemPrograma(
        id: 'posludio',
        tipo: TipoItemPrograma.fixo,
        titulo: 'Pós-lúdio',
        subtitulo: 'Saída',
        fixo: true,
      ),
    ];

    if (mounted) {
      setState(() {});
    }
  }

  // =========================================================
  // DATA
  // =========================================================

  Future<void> _selecionarData() async {
    _removerFoco();

    final agora = DateTime.now();

    DateTime inicial = agora;

    if (_dataController.text.isNotEmpty) {
      try {
        final partes = _dataController.text.split('/');

        if (partes.length == 3) {
          inicial = DateTime(
            int.parse(partes[2]),
            int.parse(partes[1]),
            int.parse(partes[0]),
          );
        }
      } catch (_) {}
    }

    final data = await showDatePicker(
      context: context,
      initialDate: inicial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: corPrimaria,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: corTexto,
            ),
          ),
          child: child!,
        );
      },
    );

    if (data == null) return;

    setState(() {
      _dataController.text =
          '${data.day.toString().padLeft(2, '0')}/'
          '${data.month.toString().padLeft(2, '0')}/'
          '${data.year}';
    });

    _removerFoco();
  }

  Future<void> _selecionarHora() async {
    _removerFoco();

    TimeOfDay inicial = TimeOfDay.now();

    if (_horaController.text.isNotEmpty) {
      try {
        final partes = _horaController.text.split(':');

        if (partes.length == 2) {
          inicial = TimeOfDay(
            hour: int.parse(partes[0]),
            minute: int.parse(partes[1]),
          );
        }
      } catch (_) {}
    }

    final hora = await showTimePicker(
      context: context,
      initialTime: inicial,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: corPrimaria,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: corTexto,
            ),
          ),
          child: child!,
        );
      },
    );

    if (hora == null) return;

    setState(() {
      _horaController.text =
          '${hora.hour.toString().padLeft(2, '0')}:'
          '${hora.minute.toString().padLeft(2, '0')}';
    });

    _removerFoco();
  }

  // =========================================================
  // SELEÇÃO DE IDIOMA
  // =========================================================

  Future<String?> _selecionarIdioma() async {
    _removerFoco();

    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const _SelecaoIdiomaBottomSheet(),
    );
  }

  // =========================================================
  // HINO
  // =========================================================

  Future<void> _configurarHino(ItemPrograma item) async {
    _removerFoco();

    final idioma = await _selecionarIdioma();

    if (idioma == null) return;

    final hinos = await HinosServico.carregarHinos(
      idioma: idioma,
    );

    if (!mounted) return;

    _removerFoco();

    final resultado = await showModalBottomSheet<Hino>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SelecaoHinoBottomSheet(
        hinos: hinos,
      ),
    );

    if (resultado == null) return;

    setState(() {
      item.titulo = resultado.titulo;
      item.subtitulo = 'Hino nº ${resultado.numero}';
      item.referencia = 'Hino nº ${resultado.numero}';
      item.conteudo = resultado.estrofes.join('\n\n');
    });

    _removerFoco();
  }

  // =========================================================
  // INVOCATÓRIA
  // =========================================================

  Future<void> _configurarInvocatoria(ItemPrograma item) async {
    _removerFoco();

    final idioma = await _selecionarIdioma();

    if (idioma == null) return;

    final invocatorias = await InvocatoriasServico.carregar(
      idioma: idioma,
    );

    if (!mounted) return;

    _removerFoco();

    final resultado = await showModalBottomSheet<Invocatoria>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SelecaoInvocatoriaBottomSheet(
        invocatorias: invocatorias,
      ),
    );

    if (resultado == null) return;

    setState(() {
      item.titulo = resultado.titulo;
      item.subtitulo = 'Invocatória nº ${resultado.numero}';
      item.referencia = 'Invocatória nº ${resultado.numero}';
      item.conteudo = resultado.texto;
    });

    _removerFoco();
  }

  // =========================================================
  // LITANIA
  // =========================================================

  Future<void> _configurarLitania(ItemPrograma item) async {
    _removerFoco();

    final idioma = await _selecionarIdioma();

    if (idioma == null) return;

    final litanias = await LitaniasServico.carregarLitanias(
      idioma: idioma,
    );

    if (!mounted) return;

    _removerFoco();

    final resultado = await showModalBottomSheet<Litania>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SelecaoLitaniaBottomSheet(
        litanias: litanias,
      ),
    );

    if (resultado == null) return;

    setState(() {
      item.titulo = resultado.titulo;
      item.subtitulo = resultado.subtitulo.isNotEmpty
          ? resultado.subtitulo
          : 'Litania selecionada';
      item.referencia = resultado.titulo;
      item.conteudo = resultado.texto;
    });

    _removerFoco();
  }

  // =========================================================
  // SALMO
  // =========================================================

  Future<void> _configurarSalmo(ItemPrograma item) async {
    _removerFoco();

    final resultado = await showModalBottomSheet<_ResultadoSalmo>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SalmoBottomSheet(),
    );

    if (resultado == null) return;

    setState(() {
      item.titulo = resultado.titulo;
      item.subtitulo = resultado.subtitulo;
      item.referencia = resultado.referencia;
      item.conteudo = resultado.conteudo;
    });

    _removerFoco();
  }

  // =========================================================
  // GRUPOS CORAIS
  // =========================================================

  Future<void> _configurarGruposCorais(ItemPrograma item) async {
    _removerFoco();

    final g1Controller = TextEditingController();
    final g2Controller = TextEditingController();
    final g3Controller = TextEditingController();

    if (item.subtitulo.contains(',')) {
      final partes = item.subtitulo.split(',');
      if (partes.length >= 1) g1Controller.text = partes[0].trim();
      if (partes.length >= 2) g2Controller.text = partes[1].trim();
      if (partes.length >= 3) g3Controller.text = partes[2].trim();
    }

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text('Grupos Corais'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: g1Controller,
                decoration: const InputDecoration(
                  labelText: 'Grupo 1',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: g2Controller,
                decoration: const InputDecoration(
                  labelText: 'Grupo 2',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: g3Controller,
                decoration: const InputDecoration(
                  labelText: 'Grupo 3',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final grupos = [
                  g1Controller.text.trim(),
                  g2Controller.text.trim(),
                  g3Controller.text.trim(),
                ].where((g) => g.isNotEmpty).join(', ');

                setState(() {
                  item.subtitulo = grupos.isNotEmpty
                      ? grupos
                      : 'Nenhum grupo informado';
                });

                Navigator.pop(context);
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );

    g1Controller.dispose();
    g2Controller.dispose();
    g3Controller.dispose();

    _removerFoco();
  }

  // =========================================================
  // CONFIGURAÇÃO DOS ITENS
  // =========================================================

  Future<void> _configurarItem(ItemPrograma item) async {
    if (item.fixo) return;

    _removerFoco();

    switch (item.tipo) {
      case TipoItemPrograma.hino:
        await _configurarHino(item);
        break;

      case TipoItemPrograma.invocatoria:
        await _configurarInvocatoria(item);
        break;

      case TipoItemPrograma.litania:
        await _configurarLitania(item);
        break;

      case TipoItemPrograma.salmo:
        await _configurarSalmo(item);
        break;

      case TipoItemPrograma.leituraBiblica:
        await _configurarLeituraBiblica(item);
        break;

      case TipoItemPrograma.coral:
        await _configurarGruposCorais(item);
        break;

      default:
        await _editarItem(item);
    }
  }

  // =========================================================
  // EDITAR ITEM
  // =========================================================

  Future<void> _editarItem(ItemPrograma item) async {
    if (item.fixo) return;

    _removerFoco();

    final tituloController =
        TextEditingController(text: item.titulo);

    final subtituloController =
        TextEditingController(text: item.subtitulo);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(
              20,
              12,
              20,
              24,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Editar elemento',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: corTexto,
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: tituloController,
                    decoration: _inputDecoration(
                      'Título',
                      Icons.title,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: subtituloController,
                    decoration: _inputDecoration(
                      'Descrição',
                      Icons.notes_outlined,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          item.titulo =
                              tituloController.text.trim();

                          item.subtitulo =
                              subtituloController.text.trim();
                        });

                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('Guardar alterações'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: corPrimaria,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    tituloController.dispose();
    subtituloController.dispose();

    _removerFoco();
  }

  // =========================================================
  // LEITURA BÍBLICA
  // =========================================================

  Future<void> _configurarLeituraBiblica(ItemPrograma item) async {
    _removerFoco();

    final livroController = TextEditingController();
    final capituloController = TextEditingController();
    final versiculoController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text('Leitura Bíblica'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: livroController,
                decoration: const InputDecoration(
                  labelText: 'Livro',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: capituloController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Capítulo',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: versiculoController,
                decoration: const InputDecoration(
                  labelText: 'Versículo(s)',
                  hintText: 'Ex: 16 ou 16-18',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final referencia =
                    '${livroController.text} '
                    '${capituloController.text}:'
                    '${versiculoController.text}';

                setState(() {
                  item.titulo = 'Leitura Bíblica';
                  item.subtitulo = referencia;
                  item.referencia = referencia;
                });

                Navigator.pop(context);
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );

    livroController.dispose();
    capituloController.dispose();
    versiculoController.dispose();

    _removerFoco();
  }

  // =========================================================
  // REMOVER
  // =========================================================

  Future<void> _removerItem(int index) async {
    _removerFoco();

    final item = _itens[index];

    if (item.fixo) {
      return;
    }

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'Remover elemento?',
            style: TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'Deseja remover "${item.titulo}" do programa?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: corTexto),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Remover',
                style: TextStyle(color: corPrimaria),
              ),
            ),
          ],
        );
      },
    );

    if (confirmar != true) {
      _removerFoco();
      return;
    }

    setState(() {
      _itens.removeAt(index);
    });

    _removerFoco();
  }

  // =========================================================
  // DUPLICAR
  // =========================================================

  void _duplicarItem(int index) {
    _removerFoco();

    final original = _itens[index];

    if (original.fixo) return;

    final copia = original.copyWith(
      id: '${original.id}_${DateTime.now().microsecondsSinceEpoch}',
      titulo: original.titulo,
      subtitulo: original.subtitulo,
      fixo: false,
    );

    setState(() {
      _itens.insert(index + 1, copia);
    });
  }

  // =========================================================
  // ADICIONAR ITEM
  // =========================================================

  Future<void> _adicionarItem() async {
    _removerFoco();

    final tipo = await showModalBottomSheet<TipoItemPrograma>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _AdicionarItemBottomSheet(),
    );

    if (tipo == null) {
      _removerFoco();
      return;
    }

    final novo = ItemPrograma(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      tipo: tipo,
      titulo: _tituloTipo(tipo),
      subtitulo: _subtituloTipo(tipo),
      fixo: false,
    );

    setState(() {
      _itens.add(novo);
    });

    if (tipo == TipoItemPrograma.hino ||
        tipo == TipoItemPrograma.invocatoria ||
        tipo == TipoItemPrograma.litania ||
        tipo == TipoItemPrograma.salmo ||
        tipo == TipoItemPrograma.leituraBiblica ||
        tipo == TipoItemPrograma.coral) {
      await _configurarItem(novo);
    }

    _removerFoco();
  }

  String _tituloTipo(TipoItemPrograma tipo) {
    switch (tipo) {
      case TipoItemPrograma.hino:
        return 'Novo Hino';

      case TipoItemPrograma.invocatoria:
        return 'Invocatória';

      case TipoItemPrograma.litania:
        return 'Litania';

      case TipoItemPrograma.salmo:
        return 'Leitura do Salmo';

      case TipoItemPrograma.leituraBiblica:
        return 'Leitura Bíblica';

      case TipoItemPrograma.coral:
        return 'Grupos Corais';

      case TipoItemPrograma.oracao:
        return 'Oração';

      case TipoItemPrograma.louvor:
        return 'Louvor';

      case TipoItemPrograma.anuncio:
        return 'Anúncio';

      case TipoItemPrograma.oferta:
        return 'Oferta';

      case TipoItemPrograma.santaCeia:
        return 'Santa Ceia';

      case TipoItemPrograma.momentoMissionario:
        return 'Momento Missionário';

      case TipoItemPrograma.testemunho:
        return 'Testemunho';

      case TipoItemPrograma.personalizado:
        return 'Elemento Personalizado';

      case TipoItemPrograma.fixo:
        return 'Elemento Fixo';
    }
  }

  String _subtituloTipo(TipoItemPrograma tipo) {
    switch (tipo) {
      case TipoItemPrograma.hino:
        return 'Selecionar hino';

      case TipoItemPrograma.invocatoria:
        return 'Selecionar invocatória';

      case TipoItemPrograma.litania:
        return 'Selecionar litania';

      case TipoItemPrograma.salmo:
        return 'Selecionar salmo';

      case TipoItemPrograma.coral:
        return 'Participação dos grupos corais';

      default:
        return 'Elemento configurável';
    }
  }

  // =========================================================
  // TIPO DE CULTO
  // =========================================================

  Future<void> _alternarTipoCulto(bool especial) async {
    _removerFoco();

    if (especial == _cultoEspecial) return;

    if (especial) {
      setState(() {
        _cultoEspecial = true;
      });

      return;
    }

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'Voltar ao culto padrão?',
            style: TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
          content: const Text(
            'A estrutura personalizada será substituída '
            'pela ordem litúrgica padrão.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: corTexto),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Continuar',
                style: TextStyle(color: corPrimaria),
              ),
            ),
          ],
        );
      },
    );

    if (confirmar != true) {
      _removerFoco();
      return;
    }

    setState(() {
      _cultoEspecial = false;
    });

    _criarEstruturaPadrao();
    _removerFoco();
  }

  // =========================================================
  // SALVAR
  // =========================================================

  Future<void> _salvarPrograma() async {
    _removerFoco();

    if (_salvando) return;

    if (_tituloController.text.trim().isEmpty) {
      _mostrarMensagem(
        'Informe o título do culto.',
      );
      return;
    }

    setState(() {
      _salvando = true;
    });

    final programa = ProgramaCulto(
      id: widget.programaExistente?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      titulo: _tituloController.text.trim(),
      data: _dataController.text.trim(),
      hora: _horaController.text.trim(),
      sinodo: _sinodoController.text.trim(),
      local: _localController.text.trim(),
      congregacao: _congregacaoController.text.trim(),
      dirigente: _dirigenteController.text.trim(),
      pregador: _pregadorController.text.trim(),
      orador: _oradorController.text.trim(),
      tipoCulto: _cultoEspecial ? 'especial' : 'padrao',
      itens: _itens,
    );

    try {
      await _programasServico.guardarPrograma(programa);

      if (!mounted) return;

      _mostrarMensagem(
        'Programa guardado com sucesso.',
      );

      Navigator.pop(context, programa);
    } catch (_) {
      if (!mounted) return;

      _mostrarMensagem(
        'Não foi possível guardar o programa.',
        erro: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _salvando = false;
        });
      }
    }
  }

  // =========================================================
  // PREVISUALIZAÇÃO
  // =========================================================

  void _previsualizar() {
    _removerFoco();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PrevisualizacaoPrograma(
        titulo: _tituloController.text.trim().isEmpty
            ? 'Programa do Culto'
            : _tituloController.text.trim(),
        data: _dataController.text.trim(),
        hora: _horaController.text.trim(),
        local: _localController.text.trim(),
        dirigente: _dirigenteController.text.trim(),
        itens: _itens,
      ),
    ).then((_) {
      _removerFoco();
    });
  }

  // =========================================================
  // MENSAGEM
  // =========================================================

  void _mostrarMensagem(
    String mensagem, {
    bool erro = false,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(mensagem),
          backgroundColor:
              erro ? Colors.red.shade700 : corTerciaria,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
  }

  // =========================================================
  // UI
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: corSuperficie,
      appBar: const CabecalhoIeca(),
      body: SafeArea(
        top: false,
        bottom: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: 100 +
                MediaQuery.of(context).padding.bottom,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 760,
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  20,
                  16,
                  40,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.stretch,
                  children: [
                    _buildIntroducao(),

                    const SizedBox(height: 20),

                    _buildSecaoInformacoes(),

                    const SizedBox(height: 20),

                    _buildSecaoTipoCulto(),

                    const SizedBox(height: 20),

                    _buildSecaoOrdemCulto(),

                    const SizedBox(height: 20),

                    _buildSecaoCultosEspeciais(),

                    const SizedBox(height: 20),

                    _buildAcoes(),

                    const SizedBox(height: 18),

                    _buildOffline(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: NavegacaoInferiorIeca(
        indiceSelecionado: 1,
        onDestinationSelected: _selecionarNavegacao,
      ),
    );
  }

  Widget _buildIntroducao() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        4,
        6,
        4,
        8,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: corPrimariaClara,
              borderRadius:
                  BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.event_note,
              color: corPrimaria,
              size: 27,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'NOVO PROGRAMA',
                  style: TextStyle(
                    color: corPrimaria,
                    fontSize: 10,
                    height: 15 / 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Prepare o culto',
                  style: TextStyle(
                    color: corTexto,
                    fontSize: 24,
                    height: 30 / 24,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Organize a ordem litúrgica e prepare '
                  'o programa para a celebração.',
                  style: const TextStyle(
                    color: corTextoSecundario,
                    fontSize: 12,
                    height: 19 / 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecaoInformacoes() {
    return _buildSecao(
      numero: '01',
      titulo: 'Informações do culto',
      descricao: 'Dados básicos do programa',
      child: Column(
        children: [
          _buildCampo(
            label: 'Título do Culto',
            controller: _tituloController,
            icon: Icons.church,
            hint: 'Ex.: Culto de Domingo de Ramos',
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _buildCampo(
                  label: 'Data',
                  controller: _dataController,
                  icon: Icons.calendar_month,
                  hint: 'Data',
                  readOnly: true,
                  onTap: _selecionarData,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCampo(
                  label: 'Hora',
                  controller: _horaController,
                  icon: Icons.schedule,
                  hint: 'Hora',
                  readOnly: true,
                  onTap: _selecionarHora,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),

          _buildCampo(
            label: 'Sínodo',
            controller: _sinodoController,
            icon: Icons.account_balance,
            hint: 'Nome do sínodo',
          ),

          const SizedBox(height: 15),

          _buildCampo(
            label: 'Pastorado',
            controller: _localController,
            icon: Icons.location_on,
            hint: 'Nome do pastorado',
          ),

          const SizedBox(height: 15),

          _buildCampo(
            label: 'Congregação',
            controller: _congregacaoController,
            icon: Icons.groups,
            hint: 'Nome da congregação',
          ),

          const SizedBox(height: 15),

          _buildCampo(
            label: 'Dirigente',
            controller: _dirigenteController,
            icon: Icons.person,
            hint: 'Nome do dirigente',
          ),

          const SizedBox(height: 15),

          _buildCampo(
            label: 'Pregador',
            controller: _pregadorController,
            icon: Icons.person,
            hint: 'Nome do pregador',
          ),

          const SizedBox(height: 15),

          _buildCampo(
            label: 'Orador',
            controller: _oradorController,
            icon: Icons.person,
            hint: 'Nome do orador',
          ),
        ],
      ),
    );
  }

  Widget _buildSecaoTipoCulto() {
    return _buildSecao(
      numero: '02',
      titulo: 'Tipo de culto',
      descricao: 'Escolha a estrutura do programa',
      child: Column(
        children: [
          _buildOpcaoTipo(
            selecionado: !_cultoEspecial,
            titulo: 'Culto padrão',
            descricao:
                'Usar a ordem litúrgica habitual',
            icon: Icons.church,
            especial: false,
            onTap: () => _alternarTipoCulto(false),
          ),
          const SizedBox(height: 10),
          _buildOpcaoTipo(
            selecionado: _cultoEspecial,
            titulo: 'Culto especial',
            descricao:
                'Criar uma ordem personalizada',
            icon: Icons.tune,
            especial: true,
            onTap: () => _alternarTipoCulto(true),
          ),
        ],
      ),
    );
  }

  Widget _buildSecaoOrdemCulto() {
    return _buildSecao(
      numero: '03',
      titulo: 'Ordem do culto',
      descricao: _cultoEspecial
          ? 'Estrutura litúrgica personalizada'
          : 'Estrutura litúrgica padrão',
      child: Column(
        children: [
          _buildAvisoEstrutura(),

          const SizedBox(height: 0),

          _cultoEspecial
              ? _buildListaEspecial()
              : _buildListaPadrao(),

          const SizedBox(height: 12),

          _buildBotaoAdicionarItem(),
        ],
      ),
    );
  }

  Widget _buildSecaoCultosEspeciais() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white,
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _buildCabecalhoSecao(
            numero: '04',
            titulo: 'Cultos especiais',
            descricao: 'Estrutura personalizada',
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF6E8),
              borderRadius:
                  BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: corSecundariaContainer,
                    borderRadius:
                        BorderRadius.circular(13),
                  ),
                  child: const Icon(
                    Icons.tune,
                    color: Color(0xFF684100),
                    size: 21,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'O culto possui uma ordem diferente?',
                        style: TextStyle(
                          fontSize: 12,
                          height: 17 / 12,
                          fontWeight: FontWeight.w700,
                          color: corTexto,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Para cultos especiais, como celebrações, '
                        'conferências ou outras ocasiões, poderá '
                        'ser criada uma estrutura própria.',
                        style: TextStyle(
                          color: corTextoSecundario,
                          fontSize: 10,
                          height: 16 / 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () =>
                  _alternarTipoCulto(true),
              icon: const Icon(
                Icons.add,
                size: 20,
              ),
              label: const Text(
                'Criar estrutura personalizada',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    corSecundariaContainer,
                foregroundColor:
                    const Color(0xFF684100),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(14),
                ),
                textStyle: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcoes() {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: SizedBox(
            height: 52,
            child: OutlinedButton.icon(
              onPressed: _previsualizar,
              icon: const Icon(
                Icons.visibility,
                size: 19,
              ),
              label: const Text('Pré-visualizar'),
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: corTexto,
                side: BorderSide(
                  color:
                      Colors.black.withValues(alpha: 0.10),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 1,
          child: SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed:
                  _salvando ? null : _salvarPrograma,
              icon: _salvando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(
                      Icons.save,
                      size: 19,
                    ),
              label: Text(
                _salvando
                    ? 'A guardar...'
                    : 'Salvar Programa',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: corPrimaria,
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                    corPrimaria.withValues(alpha: 0.65),
                elevation: 2,
                shadowColor:
                    corPrimaria.withValues(alpha: 0.17),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOffline() {
    return const Row(
      mainAxisAlignment:
          MainAxisAlignment.center,
      children: [
        Icon(
          Icons.cloud_off,
          color: corTerciaria,
          size: 16,
        ),
        SizedBox(width: 6),
        Flexible(
          child: Text(
            'O programa será guardado no dispositivo '
            'e poderá ser utilizado offline.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: corTextoSecundario,
              fontSize: 9,
              height: 15 / 9,
            ),
          ),
        ),
      ],
    );
  }

  // =========================================================
  // LISTA PADRÃO
  // =========================================================

  Widget _buildListaPadrao() {
    return Column(
      children: List.generate(
        _itens.length,
        (index) => Padding(
          padding: EdgeInsets.only(
            bottom: index == _itens.length - 1
                ? 0
                : 8,
          ),
          child: _buildItemCard(
            _itens[index],
            index,
          ),
        ),
      ),
    );
  }

  // =========================================================
  // LISTA ESPECIAL
  // =========================================================

  Widget _buildListaEspecial() {
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics:
          const NeverScrollableScrollPhysics(),
      buildDefaultDragHandles: false,
      itemCount: _itens.length,
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (newIndex > oldIndex) {
            newIndex--;
          }

          final item = _itens.removeAt(oldIndex);
          _itens.insert(newIndex, item);
        });
      },
      itemBuilder: (context, index) {
        final item = _itens[index];

        return Padding(
          key: ValueKey(item.id),
          padding: EdgeInsets.only(
            bottom: index == _itens.length - 1
                ? 0
                : 8,
          ),
          child: _buildItemCard(
            item,
            index,
            modoEspecial: true,
          ),
        );
      },
    );
  }

  // =========================================================
  // ITEM
  // =========================================================

  Widget _buildItemCard(
    ItemPrograma item,
    int index, {
    bool modoEspecial = false,
  }) {
    final configuravel =
        item.tipo == TipoItemPrograma.hino ||
        item.tipo == TipoItemPrograma.invocatoria ||
        item.tipo == TipoItemPrograma.litania ||
        item.tipo == TipoItemPrograma.salmo ||
        item.tipo == TipoItemPrograma.leituraBiblica ||
        item.tipo == TipoItemPrograma.coral;

    final tipoLabel =
        _tipoLabel(item, configuravel);

    final tipoClasse =
        _tipoClasse(item, configuravel);

    final corIcone =
        _corIconeItem(item);

    final corFundoIcone =
        _corFundoIconeItem(item);

    Widget conteudo = Container(
      constraints: const BoxConstraints(
        minHeight: 72,
      ),
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: corSuperficie,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.07),
        ),
      ),
      child: Row(
        children: [
          _buildNumeroItem(index),

          const SizedBox(width: 8),

          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: corFundoIcone,
              borderRadius:
                  BorderRadius.circular(12),
            ),
            child: Icon(
              _iconeItem(item),
              color: corIcone,
              size: 20,
            ),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  tipoLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: tipoClasse == 'fixo'
                        ? const Color(0xFF667085)
                        : tipoClasse == 'hinario'
                            ? corTerciaria
                            : tipoClasse == 'opcional'
                                ? corSecundaria
                                : corPrimaria,
                    fontSize: 8,
                    height: 13 / 8,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.7,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  item.titulo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: corTexto,
                    fontSize: 12,
                    height: 17 / 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (item.subtitulo.isNotEmpty)
                  Text(
                    item.subtitulo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: corTextoSecundario,
                      fontSize: 9,
                      height: 14 / 9,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 6),

          if (modoEspecial && !item.fixo)
            ReorderableDragStartListener(
              index: index,
              child: const SizedBox(
                width: 32,
                height: 32,
                child: Icon(
                  Icons.drag_indicator,
                  color: Colors.black38,
                  size: 20,
                ),
              ),
            )
          else if (item.fixo)
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock,
                color: Color(0xFF9298A2),
                size: 17,
              ),
            )
          else
            PopupMenuButton<String>(
              padding: EdgeInsets.zero,
              icon: const Icon(
                Icons.more_vert,
                size: 21,
                color: corTextoSecundario,
              ),
              onSelected: (valor) {
                switch (valor) {
                  case 'editar':
                    if (configuravel) {
                      _configurarItem(item);
                    } else {
                      _editarItem(item);
                    }
                    break;

                  case 'duplicar':
                    _duplicarItem(index);
                    break;

                  case 'remover':
                    _removerItem(index);
                    break;
                }
              },
              itemBuilder: (context) {
                return [
                  const PopupMenuItem(
                    value: 'editar',
                    child: Row(
                      children: [
                        Icon(
                          Icons.edit_outlined,
                          size: 19,
                        ),
                        SizedBox(width: 10),
                        Text('Editar'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'duplicar',
                    child: Row(
                      children: [
                        Icon(
                          Icons.copy_outlined,
                          size: 19,
                        ),
                        SizedBox(width: 10),
                        Text('Duplicar'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'remover',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline,
                          size: 19,
                          color: Colors.red,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Remover',
                          style: TextStyle(
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ];
              },
            ),
        ],
      ),
    );

    if (item.fixo) {
      return conteudo;
    }

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        if (configuravel) {
          _configurarItem(item);
        } else {
          _editarItem(item);
        }
      },
      child: conteudo,
    );
  }

  Widget _buildNumeroItem(int index) {
    return Container(
      width: 30,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(9),
      ),
      child: Text(
        '${index + 1}'.padLeft(2, '0'),
        style: const TextStyle(
          color: corTextoSecundario,
          fontSize: 9,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // =========================================================
  // TIPOS
  // =========================================================

  String _tipoLabel(
    ItemPrograma item,
    bool configuravel,
  ) {
    if (item.fixo) return 'FIXO';

    switch (item.tipo) {
      case TipoItemPrograma.hino:
      case TipoItemPrograma.invocatoria:
      case TipoItemPrograma.litania:
        return 'HINÁRIO';

      case TipoItemPrograma.salmo:
        return 'SALMO';

      case TipoItemPrograma.coral:
        return item.id == 'coral_2'
            ? 'OPCIONAL'
            : 'CONFIGURÁVEL';

      default:
        return configuravel
            ? 'CONFIGURÁVEL'
            : 'OPCIONAL';
    }
  }

  String _tipoClasse(
    ItemPrograma item,
    bool configuravel,
  ) {
    if (item.fixo) return 'fixo';

    if (item.id == 'coral_2') {
      return 'opcional';
    }

    if (item.tipo == TipoItemPrograma.hino ||
        item.tipo == TipoItemPrograma.invocatoria ||
        item.tipo == TipoItemPrograma.litania) {
      return 'hinario';
    }

    return configuravel
        ? 'configuravel'
        : 'opcional';
  }

  IconData _iconeItem(ItemPrograma item) {
    switch (item.tipo) {
      case TipoItemPrograma.hino:
        return Icons.music_note;

      case TipoItemPrograma.invocatoria:
      case TipoItemPrograma.litania:
        return Icons.menu_book;

      case TipoItemPrograma.salmo:
        return Icons.menu_book;

      case TipoItemPrograma.coral:
        return Icons.groups;

      case TipoItemPrograma.oracao:
        return Icons.volunteer_activism;

      case TipoItemPrograma.anuncio:
        return Icons.campaign;

      case TipoItemPrograma.oferta:
        return Icons.volunteer_activism;

      case TipoItemPrograma.leituraBiblica:
        return Icons.auto_stories;

      case TipoItemPrograma.louvor:
        return Icons.music_note;

      case TipoItemPrograma.santaCeia:
        return Icons.church;

      case TipoItemPrograma.momentoMissionario:
        return Icons.public;

      case TipoItemPrograma.testemunho:
        return Icons.record_voice_over;

      case TipoItemPrograma.personalizado:
        return Icons.edit_note;

      case TipoItemPrograma.fixo:
        if (item.id == 'posludio') {
          return Icons.music_off;
        }

        if (item.id == 'oracao_intercessora' ||
            item.id == 'oracao_final' ||
            item.id == 'oracao_dirigente') {
          return Icons.volunteer_activism;
        }

        if (item.id == 'anuncios_trabalho_igreja') {
          return Icons.campaign;
        }

        return Icons.music_note;
    }
  }

  Color _corIconeItem(ItemPrograma item) {
    switch (item.tipo) {
      case TipoItemPrograma.hino:
      case TipoItemPrograma.invocatoria:
      case TipoItemPrograma.litania:
        return corTerciaria;

      case TipoItemPrograma.coral:
        return corSecundaria;

      case TipoItemPrograma.salmo:
        return const Color(0xFF53638C);

      default:
        return const Color(0xFF667085);
    }
  }

  Color _corFundoIconeItem(ItemPrograma item) {
    switch (item.tipo) {
      case TipoItemPrograma.hino:
      case TipoItemPrograma.invocatoria:
      case TipoItemPrograma.litania:
        return const Color(0xFFDFF2F0);

      case TipoItemPrograma.coral:
        return const Color(0xFFFFF0D8);

      case TipoItemPrograma.salmo:
        return const Color(0xFFE8EAFA);

      default:
        return const Color(0xFFE9EDF3);
    }
  }

  // =========================================================
  // AVISO
  // =========================================================

  Widget _buildAvisoEstrutura() {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 14,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 11,
      ),
      decoration: BoxDecoration(
        color: corSuperficieBaixa,
        borderRadius:
            BorderRadius.circular(13),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info,
            color: corPrimaria,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _cultoEspecial
                  ? 'No culto especial, os elementos podem '
                    'ser reorganizados e personalizados.'
                  : 'Os momentos fixos fazem parte da ordem '
                    'litúrgica e não podem ser removidos.',
              style: const TextStyle(
                color: corTextoSecundario,
                fontSize: 10,
                height: 16 / 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // BOTÃO ADICIONAR
  // =========================================================

  Widget _buildBotaoAdicionarItem() {
    return Align(
      alignment: Alignment.centerRight,
      child: Material(
        color: corPrimariaClara,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: _adicionarItem,
          customBorder: const CircleBorder(),
          child: const SizedBox(
            width: 44,
            height: 44,
            child: Icon(
              Icons.add,
              color: corPrimaria,
              size: 21,
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================
  // SEÇÃO
  // =========================================================

  Widget _buildSecao({
    required String numero,
    required String titulo,
    required String descricao,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: corBranca,
        borderRadius:
            BorderRadius.circular(24),
        border: Border.all(
          color:
              Colors.black.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withValues(alpha: 0.035),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.stretch,
        children: [
          _buildCabecalhoSecao(
            numero: numero,
            titulo: titulo,
            descricao: descricao,
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildCabecalhoSecao({
    required String numero,
    required String titulo,
    required String descricao,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: corSuperficieBaixa,
            borderRadius:
                BorderRadius.circular(12),
          ),
          child: Text(
            numero,
            style: const TextStyle(
              color: corPrimaria,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: const TextStyle(
                  color: corTexto,
                  fontSize: 17,
                  height: 22 / 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                descricao,
                style: const TextStyle(
                  color: corTextoSecundario,
                  fontSize: 11,
                  height: 16 / 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // =========================================================
  // CAMPO
  // =========================================================

  Widget _buildCampo({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: 2,
            bottom: 7,
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: corTexto,
              fontSize: 11,
              height: 16 / 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          constraints: const BoxConstraints(
            minHeight: 50,
          ),
          decoration: BoxDecoration(
            color: corSuperficie,
            borderRadius:
                BorderRadius.circular(14),
            border: Border.all(
              color:
                  Colors.black.withValues(alpha: 0.09),
            ),
          ),
          child: TextField(
            controller: controller,
            readOnly: readOnly,
            onTap: onTap,
            textInputAction: TextInputAction.next,
            onSubmitted: (_) {
              // Ao premir "next" no teclado, avança para o próximo
              // campo em vez de deixar o foco "preso".
              FocusScope.of(context).nextFocus();
            },
            style: const TextStyle(
              color: corTexto,
              fontSize: 13,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hint,
              hintStyle: const TextStyle(
                color: Color(0xFF9096A0),
                fontSize: 13,
              ),
              prefixIcon: Icon(
                icon,
                color: corTextoSecundario,
                size: 20,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(
                horizontal: 13,
                vertical: 15,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // =========================================================
  // OPÇÃO TIPO
  // =========================================================

  Widget _buildOpcaoTipo({
    required bool selecionado,
    required String titulo,
    required String descricao,
    required IconData icon,
    required bool especial,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius:
          BorderRadius.circular(16),
      child: Container(
        constraints: const BoxConstraints(
          minHeight: 70,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: selecionado
              ? const Color(0xFFFFF6F6)
              : corSuperficie,
          borderRadius:
              BorderRadius.circular(16),
          border: Border.all(
            color: selecionado
                ? corPrimaria.withValues(alpha: 0.28)
                : Colors.black.withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selecionado
                      ? corPrimaria
                      : const Color(0xFFA3A8B0),
                  width: selecionado ? 5 : 2,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: especial
                    ? const Color(0xFFFFF0D7)
                    : corPrimariaClara,
                borderRadius:
                    BorderRadius.circular(13),
              ),
              child: Icon(
                icon,
                color: especial
                    ? corSecundaria
                    : corPrimaria,
                size: 21,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      color: corTexto,
                      fontSize: 13,
                      height: 18 / 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    descricao,
                    style: const TextStyle(
                      color: corTextoSecundario,
                      fontSize: 10,
                      height: 15 / 10,
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

  static InputDecoration _inputDecoration(
    String hint,
    IconData icon,
  ) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(
        icon,
        color: corTextoSecundario,
        size: 20,
      ),
      filled: true,
      fillColor: corSuperficie,
      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),
        borderSide: BorderSide(
          color:
              Colors.black.withValues(alpha: 0.09),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: corPrimaria,
        ),
      ),
    );
  }
}

// =============================================================
// BOTTOM SHEET — HINOS
// =============================================================

class _SelecaoHinoBottomSheet extends StatefulWidget {
  final List<Hino> hinos;

  const _SelecaoHinoBottomSheet({
    required this.hinos,
  });

  @override
  State<_SelecaoHinoBottomSheet> createState() =>
      _SelecaoHinoBottomSheetState();
}

class _SelecaoHinoBottomSheetState
    extends State<_SelecaoHinoBottomSheet> {
  final _pesquisaController =
      TextEditingController();

  String _pesquisa = '';

  @override
  void dispose() {
    _pesquisaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lista = widget.hinos.where((hino) {
      final termo = _pesquisa.toLowerCase();

      return hino.titulo
              .toLowerCase()
              .contains(termo) ||
          hino.numero.toString().contains(termo);
    }).toList();

    return _BottomSheetBase(
      titulo: 'Selecionar Hino',
      subtitulo: 'Escolha um hino do Hinário',
      child: Column(
        children: [
          TextField(
            controller: _pesquisaController,
            onChanged: (valor) {
              setState(() {
                _pesquisa = valor;
              });
            },
            decoration: const InputDecoration(
              hintText: 'Pesquisar hino...',
              prefixIcon:
                  Icon(Icons.search),
              filled: true,
              fillColor: Color(0xFFF8F9FF),
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.all(
                  Radius.circular(14),
                ),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: lista.isEmpty
                ? const Center(
                    child: Text(
                      'Nenhum hino encontrado.',
                    ),
                  )
                : ListView.separated(
                    itemCount: lista.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 8),
                    itemBuilder: (_, index) {
                      final hino = lista[index];

                      return ListTile(
                        onTap: () =>
                            Navigator.pop(
                          context,
                          hino,
                        ),
                        tileColor:
                            const Color(0xFFF8F9FF),
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(14),
                        ),
                        leading: Container(
                          width: 40,
                          height: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFFDFF2F0),
                            borderRadius:
                                BorderRadius.circular(11),
                          ),
                          child: Text(
                            hino.numero.toString(),
                            style:
                                const TextStyle(
                              color:
                                  Color(0xFF005754),
                              fontWeight:
                                  FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        title: Text(
                          hino.titulo,
                          maxLines: 2,
                          overflow:
                              TextOverflow.ellipsis,
                          style:
                              const TextStyle(
                            fontWeight:
                                FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        trailing:
                            const Icon(
                          Icons.chevron_right,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// =============================================================
// BOTTOM SHEET — INVOCATÓRIAS
// =============================================================

class _SelecaoInvocatoriaBottomSheet
    extends StatefulWidget {
  final List<Invocatoria> invocatorias;

  const _SelecaoInvocatoriaBottomSheet({
    required this.invocatorias,
  });

  @override
  State<_SelecaoInvocatoriaBottomSheet>
      createState() =>
          _SelecaoInvocatoriaBottomSheetState();
}

class _SelecaoInvocatoriaBottomSheetState
    extends State<_SelecaoInvocatoriaBottomSheet> {
  final _pesquisaController =
      TextEditingController();

  String _pesquisa = '';

  @override
  void dispose() {
    _pesquisaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lista =
        widget.invocatorias.where((item) {
      final termo =
          _pesquisa.toLowerCase();

      return item.titulo
          .toLowerCase()
          .contains(termo);
    }).toList();

    return _BottomSheetBase(
      titulo: 'Selecionar Invocatória',
      subtitulo:
          'Escolha uma invocatória do Hinário',
      child: Column(
        children: [
          TextField(
            controller: _pesquisaController,
            onChanged: (valor) {
              setState(() {
                _pesquisa = valor;
              });
            },
            decoration: const InputDecoration(
              hintText:
                  'Pesquisar invocatória...',
              prefixIcon:
                  Icon(Icons.search),
              filled: true,
              fillColor: Color(0xFFF8F9FF),
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.all(
                  Radius.circular(14),
                ),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: lista.isEmpty
                ? const Center(
                    child: Text(
                      'Nenhuma invocatória encontrada.',
                    ),
                  )
                : ListView.separated(
                    itemCount: lista.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 8),
                    itemBuilder: (_, index) {
                      final item = lista[index];

                      return ListTile(
                        onTap: () =>
                            Navigator.pop(
                          context,
                          item,
                        ),
                        tileColor:
                            const Color(0xFFF8F9FF),
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(14),
                        ),
                        leading: const Icon(
                          Icons.menu_book,
                          color:
                              Color(0xFF005754),
                        ),
                        title: Text(
                          item.titulo,
                          maxLines: 2,
                          overflow:
                              TextOverflow.ellipsis,
                          style:
                              const TextStyle(
                            fontWeight:
                                FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        trailing:
                            const Icon(
                          Icons.chevron_right,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// =============================================================
// BOTTOM SHEET — LITANIAS
// =============================================================

class _SelecaoLitaniaBottomSheet
    extends StatefulWidget {
  final List<Litania> litanias;

  const _SelecaoLitaniaBottomSheet({
    required this.litanias,
  });

  @override
  State<_SelecaoLitaniaBottomSheet>
      createState() =>
          _SelecaoLitaniaBottomSheetState();
}

class _SelecaoLitaniaBottomSheetState
    extends State<_SelecaoLitaniaBottomSheet> {
  final _pesquisaController =
      TextEditingController();

  String _pesquisa = '';

  @override
  void dispose() {
    _pesquisaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lista =
        widget.litanias.where((item) {
      final termo =
          _pesquisa.toLowerCase();

      return item.titulo
          .toLowerCase()
          .contains(termo);
    }).toList();

    return _BottomSheetBase(
      titulo: 'Selecionar Litania',
      subtitulo:
          'Escolha uma litania do Hinário',
      child: Column(
        children: [
          TextField(
            controller: _pesquisaController,
            onChanged: (valor) {
              setState(() {
                _pesquisa = valor;
              });
            },
            decoration: const InputDecoration(
              hintText:
                  'Pesquisar litania...',
              prefixIcon:
                  Icon(Icons.search),
              filled: true,
              fillColor: Color(0xFFF8F9FF),
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.all(
                  Radius.circular(14),
                ),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: lista.isEmpty
                ? const Center(
                    child: Text(
                      'Nenhuma litania encontrada.',
                    ),
                  )
                : ListView.separated(
                    itemCount: lista.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 8),
                    itemBuilder: (_, index) {
                      final item = lista[index];

                      return ListTile(
                        onTap: () =>
                            Navigator.pop(
                          context,
                          item,
                        ),
                        tileColor:
                            const Color(0xFFF8F9FF),
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(14),
                        ),
                        leading: const Icon(
                          Icons.menu_book,
                          color:
                              Color(0xFF005754),
                        ),
                        title: Text(
                          item.titulo,
                          maxLines: 2,
                          overflow:
                              TextOverflow.ellipsis,
                          style:
                              const TextStyle(
                            fontWeight:
                                FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        trailing:
                            const Icon(
                          Icons.chevron_right,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// =============================================================
// BOTTOM SHEET — SALMO
// =============================================================

class _ResultadoSalmo {
  final String titulo;
  final String subtitulo;
  final String referencia;
  final String conteudo;

  const _ResultadoSalmo({
    required this.titulo,
    required this.subtitulo,
    required this.referencia,
    required this.conteudo,
  });
}

class _SalmoBottomSheet extends StatelessWidget {
  _SalmoBottomSheet();

  static const List<int> _salmos = [
    19,
    24,
    33,
    34,
    46,
    67,
    90,
    96,
    100,
    103,
    115,
  ];

  @override
  Widget build(BuildContext context) {
    return _BottomSheetBase(
      titulo: 'Selecionar Salmo',
      subtitulo: 'Escolha a origem do Salmo',
      child: Column(
        children: [
          _buildOpcao(
            context,
            icone: Icons.menu_book_rounded,
            titulo: 'Selecionar do Hinário',
            subtitulo: 'Salmos disponíveis no Hinário IECA',
            aoSelecionar: () async {
              final numero =
                  await showModalBottomSheet<int>(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) =>
                    _ListaSalmosBottomSheet(
                  salmos: _salmos,
                ),
              );

              if (numero == null || !context.mounted) {
                return;
              }

              Navigator.pop(
                context,
                _ResultadoSalmo(
                  titulo: 'Salmo $numero',
                  subtitulo: 'Salmo selecionado do Hinário',
                  referencia: 'Salmo $numero',
                  conteudo: '',
                ),
              );
            },
          ),

          const SizedBox(height: 12),

          _buildOpcao(
            context,
            icone: Icons.menu_book_outlined,
            titulo: 'Selecionar da Bíblia',
            subtitulo: 'Selecionar um Salmo da Bíblia',
            aoSelecionar: () async {
              final resultado =
                  await showModalBottomSheet<_ResultadoSalmo>(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) =>
                    const _ListaSalmosBibliaBottomSheet(),
              );

              if (resultado == null || !context.mounted) {
                return;
              }

              Navigator.pop(
                context,
                resultado,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOpcao(
    BuildContext context, {
    required IconData icone,
    required String titulo,
    required String subtitulo,
    required Future<void> Function() aoSelecionar,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: aoSelecionar,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFF9E0027)
                      .withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  icone,
                  color: const Color(0xFF9E0027),
                  size: 27,
                ),
              ),

              const SizedBox(width: 15),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF121C2A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitulo,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 17,
                color: Colors.grey.shade500,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================
// LISTA DE SALMOS DA BÍBLIA
// =============================================================

class _ListaSalmosBibliaBottomSheet extends StatefulWidget {
  const _ListaSalmosBibliaBottomSheet();

  @override
  State<_ListaSalmosBibliaBottomSheet> createState() =>
      _ListaSalmosBibliaBottomSheetState();
}

class _ListaSalmosBibliaBottomSheetState
    extends State<_ListaSalmosBibliaBottomSheet> {
  final TextEditingController _pesquisaController =
      TextEditingController();

  List<BibliaCapitulo> _salmos = [];
  List<BibliaCapitulo> _salmosFiltrados = [];

  bool _carregando = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregarSalmos();

    _pesquisaController.addListener(
      _filtrarSalmos,
    );
  }

  @override
  void dispose() {
    _pesquisaController.dispose();
    super.dispose();
  }

  Future<void> _carregarSalmos() async {
    try {
      final livros = await BibliaServico.carregarBiblia(
        'assets/dados/por-almeida.usfx.xml',
      );

      if (!mounted) return;

      BibliaLivro? livroSalmos;

      for (final livro in livros) {
        final nome = livro.nome.toLowerCase();

        if (nome == 'salmos' ||
            nome.contains('salmos')) {
          livroSalmos = livro;
          break;
        }
      }

      if (livroSalmos == null) {
        setState(() {
          _erro = 'O livro de Salmos não foi encontrado.';
          _carregando = false;
        });
        return;
      }

      setState(() {
        _salmos = List<BibliaCapitulo>.from(
          livroSalmos!.capitulos,
        );

        _salmosFiltrados = List<BibliaCapitulo>.from(
          _salmos,
        );

        _carregando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _erro = 'Não foi possível carregar os Salmos.';
        _carregando = false;
      });
    }
  }

  void _filtrarSalmos() {
    final pesquisa =
        _pesquisaController.text.trim().toLowerCase();

    if (pesquisa.isEmpty) {
      setState(() {
        _salmosFiltrados =
            List<BibliaCapitulo>.from(_salmos);
      });
      return;
    }

    setState(() {
      _salmosFiltrados = _salmos.where((salmo) {
        return salmo.numero
            .toString()
            .contains(pesquisa);
      }).toList();
    });
  }

  void _selecionarSalmo(BibliaCapitulo salmo) {
    final texto = salmo.versiculos
        .map(
          (versiculo) =>
              '${versiculo.referencia} ${versiculo.texto}',
        )
        .join('\n\n');

    Navigator.pop(
      context,
      _ResultadoSalmo(
        titulo: 'Salmo ${salmo.numero}',
        subtitulo: 'Salmo ${salmo.numero} — Bíblia',
        referencia: 'Salmo ${salmo.numero}',
        conteudo: texto,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _BottomSheetBase(
      titulo: 'Salmos da Bíblia',
      subtitulo: 'Escolha um Salmo',
      child: Column(
        children: [
          TextField(
            controller: _pesquisaController,
            decoration: InputDecoration(
              hintText: 'Pesquisar Salmo...',
              prefixIcon: const Icon(
                Icons.search_rounded,
              ),
              suffixIcon:
                  _pesquisaController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _pesquisaController.clear();
                          },
                          icon: const Icon(
                            Icons.clear_rounded,
                          ),
                        )
                      : null,
              filled: true,
              fillColor: const Color(0xFFEFF4FF),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 16),

          Expanded(
            child: _buildConteudo(),
          ),
        ],
      ),
    );
  }

  Widget _buildConteudo() {
    if (_carregando) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF9E0027),
        ),
      );
    }

    if (_erro != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _erro!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF5B4040),
              fontSize: 15,
            ),
          ),
        ),
      );
    }

    if (_salmosFiltrados.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum Salmo encontrado.',
          style: TextStyle(
            fontSize: 15,
            color: Color(0xFF5B4040),
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: _salmosFiltrados.length,
      separatorBuilder: (_, __) =>
          const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final salmo = _salmosFiltrados[index];

        return Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _selecionarSalmo(salmo),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF9E0027)
                          .withValues(alpha: 0.10),
                      borderRadius:
                          BorderRadius.circular(13),
                    ),
                    child: const Icon(
                      Icons.menu_book_rounded,
                      color: Color(0xFF9E0027),
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Text(
                      'Salmo ${salmo.numero}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF121C2A),
                      ),
                    ),
                  ),

                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: Colors.grey.shade500,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// =============================================================
// BOTTOM SHEET — IDIOMA
// =============================================================

class _SelecaoIdiomaBottomSheet extends StatelessWidget {
  const _SelecaoIdiomaBottomSheet();

  @override
  Widget build(BuildContext context) {
    const corPrimaria = Color(0xFF9E0027);
    const corTexto = Color(0xFF121C2A);
    const corSuperficie = Color(0xFFF8F9FF);

    return Container(
      decoration: const BoxDecoration(
        color: corSuperficie,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            20,
            12,
            20,
            24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'Escolher idioma',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: corTexto,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                'Escolha o idioma do conteúdo',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),

              const SizedBox(height: 20),

              _buildOpcao(
                context: context,
                idioma: 'portugues',
                titulo: 'Português',
                subtitulo: 'Conteúdo em Português',
                icone: Icons.translate,
                cor: corPrimaria,
              ),

              const SizedBox(height: 12),

              _buildOpcao(
                context: context,
                idioma: 'umbundo',
                titulo: 'Umbundo',
                subtitulo: 'Conteúdo em Umbundo',
                icone: Icons.translate,
                cor: const Color(0xFF005754),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOpcao({
    required BuildContext context,
    required String idioma,
    required String titulo,
    required String subtitulo,
    required IconData icone,
    required Color cor,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.pop(context, idioma);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: cor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  icone,
                  color: cor,
                  size: 27,
                ),
              ),

              const SizedBox(width: 15),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF121C2A),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitulo,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 17,
                color: Colors.grey.shade500,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================
// LISTA DE SALMOS DO HINÁRIO
// =============================================================

class _ListaSalmosBottomSheet
    extends StatelessWidget {
  final List<int> salmos;

  const _ListaSalmosBottomSheet({
    required this.salmos,
  });

  @override
  Widget build(BuildContext context) {
    return _BottomSheetBase(
      titulo: 'Selecionar do Hinário',
      subtitulo:
          'Escolha um salmo disponível',
      child: ListView.separated(
        itemCount: salmos.length,
        separatorBuilder: (_, __) =>
            const SizedBox(height: 8),
        itemBuilder: (_, index) {
          final numero = salmos[index];

          return ListTile(
            onTap: () =>
                Navigator.pop(
              context,
              numero,
            ),
            tileColor:
                const Color(0xFFF8F9FF),
            shape:
                RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(14),
            ),
            leading: Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color:
                    const Color(0xFFE8EAFA),
                borderRadius:
                    BorderRadius.circular(11),
              ),
              child: const Icon(
                Icons.menu_book,
                color: Color(0xFF53638C),
                size: 20,
              ),
            ),
            title: Text(
              'Salmo $numero',
              style: const TextStyle(
                fontSize: 13,
                fontWeight:
                    FontWeight.w700,
              ),
            ),
            trailing: const Icon(
              Icons.chevron_right,
            ),
          );
        },
      ),
    );
  }
}

// =============================================================
// ADICIONAR ITEM
// =============================================================

class _AdicionarItemBottomSheet
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final opcoes = <_OpcaoItem>[
      _OpcaoItem(
        TipoItemPrograma.hino,
        'Hino',
        'Adicionar um hino do Hinário',
        Icons.music_note,
      ),
      _OpcaoItem(
        TipoItemPrograma.invocatoria,
        'Invocatória',
        'Selecionar uma invocatória',
        Icons.menu_book,
      ),
      _OpcaoItem(
        TipoItemPrograma.litania,
        'Litania',
        'Selecionar uma litania',
        Icons.menu_book,
      ),
      _OpcaoItem(
        TipoItemPrograma.salmo,
        'Salmo',
        'Selecionar ou escrever um salmo',
        Icons.menu_book,
      ),
      _OpcaoItem(
        TipoItemPrograma.leituraBiblica,
        'Leitura Bíblica',
        'Adicionar uma leitura bíblica',
        Icons.auto_stories,
      ),
      _OpcaoItem(
        TipoItemPrograma.coral,
        'Coral',
        'Adicionar participação coral',
        Icons.groups,
      ),
      _OpcaoItem(
        TipoItemPrograma.oracao,
        'Oração',
        'Adicionar um momento de oração',
        Icons.volunteer_activism,
      ),
      _OpcaoItem(
        TipoItemPrograma.louvor,
        'Louvor',
        'Adicionar momento de louvor',
        Icons.music_note,
      ),
      _OpcaoItem(
        TipoItemPrograma.anuncio,
        'Anúncio',
        'Adicionar um anúncio',
        Icons.campaign,
      ),
      _OpcaoItem(
        TipoItemPrograma.oferta,
        'Oferta',
        'Adicionar momento de oferta',
        Icons.volunteer_activism,
      ),
      _OpcaoItem(
        TipoItemPrograma.santaCeia,
        'Santa Ceia',
        'Adicionar Santa Ceia',
        Icons.restaurant,
      ),
      _OpcaoItem(
        TipoItemPrograma.momentoMissionario,
        'Momento Missionário',
        'Adicionar momento missionário',
        Icons.public,
      ),
      _OpcaoItem(
        TipoItemPrograma.testemunho,
        'Testemunho',
        'Adicionar testemunho',
        Icons.record_voice_over,
      ),
      _OpcaoItem(
        TipoItemPrograma.personalizado,
        'Elemento Personalizado',
        'Criar um elemento próprio',
        Icons.add_circle_outline,
      ),
    ];

    return _BottomSheetBase(
      titulo: 'Adicionar elemento',
      subtitulo:
          'Escolha o elemento que deseja adicionar',
      child: ListView.separated(
        itemCount: opcoes.length,
        separatorBuilder: (_, __) =>
            const SizedBox(height: 8),
        itemBuilder: (_, index) {
          final opcao = opcoes[index];

          return ListTile(
            onTap: () =>
                Navigator.pop(
              context,
              opcao.tipo,
            ),
            tileColor:
                const Color(0xFFF8F9FF),
            shape:
                RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(14),
            ),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color:
                    const Color(0xFFFFDAD9),
                borderRadius:
                    BorderRadius.circular(11),
              ),
              child: Icon(
                opcao.icon,
                color:
                    const Color(0xFF9E0027),
                size: 20,
              ),
            ),
            title: Text(
              opcao.titulo,
              style: const TextStyle(
                fontSize: 13,
                fontWeight:
                    FontWeight.w700,
              ),
            ),
            subtitle: Text(
              opcao.descricao,
              style: const TextStyle(
                fontSize: 10,
              ),
            ),
            trailing: const Icon(
              Icons.chevron_right,
            ),
          );
        },
      ),
    );
  }
}

class _OpcaoItem {
  final TipoItemPrograma tipo;
  final String titulo;
  final String descricao;
  final IconData icon;

  _OpcaoItem(
    this.tipo,
    this.titulo,
    this.descricao,
    this.icon,
  );
}

// =============================================================
// BASE DOS BOTTOM SHEETS
// =============================================================

class _BottomSheetBase extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final Widget child;

  const _BottomSheetBase({
    required this.titulo,
    required this.subtitulo,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height:
          MediaQuery.of(context).size.height * 0.82,
      padding: const EdgeInsets.fromLTRB(
        20,
        12,
        20,
        20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius:
                      BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              titulo,
              style: const TextStyle(
                color: Color(0xFF121C2A),
                fontSize: 19,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitulo,
              style: const TextStyle(
                color: Color(0xFF5B4040),
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================
// PRÉ-VISUALIZAÇÃO
// =============================================================

class _PrevisualizacaoPrograma
    extends StatelessWidget {
  final String titulo;
  final String data;
  final String hora;
  final String local;
  final String dirigente;
  final List<ItemPrograma> itens;

  const _PrevisualizacaoPrograma({
    required this.titulo,
    required this.data,
    required this.hora,
    required this.local,
    required this.dirigente,
    required this.itens,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height:
          MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: Color(0xFFF8F9FF),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius:
                    BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Pré-visualização',
              style: TextStyle(
                fontSize: 19,
                fontWeight:
                    FontWeight.w700,
                color: Color(0xFF121C2A),
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: ListView(
                padding:
                    const EdgeInsets.fromLTRB(
                  20,
                  0,
                  20,
                  30,
                ),
                children: [
                  Container(
                    padding:
                        const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.church,
                          color:
                              Color(0xFF9E0027),
                          size: 30,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          titulo,
                          textAlign:
                              TextAlign.center,
                          style:
                              const TextStyle(
                            fontSize: 19,
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),
                        if (data.isNotEmpty ||
                            hora.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            [
                              if (data.isNotEmpty)
                                data,
                              if (hora.isNotEmpty)
                                hora,
                            ].join(' • '),
                            style:
                                const TextStyle(
                              color:
                                  Color(0xFF5B4040),
                              fontSize: 11,
                            ),
                          ),
                        ],
                        if (local.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            local,
                            style:
                                const TextStyle(
                              color:
                                  Color(0xFF5B4040),
                              fontSize: 11,
                            ),
                          ),
                        ],
                        if (dirigente.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            'Dirigente: $dirigente',
                            style:
                                const TextStyle(
                              color:
                                  Color(0xFF5B4040),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  ...List.generate(
                    itens.length,
                    (index) {
                      final item =
                          itens[index];

                      return Padding(
                        padding:
                            const EdgeInsets.only(
                          bottom: 8,
                        ),
                        child: Container(
                          padding:
                              const EdgeInsets.all(
                            14,
                          ),
                          decoration:
                              BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(
                              16,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                alignment:
                                    Alignment.center,
                                decoration:
                                    BoxDecoration(
                                  color:
                                      const Color(
                                    0xFFEFF4FF,
                                  ),
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    9,
                                  ),
                                ),
                                child: Text(
                                  '${index + 1}'
                                      .padLeft(2, '0'),
                                  style:
                                      const TextStyle(
                                    color:
                                        Color(
                                      0xFF9E0027,
                                    ),
                                    fontSize: 9,
                                    fontWeight:
                                        FontWeight
                                            .w700,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                  children: [
                                    Text(
                                      item.titulo,
                                      style:
                                          const TextStyle(
                                        fontSize: 12,
                                        fontWeight:
                                            FontWeight
                                                .w700,
                                      ),
                                    ),
                                    if (item
                                        .subtitulo
                                        .isNotEmpty)
                                      Text(
                                        item.subtitulo,
                                        maxLines: 2,
                                        overflow:
                                            TextOverflow
                                                .ellipsis,
                                        style:
                                            const TextStyle(
                                          color:
                                              Color(
                                            0xFF5B4040,
                                          ),
                                          fontSize: 9,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              if (item.fixo)
                                const Icon(
                                  Icons.lock,
                                  size: 16,
                                  color:
                                      Color(
                                    0xFF9298A2,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
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