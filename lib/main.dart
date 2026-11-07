import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app/app.dart';
import 'servicos/notificacoes_servico.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final NotificacoesServico notificacoes =
      NotificacoesServico.instancia;

  // =========================================================
  // 1) INICIALIZAR O PLUGIN ANTES DO PRIMEIRO FRAME
  // =========================================================
  //
  // É OBRIGATÓRIO que o FlutterLocalNotificationsPlugin.initialize()
  // corra ANTES do runApp() para que o Android consiga entregar
  // corretamente o getNotificationAppLaunchDetails() quando a app
  // é aberta por toque numa notificação.
  //
  // É rápido: só carrega o fuso horário e registra callbacks.
  // =========================================================
  try {
    await notificacoes.inicializar();

    debugPrint(
      '✅ Plugin de notificações inicializado antes do runApp.',
    );
  } catch (e, stackTrace) {
    debugPrint(
      '❌ Falha ao inicializar plugin antes do runApp: $e',
    );
    debugPrint('$stackTrace');
  }

  // =========================================================
  // 2) ARRANCAR A UI
  // =========================================================
  runApp(const HinarioApp());

  // =========================================================
  // 3) PERMISSÕES — O MAIS CEDO POSSÍVEL
  // =========================================================
  //
  // ⚠️ CRÍTICO:
  // O diálogo do Android 13+ tem de ser pedido depois de existir
  // uma Activity em estado RESUMED. Se for pedido dentro de um
  // addPostFrameCallback, em muitos dispositivos o diálogo nunca
  // aparece.
  //
  // Solução: pequeno delay (300 ms) para garantir que a Activity
  // já está em RESUMED quando o pedido for feito.
  // =========================================================
  unawaited(
    _pedirPermissoesComAtrasoCurto(notificacoes),
  );

  // =========================================================
  // 4) OBSERVER DE CICLO DE VIDA
  // =========================================================
  //
  // Sem este addObserver(), didChangeAppLifecycleState() nunca
  // corre e os alarmes apagados pelo sistema (reboot, force-stop,
  // Doze agressivo em Xiaomi/Huawei) nunca seriam reconstruídos.
  // =========================================================
  WidgetsBinding.instance.addObserver(
    _CicloDeVidaObserver(),
  );

  // =========================================================
  // 5) TRABALHO PESADO FORA DO PRIMEIRO FRAME
  // =========================================================
  WidgetsBinding.instance.addPostFrameCallback((_) {
    unawaited(_inicializarServicosEmSegundoPlano());
  });
}

/// ===============================================================
/// PEDIDO DE PERMISSÕES COM ATRASO CURTO
/// ===============================================================
///
/// Garante que a Activity já está em RESUMED antes de pedir as
/// permissões, o que é necessário para que o diálogo do Android
/// 13+ apareça.
///
Future<void> _pedirPermissoesComAtrasoCurto(
  NotificacoesServico notificacoes,
) async {
  await Future<void>.delayed(
    const Duration(milliseconds: 300),
  );

  try {
    debugPrint('▶️ A pedir permissões de notificação...');

    await notificacoes.solicitarPermissoes();

    debugPrint('✅ Permissões processadas.');
  } catch (e, stackTrace) {
    debugPrint('❌ Erro ao pedir permissões: $e');
    debugPrint('$stackTrace');
  }
}

/// ===============================================================
/// INICIALIZAÇÃO DOS SERVIÇOS DE NOTIFICAÇÃO EM SEGUNDO PLANO
/// ===============================================================
///
/// Ordem dos passos (importante):
///
/// 1. processarNotificacaoQueAbriuAplicacao()
///    URGENTE: se o utilizador tocou numa notificação para abrir a
///    app, a missão deve abrir o mais rápido possível.
///
/// 2. configurarNotificacaoSabiasQue()
///    Agenda. Nas aberturas normais sai quase imediatamente pelo
///    caminho rápido (flag em SharedPreferences).
///
/// Nota: o pedido de permissões foi MOVIDO para fora desta função
/// e corre imediatamente após o runApp() (ver main()).
///
Future<void> _inicializarServicosEmSegundoPlano() async {
  debugPrint(
    '▶️ A iniciar serviços de notificação em segundo plano...',
  );

  final NotificacoesServico notificacoes =
      NotificacoesServico.instancia;

  // -----------------------------------------------------------
  // 1) URGENTE: notificação que abriu a app
  // -----------------------------------------------------------
  try {
    debugPrint(
      '   → Passo 1: processarNotificacaoQueAbriuAplicacao()',
    );

    await notificacoes
        .processarNotificacaoQueAbriuAplicacao();

    debugPrint(
      '   ✅ processarNotificacaoQueAbriuAplicacao() concluído',
    );
  } catch (e, stackTrace) {
    debugPrint(
      '   ❌ Erro em processarNotificacaoQueAbriuAplicacao: $e',
    );
    debugPrint('$stackTrace');
  }

  // -----------------------------------------------------------
  // 2) AGENDAR "SABIAS QUE?"
  // -----------------------------------------------------------
  try {
    debugPrint(
      '   → Passo 2: configurarNotificacaoSabiasQue()',
    );

    await notificacoes.configurarNotificacaoSabiasQue();

    debugPrint('   ✅ Agendamento concluído');
  } catch (e, stackTrace) {
    debugPrint('   ❌ Erro ao agendar notificações: $e');
    debugPrint('$stackTrace');
  }

  debugPrint(
    '🏁 Serviços de notificação em segundo plano concluídos.',
  );
}

/// ===============================================================
/// OBSERVER DE CICLO DE VIDA
/// ===============================================================
///
/// Chama verificarERepararAgendamentos() sempre que a app volta
/// ao foreground. É isto que garante que, se o sistema apagar os
/// alarmes (reboot, force-stop, limpeza de bateria), a app volta
/// a agendá-los na próxima abertura.
///
/// A própria função verificarERepararAgendamentos() tem throttle
/// interno (6 horas), portanto não causa jank em resumed normais.
///
class _CicloDeVidaObserver extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;

    if (kIsWeb) return;

    debugPrint(
      '↩️ App voltou ao foreground. A verificar agendamentos...',
    );

    unawaited(
      NotificacoesServico.instancia
          .verificarERepararAgendamentos(),
    );
  }
}