import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/mensagens.dart';
import '../utils/validadores.dart';
import 'cadastro_usuario_screen.dart';
import '../widgets/app_logo.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.auth});
  final AuthService auth;
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _senha = TextEditingController();
  bool _carregando = false;
  bool _ocultar = true;
  String? _erro;

  @override
  void dispose() {
    _email.dispose();
    _senha.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (_carregando || !_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      await widget.auth.entrar(_email.text, _senha.text);
    } catch (erro) {
      if (mounted) setState(() => _erro = mensagemErro(erro));
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: AutofillGroup(
                child: Form(
                  key: _form,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Center(child: AppLogo(size: 196, radius: 28)),
                      const SizedBox(height: 20),
                      Text('Bem-vindo!',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      const Text('Organize seu dia, uma tarefa de cada vez.',
                          textAlign: TextAlign.center),
                      const SizedBox(height: 28),
                      TextFormField(
                          controller: _email,
                          enabled: !_carregando,
                          decoration: const InputDecoration(
                              labelText: 'E-mail',
                              prefixIcon: Icon(Icons.mail_outline)),
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.email],
                          validator: Validadores.email),
                      const SizedBox(height: 16),
                      TextFormField(
                          controller: _senha,
                          enabled: !_carregando,
                          obscureText: _ocultar,
                          autofillHints: const [AutofillHints.password],
                          validator: Validadores.senha,
                          onFieldSubmitted: (_) => _entrar(),
                          decoration: InputDecoration(
                              labelText: 'Senha',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                  tooltip: _ocultar
                                      ? 'Mostrar senha'
                                      : 'Ocultar senha',
                                  onPressed: () =>
                                      setState(() => _ocultar = !_ocultar),
                                  icon: Icon(_ocultar
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined)))),
                      if (_erro != null)
                        Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Text(_erro!,
                                style: TextStyle(color: cores.error))),
                      const SizedBox(height: 24),
                      FilledButton(
                          onPressed: _carregando ? null : _entrar,
                          child: Text(_carregando ? 'Entrando...' : 'Entrar')),
                      const SizedBox(height: 12),
                      TextButton(
                          onPressed: _carregando
                              ? null
                              : () => Navigator.push(
                                  context,
                                  MaterialPageRoute<void>(
                                      builder: (_) => CadastroUsuarioScreen(
                                          auth: widget.auth))),
                          child: const Text('Criar uma conta')),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
