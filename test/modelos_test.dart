import 'package:flutter_test/flutter_test.dart';
import 'package:minhas_tarefas/models/tarefa.dart';
import 'package:minhas_tarefas/services/preferences_service.dart';
import 'package:minhas_tarefas/utils/validadores.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('Tarefa mantém campos e data no armazenamento', () {
    final tarefa = Tarefa(
        id: 't1',
        titulo: 'Estudar Flutter',
        descricao: 'Revisar os widgets',
        dataVencimento: DateTime(2026, 11, 25),
        prioridade: Prioridade.alta,
        concluida: false);
    final recuperada = Tarefa.fromMap(tarefa.id, tarefa.toMap());
    expect(recuperada.id, 't1');
    expect(recuperada.titulo, tarefa.titulo);
    expect(recuperada.descricao, tarefa.descricao);
    expect(recuperada.dataFormatada, '25/11/2026');
    expect(recuperada.dataVencimento.isUtc, isTrue);
    expect(recuperada.prioridade, Prioridade.alta);
    expect(recuperada.concluida, isFalse);
    expect(recuperada.copyWith(concluida: true).concluida, isTrue);
    expect(recuperada.concluida, isFalse);
  });

  test('Data civil não depende do fuso na serialização', () {
    final tarefa = Tarefa(
        id: 't2',
        titulo: 'Entrega',
        descricao: '',
        dataVencimento: DateTime.utc(2026, 1, 1),
        prioridade: Prioridade.baixa,
        concluida: true);
    final recuperada = Tarefa.fromMap(tarefa.id, tarefa.toMap());
    expect(recuperada.dataFormatada, '01/01/2026');
    expect(() => Tarefa.fromMap('t3', {'dataVencimento': 'invalida'}),
        throwsFormatException);
  });

  test('Validação de campos obrigatórios', () {
    expect(Validadores.nome('  '), isNotNull);
    expect(Validadores.email('email@'), isNotNull);
    expect(Validadores.email(' aluno@exemplo.com '), isNull);
    expect(Validadores.senha(''), isNotNull);
    expect(Validadores.novaSenha('12345'), isNotNull);
    expect(Validadores.novaSenha('123456'), isNull);
    expect(Validadores.titulo(' '), isNotNull);
    expect(Validadores.titulo('a' * 101), isNotNull);
  });

  test('Preferência de tema é recuperada em uma nova instância', () async {
    SharedPreferences.setMockInitialValues({});
    final preferencias = PreferencesService();
    await preferencias.carregar();
    expect(preferencias.escuro, isFalse);
    await preferencias.alterarTema(true);
    final reabertura = PreferencesService();
    await reabertura.carregar();
    expect(reabertura.escuro, isTrue);
    await reabertura.alterarTema(false);
    final novaReabertura = PreferencesService();
    await novaReabertura.carregar();
    expect(novaReabertura.escuro, isFalse);
  });
}
