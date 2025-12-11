import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gotas_de_esperanca/firebase_options.dart';
import 'package:gotas_de_esperanca/splash_screen.dart'; // Importa a Splash
import 'package:gotas_de_esperanca/helpers/database_helper.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Mantemos o Firebase APENAS para o banco de dados de doações
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inicializa o Banco Local (SQLite) para Login/Perfil
  await DatabaseHelper.db();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gotas de Esperança',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFFC62828),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFC62828)),
        useMaterial3: true,
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'),
        Locale('en', 'US'),
      ],
      // A Splash Screen cuidará de verificar se está logado ou não
      home: const SplashScreen(),
    );
  }
}