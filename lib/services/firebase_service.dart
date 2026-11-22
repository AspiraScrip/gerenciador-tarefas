import 'package:firebase_database/firebase_database.dart';

import '../models/tarefa.dart';

/// CRUD das tarefas no Realtime Database.
/// Estrutura: /tarefas/{uid}/{idTarefa}  -> cada usuário só enxerga o seu nó.
class FirebaseService {
  final String uid;

  FirebaseService(this.uid);

  DatabaseReference get _ref =>
      FirebaseDatabase.instance.ref('tarefas/$uid');

  /// Listener em tempo real: emite a lista sempre que algo muda no banco.
  Stream<List<Tarefa>> tarefasStream() {
    return _ref.onValue.map((event) {
      final valor = event.snapshot.value;
      if (valor is! Map) return <Tarefa>[];
      final lista = valor.entries
          .where((e) => e.value is Map)
          .map((e) => Tarefa.fromMap(e.key.toString(), e.value as Map))
          .toList();
      lista.sort((a, b) => a.dataVencimento.compareTo(b.dataVencimento));
      return lista;
    });
  }

  /// Listener de uma única tarefa (tela de detalhes).
  Stream<Tarefa?> tarefaStream(String id) {
    return _ref.child(id).onValue.map((event) {
      final valor = event.snapshot.value;
      if (valor is! Map) return null;
      return Tarefa.fromMap(id, valor);
    });
  }

  // ---------- CREATE ----------
  Future<void> criar(Tarefa tarefa) async {
    final novo = _ref.push();
    await novo.set(tarefa.toMap());
  }

  // ---------- READ (consulta pontual) ----------
  Future<Tarefa?> consultar(String id) async {
    final snap = await _ref.child(id).get();
    if (!snap.exists || snap.value is! Map) return null;
    return Tarefa.fromMap(id, snap.value as Map);
  }

  // ---------- UPDATE ----------
  Future<void> atualizar(Tarefa tarefa) async {
    await _ref.child(tarefa.id).set(tarefa.toMap());
  }

  Future<void> alternarSituacao(String id, bool concluida) async {
    await _ref.child(id).update({'concluida': concluida});
  }

  // ---------- DELETE ----------
  Future<void> excluir(String id) async {
    await _ref.child(id).remove();
  }
}
