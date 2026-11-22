import 'package:flutter/material.dart';

import '../widgets/drawer_menu.dart';

class SobreScreen extends StatelessWidget {
  const SobreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Sobre o aplicativo')),
      drawer: const DrawerMenu(rotaAtual: '/sobre'),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Icon(Icons.task_alt, size: 80, color: cores.primary),
          const SizedBox(height: 12),
          Text(
            'Gerenciador de Tarefas',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const Text('Versão 1.0.0', textAlign: TextAlign.center),
          const SizedBox(height: 24),
          const Text(
            'Aplicativo desenvolvido para a avaliação P2 de Programação Mobile. '
            'Permite cadastrar-se, autenticar-se e gerenciar tarefas pessoais, '
            'com dados sincronizados em tempo real na nuvem.',
          ),
          const SizedBox(height: 24),
          const ListTile(
            leading: Icon(Icons.flutter_dash),
            title: Text('Flutter / Dart'),
          ),
          const ListTile(
            leading: Icon(Icons.verified_user),
            title: Text('Firebase Authentication'),
          ),
          const ListTile(
            leading: Icon(Icons.cloud),
            title: Text('Firebase Realtime Database'),
          ),
          const ListTile(
            leading: Icon(Icons.save),
            title: Text('SharedPreferences'),
          ),
          const SizedBox(height: 16),
          const Text(
            'Desenvolvido por: Jefferson Batista',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
