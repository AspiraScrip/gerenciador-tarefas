import 'package:flutter/material.dart';

import '../models/tarefa.dart';
import '../models/usuario.dart';
import '../services/auth_service.dart';
import '../services/firebase_service.dart';
import '../widgets/drawer_menu.dart';
import 'cadastro_tarefa_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _auth = AuthService();
  late final FirebaseService _firebase = FirebaseService(_auth.uid);
  late final Stream<Usuario> _usuarioStream =
      _auth.usuarioStream(_auth.usuarioAtual!);
  late final Stream<List<Tarefa>> _tarefasStream = _firebase.tarefasStream();

  Widget _cartaoResumo(String titulo, int valor, IconData icone, Color cor) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            children: [
              Icon(icone, color: cor, size: 30),
              const SizedBox(height: 8),
              Text(
                '$valor',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Text(titulo, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Início')),
      drawer: const DrawerMenu(rotaAtual: '/'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          StreamBuilder<Usuario>(
            stream: _usuarioStream,
            builder: (context, snapshot) {
              final nome = snapshot.data?.nome ??
                  _auth.usuarioAtual?.displayName ??
                  '';
              return Text(
                nome.isEmpty ? 'Olá!' : 'Olá, $nome!',
                style: Theme.of(context).textTheme.headlineSmall,
              );
            },
          ),
          const SizedBox(height: 4),
          const Text('Veja o resumo das suas tarefas.'),
          const SizedBox(height: 16),
          StreamBuilder<List<Tarefa>>(
            stream: _tarefasStream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text('Não foi possível carregar as tarefas.');
              }
              final lista = snapshot.data ?? [];
              final concluidas = lista.where((t) => t.concluida).length;
              final pendentes = lista.length - concluidas;
              return Row(
                children: [
                  _cartaoResumo(
                      'Cadastradas', lista.length, Icons.list_alt, Colors.blue),
                  _cartaoResumo('Pendentes', pendentes,
                      Icons.hourglass_bottom, Colors.orange),
                  _cartaoResumo('Concluídas', concluidas,
                      Icons.check_circle, Colors.green),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            icon: const Icon(Icons.checklist),
            label: const Text('Ver minhas tarefas'),
            onPressed: () => Navigator.pushNamed(context, '/tarefas'),
          ),
          const SizedBox(height: 12),
          FilledButton.tonalIcon(
            icon: const Icon(Icons.add),
            label: const Text('Nova tarefa'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CadastroTarefaScreen(service: _firebase),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
