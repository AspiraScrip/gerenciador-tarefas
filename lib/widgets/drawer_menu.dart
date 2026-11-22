import 'package:flutter/material.dart';

import '../models/usuario.dart';
import '../services/auth_service.dart';

class DrawerMenu extends StatefulWidget {
  /// Rota da tela que está exibindo o drawer ('/', '/tarefas', '/configuracoes', '/sobre').
  final String rotaAtual;

  const DrawerMenu({super.key, required this.rotaAtual});

  @override
  State<DrawerMenu> createState() => _DrawerMenuState();
}

class _DrawerMenuState extends State<DrawerMenu> {
  final AuthService _auth = AuthService();
  Stream<Usuario>? _usuarioStream;

  @override
  void initState() {
    super.initState();
    final user = _auth.usuarioAtual;
    if (user != null) _usuarioStream = _auth.usuarioStream(user);
  }

  void _navegar(String destino) {
    final navigator = Navigator.of(context);
    navigator.pop(); // fecha o drawer
    if (destino == widget.rotaAtual) return;
    if (destino == '/') {
      navigator.popUntil((route) => route.isFirst);
    } else if (widget.rotaAtual == '/') {
      navigator.pushNamed(destino);
    } else {
      navigator.pushReplacementNamed(destino);
    }
  }

  Future<void> _sair() async {
    final navigator = Navigator.of(context);
    navigator.pop(); // fecha o drawer
    navigator.popUntil((route) => route.isFirst);
    await _auth.sair(); // o AuthGate volta para a tela de login
  }

  Widget _item(IconData icone, String texto, String rota) {
    return ListTile(
      leading: Icon(icone),
      title: Text(texto),
      selected: widget.rotaAtual == rota,
      onTap: () => _navegar(rota),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          StreamBuilder<Usuario>(
            stream: _usuarioStream,
            builder: (context, snapshot) {
              final user = _auth.usuarioAtual;
              final nome = snapshot.data?.nome ?? user?.displayName ?? '';
              final email = snapshot.data?.email ?? user?.email ?? '';
              final inicial = nome.isNotEmpty ? nome[0].toUpperCase() : '?';
              return UserAccountsDrawerHeader(
                accountName: Text(nome.isEmpty ? 'Usuário' : nome),
                accountEmail: Text(email),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  child: Text(
                    inicial,
                    style: TextStyle(
                      fontSize: 28,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              );
            },
          ),
          _item(Icons.home, 'Início', '/'),
          _item(Icons.checklist, 'Minhas tarefas', '/tarefas'),
          _item(Icons.settings, 'Configurações', '/configuracoes'),
          _item(Icons.info_outline, 'Sobre o aplicativo', '/sobre'),
          const Spacer(),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sair'),
            onTap: _sair,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
