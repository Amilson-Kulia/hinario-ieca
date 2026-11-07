import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hinario_ieca/app/app.dart';

void main() {
  testWidgets(
    'A aplicação arranca sem erros',
    (WidgetTester tester) async {
      // Constrói a app e aguarda o primeiro frame.
      await tester.pumpWidget(const HinarioApp());

      // Aguarda o frame estabilizar (ignora timers pendentes).
      await tester.pump(const Duration(seconds: 1));

      // Verifica que o widget raiz existe.
      expect(find.byType(HinarioApp), findsOneWidget);
    },
  );
}