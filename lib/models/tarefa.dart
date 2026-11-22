enum Prioridade {
  baixa('Baixa'),
  media('Média'),
  alta('Alta');

  const Prioridade(this.rotulo);
  final String rotulo;
}

class Tarefa {
  const Tarefa(
      {required this.id,
      required this.titulo,
      required this.descricao,
      required this.dataVencimento,
      required this.prioridade,
      required this.concluida});
  final String id;
  final String titulo;
  final String descricao;
  final DateTime dataVencimento;
  final Prioridade prioridade;
  final bool concluida;

  factory Tarefa.fromMap(String id, Map<Object?, Object?> map) {
    final timestamp = map['dataVencimento'];
    if (timestamp is! num) throw const FormatException('Data inválida');
    return Tarefa(
      id: id,
      titulo: map['titulo'] as String,
      descricao: map['descricao'] as String? ?? '',
      dataVencimento:
          DateTime.fromMillisecondsSinceEpoch(timestamp.toInt(), isUtc: true),
      prioridade: Prioridade.values.byName(map['prioridade'] as String),
      concluida: map['concluida'] as bool,
    );
  }

  Map<String, Object> toMap() => {
        'titulo': titulo,
        'descricao': descricao,
        'dataVencimento': DateTime.utc(
                dataVencimento.year, dataVencimento.month, dataVencimento.day)
            .millisecondsSinceEpoch,
        'prioridade': prioridade.name,
        'concluida': concluida,
      };

  Tarefa copyWith({bool? concluida}) => Tarefa(
      id: id,
      titulo: titulo,
      descricao: descricao,
      dataVencimento: dataVencimento,
      prioridade: prioridade,
      concluida: concluida ?? this.concluida);
  String get dataFormatada =>
      '${dataVencimento.day.toString().padLeft(2, '0')}/${dataVencimento.month.toString().padLeft(2, '0')}/${dataVencimento.year}';
}
