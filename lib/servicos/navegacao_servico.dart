import 'package:flutter/material.dart';

class NavegacaoServico extends NavigatorObserver {
  NavegacaoServico._();

  static final NavegacaoServico instancia = NavegacaoServico._();

  final List<RouteSettings> _historico = [];

  int _indiceAtual = -1;

  bool _processandoNavegacao = false;

  /// Histórico disponível para consulta interna.
  List<RouteSettings> get historico => List.unmodifiable(_historico);

  /// Indica se existe uma tela anterior.
  bool get podeVoltar => _indiceAtual > 0;

  /// Indica se existe uma tela para avançar.
  bool get podeAvancar =>
      _indiceAtual >= 0 && _indiceAtual < _historico.length - 1;

  RouteSettings? get rotaAnterior {
    if (!podeVoltar) {
      return null;
    }

    return _historico[_indiceAtual - 1];
  }

  RouteSettings? get proximaRota {
    if (!podeAvancar) {
      return null;
    }

    return _historico[_indiceAtual + 1];
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);

    final settings = route.settings;

    if (_processandoNavegacao) {
      return;
    }

    if (_ehSplash(settings)) {
      return;
    }

    // Se estávamos no meio do histórico e uma nova rota foi aberta,
    // descartamos o caminho que estava à frente.
    if (_indiceAtual < _historico.length - 1) {
      _historico.removeRange(
        _indiceAtual + 1,
        _historico.length,
      );
    }

    _historico.add(settings);
    _indiceAtual = _historico.length - 1;
  }

  @override
  void didPop(
    Route<dynamic> route,
    Route<dynamic>? previousRoute,
  ) {
    super.didPop(route, previousRoute);

    if (_processandoNavegacao) {
      return;
    }

    if (_indiceAtual > 0) {
      _indiceAtual--;
    }
  }

  @override
  void didRemove(
    Route<dynamic> route,
    Route<dynamic>? previousRoute,
  ) {
    super.didRemove(route, previousRoute);

    final settings = route.settings;

    final indice = _historico.indexWhere(
      (item) =>
          item.name == settings.name &&
          item.arguments == settings.arguments,
    );

    if (indice != -1) {
      _historico.removeAt(indice);

      if (_historico.isEmpty) {
        _indiceAtual = -1;
      } else if (_indiceAtual >= _historico.length) {
        _indiceAtual = _historico.length - 1;
      }
    }
  }

  @override
  void didReplace({
    Route<dynamic>? newRoute,
    Route<dynamic>? oldRoute,
  }) {
    super.didReplace(
      newRoute: newRoute,
      oldRoute: oldRoute,
    );

    if (newRoute == null) {
      return;
    }

    final novoSettings = newRoute.settings;

    if (_historico.isEmpty) {
      if (!_ehSplash(novoSettings)) {
        _historico.add(novoSettings);
        _indiceAtual = 0;
      }

      return;
    }

    if (_indiceAtual >= 0 &&
        _indiceAtual < _historico.length) {
      _historico[_indiceAtual] = novoSettings;
    }
  }

  Future<void> voltar(BuildContext context) async {
    if (!podeVoltar) {
      return;
    }

    _processandoNavegacao = true;

    try {
      await Navigator.of(context).maybePop();
    } finally {
      _processandoNavegacao = false;
    }
  }

  Future<void> avancar(BuildContext context) async {
    if (!podeAvancar) {
      return;
    }

    final proxima = _historico[_indiceAtual + 1];

    _processandoNavegacao = true;

    try {
      final route = RotasHelper.gerarRota(proxima);

      await Navigator.of(context).push(route);

      if (_indiceAtual < _historico.length - 1) {
        _indiceAtual++;
      }
    } finally {
      _processandoNavegacao = false;
    }
  }

  void limpar() {
    _historico.clear();
    _indiceAtual = -1;
  }

  bool _ehSplash(RouteSettings settings) {
    return settings.name == '/' ||
        settings.name == null;
  }
}

/// Pequeno adaptador para permitir que o serviço de navegação
/// recrie uma rota a partir dos mesmos RouteSettings.
class RotasHelper {
  static Route<dynamic> gerarRota(RouteSettings settings) {
    return _RotaGestual(
      settings: settings,
      builder: RotasBuilder.gerar(settings),
    );
  }
}

/// Será configurado pelo arquivo rotas.dart.
class RotasBuilder {
  static Widget Function(BuildContext context)? _gerador;

  static void configurar(
    Widget Function(BuildContext context) gerador,
  ) {
    _gerador = gerador;
  }

  static Widget Function(BuildContext context) gerar(
    RouteSettings settings,
  ) {
    final gerador = _gerador;

    if (gerador == null) {
      return (_) => const SizedBox.shrink();
    }

    return gerador;
  }
}

/// Rota responsável por detectar o gesto horizontal.
class _RotaGestual extends MaterialPageRoute<dynamic> {
  _RotaGestual({
    required RouteSettings settings,
    required WidgetBuilder builder,
  }) : super(
          settings: settings,
          builder: builder,
        );

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return _DetectorGestosNavegacao(
      child: super.buildPage(
        context,
        animation,
        secondaryAnimation,
      ),
    );
  }
}

class _DetectorGestosNavegacao extends StatefulWidget {
  const _DetectorGestosNavegacao({
    required this.child,
  });

  final Widget child;

  @override
  State<_DetectorGestosNavegacao> createState() =>
      _DetectorGestosNavegacaoState();
}

class _DetectorGestosNavegacaoState
    extends State<_DetectorGestosNavegacao> {
  double _inicioX = 0;
  double _inicioY = 0;

  void _inicio(DragStartDetails details) {
    _inicioX = details.globalPosition.dx;
    _inicioY = details.globalPosition.dy;
  }

  void _fim(DragEndDetails details) {
    final velocidade = details.primaryVelocity;

    if (velocidade == null) {
      return;
    }

    final deslocamentoHorizontal = velocidade.abs();

    // Só consideramos o gesto quando existe velocidade horizontal
    // significativa. Isso evita interferir no scroll vertical.
    if (deslocamentoHorizontal < 350) {
      return;
    }

    final size = MediaQuery.of(context).size;

    final posicaoFinal = _inicioX;

    // Ignora pequenos movimentos.
    if (posicaoFinal < 0 || posicaoFinal > size.width) {
      return;
    }

    if (velocidade > 0) {
      // Esquerda -> direita = voltar.
      NavegacaoServico.instancia.voltar(context);
    } else {
      // Direita -> esquerda = avançar.
      NavegacaoServico.instancia.avancar(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragStart: _inicio,
      onHorizontalDragEnd: _fim,
      child: widget.child,
    );
  }
}