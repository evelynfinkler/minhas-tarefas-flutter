import 'package:flutter/material.dart';
import '../models/tarefa.dart';
import '../services/firebase_service.dart';
import '../utils/mensagens.dart';
import '../widgets/tarefa_card.dart';
import 'cadastro_tarefa_screen.dart';

class DetalhesTarefaScreen extends StatefulWidget {
  const DetalhesTarefaScreen(
      {super.key, required this.id, required this.firebase});
  final String id;
  final FirebaseService firebase;
  @override
  State<DetalhesTarefaScreen> createState() => _DetalhesTarefaScreenState();
}

class _DetalhesTarefaScreenState extends State<DetalhesTarefaScreen> {
  late final Stream<List<Tarefa>> _tarefas;
  bool _ocupado = false;
  @override
  void initState() {
    super.initState();
    _tarefas = widget.firebase.observarTarefas();
  }

  Future<void> _alterar(Tarefa tarefa) async {
    setState(() => _ocupado = true);
    try {
      await widget.firebase.alterarSituacao(tarefa);
    } catch (erro) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(mensagemErro(erro))));
      }
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  Future<void> _excluir(Tarefa tarefa) async {
    final confirmar = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
                title: const Text('Excluir tarefa?'),
                content: Text('A tarefa "${tarefa.titulo}" será excluída.'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancelar')),
                  FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Excluir'))
                ]));
    if (confirmar != true || !mounted) return;
    setState(() => _ocupado = true);
    try {
      await widget.firebase.excluir(tarefa);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Tarefa excluída.')));
        Navigator.pop(context);
      }
    } catch (erro) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(mensagemErro(erro))));
      }
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Detalhes da tarefa')),
        body: StreamBuilder<List<Tarefa>>(
          stream: _tarefas,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                  child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(mensagemErro(snapshot.error!))));
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final encontradas = snapshot.data!.where((t) => t.id == widget.id);
            if (encontradas.isEmpty) {
              return const Center(
                  child: Text('Esta tarefa não está mais disponível.'));
            }
            final tarefa = encontradas.first;
            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(tarefa.titulo,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Text(tarefa.descricao.isEmpty
                    ? 'Sem descrição.'
                    : tarefa.descricao),
                const SizedBox(height: 28),
                Card(
                    child: Column(children: [
                  ListTile(
                      leading: const Icon(Icons.calendar_today_outlined),
                      title: const Text('Vencimento'),
                      subtitle: Text(tarefa.dataFormatada)),
                  ListTile(
                      leading: Icon(Icons.flag_outlined,
                          color: corPrioridade(tarefa.prioridade, context)),
                      title: const Text('Prioridade'),
                      subtitle: Text(tarefa.prioridade.rotulo)),
                  ListTile(
                      leading: Icon(
                          tarefa.concluida ? Icons.task_alt : Icons.schedule),
                      title: const Text('Situação'),
                      subtitle:
                          Text(tarefa.concluida ? 'Concluída' : 'Pendente'))
                ])),
                const SizedBox(height: 24),
                FilledButton.icon(
                    onPressed: _ocupado ? null : () => _alterar(tarefa),
                    icon: Icon(tarefa.concluida ? Icons.undo : Icons.check),
                    label: Text(tarefa.concluida
                        ? 'Marcar como pendente'
                        : 'Marcar como concluída')),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                    onPressed: _ocupado
                        ? null
                        : () => Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                                builder: (_) => CadastroTarefaScreen(
                                    firebase: widget.firebase,
                                    tarefa: tarefa))),
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Editar tarefa')),
                const SizedBox(height: 8),
                TextButton.icon(
                    onPressed: _ocupado ? null : () => _excluir(tarefa),
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Excluir tarefa'),
                    style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.error)),
              ],
            );
          },
        ),
      );
}
