import 'package:flutter/material.dart';
import '../widgets/app_logo.dart';

class AberturaScreen extends StatelessWidget {
  const AberturaScreen({super.key, this.erro, this.onTentarNovamente});

  final String? erro;
  final VoidCallback? onTentarNovamente;

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              cores.primaryContainer,
              Theme.of(context).scaffoldBackgroundColor
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const AppLogo(size: 260, radius: 36),
                    const SizedBox(height: 28),
                    Text('Sua rotina, do seu jeito.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                                color: cores.onSurface,
                                fontWeight: FontWeight.w600)),
                    const SizedBox(height: 28),
                    if (erro == null) ...[
                      const SizedBox(
                          width: 150,
                          child: LinearProgressIndicator(minHeight: 4)),
                      const SizedBox(height: 16),
                      Text('Preparando suas tarefas...',
                          style: TextStyle(color: cores.onSurfaceVariant)),
                    ] else ...[
                      Text(erro!,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: cores.error)),
                      const SizedBox(height: 20),
                      FilledButton.icon(
                        onPressed: onTentarNovamente,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Tentar novamente'),
                      ),
                    ],
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
