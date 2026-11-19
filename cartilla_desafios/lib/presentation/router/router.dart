import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/firebase_status.dart';
import '../../domain/entities/post.dart';
import '../screens/asistencia_screens.dart';
import '../screens/auth_screens.dart';
import '../screens/cloud_tasks_screen.dart';
import '../screens/escanear_screen.dart';
import '../screens/inicio_screen.dart';
import '../screens/local_tasks_screen.dart';
import '../screens/perfil_screen.dart';
import '../screens/post_detail_screen.dart';
import '../screens/posts_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/tareas_screen.dart';
import '../widgets/app_shell.dart';

final _rootKey = GlobalKey<NavigatorState>();
final _shellKey = GlobalKey<NavigatorState>();

// Desafío 4C — GoRouter con redirección y ShellRoute
final router = GoRouter(
  navigatorKey: _rootKey,
  initialLocation: '/',
  refreshListenable: authState,
  redirect: (context, state) {
    final loc = state.matchedLocation;
    final enAuth = loc == '/login' || loc == '/register';
    if (!authState.loggedIn) return enAuth ? null : '/login'; // sin sesión → /login
    if (enAuth) return '/'; // con sesión no tiene sentido ver el login
    return null;
  },
  routes: [
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),

    // Pantalla completa (sin NavigationBar)
    GoRoute(
      path: '/escanear',
      parentNavigatorKey: _rootKey,
      builder: (_, __) => const EscanearScreen(),
    ),

    ShellRoute(
      navigatorKey: _shellKey,
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(path: '/', builder: (_, __) => const InicioScreen()),
        GoRoute(path: '/tareas', builder: (_, __) => const TareasScreen()),
        GoRoute(
          path: '/posts',
          // EXTRA: /posts?search=flutter
          builder: (_, state) =>
              PostsScreen(initialSearch: state.uri.queryParameters['search']),
          routes: [
            GoRoute(
              path: ':id', // ruta completa: /posts/:id
              builder: (_, state) => PostDetailScreen(
                id: int.parse(state.pathParameters['id']!),
                post: state.extra as Post?,
              ),
            ),
          ],
        ),
        GoRoute(path: '/asistencia', builder: (_, __) => const AsistenciaScreen()),
        GoRoute(path: '/perfil', builder: (_, __) => const PerfilScreen()),
        GoRoute(path: '/tareas-local', builder: (_, __) => const LocalTasksScreen()),
        GoRoute(path: '/tareas-nube', builder: (_, __) => const CloudTasksScreen()),
        GoRoute(path: '/historial', builder: (_, __) => const HistorialScreen()),
        GoRoute(path: '/config', builder: (_, __) => const SettingsScreen()),
      ],
    ),
  ],
);
