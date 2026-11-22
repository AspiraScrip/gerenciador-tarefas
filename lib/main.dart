import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'screens/auth_gate.dart';
import 'screens/configuracoes_screen.dart';
import 'screens/sobre_screen.dart';
import 'screens/tarefas_screen.dart';
import 'themes/app_theme.dart';
import 'themes/theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Recupera o tema salvo no SharedPreferences antes de desenhar a primeira tela.
  await themeController.carregar();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Reconstrói o MaterialApp sempre que o tema mudar (vale para TODAS as telas).
    return ListenableBuilder(
      listenable: themeController,
      builder: (context, _) {
        return MaterialApp(
          title: 'Gerenciador de Tarefas',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeController.themeMode,
          initialRoute: '/',
          routes: {
            '/': (_) => const AuthGate(),
            '/tarefas': (_) => const TarefasScreen(),
            '/configuracoes': (_) => const ConfiguracoesScreen(),
            '/sobre': (_) => const SobreScreen(),
          },
        );
      },
    );
  }
}
