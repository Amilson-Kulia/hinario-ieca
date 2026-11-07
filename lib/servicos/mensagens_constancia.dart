import 'constancia_servico.dart';

class MensagemConstancia {
  final String titulo;
  final String mensagem;
  final String versiculo;
  final String referencia;
  final String encerramento;

  const MensagemConstancia({
    required this.titulo,
    required this.mensagem,
    required this.versiculo,
    required this.referencia,
    required this.encerramento,
  });
}

class MensagensConstancia {
  MensagensConstancia._();

  static MensagemConstancia obter({
    required TipoConstancia tipo,
    required int marco,
  }) {
    switch (tipo) {
      case TipoConstancia.geral:
        return _mensagemGeral(marco);

      case TipoConstancia.biblia:
        return _mensagemBiblia(marco);

      case TipoConstancia.hinario:
        return _mensagemHinario(marco);

      case TipoConstancia.lecionario:
        return _mensagemLecionario(marco);
    }
  }

  // ============================================================
  // CONSTÂNCIA GERAL
  // ============================================================
  static MensagemConstancia _mensagemGeral(int marco) {
    switch (marco) {
      case 3:
        return const MensagemConstancia(
          titulo: 'Um bom começo',
          mensagem:
              'Já são 3 dias de caminhada. Cada dia em que escolhes '
              'voltar é uma pequena decisão que pode produzir grandes '
              'mudanças na tua vida espiritual.',
          versiculo:
              'Tudo tem o seu tempo determinado, e há tempo para todo propósito debaixo do céu.',
          referencia: 'Eclesiastes 3:1',
          encerramento:
              'Continua. Uma caminhada de fé começa com um primeiro passo.',
        );

      case 7:
        return const MensagemConstancia(
          titulo: 'Continua firme',
          mensagem:
              'Já são 7 dias de caminhada. Cada dia representa uma '
              'escolha de permanecer, crescer e aproximar-te mais de Deus.',
          versiculo:
              'Sede firmes, inabaláveis e sempre abundantes na obra do Senhor.',
          referencia: '1 Coríntios 15:58',
          encerramento: 'Continua firme. A jornada ainda está a começar.',
        );

      case 14:
        return const MensagemConstancia(
          titulo: 'Permanece',
          mensagem:
              'Duas semanas de constância. O que começou como uma '
              'decisão está a tornar-se parte da tua caminhada.',
          versiculo: 'Permanecei em mim, e eu permanecerei em vós.',
          referencia: 'João 15:4',
          encerramento:
              'Que a tua constância não seja apenas um hábito, mas uma forma de permanecer em Cristo.',
        );

      case 21:
        return const MensagemConstancia(
          titulo: 'Uma caminhada que cresce',
          mensagem:
              'Já são 21 dias. Cada momento dedicado a Deus é uma '
              'oportunidade para fortalecer a fé e amadurecer espiritualmente.',
          versiculo:
              'Aquele, porém, que perseverar até ao fim, esse será salvo.',
          referencia: 'Mateus 24:13',
          encerramento: 'Não pares agora. Continua a caminhar com Deus.',
        );

      case 30:
        return const MensagemConstancia(
          titulo: 'Um mês de caminhada',
          mensagem:
              'Um mês de constância. São muitos dias, muitas escolhas '
              'e muitos momentos em que decidiste continuar.',
          versiculo:
              'Ensina-nos a contar os nossos dias, para que alcancemos corações sábios.',
          referencia: 'Salmos 90:12',
          encerramento:
              'Que cada novo dia seja uma oportunidade de viver mais perto de Deus.',
        );

      case 60:
        return const MensagemConstancia(
          titulo: 'Perseverança',
          mensagem:
              'Já são 60 dias de caminhada. A perseverança não significa '
              'que todos os dias sejam fáceis, mas que continuamos mesmo assim.',
          versiculo:
              'Não nos cansemos de fazer o bem, porque a seu tempo ceifaremos, se não houvermos desfalecido.',
          referencia: 'Gálatas 6:9',
          encerramento:
              'Permanece firme. Deus vê cada passo da tua caminhada.',
        );

      case 90:
        return const MensagemConstancia(
          titulo: 'Três meses de perseverança',
          mensagem:
              '90 dias de constância. Que este tempo seja mais do que '
              'uma sequência de dias: que seja uma história de crescimento '
              'na presença de Deus.',
          versiculo:
              'Bem-aventurado o homem que não anda segundo o conselho dos ímpios.',
          referencia: 'Salmos 1:1',
          encerramento:
              'Continua a cultivar aquilo que aproxima o teu coração de Deus.',
        );

      case 180:
        return const MensagemConstancia(
          titulo: 'Seis meses de caminhada',
          mensagem:
              'Já são 180 dias. Meio ano de escolhas, perseverança e '
              'momentos dedicados à tua caminhada espiritual.',
          versiculo:
              'Corramos, com perseverança, a carreira que nos está proposta.',
          referencia: 'Hebreus 12:1',
          encerramento:
              'Olha para trás com gratidão e para a frente com fé.',
        );

      case 365:
        return const MensagemConstancia(
          titulo: 'Um ano de caminhada',
          mensagem:
              '365 dias. Um ano inteiro de caminhada. Mais do que um '
              'número, este marco representa muitos dias em que escolheste '
              'continuar a buscar, aprender, louvar e aproximar-te de Deus.',
          versiculo: 'Até aqui nos ajudou o Senhor.',
          referencia: '1 Samuel 7:12',
          encerramento:
              'Celebra este marco com gratidão. E que o próximo ano seja ainda mais profundo na presença de Deus.',
        );

      default:
        return _mensagemGeralPadrao(marco);
    }
  }

  // ============================================================
  // CONSTÂNCIA NA BÍBLIA
  // ============================================================
  static MensagemConstancia _mensagemBiblia(int marco) {
    switch (marco) {
      case 3:
        return const MensagemConstancia(
          titulo: 'Primeiros passos na Palavra',
          mensagem:
              'Já são 3 dias a dedicar tempo à Palavra de Deus. '
              'Cada leitura é uma oportunidade para ouvir, aprender e crescer.',
          versiculo:
              'Desejai ardentemente, como crianças recém-nascidas, o genuíno leite espiritual.',
          referencia: '1 Pedro 2:2',
          encerramento:
              'Continua a descobrir as riquezas que existem na Palavra.',
        );

      case 7:
        return const MensagemConstancia(
          titulo: 'Uma semana na Palavra',
          mensagem:
              'Há 7 dias que tens separado um tempo para estar na Palavra. '
              'Cada dia em que voltas às Escrituras é uma oportunidade de '
              'conhecer mais a Deus, fortalecer a tua fé e deixar que a Sua '
              'Palavra transforme o teu coração.',
          versiculo:
              'Guardo no coração as tuas palavras, para não pecar contra ti.',
          referencia: 'Salmos 119:11',
          encerramento:
              'Continua firme. Cada dia conta, cada passo aproxima-te mais de Deus.',
        );

      case 14:
        return const MensagemConstancia(
          titulo: 'Crescendo na Palavra',
          mensagem:
              'Duas semanas de leitura. Quanto mais conhecemos a Palavra, '
              'mais aprendemos a reconhecer a voz de Deus e a aplicar os '
              'Seus ensinamentos à nossa vida.',
          versiculo:
              'A tua palavra é lâmpada para os meus pés e luz para o meu caminho.',
          referencia: 'Salmos 119:105',
          encerramento:
              'Continua a ler, meditar e guardar a Palavra no coração.',
        );

      case 21:
        return const MensagemConstancia(
          titulo: 'Permanece na Palavra',
          mensagem:
              'Já são 21 dias de caminhada pelas Escrituras. Que este '
              'tempo esteja a fortalecer não apenas o teu conhecimento, '
              'mas também a tua fé.',
          versiculo:
              'Nem só de pão viverá o homem, mas de toda palavra que procede da boca de Deus.',
          referencia: 'Mateus 4:4',
          encerramento:
              'Que a Palavra continue a orientar os teus passos.',
        );

      case 30:
        return const MensagemConstancia(
          titulo: 'Um mês com a Palavra',
          mensagem:
              'Um mês de constância na leitura da Bíblia. São muitos '
              'momentos em que abriste as Escrituras para aprender e crescer.',
          versiculo:
              'Toda a Escritura é inspirada por Deus e útil para o ensino.',
          referencia: '2 Timóteo 3:16',
          encerramento:
              'Não leias apenas para terminar capítulos. Lê para conhecer e viver a Palavra.',
        );

      case 60:
        return const MensagemConstancia(
          titulo: 'Firmado na Palavra',
          mensagem:
              'Já são 60 dias de leitura. A Palavra de Deus não foi dada '
              'apenas para ser lida, mas para ser vivida.',
          versiculo:
              'Sede cumpridores da palavra e não somente ouvintes.',
          referencia: 'Tiago 1:22',
          encerramento:
              'Que aquilo que lês continue a transformar a maneira como vives.',
        );

      case 90:
        return const MensagemConstancia(
          titulo: 'Três meses nas Escrituras',
          mensagem:
              '90 dias de caminhada pela Bíblia. Cada capítulo lido é '
              'mais uma oportunidade para conhecer a história da redenção '
              'e aprofundar a tua relação com Deus.',
          versiculo: 'Conheçamos e prossigamos em conhecer ao Senhor.',
          referencia: 'Oséias 6:3',
          encerramento:
              'Continua a buscar conhecimento, sabedoria e transformação na Palavra.',
        );

      case 180:
        return const MensagemConstancia(
          titulo: 'Seis meses na Palavra',
          mensagem:
              '180 dias de constância na Bíblia. Meio ano de leitura, '
              'reflexão e descoberta das verdades das Escrituras.',
          versiculo: 'Santifica-os na verdade; a tua palavra é a verdade.',
          referencia: 'João 17:17',
          encerramento:
              'Que a verdade da Palavra continue a moldar o teu coração.',
        );

      case 365:
        return const MensagemConstancia(
          titulo: 'Um ano na Palavra',
          mensagem:
              '365 dias. Um ano inteiro de caminhada pelas Escrituras. '
              'Que este marco te lembre de quantas vezes a Palavra esteve '
              'presente nos teus dias e de quanto ainda existe para descobrir.',
          versiculo:
              'Oh! Quanto amo a tua lei! É a minha meditação todo o dia.',
          referencia: 'Salmos 119:97',
          encerramento:
              'Não termines a jornada com um ano. Continua a fazer da Palavra parte da tua vida.',
        );

      default:
        return _mensagemBibliaPadrao(marco);
    }
  }

  // ============================================================
  // CONSTÂNCIA NO HINÁRIO
  // ============================================================
  static MensagemConstancia _mensagemHinario(int marco) {
    switch (marco) {
      case 3:
        return const MensagemConstancia(
          titulo: 'Um começo de louvor',
          mensagem:
              'Já são 3 dias de caminhada através dos hinos e cânticos. '
              'Que cada momento de louvor seja também um momento de adoração.',
          versiculo:
              'Cantai ao Senhor um cântico novo; cantai ao Senhor, todos os habitantes da terra.',
          referencia: 'Salmos 96:1',
          encerramento:
              'Continua a louvar. Que a adoração faça parte da tua caminhada.',
        );

      case 7:
        return const MensagemConstancia(
          titulo: 'Uma semana de louvor',
          mensagem:
              'Há 7 dias que tens caminhado através dos cânticos e hinos. '
              'Que cada louvor não seja apenas uma canção nos teus lábios, '
              'mas também uma expressão sincera de fé, gratidão e adoração a Deus.',
          versiculo:
              'Cantai ao Senhor um cântico novo; cantai ao Senhor, todos os habitantes da terra.',
          referencia: 'Salmos 96:1',
          encerramento:
              'Continua a louvar. Que a tua caminhada seja marcada pela adoração.',
        );

      case 14:
        return const MensagemConstancia(
          titulo: 'Duas semanas de adoração',
          mensagem:
              'Já são 14 dias de louvor. Que os hinos que cantas não '
              'sejam apenas melodias, mas verdades que permanecem no teu coração.',
          versiculo:
              'Falando entre vós com salmos, hinos e cânticos espirituais.',
          referencia: 'Efésios 5:19',
          encerramento:
              'Que cada cântico te conduza para mais perto de Deus.',
        );

      case 21:
        return const MensagemConstancia(
          titulo: 'O louvor continua',
          mensagem:
              '21 dias de constância. Há poder em lembrar diariamente '
              'quem Deus é e responder-Lhe com louvor.',
          versiculo:
              'Louvarei ao Senhor em todo o tempo; o seu louvor estará continuamente na minha boca.',
          referencia: 'Salmos 34:1',
          encerramento:
              'Continua a fazer do louvor uma expressão da tua fé.',
        );

      case 30:
        return const MensagemConstancia(
          titulo: 'Um mês de louvor',
          mensagem:
              'Um mês de caminhada pelo Hinário. Que as palavras dos '
              'hinos continuem a ensinar, consolar, fortalecer e conduzir '
              'o teu coração à adoração.',
          versiculo: 'Tudo quanto tem fôlego louve ao Senhor.',
          referencia: 'Salmos 150:6',
          encerramento:
              'Que nunca faltem motivos para agradecer e louvar ao Senhor.',
        );

      case 60:
        return const MensagemConstancia(
          titulo: 'Louvor que permanece',
          mensagem:
              'Já são 60 dias. O louvor não depende apenas das circunstâncias; '
              'ele nasce também de um coração que reconhece a fidelidade de Deus.',
          versiculo:
              'Bendize, ó minha alma, ao Senhor, e não te esqueças de nenhum de seus benefícios.',
          referencia: 'Salmos 103:2',
          encerramento:
              'Continua a recordar as obras de Deus e a responder-Lhe com louvor.',
        );

      case 90:
        return const MensagemConstancia(
          titulo: 'Três meses de adoração',
          mensagem:
              '90 dias de caminhada através dos hinos. Que este tempo '
              'tenha enchido os teus dias de palavras que fortalecem a fé '
              'e elevam o coração.',
          versiculo: 'Grande é o Senhor e mui digno de ser louvado.',
          referencia: 'Salmos 48:1',
          encerramento:
              'Que o teu louvor continue a apontar para a grandeza de Deus.',
        );

      case 180:
        return const MensagemConstancia(
          titulo: 'Seis meses de louvor',
          mensagem:
              '180 dias de constância no Hinário. Meio ano de cânticos, '
              'hinos e palavras de fé que podem continuar a acompanhar a tua caminhada.',
          versiculo:
              'Cantai ao Senhor, bendizei o seu nome; anunciai de dia em dia a sua salvação.',
          referencia: 'Salmos 96:2',
          encerramento:
              'Continua a cantar aquilo em que crês e a viver aquilo que cantas.',
        );

      case 365:
        return const MensagemConstancia(
          titulo: 'Um ano de louvor',
          mensagem:
              '365 dias de caminhada através do Hinário. Um ano inteiro '
              'em que o louvor encontrou espaço na tua jornada. Que cada '
              'hino aprendido e cada palavra cantada continue a fortalecer '
              'a tua fé e a tua adoração.',
          versiculo:
              'Louvarei ao Senhor durante a minha vida; cantarei louvores ao meu Deus enquanto eu viver.',
          referencia: 'Salmos 146:2',
          encerramento:
              'Que o louvor nunca seja apenas uma parte da tua rotina, mas uma expressão da tua vida com Deus.',
        );

      default:
        return _mensagemHinarioPadrao(marco);
    }
  }

  // ============================================================
  // CONSTÂNCIA NO LECIONÁRIO
  // ============================================================
  static MensagemConstancia _mensagemLecionario(int marco) {
    switch (marco) {
      case 3:
        return const MensagemConstancia(
          titulo: 'Primeiros passos no Lecionário',
          mensagem:
              'Já são 3 dias a meditar no Lecionário. Cada dia é uma '
              'oportunidade de deixar a Palavra de Deus falar ao teu coração.',
          versiculo:
              'Oh! Quanto amo a tua lei! É a minha meditação em todo o dia.',
          referencia: 'Salmos 119:97',
          encerramento:
              'Continua a meditar. A Palavra cresce em quem a guarda.',
        );

      case 7:
        return const MensagemConstancia(
          titulo: 'Uma semana no Lecionário',
          mensagem:
              'Há 7 dias que meditas no Lecionário. A leitura diária está '
              'a tornar-se um hábito. Que cada reflexão te aproxime mais de Deus.',
          versiculo:
              'Deixemos todo o embaraço, e o pecado, e corramos, com paciência, olhando para Jesus.',
          referencia: 'Hebreus 12:1b-2a',
          encerramento:
              'Continua firme. Uma semana é apenas o começo.',
        );

      case 14:
        return const MensagemConstancia(
          titulo: 'Crescendo na Palavra',
          mensagem:
              'Duas semanas de meditação. Quanto mais meditamos, mais '
              'aprendemos a reconhecer a voz de Deus na nossa vida.',
          versiculo:
              'A tua palavra é lâmpada para os meus pés e luz para o meu caminho.',
          referencia: 'Salmos 119:105',
          encerramento:
              'Que a Palavra continue a iluminar cada passo da tua caminhada.',
        );

      case 21:
        return const MensagemConstancia(
          titulo: 'Permanece na meditação',
          mensagem:
              'Já são 21 dias de constância. Que este tempo esteja a '
              'fortalecer não apenas o teu conhecimento, mas a tua fé.',
          versiculo:
              'Antes tem o seu prazer na lei do Senhor, e na sua lei medita de dia e de noite.',
          referencia: 'Salmos 1:2',
          encerramento:
              'Que a meditação diária se torne parte da tua vida.',
        );

      case 30:
        return const MensagemConstancia(
          titulo: 'Um mês de meditação',
          mensagem:
              'Um mês de constância no Lecionário. Foram muitos dias de '
              'reflexão, oração e crescimento na Palavra.',
          versiculo:
              'Ensina-nos a contar os nossos dias, para que alcancemos corações sábios.',
          referencia: 'Salmos 90:12',
          encerramento:
              'Que cada mês traga mais profundidade na tua caminhada com Deus.',
        );

      case 60:
        return const MensagemConstancia(
          titulo: 'Firmado na Palavra',
          mensagem:
              'Já são 60 dias de meditação no Lecionário. A Palavra de Deus '
              'não foi dada apenas para ser lida, mas para ser vivida.',
          versiculo:
              'Sede cumpridores da palavra e não somente ouvintes.',
          referencia: 'Tiago 1:22',
          encerramento:
              'Que aquilo que meditas continue a transformar a tua vida.',
        );

      case 90:
        return const MensagemConstancia(
          titulo: 'Três meses de meditação',
          mensagem:
              '90 dias de caminhada no Lecionário. Cada reflexão é mais '
              'uma oportunidade de conhecer a vontade de Deus para a tua vida.',
          versiculo: 'Conheçamos e prossigamos em conhecer ao Senhor.',
          referencia: 'Oséias 6:3',
          encerramento:
              'Continua a buscar conhecimento, sabedoria e transformação.',
        );

      case 180:
        return const MensagemConstancia(
          titulo: 'Seis meses de meditação',
          mensagem:
              '180 dias de constância no Lecionário. Meio ano de leitura, '
              'reflexão e descoberta das verdades das Escrituras.',
          versiculo:
              'Santifica-os na verdade; a tua palavra é a verdade.',
          referencia: 'João 17:17',
          encerramento:
              'Que a verdade da Palavra continue a moldar o teu coração.',
        );

      case 365:
        return const MensagemConstancia(
          titulo: 'Um ano no Lecionário',
          mensagem:
              '365 dias. Um ano inteiro de meditação diária. Que este marco '
              'te lembre de quantas vezes a Palavra esteve presente nos teus dias.',
          versiculo: 'Até aqui nos ajudou o Senhor.',
          referencia: '1 Samuel 7:12',
          encerramento:
              'Celebra com gratidão. E que o próximo ano seja ainda mais profundo.',
        );

      default:
        return _mensagemLecionarioPadrao(marco);
    }
  }

  // ============================================================
  // MENSAGENS DE SEGURANÇA
  // ============================================================
  static MensagemConstancia _mensagemGeralPadrao(int marco) {
    return MensagemConstancia(
      titulo: 'Continua firme',
      mensagem:
          'Alcançaste $marco dias de constância. Cada dia representa '
          'mais um passo na tua caminhada.',
      versiculo:
          'Corramos, com perseverança, a carreira que nos está proposta.',
      referencia: 'Hebreus 12:1',
      encerramento:
          'Continua a caminhar com fé, perseverança e confiança em Deus.',
    );
  }

  static MensagemConstancia _mensagemBibliaPadrao(int marco) {
    return MensagemConstancia(
      titulo: 'Continua na Palavra',
      mensagem:
          'Alcançaste $marco dias de constância na Bíblia. '
          'Cada momento dedicado à Palavra pode transformar a tua caminhada.',
      versiculo:
          'A tua palavra é lâmpada para os meus pés e luz para o meu caminho.',
      referencia: 'Salmos 119:105',
      encerramento: 'Continua a ler, meditar e viver a Palavra.',
    );
  }

  static MensagemConstancia _mensagemHinarioPadrao(int marco) {
    return MensagemConstancia(
      titulo: 'Continua a louvar',
      mensagem:
          'Alcançaste $marco dias de constância no Hinário. '
          'Que o louvor continue a fazer parte da tua caminhada.',
      versiculo: 'Cantai ao Senhor um cântico novo.',
      referencia: 'Salmos 96:1',
      encerramento: 'Continua a louvar e a adorar ao Senhor.',
    );
  }

  static MensagemConstancia _mensagemLecionarioPadrao(int marco) {
    return MensagemConstancia(
      titulo: 'Continua a meditar',
      mensagem:
          'Alcançaste $marco dias de constância no Lecionário. '
          'Cada momento dedicado à Palavra pode transformar a tua caminhada.',
      versiculo:
          'A tua palavra é lâmpada para os meus pés e luz para o meu caminho.',
      referencia: 'Salmos 119:105',
      encerramento: 'Continua a meditar e a viver a Palavra.',
    );
  }
}