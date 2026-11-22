import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 160, this.radius = 24});

  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) => Semantics(
        image: true,
        label: 'Minhas Tarefas. Agendamento e Gestão de Tarefas.',
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: Image.asset(
            'assets/images/logo.png',
            width: size,
            height: size,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.medium,
            excludeFromSemantics: true,
          ),
        ),
      );
}
