import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../modelos/item_programa.dart';
import '../modelos/programa_culto.dart';

class ProgramaPdfServico {
  // Cores institucionais
  static const PdfColor corPreta = PdfColor.fromInt(0xFF000000);
  static const PdfColor corTexto = PdfColor.fromInt(0xFF121C2A);
  static const PdfColor corSecundaria = PdfColor.fromInt(0xFF4A4A4A);
  static const PdfColor corLinhaTransparente = PdfColor.fromInt(0x1A000000);
  static const PdfColor corVermelha = PdfColor.fromInt(0xFFD32F2F);

  static Future<Uint8List> gerarPdf(ProgramaCulto programa) async {
    final pdf = pw.Document();

    final fontBase = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();
    final fontItalic = await PdfGoogleFonts.robotoItalic();

    // Carregamento do Logotipo dos assets
    pw.MemoryImage? logoImage;
    try {
      final bytes = await rootBundle.load('assets/images/logoieca.png');
      logoImage = pw.MemoryImage(bytes.buffer.asUint8List());
    } catch (_) {
      logoImage = null;
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        maxPages: 200,
        footer: (pw.Context context) =>
            _construirRodape(context, programa, fontBase),
        build: (pw.Context context) {
          return [
            // 1. Cabeçalho Centralizado
            _construirCabecalhoCentralizado(programa, logoImage, fontBold),

            pw.SizedBox(height: 10),
            pw.Divider(color: corPreta, thickness: 1.5),
            pw.SizedBox(height: 10),

            // 2. Equipe Litúrgica
            _construirEquipeLiturgica(programa, fontBase, fontBold),

            pw.SizedBox(height: 10),

            // 3. Título do Culto
            if (programa.titulo.isNotEmpty) ...[
              pw.Center(
                child: pw.Text(
                  programa.titulo.toUpperCase(),
                  style: pw.TextStyle(
                    font: fontBold,
                    fontSize: 13,
                    color: corPreta,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
              ),
              pw.SizedBox(height: 12),
            ],

            // 4. Conteúdo do Programa
            ...programa.itens.map((item) {
              return pw.Wrap(
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _construirItemPrograma(
                        item,
                        fontBase,
                        fontBold,
                        fontItalic,
                      ),
                      pw.SizedBox(height: 8),
                      pw.Divider(
                        color: corLinhaTransparente,
                        thickness: 0.5,
                      ),
                      pw.SizedBox(height: 8),
                    ],
                  ),
                ],
              );
            }),
          ];
        },
      ),
    );

    return pdf.save();
  }

  /// Cabeçalho Centralizado (Com Logo 80x80)
  static pw.Widget _construirCabecalhoCentralizado(
    ProgramaCulto programa,
    pw.MemoryImage? logoImage,
    pw.Font fontBold,
  ) {
    final styleCabecalho = pw.TextStyle(
      font: fontBold,
      fontSize: 14,
      color: corPreta,
    );

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        if (logoImage != null) ...[
          pw.Center(
            child: pw.Image(logoImage, width: 80, height: 80),
          ),
          pw.SizedBox(height: 8),
        ],
        pw.Text(
          'IGREJA EVANGÉLICA CONGREGACIONAL EM ANGOLA',
          style: styleCabecalho,
          textAlign: pw.TextAlign.center,
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          'I.E.C.A',
          style: styleCabecalho,
          textAlign: pw.TextAlign.center,
        ),
        if (programa.sinodo.isNotEmpty) ...[
          pw.SizedBox(height: 2),
          pw.Text(
            programa.sinodo,
            style: styleCabecalho,
            textAlign: pw.TextAlign.center,
          ),
        ],
        if (programa.local.isNotEmpty) ...[
          pw.SizedBox(height: 2),
          pw.Text(
            programa.local,
            style: styleCabecalho,
            textAlign: pw.TextAlign.center,
          ),
        ],
        if (programa.congregacao.isNotEmpty) ...[
          pw.SizedBox(height: 2),
          pw.Text(
            programa.congregacao,
            style: styleCabecalho,
            textAlign: pw.TextAlign.center,
          ),
        ],
      ],
    );
  }

  /// Bloco da Equipe Litúrgica
  static pw.Widget _construirEquipeLiturgica(
    ProgramaCulto programa,
    pw.Font fontBase,
    pw.Font fontBold,
  ) {
    final temEquipe = programa.dirigente.isNotEmpty ||
        programa.orador.isNotEmpty ||
        programa.pregador.isNotEmpty;

    if (!temEquipe) return pw.SizedBox();

    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      decoration: const pw.BoxDecoration(
        color: PdfColor.fromInt(0xFFF2F2F2),
        borderRadius: pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'EQUIPA LITÚRGICA',
            style: pw.TextStyle(font: fontBold, fontSize: 9, color: corPreta),
          ),
          pw.SizedBox(height: 4),
          pw.Wrap(
            spacing: 16,
            runSpacing: 4,
            children: [
              if (programa.dirigente.isNotEmpty)
                _itemEquipe(
                  'Dirigente:',
                  programa.dirigente,
                  fontBase,
                  fontBold,
                ),
              if (programa.orador.isNotEmpty)
                _itemEquipe(
                  'Orador:',
                  programa.orador,
                  fontBase,
                  fontBold,
                ),
              if (programa.pregador.isNotEmpty)
                _itemEquipe(
                  'Pregador:',
                  programa.pregador,
                  fontBase,
                  fontBold,
                ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _itemEquipe(
    String cargo,
    String nome,
    pw.Font fontBase,
    pw.Font fontBold,
  ) {
    return pw.RichText(
      text: pw.TextSpan(
        children: [
          pw.TextSpan(
            text: '$cargo ',
            style: pw.TextStyle(
              font: fontBold,
              fontSize: 8.5,
              color: corTexto,
            ),
          ),
          pw.TextSpan(
            text: nome,
            style: pw.TextStyle(
              font: fontBase,
              fontSize: 8.5,
              color: corTexto,
            ),
          ),
        ],
      ),
    );
  }

  /// Constrói cada item individual do programa
  static pw.Widget _construirItemPrograma(
    ItemPrograma item,
    pw.Font fontBase,
    pw.Font fontBold,
    pw.Font fontItalic,
  ) {
    String tituloExibicao = item.titulo;
    if (tituloExibicao.toLowerCase().contains('grupo coral')) {
      tituloExibicao = tituloExibicao.replaceAll(
        RegExp(r'Grupo Coral', caseSensitive: false),
        'Momento de Louvor',
      );
    }

    String? conteudoLimpo = item.conteudo;
    if (conteudoLimpo != null) {
      conteudoLimpo = conteudoLimpo
          .replaceAll(RegExp(r'<[^>]*>'), '')
          .replaceAll('&nbsp;', ' ')
          .trim();
    }

    // Identificação por palavra-chave ou por quantidade de linhas
    final ehHino = tituloExibicao.toLowerCase().contains('hino') ||
        item.subtitulo.toLowerCase().contains('hino') ||
        (conteudoLimpo != null &&
            conteudoLimpo.replaceAll('\r\n', '\n').split('\n').length > 5);

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // PONTO VERMELHO DESENHADO (não usa glifo da fonte)
            pw.Container(
              width: 5,
              height: 5,
              margin: const pw.EdgeInsets.only(top: 4, right: 6),
              decoration: const pw.BoxDecoration(
                color: corVermelha,
                shape: pw.BoxShape.circle,
              ),
            ),
            pw.Expanded(
              child: pw.RichText(
                text: pw.TextSpan(
                  children: [
                    pw.TextSpan(
                      text: tituloExibicao,
                      style: pw.TextStyle(
                        font: fontBold,
                        fontSize: 10,
                        color: corTexto,
                      ),
                    ),
                    if (item.subtitulo.isNotEmpty)
                      pw.TextSpan(
                        text: ' - ${item.subtitulo}',
                        style: pw.TextStyle(
                          font: fontItalic,
                          fontSize: 9,
                          color: corSecundaria,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (conteudoLimpo != null && conteudoLimpo.isNotEmpty) ...[
          pw.SizedBox(height: 4),
          pw.Padding(
            padding: const pw.EdgeInsets.only(left: 10),
            child: ehHino
                ? _processarHinoDuasColunas(conteudoLimpo, fontBase)
                : _processarTextoPadrao(conteudoLimpo, fontBase),
          ),
        ],
      ],
    );
  }

  /// Divide as linhas do Hino em 2 colunas lado a lado
  static pw.Widget _processarHinoDuasColunas(
    String conteudo,
    pw.Font fontBase,
  ) {
    final textoNormalizado =
        conteudo.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    final linhas = textoNormalizado.split('\n');

    if (linhas.length <= 3) {
      return _processarTextoPadrao(conteudo, fontBase);
    }

    final meio = (linhas.length / 2).ceil();
    final textoColunaEsquerda = linhas.sublist(0, meio).join('\n');
    final textoColunaDireita = linhas.sublist(meio).join('\n');

    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Text(
            textoColunaEsquerda,
            style: pw.TextStyle(
              font: fontBase,
              fontSize: 8.5,
              lineSpacing: 1.4,
              color: corTexto,
            ),
          ),
        ),
        pw.SizedBox(width: 16),
        pw.Expanded(
          child: pw.Text(
            textoColunaDireita,
            style: pw.TextStyle(
              font: fontBase,
              fontSize: 8.5,
              lineSpacing: 1.4,
              color: corTexto,
            ),
          ),
        ),
      ],
    );
  }

  /// Processamento para textos contínuos
  static pw.Widget _processarTextoPadrao(String conteudo, pw.Font fontBase) {
    return pw.Text(
      conteudo,
      style: pw.TextStyle(
        font: fontBase,
        fontSize: 8.5,
        lineSpacing: 1.5,
        color: corTexto,
      ),
    );
  }

  /// Rodapé: Esquerda (I.E.C.A - DATA E HORA) | Direita (Página X de Y)
  static pw.Widget _construirRodape(
    pw.Context context,
    ProgramaCulto programa,
    pw.Font fontBase,
  ) {
    final dataHoraStr = [
      if (programa.data.isNotEmpty) programa.data,
      if (programa.hora.isNotEmpty) programa.hora,
    ].join(' - ');

    final rodapeEsquerda =
        'I.E.C.A${dataHoraStr.isNotEmpty ? ' - $dataHoraStr' : ''}';

    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 8),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            rodapeEsquerda,
            style: pw.TextStyle(
              font: fontBase,
              fontSize: 8,
              color: corSecundaria,
            ),
          ),
          pw.Text(
            'Página ${context.pageNumber} de ${context.pagesCount}',
            style: pw.TextStyle(
              font: fontBase,
              fontSize: 8,
              color: corSecundaria,
            ),
          ),
        ],
      ),
    );
  }

  static Future<void> imprimirOuCompartilhar(ProgramaCulto programa) async {
    final bytes = await gerarPdf(programa);
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'Programa_${programa.titulo.replaceAll(' ', '_')}.pdf',
    );
  }
}