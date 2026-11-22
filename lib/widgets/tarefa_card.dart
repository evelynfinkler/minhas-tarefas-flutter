import 'package:flutter/material.dart';
import '../models/tarefa.dart';

Color corPrioridade(Prioridade prioridade, BuildContext context) {
  final escuro = Theme.of(context).brightness == Brightness.dark;
  return switch (prioridade) {
    Prioridade.alta => escuro ? Colors.red.shade200 : Colors.red.shade800,
    Prioridade.media => escuro ? Colors.amber.shade200 : Colors.brown.shade700,
    Prioridade.baixa => Theme.of(context).colorScheme.secondary,
  };
}

class TarefaCard extends StatelessWidget {
  const TarefaCard({super.key, required this.tarefa, required this.onTap});
  final Tarefa tarefa;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                    tarefa.concluida
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(tarefa.titulo,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  decoration: tarefa.concluida
                                      ? TextDecoration.lineThrough
                                      : null)),
                      const SizedBox(height: 8),
                      Text('Vencimento: ${tarefa.dataFormatada}'),
                      const SizedBox(height: 10),
                      Wrap(spacing: 12, runSpacing: 8, children: [
                        Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.flag_outlined,
                              size: 16,
                              color: corPrioridade(tarefa.prioridade, context)),
                          const SizedBox(width: 4),
                          Text(tarefa.prioridade.rotulo,
                              style: TextStyle(
                                  color:
                                      corPrioridade(tarefa.prioridade, context),
                                  fontWeight: FontWeight.w600)),
                        ]),
                        Text(tarefa.concluida ? 'Concluída' : 'Pendente'),
                      ]),
                    ])),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      );
}
