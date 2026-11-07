import 'dart:async';

import 'dart:typed_data';

import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';

import 'package:flutter/services.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:flutter_timezone/flutter_timezone.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:timezone/data/latest.dart' as tz;

import 'package:timezone/timezone.dart' as tz;

import '../app/app.dart';

import '../modelos/missao_ieca.dart';

import '../telas/informacoes_ieca/leitura_missao_ieca_tela.dart';

import 'informacoes_ieca_servico.dart';

/// ===============================================================

/// SERVIÇO DE NOTIFICAÇÕES DO HINÁRIO IECA

/// ===============================================================

///

/// Notificação ativa:

///   • Sabias que? → conteúdos da IECA

///

/// As notificações funcionam localmente, sem Firebase,

/// sem backend e sem necessidade de Internet.

///

/// Removidas:

///   • Bom Dia

///   • Boa Noite

///   • Palavra do Dia

///   • Hino do Dia

/// ===============================================================

class NotificacoesServico {

  static final NotificacoesServico instancia =

      NotificacoesServico._interno();

  NotificacoesServico._interno();

  final FlutterLocalNotificationsPlugin _notificacoes =

      FlutterLocalNotificationsPlugin();

  Uint8List? _logoIecaBytes;

  bool _inicializado = false;

  Future<void>? _inicializacaoEmAndamento;

  // =============================================================

  // IDS

  // =============================================================

  static const int _idTesteSabiasQue = 9005;

  static const int _baseIdSabiasQue = 500000;

  // =============================================================

  // CHAVES DE PREFERÊNCIAS

  // =============================================================

  static const String _chavePermissoesSolicitadas =

      'notificacoes_permissoes_solicitadas';

  static const String _chaveSabiasQuePeriodoNotificado =

      'sabias_que_periodo_notificado';

  static const String _chaveSabiasQuePeriodoAgendadoAte =

      'sabias_que_periodo_agendado_ate';

  static const String _chaveUltimaVerificacao =

      'notificacoes_ultima_verificacao_ms';

  // =============================================================

  // CONFIGURAÇÃO

  // =============================================================

  /// Quantos períodos futuros de "Sabias que?" ficam preparados.

  static const int ciclosSabiasQueAgendados = 4;

  /// Primeiro "Sabias que?" após a instalação.

  static const int atrasoPrimeiroSabiasQueEmMinutos = 5;

  /// Intervalo mínimo entre verificações completas.

  /// Evita jank quando a app volta ao foreground muitas vezes.

  static const Duration intervaloMinimoVerificacao =

      Duration(hours: 6);

  // =============================================================

  // CANAIS

  // =============================================================

  static const String canalSabiasQue = 'ieca_sabias_que';

  static const String nomeCanalSabiasQue = 'Sabias que?';

  static const String descricaoCanalSabiasQue =

      'Curiosidades sobre a história, missão e presença da IECA.';

  // Ícone usado pelo Android.

  static const String _iconeNotificacaoAndroid =

      '@mipmap/ic_launcher';

  String _mensagemSabiasQue({

    required MissaoIeca missao,

  }) {

    return '''

${missao.curiosidade}

Descobre mais no aplicativo.

''';

  }

  // =============================================================

  // INICIALIZAÇÃO

  // =============================================================

  Future<void> inicializar() async {

    if (_inicializado) return;

    if (_inicializacaoEmAndamento != null) {

      await _inicializacaoEmAndamento;

      return;

    }

    final Future<void> inicializacao =

        _inicializarInternamente();

    _inicializacaoEmAndamento = inicializacao;

    try {

      await inicializacao;

    } finally {

      if (identical(

        _inicializacaoEmAndamento,

        inicializacao,

      )) {

        _inicializacaoEmAndamento = null;

      }

    }

  }

  Future<void> _inicializarInternamente() async {

    if (_inicializado) return;

    if (kIsWeb) {

      debugPrint(

        '   ⚠️ kIsWeb = true → inicializar() ignorado.',

      );

      _inicializado = true;

      return;

    }

    debugPrint(

      '   🔧 A inicializar plugin de notificações...',

    );

    // -----------------------------------------------------------

    // FUSO HORÁRIO

    // -----------------------------------------------------------

    tz.initializeTimeZones();

    try {

      final TimezoneInfo timezoneInfo =

          await FlutterTimezone.getLocalTimezone();

      tz.setLocalLocation(

        tz.getLocation(timezoneInfo.identifier),

      );

    } catch (e) {

      tz.setLocalLocation(

        tz.getLocation('UTC'),

      );

      debugPrint(

        'Não foi possível obter o fuso horário local: $e',

      );

    }

    // -----------------------------------------------------------

    // ANDROID

    // -----------------------------------------------------------

    const AndroidInitializationSettings androidSettings =

        AndroidInitializationSettings(

      _iconeNotificacaoAndroid,

    );

    // -----------------------------------------------------------

    // IOS / MACOS

    // -----------------------------------------------------------

    const DarwinInitializationSettings darwinSettings =

        DarwinInitializationSettings(

      requestAlertPermission: false,

      requestBadgePermission: false,

      requestSoundPermission: false,

    );

    const InitializationSettings settings =

        InitializationSettings(

      android: androidSettings,

      iOS: darwinSettings,

      macOS: darwinSettings,

    );

    // -----------------------------------------------------------

    // INICIALIZAR PLUGIN

    // -----------------------------------------------------------

    await _notificacoes.initialize(

      settings: settings,

      onDidReceiveNotificationResponse:

          _aoClicarNaNotificacao,

      onDidReceiveBackgroundNotificationResponse:

          notificacaoBackgroundHandler,

    );

    // Carrega o logo sem bloquear a inicialização.

    unawaited(_carregarLogoIeca());

    _inicializado = true;

    debugPrint(

      'Notificações IECA inicializadas.',

    );

  }

  // =============================================================

  // LOGO

  // =============================================================

  Future<Uint8List?> _carregarLogoIeca() async {

    if (_logoIecaBytes != null) {

      return _logoIecaBytes;

    }

    try {

      final ByteData dados =

          await rootBundle.load(

        'assets/images/logoieca.png',

      );

      _logoIecaBytes = dados.buffer.asUint8List(

        dados.offsetInBytes,

        dados.lengthInBytes,

      );

      debugPrint(

        'Logo IECA carregado para as notificações.',

      );

      return _logoIecaBytes;

    } catch (e) {

      debugPrint(

        'Não foi possível carregar o logo IECA: $e',

      );

      return null;

    }

  }

  // =============================================================

  // ESTADO REAL DAS NOTIFICAÇÕES

  // =============================================================

  AndroidFlutterLocalNotificationsPlugin? _androidPlugin() {

    return _notificacoes

        .resolvePlatformSpecificImplementation<

            AndroidFlutterLocalNotificationsPlugin>();

  }

  Future<bool> _notificacoesAndroidAtivadas() async {

    if (kIsWeb) return false;

    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =

        _androidPlugin();

    if (androidPlugin == null) return false;

    try {

      return await androidPlugin.areNotificationsEnabled() ??

          false;

    } catch (e) {

      debugPrint(

        'Erro ao consultar a permissão real do Android: $e',

      );

      return false;

    }

  }

  Future<bool> _podeAgendarAlarmeExato() async {

    if (kIsWeb) return false;

    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =

        _androidPlugin();

    if (androidPlugin == null) return false;

    try {

      final bool? pode =

          await androidPlugin.canScheduleExactNotifications();

      return pode ?? false;

    } catch (e) {

      debugPrint(

        'Erro ao consultar canScheduleExactNotifications: $e',

      );

      return false;

    }

  }

  Future<List<PendingNotificationRequest>>

      _obterNotificacoesPendentes() async {

    try {

      return await _notificacoes

          .pendingNotificationRequests();

    } catch (e) {

      debugPrint(

        'Erro ao consultar notificações pendentes: $e',

      );

      return <PendingNotificationRequest>[];

    }

  }

  Future<Set<int>> _obterIdsPendentes() async {

    final List<PendingNotificationRequest> pendentes =

        await _obterNotificacoesPendentes();

    return pendentes.map((n) => n.id).toSet();

  }

  // =============================================================

  // TOQUE NAS NOTIFICAÇÕES

  // =============================================================

  void _aoClicarNaNotificacao(

    NotificationResponse resposta,

  ) {

    final String? payload = resposta.payload;

    debugPrint(

      'Notificação seleccionada: $payload',

    );

    if (payload == null || payload.isEmpty) return;

    _processarPayload(payload);

  }

  Future<void> _processarPayload(

    String payload,

  ) async {

    final List<String> partes =

        payload.split('|');

    if (partes.isEmpty) return;

    final String tipo =

        partes.first.trim();

    switch (tipo) {

      case 'sabias_que':

        if (partes.length < 2) return;

        final String id =

            partes[1].trim();

        if (id.isEmpty) return;

        await _abrirMissaoPorId(id);

        break;

      default:

        debugPrint(

          'Payload sem ação de navegação: $payload',

        );

        break;

    }

  }

  Future<void> _abrirMissaoPorId(

    String id,

  ) async {

    final MissaoIeca? missao =

        await InformacoesIecaServico

            .instancia

            .obterMissaoPorId(id);

    if (missao == null) {

      debugPrint(

        'Missão não encontrada para o payload: $id',

      );

      return;

    }

    for (int tentativa = 0;

        tentativa < 30;

        tentativa++) {

      final NavigatorState? navigator =

          navigatorKey.currentState;

      if (navigator != null) {

        navigator.push(

          MaterialPageRoute<void>(

            builder: (_) =>

                LeituraMissaoIecaTela(

              missao: missao,

            ),

          ),

        );

        debugPrint(

          'Missão aberta através da notificação: '

          '${missao.id}',

        );

        return;

      }

      await Future<void>.delayed(

        const Duration(milliseconds: 100),

      );

    }

    debugPrint(

      'Não foi possível encontrar o NavigatorState '

      'para abrir a missão: $id',

    );

  }

  // =============================================================

  // NOTIFICAÇÃO QUE ABRIU A APLICAÇÃO

  // =============================================================

  Future<void>

      processarNotificacaoQueAbriuAplicacao() async {

    await inicializar();

    if (kIsWeb) return;

    try {

      final NotificationAppLaunchDetails?

          detalhes =

          await _notificacoes

              .getNotificationAppLaunchDetails();

      if (detalhes == null ||

          !detalhes.didNotificationLaunchApp) {

        return;

      }

      final String? payload =

          detalhes.notificationResponse?.payload;

      if (payload == null || payload.isEmpty) {

        return;

      }

      debugPrint(

        'Aplicação aberta através de notificação: '

        '$payload',

      );

      await _processarPayload(payload);

    } catch (e, stackTrace) {

      debugPrint(

        'Erro ao processar notificação que abriu '

        'a aplicação: $e',

      );

      debugPrint('$stackTrace');

    }

  }

  // =============================================================

  // PERMISSÕES

  // =============================================================

  Future<void> solicitarPermissaoAndroid() async {
    if (kIsWeb) return;

    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        _androidPlugin();

    if (androidPlugin == null) {
      debugPrint('Plugin Android de notificações não disponível.');
      return;
    }

    try {
      // Não usar areNotificationsEnabled() como condição para pedir
      // a permissão: em alguns dispositivos/versões, esse estado pode
      // não reflectir correctamente se o pedido runtime já foi feito.
      //
      // O método do plugin trata os casos em que a permissão já foi
      // concedida ou em que a versão do Android não precisa do pedido.
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      debugPrint('📢 A verificar/solicitar permissão de notificações Android...');
      final bool? concedida =
          await androidPlugin.requestNotificationsPermission();

      if (concedida != null) {
        await prefs.setBool(_chavePermissoesSolicitadas, true);
      }

      final bool ativadas =
          await androidPlugin.areNotificationsEnabled() ?? false;

      debugPrint(
        'Estado das notificações Android: '
        '${ativadas ? "ativadas" : "desativadas"}. '
        'Resultado do pedido: ${concedida == null ? "sem novo diálogo/sem resposta" : concedida ? "concedida" : "recusada"}.',
      );

      if (!ativadas) {
        debugPrint(
          'As notificações continuam desativadas. '
          'Verifica as permissões da aplicação nas definições do Android.',
        );
      }

      // A permissão para alarmes exactos é independente da permissão
      // POST_NOTIFICATIONS. Pedimos apenas quando necessário.
      final bool podeExato = await _podeAgendarAlarmeExato();

      if (!podeExato) {
        debugPrint(
          'Permissão de alarme exacto desactivada. A solicitar...',
        );
        await androidPlugin.requestExactAlarmsPermission();
      } else {
        debugPrint('Permissão de alarme exacto já está activa.');
      }
    } catch (e, stackTrace) {
      debugPrint('Erro ao solicitar permissões Android: $e');
      debugPrint('$stackTrace');
    }
  }

  Future<void> solicitarPermissaoIOS() async {

    if (kIsWeb) return;

    final IOSFlutterLocalNotificationsPlugin? iosPlugin =

        _notificacoes

            .resolvePlatformSpecificImplementation<

                IOSFlutterLocalNotificationsPlugin>();

    if (iosPlugin == null) return;

    try {

      final bool? concedida =

          await iosPlugin.requestPermissions(

        alert: true,

        badge: true,

        sound: true,

      );

      debugPrint(

        'Permissão de notificações iOS: '

        '${concedida == true ? "concedida" : "não concedida"}.',

      );

    } catch (e, stackTrace) {

      debugPrint(

        'Erro ao solicitar permissões iOS: $e',

      );

      debugPrint('$stackTrace');

    }

  }

  Future<void> solicitarPermissoes() async {

    await inicializar();

    if (kIsWeb) {

      debugPrint(

        '   ⚠️ kIsWeb = true → permissões ignoradas.',

      );

      return;

    }

    debugPrint(

      '   🔧 A solicitar permissões...',

    );

    try {

      await solicitarPermissaoAndroid();

      await solicitarPermissaoIOS();

      debugPrint(

        'Processamento das permissões concluído.',

      );

    } catch (e, stackTrace) {

      debugPrint(

        'Erro ao processar permissões de notificações: $e',

      );

      debugPrint('$stackTrace');

    }

  }

  // =============================================================

  // DETALHES DAS NOTIFICAÇÕES

  // =============================================================

  Future<NotificationDetails>

      _criarDetalhesNotificacao({

    required String corpo,

    required String canalId,

    required String nomeCanal,

    required String descricaoCanal,

  }) async {

    final Uint8List? logoBytes =

        await _carregarLogoIeca();

    ByteArrayAndroidBitmap? largeIcon;

    if (logoBytes != null) {

      largeIcon =

          ByteArrayAndroidBitmap(logoBytes);

    }

    return NotificationDetails(

      android: AndroidNotificationDetails(

        canalId,

        nomeCanal,

        channelDescription: descricaoCanal,

        importance: Importance.max,

        priority: Priority.high,

        playSound: true,

        enableVibration: true,

        icon: _iconeNotificacaoAndroid,

        largeIcon: largeIcon,

        styleInformation:

            BigTextStyleInformation(corpo),

      ),

      iOS: const DarwinNotificationDetails(

        presentAlert: true,

        presentBadge: true,

        presentSound: true,

      ),

    );

  }

  Future<void> mostrarNotificacao({

    required String titulo,

    required String corpo,

    String? payload,

    int? id,

    required String canalId,

    required String nomeCanal,

    required String descricaoCanal,

  }) async {

    await inicializar();

    if (kIsWeb) return;

    // -----------------------------------------------------------

    // NÃO abortar com base em areNotificationsEnabled().

    // Em Android 13+ pode ser um falso negativo. Tentamos mostrar;

    // se a permissão não estiver concedida, o plugin simplesmente

    // não mostra (sem crash).

    // -----------------------------------------------------------

    try {

      final NotificationDetails detalhes =

          await _criarDetalhesNotificacao(

        corpo: corpo,

        canalId: canalId,

        nomeCanal: nomeCanal,

        descricaoCanal: descricaoCanal,

      );

      await _notificacoes.show(

        id: id ?? _idTesteSabiasQue,

        title: titulo,

        body: corpo,

        notificationDetails: detalhes,

        payload: payload,

      );

      debugPrint(

        'Notificação imediata apresentada. '

        'ID: ${id ?? _idTesteSabiasQue}.',

      );

    } catch (e, stackTrace) {

      debugPrint(

        'Erro ao mostrar notificação imediata '

        'ID ${id ?? _idTesteSabiasQue}: $e',

      );

      debugPrint('$stackTrace');

    }

  }

  // =============================================================

  // AGENDAR NOTIFICAÇÃO

  // =============================================================

  Future<bool> _agendarNotificacao({

    required int id,

    required String titulo,

    required String corpo,

    required tz.TZDateTime dataHora,

    String? payload,

    required String canalId,

    required String nomeCanal,

    required String descricaoCanal,

  }) async {

    try {

      final NotificationDetails detalhes =

          await _criarDetalhesNotificacao(

        corpo: corpo,

        canalId: canalId,

        nomeCanal: nomeCanal,

        descricaoCanal: descricaoCanal,

      );

      final bool podeExato =

          await _podeAgendarAlarmeExato();

      final AndroidScheduleMode modoPreferido =

          podeExato

              ? AndroidScheduleMode.exactAllowWhileIdle

              : AndroidScheduleMode.inexactAllowWhileIdle;

      try {

        await _notificacoes.zonedSchedule(

          id: id,

          title: titulo,

          body: corpo,

          notificationDetails: detalhes,

          scheduledDate: dataHora,

          androidScheduleMode: modoPreferido,

          payload: payload,

        );

        return true;

      } catch (e) {

        if (modoPreferido ==

            AndroidScheduleMode.exactAllowWhileIdle) {

          debugPrint(

            '⚠️ exactAllowWhileIdle falhou para ID $id. '

            'A tentar inexactAllowWhileIdle. '

            'Erro original: $e',

          );

          await _notificacoes.zonedSchedule(

            id: id,

            title: titulo,

            body: corpo,

            notificationDetails: detalhes,

            scheduledDate: dataHora,

            androidScheduleMode:

                AndroidScheduleMode.inexactAllowWhileIdle,

            payload: payload,

          );

          return true;

        }

        rethrow;

      }

    } catch (e, stackTrace) {

      debugPrint(

        '❌ Erro ao agendar notificação ID $id '

        'para $dataHora: $e',

      );

      debugPrint('$stackTrace');

      return false;

    }

  }

  // =============================================================

  // IDS

  // =============================================================

  int _idParaPeriodoSabiasQue(

    int periodo,

  ) {

    return _baseIdSabiasQue + periodo;

  }

  // =============================================================

  // "SABIAS QUE?"

  // =============================================================

  Future<int?> _obterPeriodoSabiasQueAgendadoAte() async {

    final SharedPreferences prefs =

        await SharedPreferences.getInstance();

    return prefs.getInt(

      _chaveSabiasQuePeriodoAgendadoAte,

    );

  }

  Future<void> _guardarPeriodoSabiasQueAgendadoAte(

    int periodo,

  ) async {

    final SharedPreferences prefs =

        await SharedPreferences.getInstance();

    await prefs.setInt(

      _chaveSabiasQuePeriodoAgendadoAte,

      periodo,

    );

  }

  Future<int?> _obterPeriodoSabiasQueNotificado() async {

    final SharedPreferences prefs =

        await SharedPreferences.getInstance();

    return prefs.getInt(

      _chaveSabiasQuePeriodoNotificado,

    );

  }

  Future<void> configurarNotificacaoSabiasQue() async {

    await inicializar();

    if (kIsWeb) return;

    debugPrint(

      '   🔧 A configurar Sabias que?...',

    );

    try {

      // -----------------------------------------------------------

      // ⚠️ NÃO abortar se areNotificationsEnabled() for false.

      // Em Android 13+ pode ser falso negativo. Tentamos agendar

      // na mesma; se a permissão não estiver concedida, o plugin

      // falha silenciosamente e o próximo resumed tenta de novo.

      // -----------------------------------------------------------

      final bool androidAtivo =

          await _notificacoesAndroidAtivadas();

      if (!androidAtivo) {

        debugPrint(

          '   ⚠️ areNotificationsEnabled() = false. '

          'A tentar agendar mesmo assim.',

        );

      }

      final InformacoesIecaServico informacoes =

          InformacoesIecaServico.instancia;

      final DateTime agora =

          DateTime.now();

      final int periodoAtual =

          await informacoes.obterPeriodoAtual(

        agora: agora,

      );

      final int? periodoAgendadoAte =

          await _obterPeriodoSabiasQueAgendadoAte();

      final int periodoNecessarioAte =

          periodoAtual +

          ciclosSabiasQueAgendados;

      final Set<int> idsPendentes =

          await _obterIdsPendentes();

      bool precisaRenovar =

          periodoAgendadoAte == null ||

          periodoAgendadoAte <

              periodoNecessarioAte;

      if (!precisaRenovar) {

        final int idPeriodoAtual =

            _idParaPeriodoSabiasQue(

          periodoAtual,

        );

        if (!idsPendentes.contains(

          idPeriodoAtual,

        )) {

          debugPrint(

            'Alarme de "Sabias que?" em falta '

            'para o período $periodoAtual. '

            'Renovação forçada.',

          );

          precisaRenovar = true;

        }

      }

      if (!precisaRenovar) {

        debugPrint(

          '"Sabias que?" já está agendado até '

          'ao período $periodoAgendadoAte. '

          'Nenhuma renovação necessária.',

        );

        return;

      }

      debugPrint(

        'Renovação de "Sabias que?" necessária.',

      );

      final DateTime inicioRotacao =

          await informacoes.obterInicioRotacao();

      final int periodo =

          periodoAtual;

      final tz.TZDateTime agoraTz =

          tz.TZDateTime.now(tz.local);

      final DateTime inicioPeriodoAtual =

          await informacoes.obterInicioPeriodo(

        agora: agora,

      );

      final MissaoIeca missaoAtual =

          await informacoes.obterMissaoAtual(

        agora: agora,

      );

      final bool ehPrimeiroPeriodo =

          periodo == 0;

      final DateTime inicioNotificacaoAtual =

          ehPrimeiroPeriodo

              ? inicioRotacao.add(

                  const Duration(

                    minutes:

                        atrasoPrimeiroSabiasQueEmMinutos,

                  ),

                )

              : inicioPeriodoAtual;

      final tz.TZDateTime dataNotificacaoAtual =

          tz.TZDateTime(

        tz.local,

        inicioNotificacaoAtual.year,

        inicioNotificacaoAtual.month,

        inicioNotificacaoAtual.day,

        inicioNotificacaoAtual.hour,

        inicioNotificacaoAtual.minute,

        inicioNotificacaoAtual.second,

      );

      final int? periodoNotificado =

          await _obterPeriodoSabiasQueNotificado();

      int maiorPeriodoAgendado =

          periodoAgendadoAte ?? -1;

      // ---------------------------------------------------------

      // PERÍODO ATUAL

      // ---------------------------------------------------------

      final int idPeriodoAtual =

          _idParaPeriodoSabiasQue(periodo);

      final bool periodoAtualPendente =

          idsPendentes.contains(

        idPeriodoAtual,

      );

      if (!periodoAtualPendente) {

        if (dataNotificacaoAtual.isAfter(

          agoraTz,

        )) {

          final bool ok =

              await _agendarNotificacao(

            id: idPeriodoAtual,

            titulo: 'Sabias que?',

            corpo: _mensagemSabiasQue(

              missao: missaoAtual,

            ),

            dataHora:

                dataNotificacaoAtual,

            payload:

                'sabias_que|${missaoAtual.id}',

            canalId:

                canalSabiasQue,

            nomeCanal:

                nomeCanalSabiasQue,

            descricaoCanal:

                descricaoCanalSabiasQue,

          );

          if (ok) {

            idsPendentes.add(

              idPeriodoAtual,

            );

            if (periodo >

                maiorPeriodoAgendado) {

              maiorPeriodoAgendado =

                  periodo;

            }

          }

        } else if (

            periodoNotificado != periodo) {

          await mostrarNotificacao(

            id: idPeriodoAtual,

            titulo: 'Sabias que?',

            corpo: _mensagemSabiasQue(

              missao: missaoAtual,

            ),

            payload:

                'sabias_que|${missaoAtual.id}',

            canalId:

                canalSabiasQue,

            nomeCanal:

                nomeCanalSabiasQue,

            descricaoCanal:

                descricaoCanalSabiasQue,

          );

          final SharedPreferences prefs =

              await SharedPreferences

                  .getInstance();

          await prefs.setInt(

            _chaveSabiasQuePeriodoNotificado,

            periodo,

          );

        }

      }

      // ---------------------------------------------------------

      // PRÓXIMOS PERÍODOS

      // ---------------------------------------------------------

      for (

        int d = 1;

        d <= ciclosSabiasQueAgendados;

        d++

      ) {

        final int periodoFuturo =

            periodoAtual + d;

        final int idPeriodo =

            _idParaPeriodoSabiasQue(

          periodoFuturo,

        );

        if (idsPendentes.contains(

          idPeriodo,

        )) {

          if (periodoFuturo >

              maiorPeriodoAgendado) {

            maiorPeriodoAgendado =

                periodoFuturo;

          }

          continue;

        }

        final DateTime inicioPeriodo =

            await informacoes

                .obterInicioPeriodoPorNumero(

          periodoFuturo,

        );

        final MissaoIeca missao =

            await informacoes.obterMissaoAtual(

          agora: inicioPeriodo,

        );

        final tz.TZDateTime dataNotificacao =

            tz.TZDateTime(

          tz.local,

          inicioPeriodo.year,

          inicioPeriodo.month,

          inicioPeriodo.day,

          inicioPeriodo.hour,

          inicioPeriodo.minute,

          inicioPeriodo.second,

        );

        if (!dataNotificacao.isAfter(

          agoraTz,

        )) {

          continue;

        }

        final bool ok =

            await _agendarNotificacao(

          id: idPeriodo,

          titulo: 'Sabias que?',

          corpo: _mensagemSabiasQue(

            missao: missao,

          ),

          dataHora:

              dataNotificacao,

          payload:

              'sabias_que|${missao.id}',

          canalId:

              canalSabiasQue,

          nomeCanal:

              nomeCanalSabiasQue,

          descricaoCanal:

              descricaoCanalSabiasQue,

        );

        if (ok) {

          idsPendentes.add(

            idPeriodo,

          );

          if (periodoFuturo >

              maiorPeriodoAgendado) {

            maiorPeriodoAgendado =

                periodoFuturo;

          }

        }

      }

      await _guardarPeriodoSabiasQueAgendadoAte(

        maiorPeriodoAgendado,

      );

      debugPrint(

        '"Sabias que?" configurado até ao '

        'período $maiorPeriodoAgendado.',

      );

    } catch (e, stackTrace) {

      debugPrint(

        'Erro ao configurar "Sabias que?": $e',

      );

      debugPrint('$stackTrace');

    }

  }

  // =============================================================

  // VERIFICAÇÃO PERIÓDICA (COM THROTTLE)

  // =============================================================

  Future<void> verificarERepararAgendamentos() async {

    await inicializar();

    if (kIsWeb) return;

    try {

      final SharedPreferences prefs =

          await SharedPreferences.getInstance();

      final int agoraMs =

          DateTime.now().millisecondsSinceEpoch;

      final int ultimaMs =

          prefs.getInt(_chaveUltimaVerificacao) ?? 0;

      final Duration desdeUltima =

          Duration(milliseconds: agoraMs - ultimaMs);

      if (desdeUltima < intervaloMinimoVerificacao) {

        debugPrint(

          '   ⏭️ Verificação ignorada (feita há '

          '${desdeUltima.inMinutes} min).',

        );

        return;

      }

      await prefs.setInt(_chaveUltimaVerificacao, agoraMs);

      debugPrint(

        '   🔧 A verificar e reparar agendamentos...',

      );

      await configurarNotificacaoSabiasQue();

    } catch (e, stackTrace) {

      debugPrint(

        'Erro ao verificar/reparar agendamentos: $e',

      );

      debugPrint('$stackTrace');

    }

  }

  // =============================================================

  // TESTE

  // =============================================================

  Future<void> testarNotificacao() async {

    await inicializar();

    if (kIsWeb) return;

    if (!await _notificacoesAndroidAtivadas()) {

      debugPrint(

        'Teste cancelado: '

        'permissão Android desativada.',

      );

      return;

    }

    try {

      final MissaoIeca missao =

          await InformacoesIecaServico

              .instancia

              .obterMissaoAtual();

      await mostrarNotificacao(

        id: _idTesteSabiasQue,

        titulo: 'Sabias que?',

        corpo: _mensagemSabiasQue(

          missao: missao,

        ),

        payload:

            'sabias_que|${missao.id}',

        canalId:

            canalSabiasQue,

        nomeCanal:

            nomeCanalSabiasQue,

        descricaoCanal:

            descricaoCanalSabiasQue,

      );

      debugPrint(

        'Notificação de teste enviada.',

      );

    } catch (e, stackTrace) {

      debugPrint(

        'Erro ao executar teste de notificações: $e',

      );

      debugPrint('$stackTrace');

    }

  }

  // =============================================================

  // CANCELAMENTOS

  // =============================================================

  Future<void> cancelarTodas() async {

    await inicializar();

    if (kIsWeb) return;

    try {

      await _notificacoes.cancelAll();

      final SharedPreferences prefs =

          await SharedPreferences.getInstance();

      await prefs.remove(

        _chaveSabiasQuePeriodoNotificado,

      );

      await prefs.remove(

        _chaveSabiasQuePeriodoAgendadoAte,

      );

      await prefs.remove(

        _chaveUltimaVerificacao,

      );

      debugPrint(

        'Todas as notificações foram canceladas.',

      );

    } catch (e, stackTrace) {

      debugPrint(

        'Erro ao cancelar todas as notificações: $e',

      );

      debugPrint('$stackTrace');

    }

  }

}

/// ===============================================================

/// HANDLER DE NOTIFICAÇÕES EM BACKGROUND

/// ===============================================================

@pragma('vm:entry-point')

void notificacaoBackgroundHandler(

  NotificationResponse resposta,

) {

  debugPrint(

    'Notificação em background: '

    '${resposta.payload}',

  );

}