import 'versiculos_servico.dart';
import '../modelos/versiculo.dart';

class PalavraDoDiaServico {
  // =============================================================
  // REFERÊNCIAS DA PALAVRA DO DIA
  //
  // Cada item representa uma unidade de leitura.
  //
  // Pode ser:
  //
  //   'João 3:16'
  //
  // ou:
  //
  //   'Romanos 8:31-32'
  //
  // Assim controlamos exatamente quando mostrar 1 ou 2
  // versículos.
  // =============================================================

  static const List<String> _referencias = [

    // =============================================================
    // ENCORAJAMENTO
    // =============================================================

    'Deuteronômio 31:6',
    'Deuteronômio 31:8',

    'Josué 1:6',
    'Josué 1:9',

    'Salmos 27:14',

    'Salmos 31:24',

    'Salmos 34:4',

    'Salmos 46:1-2',

    'Salmos 55:22',

    'Salmos 121:1-2',

    'Isaías 41:10',

    'Isaías 43:1-2',

    'Jeremias 29:11',

    'Romanos 8:31-32',

    'Romanos 8:37',

    '1 Coríntios 16:13',

    '2 Coríntios 4:16-17',

    'Filipenses 4:13',

    'Hebreus 13:5-6',

    // =============================================================
    // CONFORTO E CONSOLAÇÃO
    // =============================================================

    'Salmos 23:1-2',

    'Salmos 23:3-4',

    'Salmos 34:17-18',

    'Salmos 42:11',

    'Salmos 55:22',

    'Salmos 68:5-6',

    'Salmos 86:7',

    'Salmos 91:1-2',

    'Salmos 94:18-19',

    'Salmos 119:50',

    'Isaías 40:29',

    'Isaías 40:31',

    'Isaías 49:15-16',

    'Isaías 66:13',

    'Mateus 5:4',

    'Mateus 11:28-29',

    'João 14:18',

    'João 14:27',

    '2 Coríntios 1:3-4',

    '2 Coríntios 1:5',

    '1 Pedro 5:7',

    // =============================================================
    // ESPERANÇA
    // =============================================================

    'Salmos 33:20-22',

    'Salmos 42:5',

    'Salmos 71:5',

    'Salmos 130:5',

    'Salmos 147:11',

    'Lamentações 3:22-23',

    'Romanos 5:3-4',

    'Romanos 5:5',

    'Romanos 8:24-25',

    'Romanos 15:13',

    '1 Pedro 1:3',

    // =============================================================
    // FÉ E CONFIANÇA EM DEUS
    // =============================================================

    'Provérbios 3:5-6',

    'Salmos 9:10',

    'Salmos 20:7',

    'Salmos 37:3-4',

    'Salmos 37:5',

    'Salmos 56:3-4',

    'Salmos 62:7-8',

    'Salmos 112:7',

    'Isaías 26:3-4',

    'Marcos 9:23-24',

    'Marcos 11:24',

    'João 11:25-26',

    'Romanos 4:20-21',

    '2 Coríntios 5:7',

    'Hebreus 11:1',

    'Hebreus 11:6',

    '1 Pedro 1:8-9',

    // =============================================================
    // DEPENDÊNCIA DE DEUS
    // =============================================================

    'Salmos 16:8',

    'Salmos 18:2',

    'Salmos 25:4-5',

    'Salmos 28:7',

    'Salmos 36:9',

    'Salmos 63:1',

    'Salmos 73:25-26',

    'Salmos 84:11-12',

    'Salmos 121:5',

    'Provérbios 16:3',

    'Provérbios 16:9',

    'Isaías 30:15',

    'João 15:4-5',

    'João 15:5',

    'Atos 17:28',

    '2 Coríntios 3:5',

    'Filipenses 4:19',

    // =============================================================
    // PAZ
    // =============================================================

    'Salmos 4:8',

    'Salmos 29:11',

    'Salmos 85:8',

    'Isaías 26:3',

    'Isaías 32:17-18',

    'João 14:27',

    'João 16:33',

    'Romanos 5:1',

    'Romanos 8:6',

    'Filipenses 4:6-7',

    'Colossenses 3:15',

    '2 Tessalonicenses 3:16',

    // =============================================================
    // FORÇA
    // =============================================================

    '2 Samuel 22:2-3',

    'Salmos 18:32',

    'Salmos 18:39',

    'Salmos 28:7',

    'Salmos 46:1',

    'Salmos 73:26',

    'Isaías 40:29',

    'Isaías 40:30-31',

    'Habacuque 3:17-18',

    'Habacuque 3:19',

    'Efésios 6:10',

    'Filipenses 4:13',

    // =============================================================
    // PERSEVERANÇA / NÃO DESISTIR
    // =============================================================

    'Salmos 37:7',

    'Salmos 37:24',

    'Salmos 40:1-2',

    'Romanos 5:3-5',

    'Romanos 12:12',

    '1 Coríntios 15:58',

    'Gálatas 6:9',

    'Filipenses 3:13-14',

    'Hebreus 10:23',

    'Hebreus 12:1-2',

    'Tiago 1:2-4',

    'Tiago 1:12',

    'Tiago 5:7-8',

    // =============================================================
    // SUPERAÇÃO DE DIFICULDADES
    // =============================================================

    'Salmos 34:19',

    'Salmos 40:1-3',

    'Salmos 66:10-12',

    'Salmos 118:5-6',

    'Isaías 43:2',

    'Jeremias 17:7-8',

    'Romanos 8:28',

    'Romanos 8:35-37',

    '2 Coríntios 4:8-9',

    '2 Coríntios 4:16-18',

    '2 Coríntios 12:9',

    'Tiago 1:12',

    // =============================================================
    // PROTEÇÃO
    // =============================================================

    'Salmos 3:3',

    'Salmos 4:8',

    'Salmos 5:11-12',

    'Salmos 18:30',

    'Salmos 27:1',

    'Salmos 34:7-8',

    'Salmos 46:1-2',

    'Salmos 61:3-4',

    'Salmos 91:1-2',

    'Salmos 91:9-10',

    'Salmos 121:3-4',

    'Salmos 121:7-8',

    'Provérbios 18:10',

    'Isaías 43:2',

    '2 Tessalonicenses 3:3',

    // =============================================================
    // ADORAÇÃO
    // =============================================================

    'Salmos 8:1',

    'Salmos 19:1',

    'Salmos 29:2',

    'Salmos 34:1',

    'Salmos 47:1',

    'Salmos 63:3-4',

    'Salmos 95:6',

    'Salmos 96:9',

    'Salmos 98:1',

    'Salmos 100:1-2',

    'Salmos 103:1-2',

    'Salmos 104:1',

    'Salmos 111:1',

    'Salmos 150:1-2',

    'João 4:23-24',

    'Apocalipse 4:11',

    // =============================================================
    // DEVOÇÃO
    // =============================================================

    'Salmos 1:1-2',

    'Salmos 5:3',

    'Salmos 27:4',

    'Salmos 42:1-2',

    'Salmos 63:1',

    'Salmos 84:10',

    'Salmos 119:10-11',

    'Salmos 119:105',

    'Mateus 6:6',

    'Mateus 6:33',

    'Romanos 12:1',

    'Romanos 12:2',

    'Colossenses 3:1-2',

    'Colossenses 3:23',

    '1 Tessalonicenses 5:17',

    // =============================================================
    // ORAÇÃO
    // =============================================================

    'Salmos 5:1-2',

    'Salmos 18:6',

    'Salmos 34:4',

    'Salmos 50:15',

    'Salmos 55:16-17',

    'Salmos 86:6-7',

    'Salmos 116:1-2',

    'Jeremias 29:12',

    'Jeremias 33:3',

    'Mateus 7:7-8',

    'Mateus 7:9-11',

    'Marcos 11:24',

    'João 14:13-14',

    'João 16:23-24',

    'Romanos 8:26-27',

    '1 Tessalonicenses 5:17',

    '1 João 5:14-15',

    // =============================================================
    // GRATIDÃO
    // =============================================================

    'Salmos 7:17',

    'Salmos 9:1-2',

    'Salmos 30:12',

    'Salmos 34:1',

    'Salmos 92:1-2',

    'Salmos 95:2',

    'Salmos 100:4-5',

    'Salmos 103:1-2',

    'Salmos 107:1',

    'Salmos 118:24',

    'Salmos 136:1',

    'Efésios 5:20',

    'Colossenses 3:15',

    'Colossenses 3:16-17',

    '1 Tessalonicenses 5:18',

    // =============================================================
    // ALEGRIA
    // =============================================================

    'Salmos 16:11',

    'Salmos 30:5',

    'Salmos 32:11',

    'Salmos 47:1',

    'Salmos 66:1-2',

    'Salmos 95:1',

    'Salmos 98:4',

    'Salmos 100:1-2',

    'Salmos 118:24',

    'Salmos 126:5-6',

    'Isaías 55:12',

    'Habacuque 3:17-18',

    'João 15:10-11',

    'João 16:22',

    'Filipenses 4:4',

    '1 Tessalonicenses 5:16',

    // =============================================================
    // AMOR
    // =============================================================

    'João 13:34-35',

    'João 15:9',

    'João 15:12-13',

    'Romanos 12:9-10',

    '1 Coríntios 13:4-5',

    '1 Coríntios 13:6-7',

    '1 Pedro 4:8',

    '1 João 3:18',

    '1 João 4:7-8',

    '1 João 4:9-10',

    '1 João 4:19',

    // =============================================================
    // AMIZADE E COMUNHÃO
    // =============================================================

    'Provérbios 17:17',

    'Provérbios 18:24',

    'Provérbios 27:9',

    'Provérbios 27:17',

    'Eclesiastes 4:9-10',

    'Eclesiastes 4:11-12',

    'João 13:34-35',

    'João 15:12-13',

    'Romanos 12:10',

    'Gálatas 6:2',

    'Efésios 4:2-3',

    'Filipenses 2:1-2',

    'Colossenses 3:13-14',

    'Hebreus 10:24-25',

    // =============================================================
    // PERDÃO E MISERICÓRDIA
    // =============================================================

    'Salmos 32:1-2',

    'Salmos 51:10-12',

    'Salmos 86:5',

    'Salmos 103:8-9',

    'Salmos 103:10-12',

    'Salmos 130:3-4',

    'Provérbios 28:13',

    'Isaías 1:18',

    'Isaías 55:6-7',

    'Miquéias 7:18-19',

    'Mateus 6:14-15',

    'Mateus 18:21-22',

    'Lucas 6:36',

    'Efésios 4:31-32',

    'Colossenses 3:13',

    '1 João 1:9',

    // =============================================================
    // SABEDORIA E DIREÇÃO
    // =============================================================

    'Salmos 25:4-5',

    'Salmos 32:8',

    'Salmos 37:23-24',

    'Salmos 73:24',

    'Salmos 119:105',

    'Provérbios 2:6-7',

    'Provérbios 3:5-6',

    'Provérbios 4:7',

    'Provérbios 16:9',

    'Provérbios 19:20-21',

    'Isaías 30:21',

    'Tiago 1:5',

    // =============================================================
    // TEMOR DE DEUS E OBEDIÊNCIA
    // =============================================================

    'Deuteronômio 10:12-13',

    'Josué 24:15',

    'Salmos 1:1-3',

    'Salmos 19:7-8',

    'Salmos 111:10',

    'Salmos 119:9-11',

    'Provérbios 1:7',

    'Provérbios 3:1-2',

    'Eclesiastes 12:13',

    'João 14:15',

    'João 14:21',

    'Tiago 1:22',

    '1 João 5:3',

    // =============================================================
    // HUMILDADE
    // =============================================================

    'Salmos 51:17',

    'Provérbios 11:2',

    'Provérbios 15:33',

    'Provérbios 16:18-19',

    'Provérbios 18:12',

    'Provérbios 22:4',

    'Miquéias 6:8',

    'Mateus 5:3',

    'Mateus 18:3-4',

    'Lucas 14:11',

    'Lucas 18:14',

    'Filipenses 2:3-4',

    'Tiago 4:6-7',

    '1 Pedro 5:5-6',

    // =============================================================
    // PROPÓSITO E SERVIÇO
    // =============================================================

    'Josué 24:15',

    'Salmos 90:17',

    'Isaías 6:8',

    'Mateus 5:16',

    'Mateus 20:26-28',

    'Marcos 10:43-45',

    'João 12:26',

    'Atos 20:24',

    'Romanos 12:6-8',

    '1 Coríntios 15:58',

    'Gálatas 5:13',

    'Efésios 2:10',

    'Colossenses 3:23-24',

    '1 Pedro 4:10-11',

    // =============================================================
    // PROVISÃO E CUIDADO DE DEUS
    // =============================================================

    'Salmos 23:1',

    'Salmos 34:9-10',

    'Salmos 37:25',

    'Salmos 55:22',

    'Salmos 84:11',

    'Salmos 111:5',

    'Salmos 145:15-16',

    'Mateus 6:25-26',

    'Mateus 6:31-32',

    'Mateus 6:33-34',

    'Lucas 12:24',

    'Filipenses 4:19',

    'Hebreus 13:5',

    // =============================================================
    // FAMÍLIA E LAR
    // =============================================================

    'Salmos 127:1',

    'Salmos 127:3',

    'Salmos 128:1-2',

    'Salmos 128:3-4',

    'Provérbios 14:26',

    'Provérbios 22:6',

    'Isaías 54:13',

    'Atos 16:31',

    'Efésios 5:25',

    'Efésios 6:1-2',

    'Efésios 6:4',

    // =============================================================
    // SALVAÇÃO
    // =============================================================

    'João 3:16',

    'João 3:17-18',

    'João 5:24',

    'João 6:35',

    'João 6:37',

    'João 6:40',

    'João 10:9-10',

    'João 10:27-28',

    'João 11:25-26',

    'João 14:6',

    'Atos 4:12',

    'Atos 16:30-31',

    'Romanos 3:23-24',

    'Romanos 5:8-9',

    'Romanos 6:23',

    'Romanos 8:1',

    'Romanos 10:9-10',

    'Efésios 2:8-9',

    'Tito 3:5',

    '1 João 5:11-13',

    // =============================================================
    // PALAVRA DE DEUS
    // =============================================================

    'Salmos 19:7',

    'Salmos 119:9-11',

    'Salmos 119:17-18',

    'Salmos 119:50',

    'Salmos 119:105',

    'Salmos 119:130',

    'Isaías 55:10-11',

    'Mateus 4:4',

    'João 8:31-32',

    'João 17:17',

    'Romanos 10:17',

    '2 Timóteo 3:16-17',

    'Hebreus 4:12',

    'Tiago 1:21-22',

    '1 Pedro 1:23-25',

    // =============================================================
    // SANTIDADE E TRANSFORMAÇÃO
    // =============================================================

    'Salmos 51:10',

    'Salmos 139:23-24',

    'Romanos 6:11-12',

    'Romanos 12:1-2',

    '1 Coríntios 6:19-20',

    '2 Coríntios 5:17',

    'Gálatas 2:20',

    'Efésios 4:22-24',

    'Filipenses 1:6',

    'Colossenses 3:1-2',

    'Colossenses 3:9-10',

    '1 Tessalonicenses 4:3',

    '1 Pedro 1:14-16',

    // =============================================================
    // VIDA CRISTÃ
    // =============================================================

    'Miquéias 6:8',

    'Mateus 5:13-16',

    'Mateus 6:33',

    'Mateus 7:12',

    'Mateus 22:37-40',

    'Romanos 12:1-2',

    'Gálatas 5:22-23',

    'Filipenses 4:8-9',

    'Colossenses 3:12-14',

    'Colossenses 3:23-24',

    'Tiago 1:22',

    '1 Pedro 1:15-16',

    '1 Pedro 2:9',

    // =============================================================
    // PRESENÇA DE DEUS
    // =============================================================

    'Salmos 16:8',

    'Salmos 23:4',

    'Salmos 46:10',

    'Salmos 73:23',

    'Salmos 139:7-8',

    'Isaías 41:10',

    'Mateus 28:20',

    'João 14:18',

    'Hebreus 13:5',

    // =============================================================
    // FIDELIDADE DE DEUS
    // =============================================================

    'Deuteronômio 7:9',

    'Salmos 36:5',

    'Salmos 100:5',

    'Salmos 119:90',

    'Lamentações 3:22-23',

    '2 Tessalonicenses 3:3',

    '2 Timóteo 2:13',

    'Hebreus 10:23',

    '1 João 1:9',

    // =============================================================
    // AMOR E CUIDADO DE DEUS
    // =============================================================

    'Deuteronômio 7:9',

    'Salmos 103:11-12',

    'Isaías 43:4',

    'Jeremias 31:3',

    'João 3:16',

    'João 15:9',

    'Romanos 5:8',

    'Romanos 8:38-39',

    'Efésios 3:17-19',

    '1 João 4:9-10',

    // =============================================================
    // VITÓRIA E SUPERAÇÃO
    // =============================================================

    'Salmos 20:7',

    'Salmos 44:5',

    'Salmos 60:12',

    'Salmos 108:13',

    'Romanos 8:37',

    '1 Coríntios 15:57',

    '2 Coríntios 2:14',

    '2 Coríntios 12:9',

    'Filipenses 4:13',

    '1 João 5:4',

    // =============================================================
    // DESCANSO EM DEUS
    // =============================================================

    'Salmos 23:2',

    'Salmos 46:10',

    'Salmos 62:1-2',

    'Salmos 91:1',

    'Salmos 116:7',

    'Isaías 30:15',

    'Mateus 11:28-29',

    'Marcos 6:31',

    'Hebreus 4:9-10',

    // =============================================================
    // PAZ NO MEIO DAS LUTAS
    // =============================================================

    'Salmos 34:19',

    'Salmos 55:22',

    'Isaías 43:2',

    'João 16:33',

    'Romanos 8:28',

    'Romanos 8:31',

    '2 Coríntios 4:8-9',

    '2 Coríntios 4:16-18',

    'Filipenses 4:6-7',

    '1 Pedro 5:7',

    // =============================================================
    // FUTURO E PROPÓSITO
    // =============================================================

    'Salmos 37:5',

    'Salmos 90:17',

    'Provérbios 16:3',

    'Provérbios 16:9',

    'Jeremias 29:11',

    'Romanos 8:28',

    'Efésios 2:10',

    'Filipenses 1:6',

    'Filipenses 3:13-14',

    'Hebreus 12:1-2',
  ];

  // =============================================================
  // OBTER PALAVRA DO DIA
  // =============================================================
  //
  // A Palavra do Dia muda às 06:02.
  //
  // Antes das 06:02, ainda consideramos que estamos no
  // "dia anterior" para efeito da Palavra do Dia.
  //
  // Isso mantém a Palavra sincronizada com a notificação:
  //
  // 06:02 → nova Palavra do Dia
  //
  // =============================================================

  static Future<Versiculo?> obterPalavraDoDia() async {
    final agora = DateTime.now();

    final DateTime dataLogica = _dataLogica(agora);

    return obterPalavraParaData(dataLogica);
  }

  // =============================================================
  // DATA LÓGICA DA PALAVRA DO DIA
  // =============================================================
  //
  // Regra:
  //
  // 00:00 até 06:01 → dia anterior
  // 06:02 em diante  → dia atual
  //
  // Assim, a Palavra do Dia só muda às 06:02.
  // =============================================================

  static DateTime _dataLogica(DateTime data) {
    if (data.hour < 6 ||
        (data.hour == 6 && data.minute < 2)) {
      return data.subtract(
        const Duration(days: 1),
      );
    }

    return data;
  }

  // =============================================================
  // OBTER PALAVRA PARA UMA DATA ESPECÍFICA
  // =============================================================
  //
  // Permite descobrir qual Palavra do Dia corresponde a uma
  // determinada data.
  //
  // A data recebida aqui já representa a data lógica da Palavra.
  //
  // Exemplo:
  //
  // obterPalavraParaData(DateTime(2026, 9, 8))
  //
  // retorna a Palavra correspondente ao dia lógico
  // 8 de Setembro de 2026.
  //
  // A lista de referências e a lógica de seleção permanecem
  // exatamente as mesmas.
  // =============================================================

  static Future<Versiculo?> obterPalavraParaData(
    DateTime data,
  ) async {
    final versiculos =
        await VersiculosServico.carregarVersiculos();

    if (versiculos.isEmpty) {
      return null;
    }

    // -----------------------------------------------------------
    // MAPA DE TODOS OS VERSÍCULOS
    // -----------------------------------------------------------

    final Map<String, Versiculo> mapaVersiculos = {};

    for (final versiculo in versiculos) {
      mapaVersiculos[
        versiculo.referencia.trim()
      ] = versiculo;
    }

    // -----------------------------------------------------------
    // CRIAR AS PASSAGENS DISPONÍVEIS
    // -----------------------------------------------------------

    final List<Versiculo> palavrasDisponiveis = [];

    for (final referencia in _referencias) {
      final passagem =
          _construirPassagem(
        referencia: referencia,
        mapaVersiculos: mapaVersiculos,
      );

      if (passagem != null) {
        palavrasDisponiveis.add(passagem);
      }
    }

    // -----------------------------------------------------------
    // NENHUMA PASSAGEM ENCONTRADA
    // -----------------------------------------------------------

    if (palavrasDisponiveis.isEmpty) {
      return null;
    }

    // -----------------------------------------------------------
    // DATA SELECIONADA
    // -----------------------------------------------------------

    final dataSelecionada = DateTime(
      data.year,
      data.month,
      data.day,
    );

    // -----------------------------------------------------------
    // PRIMEIRO DIA DO ANO
    // -----------------------------------------------------------

    final inicioDoAno = DateTime(
      data.year,
      1,
      1,
    );

    // -----------------------------------------------------------
    // DIA DO ANO
    // -----------------------------------------------------------

    final diaDoAno =
        dataSelecionada
            .difference(inicioDoAno)
            .inDays;

    // -----------------------------------------------------------
    // SELEÇÃO DETERMINÍSTICA
    // -----------------------------------------------------------
    //
    // A Palavra muda de acordo com o dia lógico.
    //
    // Portanto:
    //
    // 06:01 → ainda usa a Palavra anterior
    // 06:02 → passa para a nova Palavra
    //
    // -----------------------------------------------------------

    final indice =
        diaDoAno %
            palavrasDisponiveis.length;

    return palavrasDisponiveis[indice];
  }

  // =============================================================
  // CONSTRUIR PASSAGEM
  // =============================================================

  static Versiculo? _construirPassagem({
    required String referencia,
    required Map<String, Versiculo> mapaVersiculos,
  }) {
    final referenciaLimpa =
        referencia.trim();

    // -----------------------------------------------------------
    // VERIFICAR SE É UMA PASSAGEM DE DOIS VERSÍCULOS
    // -----------------------------------------------------------

    final partes =
        _analisarIntervalo(
      referenciaLimpa,
    );

    if (partes != null) {
      final String livro =
          partes['livro'] as String;

      final int capitulo =
          partes['capitulo'] as int;

      final int versiculoInicial =
          partes['inicio'] as int;

      final int versiculoFinal =
          partes['fim'] as int;

      // ---------------------------------------------------------
      // POR SEGURANÇA, SÓ ACEITAMOS 2 VERSÍCULOS
      // ---------------------------------------------------------

      if (versiculoFinal !=
          versiculoInicial + 1) {
        return null;
      }

      final String referencia1 =
          '$livro $capitulo:$versiculoInicial';

      final String referencia2 =
          '$livro $capitulo:$versiculoFinal';

      final Versiculo? primeiro =
          mapaVersiculos[referencia1];

      final Versiculo? segundo =
          mapaVersiculos[referencia2];

      if (primeiro == null ||
          segundo == null) {
        return null;
      }

      // ---------------------------------------------------------
      // JUNTAR OS DOIS VERSÍCULOS
      // ---------------------------------------------------------

      final String texto =
          '$versiculoInicial. '
          '${primeiro.texto.trim()}'
          '\n\n'
          '$versiculoFinal. '
          '${segundo.texto.trim()}';

      return Versiculo(
        referencia:
            '$livro '
            '$capitulo:'
            '$versiculoInicial-'
            '$versiculoFinal',
        texto: texto,
      );
    }

    // ===========================================================
    // UM ÚNICO VERSÍCULO
    // ===========================================================

    final Versiculo? versiculo =
        mapaVersiculos[
          referenciaLimpa
        ];

    if (versiculo == null) {
      return null;
    }

    final partesUnico =
        _analisarReferencia(
      referenciaLimpa,
    );

    if (partesUnico == null) {
      return versiculo;
    }

    final int numero =
        partesUnico['versiculo'] as int;

    return Versiculo(
      referencia:
          referenciaLimpa,
      texto:
          '$numero. ${versiculo.texto.trim()}',
    );
  }

  // =============================================================
  // ANALISAR INTERVALO
  // =============================================================

  static Map<String, Object>?
      _analisarIntervalo(
    String referencia,
  ) {
    final indiceDoisPontos =
        referencia.lastIndexOf(':');

    if (indiceDoisPontos == -1) {
      return null;
    }

    final String parteLivroCapitulo =
        referencia
            .substring(
              0,
              indiceDoisPontos,
            )
            .trim();

    final String parteVersiculos =
        referencia
            .substring(
              indiceDoisPontos + 1,
            )
            .trim();

    final partesVersiculos =
        parteVersiculos.split('-');

    if (partesVersiculos.length != 2) {
      return null;
    }

    final int? inicio =
        int.tryParse(
      partesVersiculos[0].trim(),
    );

    final int? fim =
        int.tryParse(
      partesVersiculos[1].trim(),
    );

    if (inicio == null ||
        fim == null) {
      return null;
    }

    final ultimoEspaco =
        parteLivroCapitulo.lastIndexOf(' ');

    if (ultimoEspaco == -1) {
      return null;
    }

    final String livro =
        parteLivroCapitulo
            .substring(
              0,
              ultimoEspaco,
            )
            .trim();

    final String parteCapitulo =
        parteLivroCapitulo
            .substring(
              ultimoEspaco + 1,
            )
            .trim();

    final int? capitulo =
        int.tryParse(
      parteCapitulo,
    );

    if (capitulo == null ||
        livro.isEmpty) {
      return null;
    }

    return {
      'livro': livro,
      'capitulo': capitulo,
      'inicio': inicio,
      'fim': fim,
    };
  }

  // =============================================================
  // ANALISAR REFERÊNCIA DE UM ÚNICO VERSÍCULO
  // =============================================================

  static Map<String, Object>?
      _analisarReferencia(
    String referencia,
  ) {
    final referenciaLimpa =
        referencia.trim();

    final indiceDoisPontos =
        referenciaLimpa.lastIndexOf(':');

    if (indiceDoisPontos == -1) {
      return null;
    }

    final String parteLivroCapitulo =
        referenciaLimpa
            .substring(
              0,
              indiceDoisPontos,
            )
            .trim();

    final String parteVersiculo =
        referenciaLimpa
            .substring(
              indiceDoisPontos + 1,
            )
            .trim();

    final int? numeroVersiculo =
        int.tryParse(
      parteVersiculo,
    );

    if (numeroVersiculo == null) {
      return null;
    }

    final ultimoEspaco =
        parteLivroCapitulo.lastIndexOf(' ');

    if (ultimoEspaco == -1) {
      return null;
    }

    final String livro =
        parteLivroCapitulo
            .substring(
              0,
              ultimoEspaco,
            )
            .trim();

    final String parteCapitulo =
        parteLivroCapitulo
            .substring(
              ultimoEspaco + 1,
            )
            .trim();

    final int? capitulo =
        int.tryParse(
      parteCapitulo,
    );

    if (capitulo == null ||
        livro.isEmpty) {
      return null;
    }

    return {
      'livro': livro,
      'capitulo': capitulo,
      'versiculo': numeroVersiculo,
    };
  }
}