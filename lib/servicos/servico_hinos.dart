import '../modelos/hino.dart';
import 'hinos_servico.dart';

class ServicoHinos {
  List<Hino>? _hinos;

  Future<List<Hino>> obterTodos() async {
    if (_hinos != null) {
      return _hinos!;
    }

    _hinos = await HinosServico.carregarHinos();

    return _hinos!;
  }

  Future<Hino?> obterPorNumero(int numero) async {
    final lista = await obterTodos();

    try {
      return lista.firstWhere(
        (hino) => hino.numero == numero,
      );
    } catch (_) {
      return null;
    }
  }

  // =========================================================
  // HINO DO DIA
  // =========================================================
  //
  // Mantém o comportamento original:
  //
  // - No mesmo dia → sempre o mesmo hino
  // - Ao sair e voltar à Home → mesmo hino
  // - Ao fechar e abrir o aplicativo → mesmo hino
  // - No dia seguinte → outro hino
  //
  // Tudo funciona 100% offline.
  // =========================================================

  Future<Hino?> obterHinoDoDia() async {
    return obterHinoParaData(DateTime.now());
  }

  // =========================================================
  // HINO PARA UMA DATA ESPECÍFICA
  // =========================================================
  //
  // Este método permite descobrir qual será o Hino do Dia
  // de qualquer data.
  //
  // Será utilizado pelo sistema de notificações para
  // preparar antecipadamente os próximos dias.
  //
  // Exemplo:
  //
  // obterHinoParaData(DateTime(2026, 9, 8))
  //
  // retorna o hino correspondente ao dia 8 de Setembro.
  //
  // A lógica é exatamente a mesma utilizada anteriormente
  // pelo Hino do Dia.
  // =========================================================

  Future<Hino?> obterHinoParaData(DateTime data) async {
    final lista = await obterTodos();

    if (lista.isEmpty) {
      return null;
    }

    // ---------------------------------------------------------
    // DATA SEM HORÁRIO
    // ---------------------------------------------------------
    //
    // Consideramos somente ano, mês e dia.
    //

    final dataSelecionada = DateTime(
      data.year,
      data.month,
      data.day,
    );

    // ---------------------------------------------------------
    // PRIMEIRO DIA DO ANO
    // ---------------------------------------------------------

    final inicioDoAno = DateTime(
      data.year,
      1,
      1,
    );

    // ---------------------------------------------------------
    // DIA DO ANO
    // ---------------------------------------------------------
    //
    // 1 de Janeiro = 0
    // 2 de Janeiro = 1
    // etc.
    //

    final diaDoAno =
        dataSelecionada.difference(inicioDoAno).inDays;

    // ---------------------------------------------------------
    // DISTRIBUIÇÃO DOS DIAS PELOS HINOS
    // ---------------------------------------------------------

    final indice =
        diaDoAno % lista.length;

    return lista[indice];
  }
}