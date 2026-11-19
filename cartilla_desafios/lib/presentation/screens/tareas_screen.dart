import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/tasks_provider.dart';
import '../widgets/app_shell.dart';

class TareasScreen extends ConsumerStatefulWidget {
  const TareasScreen({super.key});

  @override
  ConsumerState<TareasScreen> createState() => _TareasScreenState();
}

class _TareasScreenState extends ConsumerState<TareasScreen> {
  final _ctrl = TextEditingController();
  Prioridad _prioridad = Prioridad.media;

  static const _colores = {
    Prioridad.alta: Colors.red,
    Prioridad.media: Colors.orange,
    Prioridad.baja: Colors.green,
  };

  void _agregar() {
    final texto = _ctrl.text.trim();
    if (texto.isEmpty) return;
    ref.read(tasksProvider.notifier).agregar(texto, _prioridad);
    _ctrl.clear();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tareas = ref.watch(tasksProvider).tareas;
    return Scaffold(
      appBar: AppBar(leading: const MenuButton(), title: const Text('Tareas')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    decoration: const InputDecoration(
                      labelText: 'Nueva tarea',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _agregar(),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<Prioridad>(
                  value: _prioridad,
                  onChanged: (v) => setState(() => _prioridad = v!),
                  items: [
                    for (final p in Prioridad.values)
                      DropdownMenuItem(value: p, child: Text(p.name)),
                  ],
                ),
                IconButton.filled(onPressed: _agregar, icon: const Icon(Icons.add)),
              ],
            ),
          ),
          Expanded(
            child: tareas.isEmpty
                ? const Center(child: Text('No hay tareas todavía'))
                : ListView.builder(
                    itemCount: tareas.length,
                    itemBuilder: (_, i) {
                      final t = tareas[i];
                      return ListTile(
                        leading: Checkbox(
                          value: t.completada,
                          onChanged: (_) => ref
                              .read(tasksProvider.notifier)
                              .toggleCompletada(t.id),
                        ),
                        title: Text(
                          t.titulo,
                          style: TextStyle(
                            decoration:
                                t.completada ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        subtitle: Text('Prioridad ${t.prioridad.name}',
                            style: TextStyle(color: _colores[t.prioridad])),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () =>
                              ref.read(tasksProvider.notifier).eliminar(t.id),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
