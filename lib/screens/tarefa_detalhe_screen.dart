import 'package:flutter/material.dart';

import '../models/tarefa.dart';
import '../services/firebase_service.dart';
import '../widgets/confirmar_dialog.dart';
import 'cadastro_tarefa_screen.dart';

class TarefaDetalheScreen extends StatelessWidget {
  final String tarefaId;
  final FirebaseService service;

  const TarefaDetalheScreen({
    super.key,
    required this.tarefaId,
    required this.service,
  });

  Future<void> _excluir(BuildContext context, Tarefa t) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    if (!await confirmarExclusao(context, t.titulo)) return;
    try {
      await service.excluir(t.id);
      navigator.pop();
      messenger.showSnackBar(const SnackBar(content: Text('Tarefa excluída.')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Erro ao excluir: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Tarefa?>(
      stream: service.tarefaStream(tarefaId),
      builder: (context, snapshot) {
        final t = snapshot.data;
        if (t == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Detalhes')),
            body: snapshot.connectionState == ConnectionState.waiting
                ? const Center(child: CircularProgressIndicator())
                : const Center(child: Text('Tarefa não encontrada.')),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text('Detalhes da tarefa'),
            actions: [
              IconButton(
                tooltip: 'Editar',
                icon: const Icon(Icons.edit),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        CadastroTarefaScreen(service: service, tarefa: t),
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Excluir',
                icon: const Icon(Icons.delete),
                onPressed: () => _excluir(context, t),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(t.titulo, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              Text(
                t.descricao.isEmpty ? 'Sem descrição.' : t.descricao,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.event),
                title: const Text('Data de vencimento'),
                subtitle: Text(t.dataFormatada),
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: t.prioridade.cor,
                  child: Icon(t.prioridade.icone, color: Colors.white),
                ),
                title: const Text('Prioridade'),
                subtitle: Text(t.prioridade.rotulo),
              ),
              ListTile(
                leading: Icon(t.concluida
                    ? Icons.check_circle
                    : Icons.hourglass_bottom),
                title: const Text('Situação'),
                subtitle: Text(t.situacao),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                icon: Icon(t.concluida ? Icons.undo : Icons.check),
                label: Text(
                    t.concluida ? 'Marcar como pendente' : 'Marcar como concluída'),
                onPressed: () => service.alternarSituacao(t.id, !t.concluida),
              ),
            ],
          ),
        );
      },
    );
  }
}
