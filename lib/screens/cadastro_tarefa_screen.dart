import 'package:flutter/material.dart';
import '../models/tarefa.dart';
import '../services/firebase_service.dart';
import '../utils/mensagens.dart';
import '../utils/validadores.dart';

class CadastroTarefaScreen extends StatefulWidget {
  const CadastroTarefaScreen({super.key, required this.firebase, this.tarefa});
  final FirebaseService firebase;
  final Tarefa? tarefa;
  @override
  State<CadastroTarefaScreen> createState() => _CadastroTarefaScreenState();
}

class _CadastroTarefaScreenState extends State<CadastroTarefaScreen> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _titulo;
  late final TextEditingController _descricao;
  late final TextEditingController _dataTexto;
  DateTime? _data;
  Prioridade _prioridade = Prioridade.media;
  bool _concluida = false;
  bool _salvando = false;
  String? _erro;

  @override
  void initState() {
    super.initState();
    final tarefa = widget.tarefa;
    _titulo = TextEditingController(text: tarefa?.titulo ?? '');
    _descricao = TextEditingController(text: tarefa?.descricao ?? '');
    _dataTexto = TextEditingController(text: tarefa?.dataFormatada ?? '');
    _data = tarefa?.dataVencimento;
    _prioridade = tarefa?.prioridade ?? Prioridade.media;
    _concluida = tarefa?.concluida ?? false;
  }

  @override
  void dispose() {
    _titulo.dispose();
    _descricao.dispose();
    _dataTexto.dispose();
    super.dispose();
  }

  Future<void> _selecionarData() async {
    final data = await showDatePicker(
        context: context,
        initialDate: _data ?? DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100, 12, 31));
    if (data != null && mounted) {
      setState(() {
        _data = data;
        _dataTexto.text =
            '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
      });
    }
  }

  Future<void> _salvar() async {
    if (_salvando || !_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _salvando = true;
      _erro = null;
    });
    final tarefa = Tarefa(
        id: widget.tarefa?.id ?? '',
        titulo: _titulo.text.trim(),
        descricao: _descricao.text.trim(),
        dataVencimento: _data!,
        prioridade: _prioridade,
        concluida: _concluida);
    try {
      await widget.firebase.salvar(tarefa);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Tarefa salva.')));
        Navigator.pop(context);
      }
    } catch (erro) {
      if (mounted) setState(() => _erro = mensagemErro(erro));
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: !_salvando,
        child: Scaffold(
          appBar: AppBar(
              title: Text(
                  widget.tarefa == null ? 'Nova tarefa' : 'Editar tarefa')),
          body: Form(
            key: _form,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                TextFormField(
                    controller: _titulo,
                    enabled: !_salvando,
                    maxLength: 100,
                    decoration: const InputDecoration(labelText: 'Título'),
                    textCapitalization: TextCapitalization.sentences,
                    validator: Validadores.titulo),
                const SizedBox(height: 12),
                TextFormField(
                    controller: _descricao,
                    enabled: !_salvando,
                    maxLength: 2000,
                    maxLines: 4,
                    decoration: const InputDecoration(
                        labelText: 'Descrição', alignLabelWithHint: true),
                    textCapitalization: TextCapitalization.sentences,
                    validator: (valor) => (valor?.length ?? 0) > 2000
                        ? 'Use até 2000 caracteres.'
                        : null),
                const SizedBox(height: 12),
                TextFormField(
                    controller: _dataTexto,
                    enabled: !_salvando,
                    readOnly: true,
                    onTap: _selecionarData,
                    decoration: const InputDecoration(
                        labelText: 'Data de vencimento',
                        suffixIcon: Icon(Icons.calendar_today_outlined)),
                    validator: (_) => _data == null
                        ? 'Selecione a data de vencimento.'
                        : null),
                const SizedBox(height: 20),
                DropdownButtonFormField<Prioridade>(
                    initialValue: _prioridade,
                    decoration: const InputDecoration(labelText: 'Prioridade'),
                    items: Prioridade.values
                        .map((p) =>
                            DropdownMenuItem(value: p, child: Text(p.rotulo)))
                        .toList(),
                    onChanged: _salvando
                        ? null
                        : (valor) => setState(() => _prioridade = valor!)),
                const SizedBox(height: 20),
                DropdownButtonFormField<bool>(
                    initialValue: _concluida,
                    decoration: const InputDecoration(labelText: 'Situação'),
                    items: const [
                      DropdownMenuItem(value: false, child: Text('Pendente')),
                      DropdownMenuItem(value: true, child: Text('Concluída'))
                    ],
                    onChanged: _salvando
                        ? null
                        : (valor) => setState(() => _concluida = valor!)),
                if (_erro != null)
                  Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(_erro!,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error))),
                const SizedBox(height: 28),
                FilledButton.icon(
                    onPressed: _salvando ? null : _salvar,
                    icon: const Icon(Icons.save_outlined),
                    label: Text(_salvando ? 'Salvando...' : 'Salvar tarefa')),
              ],
            ),
          ),
        ),
      );
}
