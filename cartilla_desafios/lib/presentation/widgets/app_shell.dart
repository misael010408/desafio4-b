import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/firebase_status.dart';

/// Key del Scaffold del shell: las pantallas hijas la usan para abrir el Drawer.
final shellScaffoldKey = GlobalKey<ScaffoldState>();

class MenuButton extends StatelessWidget {
  const MenuButton({super.key});

  @override
  Widget build(BuildContext context) => IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () => shellScaffoldKey.currentState?.openDrawer(),
      );
}

class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  static const _tabs = ['/', '/tareas', '/posts', '/asistencia', '/perfil'];

  int _indice(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    for (var i = 1; i < _tabs.length; i++) {
      if (path == _tabs[i] || path.startsWith('${_tabs[i]}/')) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final user = authState.user;
    final nombre = user?.displayName ?? user?.email ?? 'Alumno';

    return Scaffold(
      key: shellScaffoldKey,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(nombre),
              accountEmail: Text(user?.email ?? 'Modo local'),
              currentAccountPicture: const CircleAvatar(
                backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=12'),
                child: Icon(Icons.person),
              ),
            ),
            _item(context, Icons.home, 'Inicio', '/'),
            _item(context, Icons.checklist, 'Tareas (Riverpod)', '/tareas'),
            _item(context, Icons.storage, 'Tareas SQLite', '/tareas-local'),
            _item(context, Icons.cloud, 'Tareas en la nube', '/tareas-nube'),
            _item(context, Icons.history, 'Historial asistencias', '/historial'),
            _item(context, Icons.settings, 'Configuración', '/config'),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar sesión'),
              onTap: () async {
                Navigator.of(context).pop();
                await authState.cerrarSesion(); // el redirect lleva a /login
              },
            ),
          ],
        ),
      ),
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indice(context),
        onDestinationSelected: (i) => context.go(_tabs[i]),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Inicio'),
          NavigationDestination(icon: Icon(Icons.checklist), label: 'Tareas'),
          NavigationDestination(icon: Icon(Icons.article_outlined), selectedIcon: Icon(Icons.article), label: 'Posts'),
          NavigationDestination(icon: Icon(Icons.qr_code_scanner), label: 'Asistencia'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }

  Widget _item(BuildContext context, IconData icono, String texto, String ruta) =>
      ListTile(
        leading: Icon(icono),
        title: Text(texto),
        onTap: () {
          Navigator.of(context).pop(); // cierra el drawer
          context.go(ruta);
        },
      );
}
