import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minhas_tarefas/main.dart';
import 'package:minhas_tarefas/services/preferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'apoio.dart';

void main() {
  late AuthTeste auth;
  late FirebaseTeste banco;
  late PreferencesService preferencias;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    auth = AuthTeste();
    banco = FirebaseTeste('aluno');
    preferencias = PreferencesService();
    await preferencias.carregar();
  });
  tearDown(() {
    auth.fechar();
    banco.fechar();
  });

  Future<void> iniciar(WidgetTester tester) async {
    tester.view.physicalSize = const Size(440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MinhasTarefasApp(
        preferencias: preferencias, auth: auth, firebaseFactory: (_) => banco));
    await tester.pumpAndSettle();
  }

  Future<void> menu(WidgetTester tester, String opcao) async {
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.text(opcao).last);
    await tester.pumpAndSettle();
  }

  testWidgets('Login valida os campos e mostra erro de autenticação',
      (tester) async {
    await iniciar(tester);
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();
    expect(find.text('Informe seu e-mail.'), findsOneWidget);
    expect(find.text('Informe sua senha.'), findsOneWidget);
    await tester.enterText(
        find.byType(TextFormField).at(0), 'aluno@exemplo.com');
    await tester.enterText(find.byType(TextFormField).at(1), '123456');
    auth.falhar = true;
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();
    expect(find.text('E-mail ou senha incorretos.'), findsOneWidget);
    expect(auth.usuario, isNull);
  });

  testWidgets('Cadastro, CRUD, tema, logout e novo login', (tester) async {
    await iniciar(tester);
    await tester.tap(find.text('Criar uma conta'));
    await tester.pumpAndSettle();
    final campos = find.byType(TextFormField);
    await tester.enterText(campos.at(0), 'Estudante');
    await tester.enterText(campos.at(1), 'aluno@exemplo.com');
    await tester.enterText(campos.at(2), '123456');
    await tester.enterText(campos.at(3), 'outra');
    await tester.tap(find.text('Cadastrar'));
    await tester.pumpAndSettle();
    expect(find.text('As senhas não coincidem.'), findsOneWidget);
    await tester.enterText(campos.at(3), '123456');
    await tester.tap(find.text('Cadastrar'));
    await tester.pumpAndSettle();
    expect(find.text('Olá, Estudante!'), findsOneWidget);

    for (final titulo in ['Estudar Flutter', 'Entregar atividade']) {
      await tester.tap(find.text('Nova tarefa'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Salvar tarefa'));
      await tester.pumpAndSettle();
      expect(find.text('Informe o título da tarefa.'), findsOneWidget);
      expect(find.text('Selecione a data de vencimento.'), findsOneWidget);
      await tester.enterText(find.byType(TextFormField).at(0), titulo);
      await tester.enterText(
          find.byType(TextFormField).at(1), 'Descrição da tarefa');
      await tester.tap(find.byType(TextFormField).at(2));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Salvar tarefa'));
      await tester.pumpAndSettle();
    }
    expect(banco.tarefas.length, 2);
    await tester.tap(find.text('Ver minhas tarefas'));
    await tester.pumpAndSettle();
    expect(find.text('Estudar Flutter'), findsOneWidget);
    expect(find.text('Entregar atividade'), findsOneWidget);
    await tester.tap(find.text('Estudar Flutter'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Editar tarefa'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'Revisar Flutter');
    await tester.tap(find.text('Salvar tarefa'));
    await tester.pumpAndSettle();
    expect(find.text('Revisar Flutter'), findsOneWidget);
    await tester.tap(find.text('Marcar como concluída'));
    await tester.pumpAndSettle();
    expect(banco.tarefas.first.concluida, isTrue);
    await tester.tap(find.text('Marcar como pendente'));
    await tester.pumpAndSettle();
    expect(banco.tarefas.first.concluida, isFalse);
    await tester.tap(find.text('Excluir tarefa'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(banco.tarefas.length, 2);
    await tester.tap(find.text('Excluir tarefa'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Excluir'));
    await tester.pumpAndSettle();
    expect(banco.tarefas.length, 1);
    expect(find.text('Revisar Flutter'), findsNothing);
    await menu(tester, 'Configurações');
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(preferencias.escuro, isTrue);
    expect(Theme.of(tester.element(find.text('Aparência'))).brightness,
        Brightness.dark);
    await menu(tester, 'Sair');
    expect(find.text('Entrar'), findsOneWidget);
    expect(Theme.of(tester.element(find.text('Entrar'))).brightness,
        Brightness.dark);
    await tester.enterText(
        find.byType(TextFormField).at(0), 'aluno@exemplo.com');
    await tester.enterText(find.byType(TextFormField).at(1), '123456');
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();
    expect(find.text('Olá, Estudante!'), findsOneWidget);
    expect(banco.tarefas.single.titulo, 'Entregar atividade');
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'Listagem acompanha atualização recebida e erro de gravação preserva formulário',
      (tester) async {
    await auth.entrar('aluno@exemplo.com', '123456');
    await iniciar(tester);
    await tester.tap(find.text('Ver minhas tarefas'));
    await tester.pumpAndSettle();
    expect(find.text('Nenhuma tarefa cadastrada.'), findsOneWidget);
    await banco.salvar(tarefasExemplo.first);
    await tester.pumpAndSettle();
    expect(find.text('Estudar Flutter'), findsOneWidget);
    await tester.tap(find.text('Estudar Flutter'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Editar tarefa'));
    await tester.pumpAndSettle();
    banco.falhar = true;
    await tester.enterText(
        find.byType(TextFormField).at(0), 'Título preservado');
    await tester.tap(find.text('Salvar tarefa'));
    await tester.pumpAndSettle();
    expect(find.text('Título preservado'), findsOneWidget);
    expect(
        find.text(
            'Não foi possível acessar seus dados. Confira as regras do banco.'),
        findsOneWidget);
    expect(banco.tarefas.single.titulo, 'Estudar Flutter');
  });
}
