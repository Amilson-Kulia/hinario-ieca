
/// =============================================================
/// MENSAGENS LOCAIS DAS NOTIFICAÇÕES
/// =============================================================
///
/// 14 mensagens para cada período (Bom Dia e Boa Noite).
///
/// As mensagens foram escritas para serem curtas, acolhedoras
/// e espiritualmente reconfortantes, evitando um tom excessivamente
/// formal ou repetitivo.
///
/// A cada dia é escolhida uma mensagem, rodando ciclicamente.
/// A escolha utiliza o número do dia no ano, mantendo o resultado
/// consistente para a mesma data.
///
class MensagensNotificacoes {
  MensagensNotificacoes._();

  // ===========================================================
  // BOM DIA — 14 mensagens
  // ===========================================================

  static const List<String> bomDia = [
    'Bom dia, irmão/ã. Que a paz do Senhor encontre o teu coração '
        'antes mesmo de começares o teu dia.',

    'Bom dia, irmão/ã. Respira fundo, entrega este dia ao Senhor '
        'e caminha com a certeza de que Ele está contigo.',

    'Bom dia, irmão/ã. Não carregues sozinho aquilo que podes '
        'entregar a Deus. Confia n’Ele e segue em paz.',

    'Bom dia, irmão/ã. Que a misericórdia do Senhor te alcance '
        'nesta manhã e te dê forças para tudo o que vier.',

    'Bom dia, irmão/ã. Talvez não saibas o que este dia trará, '
        'mas podes descansar sabendo em quem colocaste a tua confiança.',

    'Bom dia, irmão/ã. Que Deus acalme as tuas preocupações, '
        'fortaleça a tua fé e guie cada passo teu hoje.',

    'Bom dia, irmão/ã. Se ontem foi difícil, não significa que hoje '
        'também será. Recebe esta nova manhã como um presente de Deus.',

    'Bom dia, irmão/ã. Que a presença do Senhor seja maior '
        'do que qualquer preocupação que hoje esteja no teu coração.',

    'Bom dia, irmão/ã. Não tenhas pressa para resolver tudo hoje. '
        'Faz a tua parte, confia em Deus e deixa o resto nas Suas mãos.',

    'Bom dia, irmão/ã. Que hoje encontres motivos para agradecer, '
        'mesmo nas pequenas coisas que muitas vezes passam despercebidas.',

    'Bom dia, irmão/ã. Quando o caminho parecer incerto, lembra-te: '
        'Deus continua a ser Deus mesmo quando tu ainda não vês a resposta.',

    'Bom dia, irmão/ã. Que a tua mente encontre descanso, '
        'o teu coração encontre esperança e os teus passos encontrem direção.',

    'Bom dia, irmão/ã. Começa este dia sem medo. O Senhor conhece '
        'as tuas necessidades e permanece contigo em cada momento.',

    'Bom dia, irmão/ã. Que a graça de Deus te acompanhe hoje, '
        'e que ao chegar a noite possas olhar para trás e agradecer.',
  ];

  // ===========================================================
  // BOA NOITE — 14 mensagens
  // ===========================================================

  static const List<String> boaNoite = [
    'Boa noite, irmão/ã. Deixa nas mãos de Deus aquilo que hoje '
        'não conseguiste resolver e permite que o teu coração descanse.',

    'Boa noite, irmão/ã. O dia terminou. Respira, agradece pelo que '
        'Deus te permitiu viver e descansa em Sua paz.',

    'Boa noite, irmão/ã. Não leves para a cama todas as preocupações '
        'do dia. Entrega-as ao Senhor e descansa.',

    'Boa noite, irmão/ã. Talvez hoje não tenha sido como esperavas, '
        'mas Deus esteve contigo em cada momento.',

    'Boa noite, irmão/ã. O que ficou por fazer pode esperar até amanhã. '
        'Agora é tempo de descansar e confiar em Deus.',

    'Boa noite, irmão/ã. Que a paz de Cristo silencie aquilo que '
        'está inquietando o teu coração e te conceda um sono tranquilo.',

    'Boa noite, irmão/ã. Se o teu coração está cansado, fala com Deus. '
        'Ele conhece até aquilo que não consegues colocar em palavras.',

    'Boa noite, irmão/ã. Descansa. Nem tudo precisa de uma resposta '
        'esta noite. Algumas coisas precisam apenas de ser entregues a Deus.',

    'Boa noite, irmão/ã. Agradece por teres chegado até aqui. '
        'Amanhã será um novo dia, sustentado pela mesma graça.',

    'Boa noite, irmão/ã. Fecha os olhos em paz. O Senhor não deixa '
        'de cuidar de ti quando tu adormeces.',

    'Boa noite, irmão/ã. Que Deus guarde a tua casa, a tua família '
        'e o teu coração durante esta noite.',

    'Boa noite, irmão/ã. Não permitas que os erros de hoje roubem '
        'a esperança de amanhã. A graça de Deus continua contigo.',

    'Boa noite, irmão/ã. Descansa sabendo que Deus conhece o teu '
        'cansaço, as tuas lutas e também os teus sonhos.',

    'Boa noite, irmão/ã. Entrega o amanhã ao Senhor e descansa hoje. '
        'Aquele que cuidou de ti até aqui continuará a cuidar de ti.',
  ];

  /// Devolve a mensagem de Bom Dia para a data.
  ///
  /// Usa o dia do ano (1..366) para escolher ciclicamente.
  static String bomDiaParaData(DateTime data) {
    final int dia = _diaDoAno(data);
    return bomDia[(dia - 1) % bomDia.length];
  }

  /// Devolve a mensagem de Boa Noite para a data.
  static String boaNoiteParaData(DateTime data) {
    final int dia = _diaDoAno(data);
    return boaNoite[(dia - 1) % boaNoite.length];
  }

  /// Dia do ano (1 a 366), estável entre anos bissextos.
  static int _diaDoAno(DateTime data) {
    final DateTime primeiroDia = DateTime(data.year, 1, 1);
    final DateTime d = DateTime(
      data.year,
      data.month,
      data.day,
    );

    return d.difference(primeiroDia).inDays + 1;
  }
}