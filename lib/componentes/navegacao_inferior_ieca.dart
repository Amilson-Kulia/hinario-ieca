import 'package:flutter/material.dart';

import '../app/tema.dart';

class NavegacaoInferiorIeca extends StatelessWidget {
  final int indiceSelecionado;
  final ValueChanged<int> onDestinationSelected;

  const NavegacaoInferiorIeca({
    super.key,
    required this.indiceSelecionado,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: indiceSelecionado,
      onDestinationSelected: onDestinationSelected,
      
      // -----------------------------------------------------------
      // FUNDO: vermelho IECA muito suave (opacidade ~8%)
      // Mescla com a cor de superfície para um tom quente discreto
      // -----------------------------------------------------------
      backgroundColor: TemaHinario.corPrimaria.withValues(alpha: 0.06),
      
      surfaceTintColor: Colors.transparent,
      elevation: 8,
      height: 72,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.menu_book_outlined),
          selectedIcon: Icon(Icons.menu_book),
          label: 'Hinário',
        ),
        NavigationDestination(
          icon: Icon(Icons.menu_book_outlined),
          selectedIcon: Icon(Icons.menu_book),
          label: 'Bíblia',
        ),
        NavigationDestination(
          icon: Icon(Icons.church_outlined),
          selectedIcon: Icon(Icons.church),
          label: 'IECA',
        ),
        NavigationDestination(
          icon: Icon(Icons.more_horiz),
          selectedIcon: Icon(Icons.more_horiz),
          label: 'Sobre',
        ),
      ],
    );
  }
}