import 'package:flutter/material.dart';

import '../../data/services/local_database.dart';
import '../../domain/entities/tarea_db.dart';
import '../widgets/app_shell.dart';

enum _Filtro { todas, pendientes, completadas }

class LocalTasksScreen extends StatefulWidget {
  const LocalTasksScreen({super.key});

  @override
  State<LocalTasksScreen> createState() => _LocalTasksScreenState();
}

class _LocalTasksScreenState extends State<LocalTasksScreen> {
  final _db = LocalDatabase.instance;
  final _ctrl = TextEditingController();
  List<TareaDb> _tareas = [];
  _Filtro _filtro = _Filtro.todas;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    final datos = await _db.obtenerTodas();
    if (!mounted) return;
    setState(() {
      _tareas = datos;
      _cargando = false;
    });
  }

  Future<void> _agregar() async {
    final texto = _ctrl.text.trim();
    if (texto.isEmpty) return;
    await _db.insertar(TareaDb(titulo: texto));
    _ctrl.clear();
    await _cargar();
  }

  Future<void> _toggle(TareaDb t) async {
    await _db.actualizar(t.copyWith(completada: !t.completada));
    await _cargar();
  }

  Future<void> _eliminar(TareaDb t) async {
    await _db.eliminar(t.id!);
    await _cargar();
  }

  List<TareaDb> get _visibles => switch (_filtro) {
        _Filtro.todas => _tareas,
        _Filtro.pendientes => _tareas.where((t) => !t.completada).toList(),
        _Filtro.completadas => _tareas.where((t) => t.completada).toList(),
      };

  @override
  Widget build(BuildContext context) {
    final lista = _visibles;
    return Scaffold(
      appBar: AppBar(leading: const MenuButton(), title: const Text('Tareas SQLite')),
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
                        labelText: 'Nueva tarea', border: OutlineInputBorder()),
                    onSubmitted: (_) => _agregar(),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(onPressed: _agregar, child: const Text('Agregar')),
              ],
            ),
          ),
          // EXTRA: filtro pendientes / completadas
          SegmentedButton<_Filtro>(
            segments: const [
              ButtonSegment(value: _Filtro.todas, label: Text('Todas')),
              ButtonSegment(value: _Filtro.pendientes, label: Text('Pendientes')),
              ButtonSegment(value: _Filtro.completadas, label: Text('Hechas')),
            ],
            selected: {_filtro},
            onSelectionChanged: (s) => setState(() => _filtro = s.first),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _cargando
                ? const Center(child: CircularProgressIndicator())
                : lista.isEmpty
                    ? const Center(child: Text('Sin tareas'))
                    : ListView.builder(
                        itemCount: lista.length,
                        itemBuilder: (_, i) {
                          final t = lista[i];
                          return Dismissible(
                            key: ValueKey(t.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 16),
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (_) => _eliminar(t),
                            child: CheckboxListTile(
                              value: t.completada,
                              onChanged: (_) => _toggle(t),
                              title: Text(
                                t.titulo,
                                style: TextStyle(
                                  decoration: t.completada
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
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
