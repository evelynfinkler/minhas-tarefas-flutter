import 'package:flutter/material.dart';
import '../models/tarefa.dart';
import '../models/usuario.dart';
import '../services/auth_service.dart';
import '../services/firebase_service.dart';
import '../services/preferences_service.dart';
import '../utils/mensagens.dart';
import '../widgets/drawer_menu.dart';
import '../widgets/app_logo.dart';
import 'cadastro_tarefa_screen.dart';
import 'configuracoes_screen.dart';
import 'tarefas_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen(
      {super.key,
      required this.usuario,
      required this.auth,
      required this.preferencias,
      this.firebase});
  final Usuario usuario;
  final AuthService auth;
  final PreferencesService preferencias;
  final FirebaseService? firebase;
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final FirebaseService _firebase;
  late Stream<List<Tarefa>> _tarefas;
  int _pagina = 0;
  bool _saindo = false;

  @override
  void initState() {
    super.initState();
    _firebase = widget.firebase ?? FirebaseService(widget.usuario.uid);
    _tarefas = _firebase.observarTarefas();
  }

  Future<void> _sair() async {
    if (_saindo) return;
    setState(() => _saindo = true);
    try {
      await widget.auth.sair();
    } catch (erro) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(mensagemErro(erro))));
      }
    } finally {
      if (mounted) setState(() => _saindo = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const titulos = [
      'Início',
      'Minhas tarefas',
      'Configurações',
      'Sobre o aplicativo'
    ];
    return Scaffold(
      appBar: AppBar(title: Text(titulos[_pagina]), actions: const [
        Padding(
            padding: EdgeInsets.only(right: 16),
            child: AppLogo(size: 38, radius: 9)),
      ]),
      drawer: DrawerMenu(
          usuario: widget.usuario,
          pagina: _pagina,
          onSelecionar: (valor) => setState(() => _pagina = valor),
          onSair: _sair),
      body: StreamBuilder<List<Tarefa>>(
        stream: _tarefas,
        builder: (context, snapshot) {
          if (_pagina == 2) {
            return ConfiguracoesScreen(preferencias: widget.preferencias);
          }
          if (_pagina == 3) return const _Sobre();
          if (snapshot.hasError) {
            return Center(
                child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.cloud_off, size: 48),
                      const SizedBox(height: 16),
                      Text(mensagemErro(snapshot.error!),
                          textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      FilledButton(
                          onPressed: () => setState(
                              () => _tarefas = _firebase.observarTarefas()),
                          child: const Text('Tentar novamente'))
                    ])));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final tarefas = snapshot.data!;
          if (_pagina == 1) {
            return TarefasScreen(tarefas: tarefas, firebase: _firebase);
          }
          final concluidas = tarefas.where((t) => t.concluida).length;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            children: [
              Text('Olá, ${widget.usuario.nome}!',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Veja como estão suas tarefas.'),
              const SizedBox(height: 24),
              _Resumo(
                  titulo: 'Cadastradas',
                  quantidade: tarefas.length,
                  icone: Icons.format_list_bulleted,
                  cor: Theme.of(context).colorScheme.primary),
              _Resumo(
                  titulo: 'Pendentes',
                  quantidade: tarefas.length - concluidas,
                  icone: Icons.schedule,
                  cor: Theme.of(context).brightness == Brightness.dark
                      ? Colors.amber.shade200
                      : Theme.of(context).colorScheme.secondary),
              _Resumo(
                  titulo: 'Concluídas',
                  quantidade: concluidas,
                  icone: Icons.task_alt,
                  cor: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 20),
              FilledButton.icon(
                  onPressed: () => setState(() => _pagina = 1),
                  icon: const Icon(Icons.checklist),
                  label: const Text('Ver minhas tarefas')),
              const SizedBox(height: 16),
              const Text('Use o botão abaixo para adicionar uma tarefa.',
                  textAlign: TextAlign.center),
            ],
          );
        },
      ),
      floatingActionButton: _pagina <= 1
          ? FloatingActionButton.extended(
              onPressed: _saindo
                  ? null
                  : () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                          builder: (_) =>
                              CadastroTarefaScreen(firebase: _firebase))),
              icon: const Icon(Icons.add),
              label: const Text('Nova tarefa'))
          : null,
    );
  }
}

class _Resumo extends StatelessWidget {
  const _Resumo(
      {required this.titulo,
      required this.quantidade,
      required this.icone,
      required this.cor});
  final String titulo;
  final int quantidade;
  final IconData icone;
  final Color cor;
  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(children: [
              Icon(icone, color: cor, size: 32),
              const SizedBox(width: 20),
              Expanded(
                  child: Text(titulo,
                      style: Theme.of(context).textTheme.titleMedium)),
              Text('$quantidade',
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(fontWeight: FontWeight.bold, color: cor))
            ])),
      );
}

class _Sobre extends StatelessWidget {
  const _Sobre();
  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Center(child: AppLogo(size: 160)),
          const SizedBox(height: 20),
          Text('Minhas tarefas',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          const Text('Versão 1.0.0', textAlign: TextAlign.center),
          const SizedBox(height: 28),
          const Text(
              'Aplicativo desenvolvido para a atividade prática de Programação Mobile. Permite cadastrar, editar, concluir e excluir tarefas pessoais.'),
          const SizedBox(height: 16),
          const Text(
              'Desenvolvido com Flutter e Dart. Utiliza Firebase Authentication, Firebase Realtime Database e SharedPreferences.'),
        ],
      );
}
