import 'package:flutter/material.dart';
import '../models/tarefa.dart';
import '../services/firebase_service.dart';
import '../widgets/tarefa_card.dart';
import 'detalhes_tarefa_screen.dart';

class TarefasScreen extends StatefulWidget {
  const TarefasScreen(
      {super.key, required this.tarefas, required this.firebase});
  final List<Tarefa> tarefas;
  final FirebaseService firebase;
  @override
  State<TarefasScreen> createState() => _TarefasScreenState();
}

class _TarefasScreenState extends State<TarefasScreen> {
  int _filtro = 0;
  @override
  Widget build(BuildContext context) {
    final tarefas = widget.tarefas
        .where((t) =>
            _filtro == 0 ||
            (_filtro == 1 && !t.concluida) ||
            (_filtro == 2 && t.concluida))
        .toList();
    return Column(
      children: [
        Padding(
            padding: const EdgeInsets.all(20),
            child: DropdownButtonFormField<int>(
                initialValue: _filtro,
                decoration: const InputDecoration(labelText: 'Mostrar'),
                items: const [
                  DropdownMenuItem(value: 0, child: Text('Todas as tarefas')),
                  DropdownMenuItem(value: 1, child: Text('Pendentes')),
                  DropdownMenuItem(value: 2, child: Text('Concluídas'))
                ],
                onChanged: (valor) => setState(() => _filtro = valor ?? 0))),
        Expanded(
            child: tarefas.isEmpty
                ? Center(
                    child: Padding(
                        padding: const EdgeInsets.all(24),
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.checklist,
                              size: 64,
                              color: Theme.of(context).colorScheme.primary),
                          const SizedBox(height: 16),
                          Text(widget.tarefas.isEmpty
                              ? 'Nenhuma tarefa cadastrada.'
                              : 'Nenhuma tarefa neste filtro.'),
                          if (widget.tarefas.isEmpty)
                            const Padding(
                                padding: EdgeInsets.only(top: 8),
                                child:
                                    Text('Toque em Nova tarefa para começar.'))
                        ])))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    itemCount: tarefas.length,
                    itemBuilder: (context, index) => TarefaCard(
                        tarefa: tarefas[index],
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                                builder: (_) => DetalhesTarefaScreen(
                                    id: tarefas[index].id,
                                    firebase: widget.firebase)))))),
      ],
    );
  }
}
