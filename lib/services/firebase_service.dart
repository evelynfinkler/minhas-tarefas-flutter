import 'package:firebase_database/firebase_database.dart';
import '../models/tarefa.dart';

class FirebaseService {
  FirebaseService(this.uid);
  final String uid;
  DatabaseReference get _ref => FirebaseDatabase.instance.ref('tarefas/$uid');

  Stream<List<Tarefa>> observarTarefas() => _ref.onValue.map((event) {
        final tarefas = event.snapshot.children.map((item) {
          return Tarefa.fromMap(
              item.key!, Map<Object?, Object?>.from(item.value as Map));
        }).toList();
        tarefas.sort((a, b) {
          final situacao = (a.concluida ? 1 : 0).compareTo(b.concluida ? 1 : 0);
          if (situacao != 0) return situacao;
          final data = a.dataVencimento.compareTo(b.dataVencimento);
          if (data != 0) return data;
          return b.prioridade.index.compareTo(a.prioridade.index);
        });
        return tarefas;
      });

  Future<void> salvar(Tarefa tarefa) async {
    final destino = tarefa.id.isEmpty ? _ref.push() : _ref.child(tarefa.id);
    await destino.set(tarefa.toMap());
  }

  Future<void> alterarSituacao(Tarefa tarefa) =>
      _ref.child(tarefa.id).update({'concluida': !tarefa.concluida});
  Future<void> excluir(Tarefa tarefa) => _ref.child(tarefa.id).remove();
}
