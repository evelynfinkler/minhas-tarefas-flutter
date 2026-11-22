import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:minhas_tarefas/models/tarefa.dart';
import 'package:minhas_tarefas/models/usuario.dart';
import 'package:minhas_tarefas/services/auth_service.dart';
import 'package:minhas_tarefas/services/firebase_service.dart';

class AuthTeste extends AuthService {
  final _eventos = StreamController<Usuario?>.broadcast();
  Usuario? usuario;
  String? nomeCadastrado;
  String? emailLogin;
  bool falhar = false;

  @override
  Usuario? get usuarioAtual => usuario;
  @override
  Stream<Usuario?> get usuarioChanges async* {
    yield usuario;
    yield* _eventos.stream;
  }

  @override
  Future<void> entrar(String email, String senha) async {
    if (falhar) throw FirebaseAuthException(code: 'invalid-credential');
    emailLogin = email;
    usuario = Usuario(
        uid: 'aluno', nome: nomeCadastrado ?? 'Estudante', email: email.trim());
    _eventos.add(usuario);
  }

  @override
  Future<void> cadastrar(String nome, String email, String senha) async {
    nomeCadastrado = nome;
    await entrar(email, senha);
  }

  @override
  Future<void> sair() async {
    usuario = null;
    _eventos.add(null);
  }

  Future<void> fechar() => _eventos.close();
}

class FirebaseTeste extends FirebaseService {
  FirebaseTeste(super.uid, [List<Tarefa>? iniciais]) : tarefas = [...?iniciais];
  final List<Tarefa> tarefas;
  final _eventos = StreamController<List<Tarefa>>.broadcast();
  int _contador = 0;
  bool falhar = false;

  @override
  Stream<List<Tarefa>> observarTarefas() async* {
    yield List.of(tarefas);
    yield* _eventos.stream;
  }

  @override
  Future<void> salvar(Tarefa tarefa) async {
    if (falhar) {
      throw FirebaseException(
          plugin: 'firebase_database', code: 'permission-denied');
    }
    if (tarefa.id.isEmpty) {
      tarefas.add(Tarefa(
          id: 'nova-${++_contador}',
          titulo: tarefa.titulo,
          descricao: tarefa.descricao,
          dataVencimento: tarefa.dataVencimento,
          prioridade: tarefa.prioridade,
          concluida: tarefa.concluida));
    } else {
      final indice = tarefas.indexWhere((t) => t.id == tarefa.id);
      if (indice < 0) {
        tarefas.add(tarefa);
      } else {
        tarefas[indice] = tarefa;
      }
    }
    _eventos.add(List.of(tarefas));
  }

  @override
  Future<void> alterarSituacao(Tarefa tarefa) =>
      salvar(tarefa.copyWith(concluida: !tarefa.concluida));

  @override
  Future<void> excluir(Tarefa tarefa) async {
    tarefas.removeWhere((t) => t.id == tarefa.id);
    _eventos.add(List.of(tarefas));
  }

  Future<void> fechar() => _eventos.close();
}

final tarefasExemplo = [
  Tarefa(
      id: '1',
      titulo: 'Estudar Flutter',
      descricao: 'Revisar navegação, formulários e integração com o Firebase.',
      dataVencimento: DateTime(2026, 11, 25),
      prioridade: Prioridade.alta,
      concluida: false),
  Tarefa(
      id: '2',
      titulo: 'Organizar os materiais',
      descricao: 'Separar os arquivos usados na apresentação.',
      dataVencimento: DateTime(2026, 11, 26),
      prioridade: Prioridade.media,
      concluida: false),
  Tarefa(
      id: '3',
      titulo: 'Revisar a atividade',
      descricao: 'Conferir os requisitos do projeto.',
      dataVencimento: DateTime(2026, 11, 24),
      prioridade: Prioridade.baixa,
      concluida: true),
];
