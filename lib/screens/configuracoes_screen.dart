import 'package:flutter/material.dart';
import '../services/preferences_service.dart';

class ConfiguracoesScreen extends StatefulWidget {
  const ConfiguracoesScreen({super.key, required this.preferencias});
  final PreferencesService preferencias;
  @override
  State<ConfiguracoesScreen> createState() => _ConfiguracoesScreenState();
}

class _ConfiguracoesScreenState extends State<ConfiguracoesScreen> {
  bool _salvando = false;
  Future<void> _alterar(bool valor) async {
    setState(() => _salvando = true);
    try {
      await widget.preferencias.alterarTema(valor);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Não foi possível salvar o tema. Tente novamente.')));
      }
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: widget.preferencias,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('Aparência', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Card(
                child: SwitchListTile(
                    secondary: const Icon(Icons.dark_mode_outlined),
                    title: const Text('Tema escuro'),
                    subtitle: const Text('Aplicar em todas as telas'),
                    value: widget.preferencias.escuro,
                    onChanged: _salvando ? null : _alterar)),
            const SizedBox(height: 16),
            const Text(
                'Sua escolha fica salva neste aparelho e será mantida quando você abrir o aplicativo novamente.'),
          ],
        ),
      );
}
