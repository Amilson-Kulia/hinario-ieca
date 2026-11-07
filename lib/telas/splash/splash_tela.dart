import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../servicos/constancia_servico.dart';
import '../constancia/minha_constancia_tela.dart';
import '../onboarding/onboarding_tela.dart';

class SplashTela extends StatefulWidget {
  const SplashTela({super.key});

  @override
  State<SplashTela> createState() => _SplashTelaState();
}

class _SplashTelaState extends State<SplashTela>
    with SingleTickerProviderStateMixin {
  late AnimationController _controlador;

  late Future<ResultadoConstancia> _resultadoConstancia;

  @override
  void initState() {
    super.initState();

    _controlador = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // Regista a utilização geral sem bloquear a Splash.
    _resultadoConstancia = _registrarConstanciaGeral();

    _inicializarSplash();
  }

  Future<ResultadoConstancia> _registrarConstanciaGeral() async {
    try {
      return await ConstanciaServico.instancia
          .registrarUsoGeral();
    } catch (e, stackTrace) {
      debugPrint(
        'Erro ao registar constância geral: $e',
      );

      debugPrint(
        '$stackTrace',
      );

      rethrow;
    }
  }

  // =============================================================
  // ONBOARDING — verificar se é a primeira abertura
  // =============================================================
  Future<bool> _deveMostrarOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool('onboarding_concluido') ?? false);
  }

  // =============================================================
  // NAVEGAÇÃO FINAL (Home ou Onboarding)
  // =============================================================
  Future<void> _irParaDestinoFinal() async {
    if (!mounted) return;

    final bool mostrarOnboarding = await _deveMostrarOnboarding();

    if (!mounted) return;

    if (mostrarOnboarding) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(
          builder: (_) => const OnboardingTela(),
        ),
      );
    } else {
      Navigator.pushReplacementNamed(
        context,
        '/home',
      );
    }
  }

  Future<void> _inicializarSplash() async {
    // Mantém os 4 segundos da Splash.
    await Future<void>.delayed(
      const Duration(seconds: 4),
    );

    if (!mounted) return;

    try {
      // Espera pelo registo da utilização geral.
      //
      // Isto é importante porque o registo pode ser justamente
      // o que acabou de criar um novo marco pendente.
      await _resultadoConstancia;

      if (!mounted) return;

      final ConstanciaServico servico =
          ConstanciaServico.instancia;

      // =========================================================
      // VERIFICAR MARCOS PENDENTES
      // =========================================================
      //
      // Verificamos as três constâncias:
      //
      // - Geral
      // - Bíblia
      // - Hinário
      //
      // A primeira que possuir um marco pendente fará com que
      // a MinhaConstanciaTela seja apresentada.
      //
      // =========================================================

      final int? marcoGeral =
          await servico.obterMarcoPendente(
        TipoConstancia.geral,
      );

      final int? marcoBiblia =
          await servico.obterMarcoPendente(
        TipoConstancia.biblia,
      );

      final int? marcoHinario =
          await servico.obterMarcoPendente(
        TipoConstancia.hinario,
      );

      if (!mounted) return;

      // =========================================================
      // EXISTE MARCO PENDENTE?
      // =========================================================

      if (marcoGeral != null ||
          marcoBiblia != null ||
          marcoHinario != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute<void>(
            builder: (context) =>
                const MinhaConstanciaTela(),
          ),
        );

        return;
      }

      // =========================================================
      // NENHUM MARCO PENDENTE → ONBOARDING OU HOME
      // =========================================================

      await _irParaDestinoFinal();
    } catch (e, stackTrace) {
      debugPrint(
        'Erro ao inicializar Splash/constância: $e',
      );

      debugPrint(
        '$stackTrace',
      );

      if (!mounted) return;

      // Se houver algum problema com a constância,
      // o aplicativo continua normalmente para a Home
      // (ou onboarding, se for a primeira abertura).
      await _irParaDestinoFinal();
    }
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 110),

              AnimatedBuilder(
                animation: _controlador,
                builder: (context, child) {
                  final valor = _controlador.value;

                  final sombra = 15 + (40 * valor);

                  return Container(
                    width: 150,
                    height: 165,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color:
                              const Color(0x79FCAC00),
                          blurRadius: sombra,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(20),
                      child: Image.asset(
                        'assets/images/logoieca.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 55),

              const Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: 25),
                child: Text(
                  'Igreja Evangélica Congregacional em Angola',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFCA8700),
                  ),
                ),
              ),

              const SizedBox(height: 85),

              RotationTransition(
                turns: _controlador,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color:
                          const Color(0xFFE5E7EB),
                      width: 4,
                    ),
                  ),
                  child:
                      const CircularProgressIndicator(
                    strokeWidth: 4,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(
                      Color(0x79FCAC00),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              const Text(
                'Carregando',
                style: TextStyle(
                  color: Color(0xFF5F5F5F),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}