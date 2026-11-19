import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../core/firebase_status.dart';
import '../widgets/app_shell.dart';

class CloudTasksScreen extends StatefulWidget {
  const CloudTasksScreen({super.key});

  @override
  State<CloudTasksScreen> createState() => _CloudTasksScreenState();
}

class _CloudTasksScreenState extends State<CloudTasksScreen> {
  final _ctrl = TextEditingController();

  CollectionReference<Map<String, dynamic>> get _col =>
      FirebaseFirestore.instance.collection('tareas');

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _agregar(String uid) async {
    final texto = _ctrl.text.trim();
    if (texto.isEmpty) return;
    await _col.add({
      'titulo': texto,
      'completada': false,
      'userId': uid,
      'creada': FieldValue.serverTimestamp(),
    });
    _ctrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final uid = authState.user?.uid;
    return Scaffold(
      appBar: AppBar(leading: const MenuButton(), title: const Text('Tareas en la nube')),
      body: (!firebaseReady || uid == null)
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Esta pantalla necesita Firebase configurado y una sesión iniciada.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : Column(
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
                              border: OutlineInputBorder()),
                          onSubmitted: (_) => _agregar(uid),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                          onPressed: () => _agregar(uid),
                          icon: const Icon(Icons.add)),
                    ],
                  ),
                ),
                Expanded(
                  // Solo las tareas del usuario actual, en tiempo real
                  child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: _col.where('userId', isEqualTo: uid).snapshots(),
                    builder: (context, snap) {
                      if (snap.hasError) {
                        return Center(child: Text('Error: ${snap.error}'));
                      }
                      if (!snap.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final docs = snap.data!.docs;
                      if (docs.isEmpty) {
                        return const Center(child: Text('No tenés tareas'));
                      }
                      return ListView.builder(
                        itemCount: docs.length,
                        itemBuilder: (_, i) {
                          final d = docs[i];
                          final data = d.data();
                          final hecha = data['completada'] as bool? ?? false;
                          return ListTile(
                            leading: Checkbox(
                              value: hecha,
                              onChanged: (v) =>
                                  d.reference.update({'completada': v ?? false}),
                            ),
                            title: Text(
                              data['titulo'] as String? ?? '',
                              style: TextStyle(
                                  decoration:
                                      hecha ? TextDecoration.lineThrough : null),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => d.reference.delete(),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
