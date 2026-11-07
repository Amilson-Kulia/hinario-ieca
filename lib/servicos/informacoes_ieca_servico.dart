import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../modelos/historia_ieca.dart';
import '../modelos/missao_ieca.dart';

class InformacoesIecaServico {
InformacoesIecaServico._();

static final InformacoesIecaServico instancia =
InformacoesIecaServico._();

static const String _caminhoHistoria =
'assets/dados/historia_ieca.json';

static const String _caminhoMissoes =
'assets/dados/missoes_ieca.json';

// =============================================================
// CONFIGURAÇÃO DA ROTAÇÃO
// =============================================================

/// Cada curiosidade permanece activa durante 14 dias.
static const int duracaoCuriosidadeEmDias = 14;

/// Data em que a rotação foi iniciada nesta instalação.
///
/// Esta data NÃO é fixa para todos os utilizadores.
///
/// É criada na primeira inicialização do serviço e guardada
/// localmente através do SharedPreferences.
static const String _chaveInicioRotacao =
'informacoes_ieca_inicio_rotacao';

/// Ordem aleatória das missões no ciclo actual.
static const String _chaveOrdemMissoes =
'informacoes_ieca_ordem_missoes';

/// Número do ciclo correspondente à ordem guardada.
static const String _chaveCicloMissoes =
'informacoes_ieca_ciclo_missoes';

HistoriaIeca? _historia;

List<MissaoIeca>? _missoes;

// =============================================================
// HISTÓRIA DA IECA
// =============================================================

Future<HistoriaIeca> carregarHistoria() async {
if (_historia != null) {
return _historia!;
}

final String jsonString = await rootBundle.loadString(
  _caminhoHistoria,
);

final dynamic dados = jsonDecode(jsonString);

// -----------------------------------------------------------
// FORMATO ACTUAL
// -----------------------------------------------------------
//
// historia_ieca.json contém actualmente um único objecto:
//
// {
//   "id": "historia_ieca",
//   "titulo": "...",
//   "resumo": "...",
//   "texto": "..."
// }
//
// -----------------------------------------------------------

if (dados is Map) {
  _historia = HistoriaIeca.fromJson(
    Map<String, dynamic>.from(dados),
  );

  return _historia!;
}

// -----------------------------------------------------------
// COMPATIBILIDADE COM O FORMATO ANTERIOR
// -----------------------------------------------------------
//
// Caso o ficheiro seja uma lista de objectos, continuamos
// a aceitar o primeiro elemento.
//
// -----------------------------------------------------------

if (dados is List && dados.isNotEmpty) {
  final dynamic primeiroItem = dados.first;

  if (primeiroItem is Map) {
    _historia = HistoriaIeca.fromJson(
      Map<String, dynamic>.from(
        primeiroItem,
      ),
    );

    return _historia!;
  }
}

throw const FormatException(
  'O ficheiro da história da IECA não contém '
  'um objecto ou uma lista de dados válidos.',
);

}

// =============================================================
// MISSÕES / CURIOSIDADES
// =============================================================

Future<List<MissaoIeca>> carregarMissoes() async {
if (_missoes != null) {
return _missoes!;
}

final String jsonString = await rootBundle.loadString(
  _caminhoMissoes,
);

final dynamic dados = jsonDecode(jsonString);

if (dados is! List) {
  throw const FormatException(
    'O ficheiro das missões da IECA não contém '
    'uma lista válida.',
  );
}

_missoes = dados
    .map(
      (item) => MissaoIeca.fromJson(
        Map<String, dynamic>.from(
          item as Map,
        ),
      ),
    )
    .toList(growable: false);

if (_missoes!.isEmpty) {
  throw const FormatException(
    'O ficheiro das missões da IECA está vazio.',
  );
}

return _missoes!;

}

// =============================================================
// INÍCIO DA ROTAÇÃO
// =============================================================

/// Obtém a data em que a rotação das curiosidades começou.
///
/// Na primeira utilização, esta data é criada automaticamente
/// e guardada localmente.
///
/// A partir daí, todos os períodos de 14 dias são calculados
/// com base nessa data.
Future<DateTime> obterInicioRotacao() async {
final SharedPreferences preferencias =
await SharedPreferences.getInstance();

final String? valor =
    preferencias.getString(
  _chaveInicioRotacao,
);

if (valor != null && valor.isNotEmpty) {
  final DateTime? dataGuardada =
      DateTime.tryParse(valor);

  if (dataGuardada != null) {
    return dataGuardada;
  }
}

final DateTime agora = DateTime.now();

final DateTime inicio =
    DateTime(
  agora.year,
  agora.month,
  agora.day,
  agora.hour,
  agora.minute,
  agora.second,
);

await preferencias.setString(
  _chaveInicioRotacao,
  inicio.toIso8601String(),
);

return inicio;

}

// =============================================================
// CURIOSIDADE ACTUAL
// =============================================================

/// Obtém a missão correspondente ao período actual.
///
/// As missões são organizadas aleatoriamente num ciclo.
///
/// Cada missão aparece uma única vez dentro desse ciclo.
/// Quando todas as missões tiverem sido utilizadas, um novo
/// ciclo é iniciado com uma nova ordem aleatória.
Future<MissaoIeca> obterMissaoAtual({
DateTime? agora,
}) async {
final List<MissaoIeca> missoes =
await carregarMissoes();

final int periodo =
    await obterPeriodoAtual(
  agora: agora,
);

final int tamanhoCiclo =
    missoes.length;

if (tamanhoCiclo == 0) {
  throw const FormatException(
    'Não existem missões disponíveis para a rotação.',
  );
}

// -----------------------------------------------------------
// CICLO E POSIÇÃO ACTUAIS
// -----------------------------------------------------------
//
// Exemplo com 10 missões:
//
// período 0 → ciclo 0, posição 0
// período 1 → ciclo 0, posição 1
// ...
// período 9 → ciclo 0, posição 9
// período 10 → ciclo 1, posição 0
//
// -----------------------------------------------------------

final int ciclo =
    periodo ~/ tamanhoCiclo;

final int posicao =
    periodo % tamanhoCiclo;

final SharedPreferences preferencias =
    await SharedPreferences.getInstance();

// -----------------------------------------------------------
// OBTÉM A ORDEM GUARDADA
// -----------------------------------------------------------

List<String>? ordemGuardada =
    preferencias.getStringList(
  _chaveOrdemMissoes,
);

final int? cicloGuardado =
    preferencias.getInt(
  _chaveCicloMissoes,
);

// -----------------------------------------------------------
// VERIFICA SE É NECESSÁRIO CRIAR UMA NOVA ORDEM
// -----------------------------------------------------------

final bool ordemValida =
    ordemGuardada != null &&
    ordemGuardada.length == tamanhoCiclo &&
    cicloGuardado == ciclo &&
    _ordemContemTodasAsMissoes(
      ordemGuardada,
      missoes,
    );

if (!ordemValida) {
  ordemGuardada =
      _criarNovaOrdemAleatoria(
    missoes,
  );

  await preferencias.setStringList(
    _chaveOrdemMissoes,
    ordemGuardada,
  );

  await preferencias.setInt(
    _chaveCicloMissoes,
    ciclo,
  );
}

// -----------------------------------------------------------
// OBTÉM O ID DA MISSÃO DA POSIÇÃO ACTUAL
// -----------------------------------------------------------

final String idMissao =
    ordemGuardada[posicao];

// -----------------------------------------------------------
// PROCURA A MISSÃO CORRESPONDENTE
// -----------------------------------------------------------

for (final MissaoIeca missao in missoes) {
  if (missao.id == idMissao) {
    return missao;
  }
}

// -----------------------------------------------------------
// PROTECÇÃO CONTRA INCONSISTÊNCIA
// -----------------------------------------------------------
//
// Em condições normais isto nunca deve acontecer, porque
// _ordemContemTodasAsMissoes() valida os IDs.
//
// Se acontecer, criamos uma nova ordem e tentamos novamente.
// -----------------------------------------------------------

final List<String> novaOrdem =
    _criarNovaOrdemAleatoria(
  missoes,
);

await preferencias.setStringList(
  _chaveOrdemMissoes,
  novaOrdem,
);

await preferencias.setInt(
  _chaveCicloMissoes,
  ciclo,
);

final String novoId =
    novaOrdem[posicao];

for (final MissaoIeca missao in missoes) {
  if (missao.id == novoId) {
    return missao;
  }
}

throw const FormatException(
  'Não foi possível determinar a missão actual.',
);

}

// =============================================================
// PERÍODO ACTUAL
// =============================================================

/// Retorna o número do período actual da rotação.
///
/// Cada período possui 14 dias.
///
/// Exemplo:
///
/// Instalação:
/// 14/09/2026 às 19:00
///
/// Período 0:
/// 14/09/2026 às 19:00
/// até
/// 28/09/2026 às 18:59...
///
/// Período 1:
/// a partir de 28/09/2026 às 19:00
///
/// Período 2:
/// +14 dias
///
/// E assim sucessivamente.
Future<int> obterPeriodoAtual({
DateTime? agora,
}) async {
final DateTime inicio =
await obterInicioRotacao();


final DateTime momentoAtual =
    agora ?? DateTime.now();

final Duration diferenca =
    momentoAtual.difference(
  inicio,
);

if (diferenca.isNegative) {
  return 0;
}

return diferenca.inDays ~/
    duracaoCuriosidadeEmDias;


}

// =============================================================
// INÍCIO DO PERÍODO ACTUAL
// =============================================================

/// Retorna exactamente quando começou o período actual.
///
/// Diferentemente da versão anterior, este valor não depende
/// de uma data fixa global.
Future<DateTime> obterInicioPeriodo({
DateTime? agora,
}) async {
final DateTime inicioRotacao =
await obterInicioRotacao();

final int periodo =
    await obterPeriodoAtual(
  agora: agora,
);

return inicioRotacao.add(
  Duration(
    days:
        periodo *
            duracaoCuriosidadeEmDias,
  ),
);

}

// =============================================================
// INÍCIO DE UM PERÍODO ESPECÍFICO
// =============================================================

/// Retorna a data de início de um determinado período.
///
/// Exemplo:
///
/// período 0 → início da rotação
/// período 1 → +14 dias
/// período 2 → +28 dias
/// período 3 → +42 dias
Future<DateTime> obterInicioPeriodoPorNumero(
int periodo,
) async {
final DateTime inicioRotacao =
await obterInicioRotacao();

return inicioRotacao.add(
  Duration(
    days:
        periodo *
            duracaoCuriosidadeEmDias,
  ),
);

}

// =============================================================
// MISSÃO POR ID
// =============================================================

Future<MissaoIeca?> obterMissaoPorId(
String id,
) async {
final List<MissaoIeca> missoes =
await carregarMissoes();

for (final MissaoIeca missao in missoes) {
  if (missao.id == id) {
    return missao;
  }
}

return null;

}

// =============================================================
// CRIAR NOVA ORDEM ALEATÓRIA
// =============================================================

/// Cria uma nova ordem aleatória contendo todas as missões
/// exactamente uma vez.
///
/// É utilizado quando começa um novo ciclo.
List<String> _criarNovaOrdemAleatoria(
List<MissaoIeca> missoes,
) 

{
final List<String> ordem =
missoes
.map(
(missao) => missao.id,
)
.toList();

ordem.shuffle(Random());

return ordem;

}

// =============================================================
// VALIDAR ORDEM GUARDADA
// =============================================================

/// Verifica se a ordem guardada corresponde exactamente
/// às missões actualmente existentes no JSON.
///
/// Isto permite detectar alterações no ficheiro de missões,
/// como a adição ou remoção de uma missão.
bool _ordemContemTodasAsMissoes(
List<String> ordem,
List<MissaoIeca> missoes,
) {
if (ordem.length != missoes.length) {
return false;
}

final Set<String> idsOrdem =
    ordem.toSet();

final Set<String> idsMissoes =
    missoes
        .map(
          (missao) => missao.id,
        )
        .toSet();

if (idsOrdem.length != ordem.length) {
  return false;
}

return idsOrdem.length ==
        idsMissoes.length &&
    idsOrdem.containsAll(
      idsMissoes,
    ) &&
    idsMissoes.containsAll(
      idsOrdem,
    );

}

// =============================================================
// LIMPAR CACHE
// =============================================================

void limparCache() {
_historia = null;
_missoes = null;
}
}
