import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/tasks_provider.dart';
import '../widgets/app_shell.dart';

class InicioScreen extends ConsumerWidget {
  const InicioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendientes = ref.watch(tasksProvider).pendientes;
    return Scaffold(
      appBar: AppBar(leading: const MenuButton(), title: const Text('Inicio')),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(24),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.pending_actions, size: 56),
                const SizedBox(height: 12),
                Text('$pendientes',
                    style: Theme.of(context).textTheme.displayLarge),
                const Text('tareas pendientes'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
