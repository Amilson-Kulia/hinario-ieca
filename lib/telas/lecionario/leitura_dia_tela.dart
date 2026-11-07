import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/tema.dart';
import '../../componentes/cabecalho_ieca.dart';
import '../../componentes/navegacao_inferior_ieca.dart';
import '../../modelos/lecionario_modelo.dart';
import '../../servicos/constancia_servico.dart';
import '../../componentes/quadra_liturgica.dart';

import '../hinario/idiomas_tela.dart';
import '../sobre/sobre_tela.dart';
import '../biblia/biblia_tela.dart';
import '../informacoes_ieca/informacoes_ieca_tela.dart';

class LeituraDiaTela extends StatefulWidget {
  final DiaLecionario dia;
  final String mes;
  final int ano;

  const LeituraDiaTela({
    super.key,
    required this.dia,
    required this.mes,
    required this.ano,
  });

  @override
  State<LeituraDiaTela> createState() => _LeituraDiaTelaState();
}

class _LeituraDiaTelaState extends State<LeituraDiaTela> {
  DiaLecionario get dia => widget.dia;
  String get mes => widget.mes;
  int get ano => widget.ano;

  int _itemSelecionado = 1;

  @override
  void initState() {
    super.initState();
    _registarConstancia();
  }

  Future<void> _registarConstancia() async {
    await ConstanciaServico.instancia.registrarUsoLecionario();
  }

  // =============================================================
  // NAVEGAÇÃO INFERIOR
  // =============================================================

  void _selecionarNavegacao(int indice) {
    if (!mounted) return;

    if (indice == 0) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    }

    if (indice == 1) {
      setState(() => _itemSelecionado = 1);

      Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (context) => const IdiomasTela(),
        ),
      ).then((_) {
        if (!mounted) return;
        setState(() => _itemSelecionado = 1);
      });

      return;
    }

    if (indice == 2) {
      setState(() => _itemSelecionado = 2);

      Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (context) => const BibliaTela(),
        ),
      ).then((_) {
        if (!mounted) return;
        setState(() => _itemSelecionado = 1);
      });

      return;
    }

    if (indice == 3) {
      setState(() => _itemSelecionado = 3);

      Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (context) => const InformacoesIecaTela(),
        ),
      ).then((_) {
        if (!mounted) return;
        setState(() => _itemSelecionado = 1);
      });

      return;
    }

    if (indice == 4) {
      setState(() => _itemSelecionado = 4);

      Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (context) => const SobreTela(),
        ),
      ).then((_) {
        if (!mounted) return;
        setState(() => _itemSelecionado = 1);
      });

      return;
    }
  }

  // =============================================================
  // BUILD
  // =============================================================

  @override
  Widget build(BuildContext context) {
    final possuiReferencias = dia.referenciasBiblicas.isNotEmpty;
    final possuiReflexao = dia.reflexao.trim().isNotEmpty;
    final possuiOracao = dia.possuiOracao;
    final possuiLiturgia = dia.liturgia != null;
    final possuiPalavras = dia.palavras.isNotEmpty;

    return Scaffold(
      backgroundColor: TemaHinario.corSuperficie,
      appBar: const CabecalhoIeca(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 36),
          children: [
            // =====================================================
            // CABEÇALHO
            // =====================================================

            _CabecalhoDia(
              dia: dia,
              mes: mes,
              ano: ano,
            ),

            const SizedBox(height: 22),

            // =====================================================
            // RESUMO
            // =====================================================

            _ResumoLeitura(
              possuiReferencias: possuiReferencias,
              possuiReflexao: possuiReflexao,
              possuiOracao: possuiOracao,
              possuiLiturgia: possuiLiturgia,
              possuiPalavras: possuiPalavras,
            ),

            // =====================================================
            // REFERÊNCIAS BÍBLICAS
            // =====================================================

            if (possuiReferencias) ...[
              const SizedBox(height: 26),
              const _SecaoTitulo(
                icone: Icons.menu_book_outlined,
                titulo: 'Referências Bíblicas',
                descricao: 'Textos para a leitura deste dia',
              ),
              const SizedBox(height: 10),
              ...dia.referenciasBiblicas.map(
                (ref) => _CartaoReferencia(texto: ref),
              ),
            ],

            // =====================================================
            // REFLEXÃO
            // =====================================================

            if (possuiReflexao) ...[
              const SizedBox(height: 26),
              const _SecaoTitulo(
                icone: Icons.lightbulb_outline_rounded,
                titulo: 'Reflexão',
                descricao: 'Uma palavra para meditar',
              ),
              const SizedBox(height: 10),
              _CartaoReflexao(texto: dia.reflexao),
            ],

            // =====================================================
            // ORAÇÃO
            // =====================================================

            if (possuiOracao) ...[
              const SizedBox(height: 26),
              const _SecaoTitulo(
                icone: Icons.volunteer_activism_outlined,
                titulo: 'Oração',
                descricao: 'Oração sugerida para este dia',
              ),
              const SizedBox(height: 10),
              _CartaoOracao(texto: dia.oracao!),
            ],

            // =====================================================
            // LITURGIA
            // =====================================================

            if (possuiLiturgia) ...[
              const SizedBox(height: 26),
              const _SecaoTitulo(
                icone: Icons.church_outlined,
                titulo: 'Liturgia',
                descricao: 'Elementos litúrgicos do dia',
              ),
              const SizedBox(height: 10),
              _CartaoLiturgia(liturgia: dia.liturgia!),
            ],

            // =====================================================
            // 7 PALAVRAS DE CRISTO
            // =====================================================

            if (possuiPalavras) ...[
              const SizedBox(height: 26),
              const _SecaoTitulo(
                icone: Icons.record_voice_over_outlined,
                titulo: 'As 7 Palavras de Cristo',
                descricao: 'Palavras para meditação',
              ),
              const SizedBox(height: 10),
              ..._construirPalavrasOrdenadas(),
            ],

            const SizedBox(height: 24),

            // =====================================================
            // AÇÕES
            // =====================================================

            _AcoesLeitura(
              onCopiar: () => _copiarDia(context),
              onPartilhar: () => _partilharDia(context),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavegacaoInferiorIeca(
        indiceSelecionado: _itemSelecionado,
        onDestinationSelected: _selecionarNavegacao,
      ),
    );
  }

  List<Widget> _construirPalavrasOrdenadas() {
    final palavras = [...dia.palavras]
      ..sort((a, b) => a.ordem.compareTo(b.ordem));

    return palavras
        .map(
          (palavra) => _CartaoPalavra(
            palavra: palavra,
          ),
        )
        .toList();
  }

  // =============================================================
  // TEXTO COMPLETO DA LEITURA
  // =============================================================

  String _gerarTextoLeitura() {
    final buffer = StringBuffer()
      ..writeln(dia.data)
      ..writeln(dia.titulo)
      ..writeln();

    if (dia.evento != null &&
        dia.evento!.trim().isNotEmpty &&
        dia.evento != dia.titulo) {
      buffer
        ..writeln(dia.evento)
        ..writeln();
    }

    if (dia.referenciasBiblicas.isNotEmpty) {
      buffer.writeln('REFERÊNCIAS BÍBLICAS');

      for (final ref in dia.referenciasBiblicas) {
        buffer.writeln('• $ref');
      }

      buffer.writeln();
    }

    if (dia.reflexao.trim().isNotEmpty) {
      buffer
        ..writeln('REFLEXÃO')
        ..writeln(dia.reflexao)
        ..writeln();
    }

    if (dia.possuiOracao) {
      buffer
        ..writeln('ORAÇÃO')
        ..writeln(dia.oracao)
        ..writeln();
    }

    if (dia.liturgia != null) {
      final liturgia = dia.liturgia!;

      buffer.writeln('LITURGIA');

      if (liturgia.hinos.isNotEmpty) {
        buffer.writeln(
          'Hinos: ${liturgia.hinos.join(', ')}',
        );
      }

      if (liturgia.possuiSalmo) {
        buffer.writeln(
          'Salmo: ${liturgia.salmo}',
        );
      }

      if (liturgia.leiturasBiblicas.isNotEmpty) {
        buffer.writeln(
          'Leituras: ${liturgia.leiturasBiblicas.join(', ')}',
        );
      }

      buffer.writeln();
    }

    if (dia.palavras.isNotEmpty) {
      buffer.writeln('AS 7 PALAVRAS DE CRISTO');

      final palavras = [...dia.palavras]
        ..sort((a, b) => a.ordem.compareTo(b.ordem));

      for (final palavra in palavras) {
        buffer
          ..writeln('${palavra.ordem}. ${palavra.palavra}')
          ..writeln(palavra.texto);

        if (palavra.meditacao.trim().isNotEmpty) {
          buffer.writeln(palavra.meditacao);
        }

        buffer.writeln();
      }
    }

    return buffer.toString().trim();
  }

  // =============================================================
  // COPIAR
  // =============================================================

  Future<void> _copiarDia(BuildContext context) async {
    await Clipboard.setData(
      ClipboardData(
        text: _gerarTextoLeitura(),
      ),
    );

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Leitura copiada para a área de transferência.',
        ),
        duration: Duration(milliseconds: 1400),
      ),
    );
  }

  // =============================================================
  // PARTILHAR
  // =============================================================

  Future<void> _partilharDia(BuildContext context) async {
    await Clipboard.setData(
      ClipboardData(
        text: _gerarTextoLeitura(),
      ),
    );

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Leitura copiada. Já podes partilhá-la.',
        ),
        duration: Duration(milliseconds: 1600),
      ),
    );
  }
}

// =================================================================
// CABEÇALHO DO DIA
// =================================================================

class _CabecalhoDia extends StatelessWidget {
  final DiaLecionario dia;
  final String mes;
  final int ano;

  const _CabecalhoDia({
    required this.dia,
    required this.mes,
    required this.ano,
  });

  @override
  Widget build(BuildContext context) {
    final destaque = dia.isDomingo;

    final corFundo1 = destaque
        ? TemaHinario.corPrimaria
        : TemaHinario.corPrimaria.withValues(alpha: 0.09);

    final corFundo2 = destaque
        ? TemaHinario.corPrimariaContainer
        : TemaHinario.corSuperficieAlta;

    final corTextoPrincipal =
        destaque ? Colors.white : TemaHinario.corTexto;

    final corTextoSec = destaque
        ? Colors.white.withValues(alpha: 0.84)
        : TemaHinario.corTextoSecundario;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            corFundo1,
            corFundo2,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: TemaHinario.corPrimaria.withValues(alpha: 0.13),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: destaque
                      ? Colors.white.withValues(alpha: 0.17)
                      : TemaHinario.corPrimaria.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Icon(
                  destaque
                      ? Icons.church_rounded
                      : Icons.calendar_today_rounded,
                  color: destaque
                      ? Colors.white
                      : TemaHinario.corPrimaria,
                  size: 22,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$mes • $ano',
                      style: TextStyle(
                        color: corTextoSec,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dia.data,
                      style: TextStyle(
                        color: corTextoPrincipal,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _BadgeQuadra(
                data: dia.data,
                destaque: destaque,
              ),
            ],
          ),

          const SizedBox(height: 20),

          Text(
            dia.titulo,
            style: TextStyle(
              color: corTextoPrincipal,
              fontSize: 22,
              height: 1.25,
              fontWeight: FontWeight.w800,
            ),
          ),

          if (dia.evento != null &&
              dia.evento!.trim().isNotEmpty &&
              dia.evento != dia.titulo) ...[
            const SizedBox(height: 8),
            Text(
              dia.evento!,
              style: TextStyle(
                color: corTextoSec,
                fontSize: 13,
                height: 1.45,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],

          if (destaque) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.church_outlined,
                    size: 14,
                    color: Colors.white,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'DOMINGO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.7,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// =================================================================
// RESUMO DA LEITURA
// =================================================================

class _ResumoLeitura extends StatelessWidget {
  final bool possuiReferencias;
  final bool possuiReflexao;
  final bool possuiOracao;
  final bool possuiLiturgia;
  final bool possuiPalavras;

  const _ResumoLeitura({
    required this.possuiReferencias,
    required this.possuiReflexao,
    required this.possuiOracao,
    required this.possuiLiturgia,
    required this.possuiPalavras,
  });

  @override
  Widget build(BuildContext context) {
    final itens = <String>[];

    if (possuiReferencias) {
      itens.add('Bíblia');
    }

    if (possuiReflexao) {
      itens.add('Reflexão');
    }

    if (possuiOracao) {
      itens.add('Oração');
    }

    if (possuiLiturgia) {
      itens.add('Liturgia');
    }

    if (possuiPalavras) {
      itens.add('7 Palavras');
    }

    if (itens.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: TemaHinario.corSuperficieAlta,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: TemaHinario.corPrimaria.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: TemaHinario.corPrimaria.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.auto_stories_outlined,
              size: 18,
              color: TemaHinario.corPrimaria,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              itens.join('  •  '),
              style: const TextStyle(
                color: TemaHinario.corTextoSecundario,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =================================================================
// BADGE DE QUADRA LITÚRGICA
// =================================================================

class _BadgeQuadra extends StatelessWidget {
  final String data;
  final bool destaque;

  const _BadgeQuadra({
    required this.data,
    this.destaque = false,
  });

  DateTime _extrairDataOuHoje(String texto) {
    final regex = RegExp(
      r'(\d{1,2})\s+de\s+([A-Za-zÀ-ÿ]+)\s+de\s+(\d{4})',
      caseSensitive: false,
    );

    final match = regex.firstMatch(texto);

    if (match == null) {
      return DateTime.now();
    }

    final dia = int.tryParse(match.group(1)!) ?? 1;
    final nomeMes = match.group(2)!.toLowerCase();
    final ano = int.tryParse(match.group(3)!) ?? 2026;

    const meses = {
      'janeiro': 1,
      'fevereiro': 2,
      'março': 3,
      'marco': 3,
      'abril': 4,
      'maio': 5,
      'junho': 6,
      'julho': 7,
      'agosto': 8,
      'setembro': 9,
      'outubro': 10,
      'novembro': 11,
      'dezembro': 12,
    };

    final numeroMes = meses[nomeMes] ?? 1;

    return DateTime(
      ano,
      numeroMes,
      dia,
    );
  }

  @override
  Widget build(BuildContext context) {
    final quadra = QuadraLiturgica.paraData(
      _extrairDataOuHoje(data),
    );

    final cor = Color(quadra.corArgb);

    return Container(
      constraints: const BoxConstraints(
        maxWidth: 110,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: destaque
            ? Colors.white.withValues(alpha: 0.14)
            : cor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: destaque
              ? Colors.white.withValues(alpha: 0.30)
              : cor.withValues(alpha: 0.28),
          width: 0.8,
        ),
      ),
      child: Text(
        quadra.nome.toUpperCase(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: destaque ? Colors.white : cor,
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

// =================================================================
// TÍTULO DE SECÇÃO
// =================================================================

class _SecaoTitulo extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String descricao;

  const _SecaoTitulo({
    required this.icone,
    required this.titulo,
    required this.descricao,
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
            color: TemaHinario.corPrimaria.withValues(alpha: 0.09),
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
                  fontSize: 15.5,
                  fontWeight: FontWeight.w800,
                  color: TemaHinario.corTexto,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                descricao,
                style: const TextStyle(
                  fontSize: 11,
                  color: TemaHinario.corTextoSecundario,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// =================================================================
// CARTÃO DE REFERÊNCIA BÍBLICA
// =================================================================

class _CartaoReferencia extends StatelessWidget {
  final String texto;

  const _CartaoReferencia({
    required this.texto,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 13,
      ),
      decoration: BoxDecoration(
        color: TemaHinario.corSuperficieAlta,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: TemaHinario.corPrimaria.withValues(alpha: 0.14),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: TemaHinario.corPrimaria.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(9),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.menu_book_rounded,
              size: 16,
              color: TemaHinario.corPrimaria,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              texto,
              style: const TextStyle(
                fontSize: 14,
                height: 1.35,
                fontWeight: FontWeight.w700,
                color: TemaHinario.corPrimaria,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =================================================================
// CARTÃO DE REFLEXÃO
// =================================================================

class _CartaoReflexao extends StatelessWidget {
  final String texto;

  const _CartaoReflexao({
    required this.texto,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: TemaHinario.corSuperficieAlta,
        borderRadius: BorderRadius.circular(18),
        border: Border(
          left: BorderSide(
            color: TemaHinario.corPrimaria,
            width: 4,
          ),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _LinhaRotulo(
            icone: Icons.lightbulb_outline_rounded,
            texto: 'PARA MEDITAR',
          ),
          const SizedBox(height: 12),
          Text(
            texto,
            style: const TextStyle(
              fontSize: 15,
              height: 1.65,
              color: TemaHinario.corTexto,
            ),
          ),
        ],
      ),
    );
  }
}

// =================================================================
// CARTÃO DE ORAÇÃO
// =================================================================

class _CartaoOracao extends StatelessWidget {
  final String texto;

  const _CartaoOracao({
    required this.texto,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: TemaHinario.corSuperficieAlta,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: TemaHinario.corPrimaria.withValues(alpha: 0.12),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _LinhaRotulo(
            icone: Icons.volunteer_activism_outlined,
            texto: 'ORAÇÃO',
          ),
          const SizedBox(height: 12),
          Text(
            texto,
            style: const TextStyle(
              fontSize: 15,
              height: 1.65,
              color: TemaHinario.corTexto,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

// =================================================================
// CARTÃO DE LITURGIA
// =================================================================

class _CartaoLiturgia extends StatelessWidget {
  final Liturgia liturgia;

  const _CartaoLiturgia({
    required this.liturgia,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: TemaHinario.corSuperficieAlta,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: TemaHinario.corPrimaria.withValues(alpha: 0.08),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (liturgia.hinos.isNotEmpty) ...[
            const _LinhaRotulo(
              icone: Icons.music_note_rounded,
              texto: 'HINOS',
            ),
            const SizedBox(height: 9),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: liturgia.hinos
                  .map(
                    (hino) => _Etiqueta(
                      texto: hino,
                    ),
                  )
                  .toList(),
            ),
          ],

          if (liturgia.possuiSalmo) ...[
            if (liturgia.hinos.isNotEmpty)
              const SizedBox(height: 20),

            const _LinhaRotulo(
              icone: Icons.format_quote_rounded,
              texto: 'SALMO',
            ),
            const SizedBox(height: 9),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: TemaHinario.corSuperficieMedia.withValues(
                  alpha: 0.65,
                ),
                borderRadius: BorderRadius.circular(13),
                border: Border(
                  left: BorderSide(
                    color: TemaHinario.corPrimaria,
                    width: 3,
                  ),
                ),
              ),
              child: Text(
                liturgia.salmo ?? '',
                style: const TextStyle(
                  fontSize: 14.5,
                  height: 1.6,
                  fontStyle: FontStyle.italic,
                  color: TemaHinario.corTexto,
                ),
              ),
            ),
          ],

          if (liturgia.leiturasBiblicas.isNotEmpty) ...[
            if (liturgia.hinos.isNotEmpty ||
                liturgia.possuiSalmo)
              const SizedBox(height: 20),

            const _LinhaRotulo(
              icone: Icons.menu_book_outlined,
              texto: 'LEITURAS BÍBLICAS',
            ),
            const SizedBox(height: 9),

            ...liturgia.leiturasBiblicas.map(
              (leitura) => Padding(
                padding: const EdgeInsets.only(bottom: 7),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 7),
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: TemaHinario.corPrimaria,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        leitura,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: TemaHinario.corTexto,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// =================================================================
// CARTÃO DAS 7 PALAVRAS
// =================================================================

class _CartaoPalavra extends StatefulWidget {
  final PalavraCristo palavra;

  const _CartaoPalavra({
    required this.palavra,
  });

  @override
  State<_CartaoPalavra> createState() => _CartaoPalavraState();
}

class _CartaoPalavraState extends State<_CartaoPalavra> {
  bool _expandido = false;

  @override
  Widget build(BuildContext context) {
    final palavra = widget.palavra;
    final possuiMeditacao = palavra.meditacao.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: TemaHinario.corSuperficieAlta,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: TemaHinario.corPrimaria.withValues(alpha: 0.13),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(17),
          onTap: () {
            setState(() {
              _expandido = !_expandido;
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            TemaHinario.corPrimaria,
                            TemaHinario.corPrimariaContainer,
                          ],
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${palavra.ordem}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        palavra.palavra,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: TemaHinario.corTexto,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      _expandido
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: TemaHinario.corTextoSecundario,
                    ),
                  ],
                ),

                if (_expandido) ...[
                  const SizedBox(height: 14),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(
                      left: 13,
                      right: 13,
                      top: 12,
                      bottom: 12,
                    ),
                    decoration: BoxDecoration(
                      color: TemaHinario.corSuperficieMedia,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Text(
                      palavra.texto,
                      style: const TextStyle(
                        fontSize: 14.5,
                        height: 1.65,
                        fontStyle: FontStyle.italic,
                        color: TemaHinario.corTexto,
                      ),
                    ),
                  ),

                  if (possuiMeditacao) ...[
                    const SizedBox(height: 10),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        color: TemaHinario.corPrimaria.withValues(
                          alpha: 0.055,
                        ),
                        borderRadius: BorderRadius.circular(13),
                        border: Border(
                          left: BorderSide(
                            color: TemaHinario.corPrimaria,
                            width: 3,
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _LinhaRotulo(
                            icone: Icons.lightbulb_outline_rounded,
                            texto: 'MEDITAÇÃO',
                          ),
                          const SizedBox(height: 7),
                          Text(
                            palavra.meditacao,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.6,
                              color: TemaHinario.corTexto,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =================================================================
// LINHA DE RÓTULO
// =================================================================

class _LinhaRotulo extends StatelessWidget {
  final IconData icone;
  final String texto;

  const _LinhaRotulo({
    required this.icone,
    required this.texto,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icone,
          size: 15,
          color: TemaHinario.corPrimaria,
        ),
        const SizedBox(width: 6),
        Text(
          texto,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
            color: TemaHinario.corPrimaria,
          ),
        ),
      ],
    );
  }
}

// =================================================================
// ETIQUETA
// =================================================================

class _Etiqueta extends StatelessWidget {
  final String texto;

  const _Etiqueta({
    required this.texto,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: TemaHinario.corPrimaria.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: TemaHinario.corPrimaria.withValues(alpha: 0.17),
          width: 0.6,
        ),
      ),
      child: Text(
        texto,
        style: const TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: TemaHinario.corPrimaria,
        ),
      ),
    );
  }
}

// =================================================================
// AÇÕES DA LEITURA
// =================================================================

class _AcoesLeitura extends StatelessWidget {
  final VoidCallback onCopiar;
  final VoidCallback onPartilhar;

  const _AcoesLeitura({
    required this.onCopiar,
    required this.onPartilhar,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _BotaoAcao(
            icone: Icons.copy_rounded,
            texto: 'Copiar',
            onPressed: onCopiar,
            principal: true,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _BotaoAcao(
            icone: Icons.share_outlined,
            texto: 'Partilhar',
            onPressed: onPartilhar,
            principal: false,
          ),
        ),
      ],
    );
  }
}

// =================================================================
// BOTÃO DE AÇÃO
// =================================================================

class _BotaoAcao extends StatelessWidget {
  final IconData icone;
  final String texto;
  final VoidCallback onPressed;
  final bool principal;

  const _BotaoAcao({
    required this.icone,
    required this.texto,
    required this.onPressed,
    required this.principal,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: principal
                ? TemaHinario.corPrimaria
                : TemaHinario.corSuperficieAlta,
            borderRadius: BorderRadius.circular(15),
            border: principal
                ? null
                : Border.all(
                    color: TemaHinario.corPrimaria.withValues(
                      alpha: 0.16,
                    ),
                  ),
            boxShadow: principal
                ? [
                    BoxShadow(
                      color: TemaHinario.corPrimaria.withValues(
                        alpha: 0.20,
                      ),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icone,
                size: 17,
                color: principal
                    ? Colors.white
                    : TemaHinario.corPrimaria,
              ),
              const SizedBox(width: 7),
              Text(
                texto,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: principal
                      ? Colors.white
                      : TemaHinario.corPrimaria,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}