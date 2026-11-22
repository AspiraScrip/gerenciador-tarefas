import 'package:flutter/material.dart';

import '../themes/theme_controller.dart';
import '../widgets/drawer_menu.dart';

class ConfiguracoesScreen extends StatelessWidget {
  const ConfiguracoesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      drawer: const DrawerMenu(rotaAtual: '/configuracoes'),
      body: ListenableBuilder(
        listenable: themeController,
        builder: (context, _) {
          return ListView(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
                child: Text('Aparência'),
              ),
              SwitchListTile(
                secondary: Icon(
                  themeController.escuro ? Icons.dark_mode : Icons.light_mode,
                ),
                title: const Text('Tema escuro'),
                subtitle: Text(
                  themeController.escuro ? 'Tema escuro ativo' : 'Tema claro ativo',
                ),
                value: themeController.escuro,
                onChanged: (v) => themeController.definirEscuro(v),
              ),
            ],
          );
        },
      ),
    );
  }
}
