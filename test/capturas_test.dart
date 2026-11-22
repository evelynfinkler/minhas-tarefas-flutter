import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minhas_tarefas/main.dart';
import 'package:minhas_tarefas/services/preferences_service.dart';
import 'package:minhas_tarefas/screens/abertura_screen.dart';
import 'package:minhas_tarefas/themes/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'apoio.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Capturas das telas com dados locais de teste', (tester) async {
    final sombrasAnteriores = debugDisableShadows;
    debugDisableShadows = false;
    try {
      final fonte = FontLoader('Roboto');
      fonte.addFont(Future.value(ByteData.sublistView(
          File('test/fontes/roboto-regular.ttf').readAsBytesSync())));
      await fonte.load();
      final fonteNegrito = FontLoader('Roboto');
      fonteNegrito.addFont(Future.value(ByteData.sublistView(
          File('test/fontes/roboto-bold.ttf').readAsBytesSync())));
      await fonteNegrito.load();
      final icones = FontLoader('MaterialIcons');
      icones.addFont(Future.value(ByteData.sublistView(
          File('test/fontes/materialicons-regular.otf').readAsBytesSync())));
      await icones.load();
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      SharedPreferences.setMockInitialValues({});
      final preferencias = PreferencesService();
      await preferencias.carregar();
      final auth = AuthTeste();
      final banco = FirebaseTeste('aluno', tarefasExemplo);
      final capturaKey = GlobalKey();
      await tester.pumpWidget(RepaintBoundary(
          key: capturaKey,
          child: MinhasTarefasApp(
              preferencias: preferencias,
              auth: auth,
              firebaseFactory: (_) => banco)));
      await tester.pumpAndSettle();
      await tester.runAsync(() => precacheImage(
          const AssetImage('assets/images/logo.png'),
          tester.element(find.byType(MinhasTarefasApp))));
      await tester.pumpAndSettle();

      Future<void> capturar(String nome, {bool animacao = false}) async {
        if (animacao) {
          await tester.pump(const Duration(milliseconds: 200));
        } else {
          await tester.pumpAndSettle();
        }
        final boundary = capturaKey.currentContext!.findRenderObject()
            as RenderRepaintBoundary;
        await tester.runAsync(() async {
          final imagem = await boundary.toImage(pixelRatio: 2);
          final dados = await imagem.toByteData(format: ui.ImageByteFormat.png);
          final pasta = Directory('capturas');
          await pasta.create(recursive: true);
          await File('${pasta.path}/$nome.png')
              .writeAsBytes(dados!.buffer.asUint8List());
          imagem.dispose();
        });
      }

      Future<void> menu(String opcao) async {
        await tester.tap(find.byType(BackButton).evaluate().isEmpty
            ? find.byIcon(Icons.menu)
            : find.byType(BackButton));
        await tester.pumpAndSettle();
        await tester.tap(find.text(opcao).last);
        await tester.pumpAndSettle();
      }

      await capturar('01_login');
      await tester.tap(find.text('Criar uma conta'));
      await tester.pumpAndSettle();
      await capturar('02_cadastro_usuario');
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      await auth.entrar('estudante@exemplo.com', '123456');
      await tester.pumpAndSettle();
      await capturar('03_inicio');
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await capturar('04_menu');
      await tester.tap(find.text('Minhas tarefas').last);
      await tester.pumpAndSettle();
      await capturar('05_tarefas');
      await tester.tap(find.text('Estudar Flutter'));
      await tester.pumpAndSettle();
      await capturar('06_detalhes');
      await tester.tap(find.text('Editar tarefa'));
      await tester.pumpAndSettle();
      await capturar('07_edicao');
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Excluir tarefa'));
      await tester.pumpAndSettle();
      await capturar('08_confirmacao_exclusao');
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      await menu('Configurações');
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      await capturar('09_configuracoes_escuro');
      await menu('Minhas tarefas');
      await capturar('10_tarefas_escuro');
      await menu('Sair');
      await capturar('11_login_escuro');
      await tester.pumpWidget(RepaintBoundary(
        key: capturaKey,
        child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            home: const AberturaScreen()),
      ));
      await capturar('12_abertura', animacao: true);
      await tester.pumpWidget(RepaintBoundary(
        key: capturaKey,
        child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.darkTheme,
            home: const AberturaScreen()),
      ));
      await capturar('13_abertura_escuro', animacao: true);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await auth.fechar();
      await banco.fechar();
    } finally {
      debugDisableShadows = sombrasAnteriores;
    }
  });
}
