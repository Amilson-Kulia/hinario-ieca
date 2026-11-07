import 'package:flutter/material.dart';

import 'rotas.dart';
import 'tema.dart';

/// ===============================================================
/// CHAVE GLOBAL DE NAVEGAÇÃO
/// ===============================================================
///
/// Permite que serviços que não possuem BuildContext, como o
/// serviço de notificações, possam navegar dentro da aplicação.
///
/// É utilizada principalmente quando o utilizador toca numa
/// notificação enquanto a aplicação já está aberta.
///

final GlobalKey<NavigatorState> navigatorKey =
    GlobalKey<NavigatorState>();

class HinarioApp extends StatelessWidget {
  const HinarioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hinário IECA',
      debugShowCheckedModeBanner: false,

      theme: TemaHinario.tema(),

      navigatorKey: navigatorKey,

      initialRoute: Rotas.splash,

      onGenerateRoute: Rotas.gerarRota,
    );
  }
}