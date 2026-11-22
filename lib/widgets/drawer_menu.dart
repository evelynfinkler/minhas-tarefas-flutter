import 'package:flutter/material.dart';
import '../models/usuario.dart';
import 'app_logo.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu(
      {super.key,
      required this.usuario,
      required this.pagina,
      required this.onSelecionar,
      required this.onSair});
  final Usuario usuario;
  final int pagina;
  final ValueChanged<int> onSelecionar;
  final VoidCallback onSair;

  @override
  Widget build(BuildContext context) {
    const opcoes = [
      'Início',
      'Minhas tarefas',
      'Configurações',
      'Sobre o aplicativo'
    ];
    const icones = [
      Icons.home_outlined,
      Icons.checklist,
      Icons.settings_outlined,
      Icons.info_outline
    ];
    final cores = Theme.of(context).colorScheme;
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              margin: EdgeInsets.zero,
              decoration: BoxDecoration(color: cores.primaryContainer),
              accountName: Text(usuario.nome,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: cores.onPrimaryContainer,
                      fontWeight: FontWeight.bold)),
              accountEmail: Text(usuario.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: cores.onPrimaryContainer)),
              currentAccountPicture: const AppLogo(size: 72, radius: 14),
            ),
            const SizedBox(height: 12),
            for (var i = 0; i < opcoes.length; i++)
              ListTile(
                  selected: pagina == i,
                  leading: Icon(icones[i]),
                  title: Text(opcoes[i]),
                  onTap: () {
                    Navigator.pop(context);
                    onSelecionar(i);
                  }),
            const Divider(),
            ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Sair'),
                onTap: () {
                  Navigator.pop(context);
                  onSair();
                }),
          ],
        ),
      ),
    );
  }
}
