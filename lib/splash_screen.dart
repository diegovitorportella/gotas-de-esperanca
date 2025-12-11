import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Flag para garantir que a inicialização ocorra apenas uma vez
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // A lógica de inicialização foi movida para didChangeDependencies
    // para garantir que temos um 'context' válido para o precache.
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Só executa a inicialização uma vez
    if (!_isInitialized) {
      _isInitialized = true;
      _initializeApp();
    }
  }

  Future<void> _initializeApp() async {
    // 1. Pré-carrega as imagens de fundo principais
    // Isso garante que elas estejam na memória antes de navegar
    await _precacheAssets();

    // 2. Mantém o delay original (reduzido para 1s, já que o precache leva tempo)
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return; // Garante que o widget ainda está na tela

    // 3. Verifica o status de login
    final prefs = await SharedPreferences.getInstance();
    final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    // 4. Navega para a tela correta
    if (isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  /// Carrega as imagens mais pesadas na memória.
  Future<void> _precacheAssets() async {
    try {
      // Imagem de fundo da HomeScreenApp
      await precacheImage(const AssetImage("assets/images/tela_inicioapp.png"), context);

      // Imagem de fundo da CalendarioScreen
      await precacheImage(const AssetImage("assets/images/tela_calendario.png"), context);

      // Logo (usado em várias telas)
      await precacheImage(const AssetImage("assets/images/logo_app.png"), context);

      debugPrint("Imagens pré-carregadas com sucesso.");
    } catch (e) {
      // Se o precache falhar (ex: imagem não encontrada),
      // apenas registra no console e continua o app.
      debugPrint("Erro ao pré-carregar imagens: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // A tela da splash (o 'build') continua exatamente a mesma
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo_app.png',
              height: 120,
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(
              color: Color(0xFFC62828),
            ),
          ],
        ),
      ),
    );
  }
}