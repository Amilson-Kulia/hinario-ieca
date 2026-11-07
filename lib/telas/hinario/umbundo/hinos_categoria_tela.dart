import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/tema.dart';
import '../../../componentes/cabecalho_ieca.dart';
import '../../../componentes/navegacao_inferior_ieca.dart';
import '../../../modelos/hino.dart';
import '../../biblia/biblia_tela.dart';
import '../../home/home_tela.dart';
import '../../sobre/sobre_tela.dart';
import '../leitura_tela.dart';
import '../../informacoes_ieca/informacoes_ieca_tela.dart';

 
class HinosCategoriaTela extends StatefulWidget {
  final String categoria;
  final String descricao;

  const HinosCategoriaTela({
    super.key,
    required this.categoria,
    required this.descricao,
  });

  @override
  State<HinosCategoriaTela> createState() =>
      _HinosCategoriaTelaState();
}

class _HinosCategoriaTelaState extends State<HinosCategoriaTela> {
  final TextEditingController pesquisaController =
      TextEditingController();

  List<Hino> todosHinos = [];
  List<Hino> hinosFiltrados = [];

  bool carregando = true;

  // =========================================================
  // CICLO DE VIDA
  // =========================================================

  @override
  void initState() {
    super.initState();
    carregarHinos();
  }

  @override
  void dispose() {
    pesquisaController.dispose();
    super.dispose();
  }

  // =========================================================
  // CARREGAR HINOS
  // =========================================================

  Future<void> carregarHinos() async {
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/dados/hinos_umbundo.json',
      );

      final dynamic dados = json.decode(jsonString);

      List<dynamic> lista;

      if (dados is List) {
        lista = dados;
      } else if (dados is Map<String, dynamic> &&
          dados['hinos'] is List) {
        lista = dados['hinos'] as List<dynamic>;
      } else {
        throw const FormatException(
          'Formato inválido do arquivo de hinos de Umbundo.',
        );
      }

      final List<Hino> listaCompleta = [];

      for (final item in lista) {
        if (item is! Map) {
          continue;
        }

        try {
          final Map<String, dynamic> mapa =
              Map<String, dynamic>.from(item);

          final Hino hino = Hino.fromJson(mapa);

          listaCompleta.add(hino);
        } catch (e) {
          debugPrint(
            'Erro ao converter hino de Umbundo: $e',
          );
        }
      }

      final String categoriaSelecionada =
          widget.categoria.trim().toLowerCase();

      final List<Hino> categoriaFiltrada =
          listaCompleta.where((hino) {
        return hino.categoria.trim().toLowerCase() ==
            categoriaSelecionada;
      }).toList();

      categoriaFiltrada.sort((a, b) {
        final int numeroA =
            int.tryParse(a.numero.toString()) ?? 0;

        final int numeroB =
            int.tryParse(b.numero.toString()) ?? 0;

        return numeroA.compareTo(numeroB);
      });

      if (!mounted) {
        return;
      }

      setState(() {
        todosHinos = categoriaFiltrada;
        hinosFiltrados =
            List<Hino>.from(categoriaFiltrada);
        carregando = false;
      });
    } catch (e) {
      debugPrint(
        'ERRO AO CARREGAR HINOS DE UMBUNDO: $e',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        todosHinos = [];
        hinosFiltrados = [];
        carregando = false;
      });
    }
  }

  // =========================================================
  // PESQUISA
  // =========================================================

  void pesquisar(String texto) {
    final String termo =
        texto.trim().toLowerCase();

    setState(() {
      if (termo.isEmpty) {
        hinosFiltrados =
            List<Hino>.from(todosHinos);
      } else {
        hinosFiltrados =
            todosHinos.where((hino) {
          final String numero =
              hino.numero.toString().toLowerCase();

          final String titulo =
              hino.titulo.toLowerCase();

          return numero.contains(termo) ||
              titulo.contains(termo);
        }).toList();
      }
    });
  }

  // =========================================================
// ABRIR LEITURA DO HINO
// =========================================================

void abrirHino(Hino hino) {
  // Descobre o índice do hino clicado dentro da lista filtrada
  final indice = hinosFiltrados.indexWhere(
    (h) => h.numero == hino.numero,
  );

  // Constrói a lista de itens de navegação a partir dos hinos filtrados
  final listaNavegacao = hinosFiltrados
      .map((h) => LeituraItem(hino: h))
      .toList();

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => LeituraTela(
        indiceInicial: indice < 0 ? 0 : indice,
        listaNavegacao: listaNavegacao,
      ),
    ),
  );
}
 // =========================================================
// NAVEGAÇÃO INFERIOR
// =========================================================

void selecionarNavegacao(int indice) {
  if (!mounted) return;

  switch (indice) {
    case 0:
      Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(
          builder: (_) => const HomeTela(),
        ),
      );
      break;

    case 1:
      // Já estamos dentro do Hinário.
      break;

    case 2:
      Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(
          builder: (_) => const BibliaTela(),
        ),
      );
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
        MaterialPageRoute<void>(
          builder: (_) => const SobreTela(),
        ),
      );
      break;

    default:
      return;
  }
}


  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TemaHinario.corSuperficie,

      // =======================================================
      // CABEÇALHO PADRÃO
      // =======================================================

      appBar: const CabecalhoIeca(),

      // =======================================================
      // CORPO
      // =======================================================

      body: carregando
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  10,
                ),
                child: Column(
                  children: [
                    // =================================================
                    // CABEÇALHO DA CATEGORIA
                    // =================================================

                    _CabecalhoCategoria(
                      categoria: widget.categoria,
                      descricao: widget.descricao,
                      quantidade: todosHinos.length,
                    ),

                    const SizedBox(height: 16),

                    // =================================================
                    // PESQUISA
                    // =================================================

                    _CampoPesquisa(
                      controller: pesquisaController,
                      onChanged: pesquisar,
                    ),

                    const SizedBox(height: 18),

                    // =================================================
                    // TÍTULO + CONTADOR
                    // =================================================

                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Ekovongo',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w700,
                              color: TemaHinario.corTexto,
                            ),
                          ),
                        ),
                        _ContadorResultados(
                          quantidade:
                              hinosFiltrados.length,
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // =================================================
                    // GRID
                    // =================================================

                    Expanded(
                      child: hinosFiltrados.isEmpty
                          ? _EstadoVazio(
                              pesquisa:
                                  pesquisaController.text
                                      .trim()
                                      .isNotEmpty,
                            )
                          : LayoutBuilder(
                              builder: (
                                context,
                                constraints,
                              ) {
                                final largura =
                                    constraints.maxWidth;

                                int colunas = 3;

                                if (largura >= 900) {
                                  colunas = 6;
                                } else if (largura >= 650) {
                                  colunas = 5;
                                } else if (largura >= 480) {
                                  colunas = 4;
                                }

                                return GridView.builder(
                                  padding:
                                      const EdgeInsets.only(
                                    bottom: 8,
                                  ),
                                  itemCount:
                                      hinosFiltrados.length,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount:
                                        colunas,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10,
                                    childAspectRatio: 1.15,
                                  ),
                                  itemBuilder:
                                      (context, index) {
                                    final Hino hino =
                                        hinosFiltrados[index];

                                    return _CartaoHino(
                                      hino: hino,
                                      onPressed: () =>
                                          abrirHino(hino),
                                    );
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),

      // =======================================================
      // RODAPÉ PADRÃO
      // =======================================================

      bottomNavigationBar:
          NavegacaoInferiorIeca(
        indiceSelecionado: 1,
        onDestinationSelected:
            selecionarNavegacao,
      ),
    );
  }
}

// =============================================================
// CABEÇALHO DA CATEGORIA
// =============================================================

class _CabecalhoCategoria extends StatelessWidget {
  final String categoria;
  final String descricao;
  final int quantidade;

  const _CabecalhoCategoria({
    required this.categoria,
    required this.descricao,
    required this.quantidade,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: TemaHinario.corSuperficieMedia,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: TemaHinario.corContorno.withValues(
            alpha: 0.35,
          ),
        ),
      ),
      child: Row(
        children: [
          // ÍCONE NEUTRO
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: TemaHinario.corSuperficieAlta,
              borderRadius:
                  BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.library_music_outlined,
              size: 27,
              color: TemaHinario.corTextoSecundario,
            ),
          ),

          const SizedBox(width: 14),

          // INFORMAÇÕES
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  categoria,
                  maxLines: 2,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight:
                        FontWeight.w700,
                    color: TemaHinario.corTexto,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  descricao,
                  maxLines: 2,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.3,
                    color:
                        TemaHinario.corTextoSecundario,
                  ),
                ),

                const SizedBox(height: 7),

                Text(
                  '$quantidade ${quantidade == 1 ? 'ekovongo' : 'ekovongo'}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight:
                        FontWeight.w600,
                    color:
                        TemaHinario.corTextoSecundario,
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
// CAMPO DE PESQUISA
// =============================================================

class _CampoPesquisa extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _CampoPesquisa({
    required this.controller,
    required this.onChanged,
  });

  @override
  State<_CampoPesquisa> createState() =>
      _CampoPesquisaState();
}

class _CampoPesquisaState
    extends State<_CampoPesquisa> {
  @override
  void initState() {
    super.initState();

    widget.controller.addListener(
      _atualizar,
    );
  }

  @override
  void dispose() {
    widget.controller.removeListener(
      _atualizar,
    );
    super.dispose();
  }

  void _atualizar() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      onChanged: widget.onChanged,
      textInputAction: TextInputAction.search,
      style: const TextStyle(
        fontSize: 15,
        color: TemaHinario.corTexto,
      ),
      decoration: InputDecoration(
        hintText:
            'Pesquisar por número ou título...',
        hintStyle: const TextStyle(
          fontSize: 14,
          color:
              TemaHinario.corTextoSecundario,
        ),
        prefixIcon: const Icon(
          Icons.search_rounded,
          color:
              TemaHinario.corTextoSecundario,
        ),
        suffixIcon:
            widget.controller.text.isNotEmpty
                ? IconButton(
                    tooltip:
                        'Limpar pesquisa',
                    onPressed: () {
                      widget.controller.clear();
                      widget.onChanged('');
                    },
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 20,
                    ),
                  )
                : null,
        filled: true,
        fillColor:
            TemaHinario.corSuperficieAlta,
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(15),
          borderSide: BorderSide(
            color: TemaHinario.corContorno
                .withValues(alpha: 0.35),
          ),
        ),
        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(15),
          borderSide: BorderSide(
            color: TemaHinario.corContorno
                .withValues(alpha: 0.35),
          ),
        ),
        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(15),
          borderSide: BorderSide(
            color:
                TemaHinario.corTextoSecundario
                    .withValues(alpha: 0.65),
            width: 1.2,
          ),
        ),
      ),
    );
  }
}

// =============================================================
// CONTADOR
// =============================================================

class _ContadorResultados
    extends StatelessWidget {
  final int quantidade;

  const _ContadorResultados({
    required this.quantidade,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color:
            TemaHinario.corSuperficieMedia,
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Text(
        '$quantidade ${quantidade == 1 ? 'resultado' : 'resultados'}',
        style: const TextStyle(
          fontSize: 12,
          fontWeight:
              FontWeight.w600,
          color:
              TemaHinario.corTextoSecundario,
        ),
      ),
    );
  }
}

// =============================================================
// CARTÃO DO HINO
// =============================================================

class _CartaoHino extends StatelessWidget {
  final Hino hino;
  final VoidCallback onPressed;

  const _CartaoHino({
    required this.hino,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color:
          TemaHinario.corSuperficieAlta,
      borderRadius:
          BorderRadius.circular(15),
      child: InkWell(
        onTap: onPressed,
        borderRadius:
            BorderRadius.circular(15),
        child: Container(
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(15),
            border: Border.all(
              color:
                  TemaHinario.corContorno
                      .withValues(alpha: 0.35),
            ),
          ),
          child: Center(
            child: Text(
              hino.numero.toString(),
              style: const TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.w700,
                color: TemaHinario.corTexto,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================
// ESTADO VAZIO
// =============================================================

class _EstadoVazio
    extends StatelessWidget {
  final bool pesquisa;

  const _EstadoVazio({
    required this.pesquisa,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              color:
                  TemaHinario.corSuperficieMedia,
              shape: BoxShape.circle,
            ),
            child: Icon(
              pesquisa
                  ? Icons.search_off_rounded
                  : Icons.library_music_outlined,
              size: 38,
              color:
                  TemaHinario.corTextoSecundario,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            pesquisa
                ? 'Nenhum ekovongo encontrado'
                : 'Nenhum ekovongo disponível',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 17,
              fontWeight:
                  FontWeight.w700,
              color: TemaHinario.corTexto,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            pesquisa
                ? 'Tente pesquisar por outro número ou título.'
                : 'Não existem ekovongo nesta categoria.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              height: 1.4,
              color:
                  TemaHinario.corTextoSecundario,
            ),
          ),
        ],
      ),
    );
  }
}