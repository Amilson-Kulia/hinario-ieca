import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app/tema.dart';
import '../modelos/referencia_ieca.dart';

class ReferenciasIeca extends StatelessWidget {
  final List<ReferenciaIeca> referencias;

  const ReferenciasIeca({
    super.key,
    required this.referencias,
  });

  Future<void> _abrirReferencia(
    BuildContext context,
    ReferenciaIeca referencia,
  ) async {
    final uri = Uri.tryParse(referencia.url);

    if (uri == null ||
        (uri.scheme != 'http' && uri.scheme != 'https')) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'O endereço desta fonte não é válido.',
          ),
        ),
      );

      return;
    }

    final abriu = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!abriu && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Não foi possível abrir a fonte.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (referencias.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 28),

        // =====================================================
        // TÍTULO
        // =====================================================

        Text(
          'Referências',
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(
                color: TemaHinario.corPrimaria,
                fontWeight: FontWeight.w800,
              ),
        ),

        const SizedBox(height: 6),

        Text(
          'Fontes utilizadas para a elaboração deste conteúdo.',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(
                color: TemaHinario.corTextoSecundario,
                height: 1.4,
              ),
        ),

        const SizedBox(height: 14),

        // =====================================================
        // LISTA DE REFERÊNCIAS
        // =====================================================

        ...referencias.asMap().entries.map(
          (entrada) {
            final int indice = entrada.key + 1;
            final ReferenciaIeca referencia = entrada.value;

            return Card(
              margin: const EdgeInsets.only(
                bottom: 10,
              ),
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(
                  color: TemaHinario.corPrimaria.withValues(
                    alpha: 0.08,
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    // =================================================
                    // NÚMERO
                    // =================================================

                    Container(
                      width: 34,
                      height: 34,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color:
                            TemaHinario.corPrimaria.withValues(
                          alpha: 0.08,
                        ),
                        borderRadius:
                            BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$indice',
                        style: const TextStyle(
                          color: TemaHinario.corPrimaria,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // =================================================
                    // CONTEÚDO DA REFERÊNCIA
                    // =================================================

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          // =================================================
                          // FONTE
                          // =================================================

                          Text(
                            referencia.fonte,
                            style: const TextStyle(
                              color: TemaHinario.corTexto,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              height: 1.35,
                            ),
                          ),

                          const SizedBox(height: 5),

                          // =================================================
                          // DATA
                          // =================================================

                          Text(
                            referencia.data,
                            style: const TextStyle(
                              color:
                                  TemaHinario.corTextoSecundario,
                              fontSize: 12,
                            ),
                          ),

                          const SizedBox(height: 10),

                          // =================================================
                          // ABRIR FONTE
                          // =================================================

                          InkWell(
                            onTap: () => _abrirReferencia(
                              context,
                              referencia,
                            ),
                            borderRadius:
                                BorderRadius.circular(8),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(
                                vertical: 4,
                                horizontal: 2,
                              ),
                              child: Row(
                                mainAxisSize:
                                    MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.open_in_new_rounded,
                                    size: 16,
                                    color:
                                        TemaHinario.corPrimaria,
                                  ),

                                  const SizedBox(width: 6),

                                  const Text(
                                    'Abrir fonte',
                                    style: TextStyle(
                                      color: TemaHinario
                                          .corPrimaria,
                                      fontSize: 13,
                                      fontWeight:
                                          FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}