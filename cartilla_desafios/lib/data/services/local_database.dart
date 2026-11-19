import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../../domain/entities/tarea_db.dart';

/// Desafío 6 — CRUD completo con SQLite.
class LocalDatabase {
  LocalDatabase._();
  static final LocalDatabase instance = LocalDatabase._();

  Database? _db;

  Future<Database> get _database async => _db ??= await _abrir();

  Future<Database> _abrir() async {
    final ruta = join(await getDatabasesPath(), 'tareas.db');
    return openDatabase(
      ruta,
      version: 1,
      onCreate: (db, version) => db.execute('''
        CREATE TABLE tareas(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          titulo TEXT NOT NULL,
          completada INTEGER NOT NULL DEFAULT 0
        )
      '''),
    );
  }

  Future<int> insertar(TareaDb t) async =>
      (await _database).insert('tareas', t.toMap());

  Future<List<TareaDb>> obtenerTodas() async {
    final filas = await (await _database).query('tareas', orderBy: 'id DESC');
    return filas.map(TareaDb.fromMap).toList();
  }

  Future<int> actualizar(TareaDb t) async => (await _database)
      .update('tareas', t.toMap(), where: 'id = ?', whereArgs: [t.id]);

  Future<int> eliminar(int id) async =>
      (await _database).delete('tareas', where: 'id = ?', whereArgs: [id]);
}
