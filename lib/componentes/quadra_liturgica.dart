/// Identifica a quadra litúrgica de uma data (calendário 2026).
class QuadraLiturgica {
  final String nome;
  final int corArgb;

  const QuadraLiturgica(this.nome, this.corArgb);

  static QuadraLiturgica paraData(DateTime data) {
    final mes = data.month;
    final dia = data.day;

    // Advento: 4 Domingos antes do Natal (aprox. 27 Nov a 24 Dez)
    if ((mes == 11 && dia >= 27) || (mes == 12 && dia <= 24)) {
      return const QuadraLiturgica('Advento', 0xFF6A1B9A); // roxo
    }
    // Natal: 25 Dez a 5 Jan
    if ((mes == 12 && dia >= 25) || (mes == 1 && dia <= 5)) {
      return const QuadraLiturgica('Natal', 0xFFF9A825); // amarelo-ouro
    }
    // Epifania: 6 Jan a 12 Jan
    if (mes == 1 && dia >= 6 && dia <= 12) {
      return const QuadraLiturgica('Epifania', 0xFFF9A825);
    }
    // Quaresma: 18 Fev (Quarta de Cinzas) a 28 Mar 2026
    if ((mes == 2 && dia >= 18) || (mes == 3 && dia <= 28)) {
      return const QuadraLiturgica('Quaresma', 0xFF6A1B9A); // roxo
    }
    // Semana Santa: 29 Mar a 4 Abr 2026
    if (mes == 3 && dia >= 29) {
      return const QuadraLiturgica('Semana Santa', 0xFF6A1B9A);
    }
    if (mes == 4 && dia <= 4) {
      return const QuadraLiturgica('Semana Santa', 0xFF6A1B9A);
    }
    // Páscoa e Tempo Pascal: 5 Abr a 23 Mai 2026
    if (mes == 4 && dia >= 5) {
      return const QuadraLiturgica('Tempo Pascal', 0xFFF9A825);
    }
    if (mes == 5 && dia <= 23) {
      return const QuadraLiturgica('Tempo Pascal', 0xFFF9A825);
    }
    // Pentecostes: 24 Mai 2026
    if (mes == 5 && dia == 24) {
      return const QuadraLiturgica('Pentecostes', 0xFFD32F2F); // vermelho
    }
    // Resto: Tempo Comum
    return const QuadraLiturgica('Tempo Comum', 0xFF388E3C); // verde
  }
}