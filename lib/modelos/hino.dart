class Hino {
  /// Número árabe do hino (usado para ordenação e para as telas
  /// que só trabalham com números inteiros).
  ///
  /// Quando o hino tem numeração romana (ex: "I", "II"), este
  /// campo fica a 0 e o valor original é guardado em [numeroTexto].
  final int numero;

  /// Valor original do número, em texto.
  ///
  /// - Se o hino for numerado em árabe (ex: "1", "2"), este campo
  ///   fica a `null`.
  /// - Se o hino for numerado em romano (ex: "I", "II"), este campo
  ///   guarda o texto original para ser exibido.
  final String? numeroTexto;

  final String titulo;
  final String idioma;
  final String categoria;
  final List<String> estrofes;

  /// Lista de coros do hino.
  ///
  /// Regras de exibição (ver [coroParaEstrofe]):
  /// - `null` ou vazio → hino sem coro.
  /// - 1 item → o coro aparece **depois de cada estrofe**.
  /// - N itens (N > 1) → cada coro aparece depois da estrofe
  ///   de índice correspondente (ex: hino 264 com 3 coros).
  final List<String>? coros;

  Hino({
    required this.numero,
    this.numeroTexto,
    required this.titulo,
    required this.idioma,
    required this.categoria,
    required this.estrofes,
    this.coros,
  });

  // =============================================================
  // GETTER DE CONVENIÊNCIA
  // =============================================================

  /// Texto do número para exibição.
  /// Se o hino tem numeração romana, devolve o texto original.
  /// Caso contrário, devolve o número árabe em texto.
  String get numeroExibicao => numeroTexto ?? numero.toString();

  /// Indica se o hino tem coro.
  bool get temCoro => coros != null && coros!.isNotEmpty;

  /// Devolve o coro que deve ser mostrado após a estrofe [indiceEstrofe].
  ///
  /// Regras:
  /// - Sem coros → `null`.
  /// - 1 coro → devolvido após **cada** estrofe (repetição).
  /// - N coros → devolvido o coro de índice [indiceEstrofe]
  ///   (usado no hino 264, com coros diferentes).
  String? coroParaEstrofe(int indiceEstrofe) {
    if (coros == null || coros!.isEmpty) return null;

    // Caso normal: um único coro → aparece depois de cada estrofe.
    if (coros!.length == 1) {
      final coro = coros!.first;
      return coro.trim().isEmpty ? null : coro;
    }

    // Caso especial: vários coros → cada um aparece depois
    // da estrofe de índice correspondente.
    if (indiceEstrofe < coros!.length) {
      final coro = coros![indiceEstrofe];
      return coro.trim().isEmpty ? null : coro;
    }

    return null;
  }

  // =============================================================
  // FROM JSON
  // =============================================================

  factory Hino.fromJson(Map<String, dynamic> json) {
    // -----------------------------------------------------------
    // NÚMERO
    // -----------------------------------------------------------
    //
    // Aceita tanto números árabes ("1", "2", "10")
    // como números romanos ("I", "II", "XVII").
    //
    // - Se for árabe → guarda em `numero` (int).
    // - Se for romano → guarda em `numeroTexto` (String).
    // - Se falhar tudo → `numero` = 0, `numeroTexto` = null.
    //

    final String numeroRaw = json['numero']?.toString().trim() ?? '';

    final int? numeroArabico = int.tryParse(numeroRaw);

    final int numero = numeroArabico ?? 0;

    final String? numeroTexto =
        numeroArabico == null && numeroRaw.isNotEmpty ? numeroRaw : null;

    // -----------------------------------------------------------
    // TÍTULO
    // -----------------------------------------------------------

    final String titulo = json['titulo_pt']?.toString().trim() ?? '';

    // -----------------------------------------------------------
    // TEXTO
    // -----------------------------------------------------------

    final String texto = json['texto_pt']?.toString() ?? '';

    // -----------------------------------------------------------
    // COROS
    // -----------------------------------------------------------
    //
    // Aceita dois formatos:
    // - `"coro": "..."` (string única) → lista com 1 item.
    // - `"coros": ["...", "..."]` (lista) → cada item é um coro.

    final List<String>? coros = _parsearCoros(json);

    // -----------------------------------------------------------
    // ESTROFES
    // -----------------------------------------------------------

    final List<String> estrofes = texto
        .split(RegExp(r'\n\s*\n'))
        .map((estrofe) => estrofe.trim())
        .where((estrofe) => estrofe.isNotEmpty)
        .toList();

    // -----------------------------------------------------------
    // IDIOMA
    // -----------------------------------------------------------

    const String idioma = 'Português';

    // -----------------------------------------------------------
    // CATEGORIA
    // -----------------------------------------------------------

    final String categoria = json['categoria']?.toString().trim() ?? '';

    // -----------------------------------------------------------
    // RETORNO
    // -----------------------------------------------------------

    return Hino(
      numero: numero,
      numeroTexto: numeroTexto,
      titulo: titulo,
      idioma: idioma,
      categoria: categoria,
      estrofes: estrofes,
      coros: coros,
    );
  }

  // =============================================================
  // PARSER DE COROS
  // =============================================================

  static List<String>? _parsearCoros(Map<String, dynamic> json) {
    // Caso 1: campo `coros` como lista (ex: hino 264)
    final dynamic corosRaw = json['coros'];
    if (corosRaw is List) {
      final lista = corosRaw
          .map((e) => e?.toString().trim() ?? '')
          .where((e) => e.isNotEmpty && e != 'null')
          .toList();
      return lista.isEmpty ? null : lista;
    }

    // Caso 2: campo `coro` como string (compatibilidade com o resto)
    final String? coroBruto = json['coro']?.toString().trim();
    if (coroBruto == null || coroBruto.isEmpty || coroBruto == 'null') {
      return null;
    }

    return [coroBruto];
  }
}