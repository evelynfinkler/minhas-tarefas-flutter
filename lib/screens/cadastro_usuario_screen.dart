import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/mensagens.dart';
import '../utils/validadores.dart';
import '../widgets/app_logo.dart';

class CadastroUsuarioScreen extends StatefulWidget {
  const CadastroUsuarioScreen({super.key, required this.auth});
  final AuthService auth;
  @override
  State<CadastroUsuarioScreen> createState() => _CadastroUsuarioScreenState();
}

class _CadastroUsuarioScreenState extends State<CadastroUsuarioScreen> {
  final _form = GlobalKey<FormState>();
  final _nome = TextEditingController();
  final _email = TextEditingController();
  final _senha = TextEditingController();
  final _confirmacao = TextEditingController();
  bool _carregando = false;
  bool _ocultar = true;
  String? _erro;

  @override
  void dispose() {
    for (final controller in [_nome, _email, _senha, _confirmacao]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _cadastrar() async {
    if (_carregando || !_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      await widget.auth.cadastrar(_nome.text, _email.text, _senha.text);
      if (mounted) Navigator.pop(context);
    } catch (erro) {
      if (mounted) setState(() => _erro = mensagemErro(erro));
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_carregando,
      child: Scaffold(
        appBar: AppBar(title: const Text('Criar conta')),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(child: AppLogo(size: 104, radius: 18)),
                    const SizedBox(height: 24),
                    Text('Vamos começar',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('Crie sua conta para organizar suas tarefas.'),
                    const SizedBox(height: 28),
                    TextFormField(
                        controller: _nome,
                        enabled: !_carregando,
                        maxLength: 80,
                        decoration: const InputDecoration(
                            labelText: 'Nome',
                            prefixIcon: Icon(Icons.person_outline),
                            counterText: ''),
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        validator: Validadores.nome),
                    const SizedBox(height: 16),
                    TextFormField(
                        controller: _email,
                        enabled: !_carregando,
                        decoration: const InputDecoration(
                            labelText: 'E-mail',
                            prefixIcon: Icon(Icons.mail_outline)),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: Validadores.email),
                    const SizedBox(height: 16),
                    TextFormField(
                        controller: _senha,
                        enabled: !_carregando,
                        obscureText: _ocultar,
                        validator: Validadores.novaSenha,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                            labelText: 'Senha',
                            helperText: 'Pelo menos 6 caracteres',
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
                    const SizedBox(height: 16),
                    TextFormField(
                        controller: _confirmacao,
                        enabled: !_carregando,
                        obscureText: _ocultar,
                        decoration: const InputDecoration(
                            labelText: 'Confirmar senha',
                            prefixIcon: Icon(Icons.lock_outline)),
                        onFieldSubmitted: (_) => _cadastrar(),
                        validator: (valor) => valor == null || valor.isEmpty
                            ? 'Confirme sua senha.'
                            : valor != _senha.text
                                ? 'As senhas não coincidem.'
                                : null),
                    if (_erro != null)
                      Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Text(_erro!,
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.error))),
                    const SizedBox(height: 24),
                    FilledButton(
                        onPressed: _carregando ? null : _cadastrar,
                        child:
                            Text(_carregando ? 'Cadastrando...' : 'Cadastrar')),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
