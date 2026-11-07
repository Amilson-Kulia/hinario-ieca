import 'package:flutter/material.dart';

import '../app/tema.dart';

class CabecalhoIeca extends StatelessWidget
    implements PreferredSizeWidget {
  final String? titulo;
  final String? subtitulo;
  final List<Widget>? actions;

  const CabecalhoIeca({
    super.key,
    this.titulo,
    this.subtitulo,
    this.actions, 
  });

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: TemaHinario.corSuperficie,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      toolbarHeight: 72,
      titleSpacing: 24,

      title: Row(
        children: [
          Image.asset(
            'assets/images/logoieca.png',
            height: 44,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) {
              return const Icon(
                Icons.menu_book_rounded,
                color: TemaHinario.corPrimaria,
                size: 34,
              );
            },
          ),

          const SizedBox(width: 12),

          if (titulo == null && subtitulo == null)
            const Text(
              'IECA',
              style: TextStyle(
                fontSize: 26,
                height: 1,
                fontWeight: FontWeight.w700,
                color: TemaHinario.corTexto,
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  titulo ?? 'IECA',
                  style: const TextStyle(
                    fontSize: 24,
                    height: 1,
                    fontWeight: FontWeight.w700,
                    color: TemaHinario.corTexto,
                  ),
                ),

                if (subtitulo != null) ...[
                  const SizedBox(height: 5),
                  Text(
                    subtitulo!,
                    style: const TextStyle(
                      fontSize: 10.5,
                      height: 14 / 10.5,
                      fontWeight: FontWeight.w500,
                      color: TemaHinario.corTextoSecundario,
                    ),
                  ),
                ],
              ],
            ),
        ],
      ),

      actions: [
        // Botão voltar.
        // Fica antes das outras ações, como Pesquisa, Favoritos, etc.
        IconButton(
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
          tooltip: 'Voltar',
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: TemaHinario.corTexto,
            size: 24,
          ),
          splashRadius: 22,
        ),

        // Ações específicas da tela.
        if (actions != null) ...actions!,

        const SizedBox(width: 8),
      ],
    );
  }
}