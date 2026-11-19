class TareaDb {
  final int? id;
  final String titulo;
  final bool completada;

  const TareaDb({this.id, required this.titulo, this.completada = false});

  TareaDb copyWith({String? titulo, bool? completada}) => TareaDb(
        id: id,
        titulo: titulo ?? this.titulo,
        completada: completada ?? this.completada,
      );

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'titulo': titulo,
        'completada': completada ? 1 : 0,
      };

  factory TareaDb.fromMap(Map<String, Object?> m) => TareaDb(
        id: m['id'] as int,
        titulo: m['titulo'] as String,
        completada: (m['completada'] as int) == 1,
      );
}
