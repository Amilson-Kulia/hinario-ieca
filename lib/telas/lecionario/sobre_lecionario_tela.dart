import 'package:flutter/material.dart';

import '../../app/tema.dart';
import '../../componentes/cabecalho_ieca.dart';

class SobreLecionarioTela extends StatelessWidget {
  const SobreLecionarioTela({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TemaHinario.corSuperficie,
      appBar: const CabecalhoIeca(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: const [
          _Titulo(
            icone: Icons.menu_book_rounded,
            texto: 'Sobre o Lecionário',
          ),
          SizedBox(height: 12),
          _Paragrafo(
            'As denominações cristãs que têm as suas raízes na Reforma '
            'Cristã — como a Igreja Presbiteriana, Anglicana, '
            'Congregacional, Metodista e Luterana — têm sido chamadas '
            'de "Igrejas históricas". Nestas denominações são publicadas '
            'periodicamente reflexões bíblicas diárias ao longo do ano.',
          ),
          _Paragrafo(
            'Genericamente, estas publicações são designadas por '
            '"Lecionário", palavra que vem do Latim "lectio", '
            '"lectionis", e refere-se às lições bíblicas diárias para os '
            'membros meditarem nas suas famílias e nos Cultos Públicos. '
            'Por isso também recebe o nome de "Lecionário Litúrgico", '
            'porque as leituras indicadas são para uso no culto doméstico '
            'e culto público cristão.',
          ),

          SizedBox(height: 24),
          _Subtitulo(texto: 'Estrutura'),
          _Paragrafo(
            'A estrutura do Lecionário é sistemática: cada mês tem um '
            'tema, que é subdividido por semanas, fazendo com que o tema '
            'de cada dia tenha ligação com o da semana — e este com o do '
            'mês — numa harmonia espiritual para a edificação do membro.',
          ),
          _Paragrafo(
            'Aos Domingos são sugeridas passagens do Antigo Testamento '
            'e do Novo Testamento. Conforme o Didaquê indica, nos '
            'primeiros séculos do Cristianismo lia-se o Livro de Actos '
            'entre a Páscoa e o Pentecostes.',
          ),

          SizedBox(height: 24),
          _Subtitulo(texto: 'Vantagens do uso'),
          _Item(
            numero: '1',
            texto:
                'As várias congregações lêem no mesmo Domingo as mesmas '
                'lições das Escrituras Sagradas. É um sinal da proclamação '
                'da mensagem do Senhor e de que fomos chamados a ser um '
                'só povo, seguindo um só Senhor.',
          ),
          _Item(
            numero: '2',
            texto:
                'Ainda que cada pregador faça mensagens diferentes com os '
                'mesmos textos bíblicos, é impossível que no conjunto não '
                'soe um pensamento comum — um testemunho forte do '
                'discipulado cristão.',
          ),
          _Item(
            numero: '3',
            texto:
                'O Lecionário combate o individualismo do pregador, '
                'impedindo que ele escolha um texto que julga compreender '
                'muito bem apenas como pretexto para as suas ideias.',
          ),
          _Item(
            numero: '4',
            texto:
                'Os pregadores têm a oportunidade de estudar em conjunto '
                'os textos de cada Domingo, encontrando materiais '
                'auxiliares que os ajudam a aprofundar as lições.',
          ),
          _Item(
            numero: '5',
            texto:
                'Os textos indicados para o Domingo são uma conclusão dos '
                'que as famílias e as comunidades estudaram ao longo da '
                'semana. Desviar-se deles priva os membros que seguem o '
                'Lecionário de completarem o seu estudo semanal.',
          ),

          SizedBox(height: 24),
          _Subtitulo(texto: 'Calendário Litúrgico'),
          _Paragrafo(
            'O Ano Litúrgico Cristão começa liturgicamente 4 Domingos '
            'antes do Natal, período designado por Tempo de Advento — '
            'não coincidindo com o ano civil que começa a 1 de Janeiro.',
          ),
          _Paragrafo(
            'Ao longo dos séculos, convencionou-se uma estrutura que se '
            'organiza em sete grandes quadras: Advento, Natal, Epifania, '
            'Primeiro Tempo Comum, Quaresma, Páscoa e um Segundo e '
            'maior Tempo Comum.',
          ),

          SizedBox(height: 12),
          _QuadraLiturgica(
            titulo: 'Advento',
            descricao:
                'Inicia-se quatro Domingos antes do Natal e termina a 24 '
                'de Dezembro. Celebra a expectativa da vinda do Messias. '
                'Cor: roxo, lilás e rosa.',
          ),
          _QuadraLiturgica(
            titulo: 'Natal',
            descricao:
                '25 de Dezembro. Celebra-se "o Verbo que se fez carne e '
                'habitou entre nós" (S. João 1:14). Cor: branca e/ou amarela.',
          ),
          _QuadraLiturgica(
            titulo: 'Epifania',
            descricao:
                '6 de Janeiro. Celebra a manifestação de Cristo ao mundo, '
                'simbolizada pela visita dos reis magos. Cor: branca e amarela.',
          ),
          _QuadraLiturgica(
            titulo: 'Primeiro Tempo Comum',
            descricao:
                'Da segunda-feira após o Baptismo do Senhor até à véspera '
                'da Quarta-feira de Cinzas. Cor: verde.',
          ),
          _QuadraLiturgica(
            titulo: 'Quaresma',
            descricao:
                'Da Quarta-feira de Cinzas até à Quinta-feira Santa. '
                'Enfatiza o arrependimento, a confissão e a conversão. '
                'Cor: roxo ou lilás.',
          ),
          _QuadraLiturgica(
            titulo: 'Páscoa',
            descricao:
                'Festa da ressurreição e da libertação. Um novo Êxodo '
                'ocorre: a humanidade passa do cativeiro da morte para a '
                'vida. Cor: branca e amarelo-ouro.',
          ),
          _QuadraLiturgica(
            titulo: 'Pentecostes',
            descricao:
                'Comemora-se 50 dias depois da Páscoa. Celebra a chegada '
                'do Espírito Santo. Cor: vermelha.',
          ),
          _QuadraLiturgica(
            titulo: 'Segundo Tempo Comum',
            descricao:
                'Começa na segunda-feira após o Pentecostes e dura até à '
                'véspera do Primeiro Domingo do Advento. Cor: verde.',
          ),

          SizedBox(height: 24),
          _Subtitulo(texto: 'Objectivos do Culto'),
          _Paragrafo(
            'A hora de culto é um período qualitativo de bênçãos e '
            'momento especial do reencontro do homem com Deus. O '
            'adorador deve carregar consigo cinco objectivos:',
          ),
          _Item(
            numero: '1',
            texto: 'Encontrar-se pessoalmente com Deus para ser vivificado.',
          ),
          _Item(
            numero: '2',
            texto:
                'Reconhecer, confessar, arrepender-se e deixar todos os '
                'pecados (Provérbios 28:13).',
          ),
          _Item(
            numero: '3',
            texto:
                'Agradecer a Deus por todos os benefícios recebidos '
                '(Salmo 116:12-14, 17-18).',
          ),
          _Item(
            numero: '4',
            texto: 'Ouvir a Palavra de Salvação.',
          ),
          _Item(
            numero: '5',
            texto:
                'Pedir a protecção e a iluminação do Espírito Santo.',
          ),
        ],
      ),
    );
  }
}

// =================================================================
// COMPONENTES INTERNOS
// =================================================================

class _Titulo extends StatelessWidget {
  final IconData icone;
  final String texto;

  const _Titulo({required this.icone, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: TemaHinario.corPrimaria.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Icon(icone, size: 20, color: TemaHinario.corPrimaria),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            texto,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: TemaHinario.corTexto,
            ),
          ),
        ),
      ],
    );
  }
}

class _Subtitulo extends StatelessWidget {
  final String texto;

  const _Subtitulo({required this.texto});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        texto,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w800,
          color: TemaHinario.corPrimaria,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _Paragrafo extends StatelessWidget {
  final String texto;

  const _Paragrafo(this.texto);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        texto,
        textAlign: TextAlign.justify,
        style: const TextStyle(
          fontSize: 14,
          height: 1.6,
          color: TemaHinario.corTexto,
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  final String numero;
  final String texto;

  const _Item({required this.numero, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: TemaHinario.corPrimaria.withOpacity(0.12),
              borderRadius: BorderRadius.circular(7),
            ),
            alignment: Alignment.center,
            child: Text(
              numero,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: TemaHinario.corPrimaria,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              texto,
              style: const TextStyle(
                fontSize: 14,
                height: 1.55,
                color: TemaHinario.corTexto,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuadraLiturgica extends StatelessWidget {
  final String titulo;
  final String descricao;

  const _QuadraLiturgica({
    required this.titulo,
    required this.descricao,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TemaHinario.corSuperficieAlta,
        borderRadius: BorderRadius.circular(14),
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
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: TemaHinario.corTexto,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            descricao,
            style: const TextStyle(
              fontSize: 13,
              height: 1.5,
              color: TemaHinario.corTextoSecundario,
            ),
          ),
        ],
      ),
    );
  }
}