import 'package:firebase_core/firebase_core.dart' show Firebase;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'firebase_options.dart';
import 'models/usuario.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';
import 'services/firebase_service.dart';
import 'services/preferences_service.dart';
import 'themes/app_theme.dart';
import 'screens/abertura_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const InicializacaoApp());
}

class InicializacaoApp extends StatefulWidget {
  const InicializacaoApp({super.key});

  @override
  State<InicializacaoApp> createState() => _InicializacaoAppState();
}

class _InicializacaoAppState extends State<InicializacaoApp> {
  PreferencesService? _preferencias;
  bool _pronto = false;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _iniciar();
  }

  Future<void> _iniciar() async {
    setState(() => _erro = null);
    final tempoMinimo = Future<void>.delayed(const Duration(milliseconds: 850));
    try {
      final preferencias = _preferencias ?? PreferencesService();
      await preferencias.carregar();
      if (!mounted) return;
      setState(() => _preferencias = preferencias);
      await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform);
      await tempoMinimo;
      if (mounted) setState(() => _pronto = true);
    } catch (_) {
      if (mounted) {
        setState(() =>
            _erro = 'Não foi possível iniciar o aplicativo. Tente novamente.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final preferencias = _preferencias;
    if (_pronto && preferencias != null) {
      return MinhasTarefasApp(preferencias: preferencias, auth: AuthService());
    }
    return MaterialApp(
      title: 'Minhas Tarefas',
      debugShowCheckedModeBanner: false,
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: preferencias?.themeMode ?? ThemeMode.light,
      home: AberturaScreen(erro: _erro, onTentarNovamente: _iniciar),
    );
  }
}

class MinhasTarefasApp extends StatelessWidget {
  const MinhasTarefasApp(
      {super.key,
      required this.preferencias,
      required this.auth,
      this.firebaseFactory});
  final PreferencesService preferencias;
  final AuthService auth;
  final FirebaseService Function(String uid)? firebaseFactory;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: preferencias,
      builder: (context, _) => MaterialApp(
        title: 'Minhas tarefas',
        debugShowCheckedModeBanner: false,
        locale: const Locale('pt', 'BR'),
        supportedLocales: const [Locale('pt', 'BR')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: preferencias.themeMode,
        home: StreamBuilder<Usuario?>(
          stream: auth.usuarioChanges,
          initialData: auth.usuarioAtual,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return const AberturaScreen();
            }
            if (snapshot.hasError) {
              return const Scaffold(
                  body: Center(
                      child: Text(
                          'Não foi possível recuperar a sessão. Reinicie o aplicativo.')));
            }
            final usuario = snapshot.data;
            if (usuario == null) return LoginScreen(auth: auth);
            return HomeScreen(
                key: ValueKey(usuario.uid),
                usuario: usuario,
                auth: auth,
                preferencias: preferencias,
                firebase: firebaseFactory?.call(usuario.uid));
          },
        ),
      ),
    );
  }
}
