import 'package:flutter_riverpod/flutter_riverpod.dart';

// Desafío 4 — estado compartido con Riverpod (StateNotifier)
enum Prioridad { alta, media, baja }

class Task {
  final String id;
  final String titulo;
  final bool completada;
  final Prioridad prioridad;

  const Task({
    required this.id,
    required this.titulo,
    this.completada = false,
    this.prioridad = Prioridad.media,
  });

  Task copyWith({bool? completada}) => Task(
        id: id,
        titulo: titulo,
        completada: completada ?? this.completada,
        prioridad: prioridad,
      );
}

class TasksState {
  final List<Task> tareas;
  const TasksState({this.tareas = const []});

  int get pendientes => tareas.where((t) => !t.completada).length;
}

class TasksNotifier extends StateNotifier<TasksState> {
  TasksNotifier() : super(const TasksState());

  void agregar(String titulo, Prioridad prioridad) {
    final t = Task(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      titulo: titulo,
      prioridad: prioridad,
    );
    state = TasksState(tareas: [...state.tareas, t]);
  }

  void eliminar(String id) {
    state = TasksState(tareas: state.tareas.where((t) => t.id != id).toList());
  }

  void toggleCompletada(String id) {
    state = TasksState(
      tareas: [
        for (final t in state.tareas)
          if (t.id == id) t.copyWith(completada: !t.completada) else t,
      ],
    );
  }
}

final tasksProvider = StateNotifierProvider<TasksNotifier, TasksState>(
  (ref) => TasksNotifier(),
);
