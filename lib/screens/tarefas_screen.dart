import 'package:flutter/material.dart';

import '../models/tarefa.dart';
import '../services/auth_service.dart';
import '../services/firebase_service.dart';
import '../widgets/confirmar_dialog.dart';
import '../widgets/drawer_menu.dart';
import 'cadastro_tarefa_screen.dart';
import 'tarefa_detalhe_screen.dart';

enum _Filtro { todas, pendentes, concluidas }

class TarefasScreen extends StatefulWidget {
  const TarefasScreen({super.key});

  @override
  State<TarefasScreen> createState() => _TarefasScreenState();
}

class _TarefasScreenState extends State<TarefasScreen> {
  late final FirebaseService _firebase = FirebaseService(AuthService().uid);
  late final Stream<List<Tarefa>> _stream = _firebase.tarefasStream();
  _Filtro _filtro = _Filtro.todas;

  void _msg(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  void _abrirCadastro([Tarefa? tarefa]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            CadastroTarefaScreen(service: _firebase, tarefa: tarefa),
      ),
    );
  }

  void _abrirDetalhes(Tarefa tarefa) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            TarefaDetalheScreen(tarefaId: tarefa.id, service: _firebase),
      ),
    );
  }

  Future<void> _alternar(Tarefa t, bool valor) async {
    try {
      await _firebase.alternarSituacao(t.id, valor);
    } catch (e) {
      _msg('Erro ao atualizar a tarefa: $e');
    }
  }

  Future<void> _excluir(Tarefa t) async {
    if (!await confirmarExclusao(context, t.titulo)) return;
    try {
      await _firebase.excluir(t.id);
      _msg('Tarefa excluída.');
    } catch (e) {
      _msg('Erro ao excluir a tarefa: $e');
    }
  }

  List<Tarefa> _filtrar(List<Tarefa> lista) {
    switch (_filtro) {
      case _Filtro.pendentes:
        return lista.where((t) => !t.concluida).toList();
      case _Filtro.concluidas:
        return lista.where((t) => t.concluida).toList();
      case _Filtro.todas:
        return lista;
    }
  }

  Widget _chip(String texto, _Filtro valor) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(texto),
        selected: _filtro == valor,
        onSelected: (_) => setState(() => _filtro = valor),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Minhas tarefas')),
      drawer: const DrawerMenu(rotaAtual: '/tarefas'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirCadastro(),
        icon: const Icon(Icons.add),
        label: const Text('Nova tarefa'),
      ),
      body: StreamBuilder<List<Tarefa>>(
        stream: _stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Não foi possível carregar as tarefas.'),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final tarefas = _filtrar(snapshot.data!);
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                child: Row(
                  children: [
                    _chip('Todas', _Filtro.todas),
                    _chip('Pendentes', _Filtro.pendentes),
                    _chip('Concluídas', _Filtro.concluidas),
                  ],
                ),
              ),
              Expanded(
                child: tarefas.isEmpty
                    ? const Center(child: Text('Nenhuma tarefa encontrada.'))
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 88),
                        itemCount: tarefas.length,
                        itemBuilder: (context, i) {
                          final t = tarefas[i];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            child: ListTile(
                              onTap: () => _abrirDetalhes(t),
                              isThreeLine: true,
                              leading: CircleAvatar(
                                backgroundColor: t.prioridade.cor,
                                child: Icon(t.prioridade.icone,
                                    color: Colors.white),
                              ),
                              title: Text(
                                t.titulo,
                                style: TextStyle(
                                  decoration: t.concluida
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                              subtitle: Text(
                                'Vence em ${t.dataFormatada}\n'
                                'Prioridade ${t.prioridade.rotulo} • ${t.situacao}',
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Checkbox(
                                    value: t.concluida,
                                    onChanged: (v) => _alternar(t, v ?? false),
                                  ),
                                  PopupMenuButton<String>(
                                    onSelected: (op) {
                                      if (op == 'editar') _abrirCadastro(t);
                                      if (op == 'excluir') _excluir(t);
                                    },
                                    itemBuilder: (_) => const [
                                      PopupMenuItem(
                                          value: 'editar', child: Text('Editar')),
                                      PopupMenuItem(
                                          value: 'excluir',
                                          child: Text('Excluir')),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
