import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/firebase_status.dart';
import '../widgets/app_shell.dart';

String _hoy() => DateFormat('yyyy-MM-dd').format(DateTime.now());

/// Lista en tiempo real de asistencias de una fecha (yyyy-MM-dd).
class _ListaAsistencias extends StatelessWidget {
  final String fecha;
  const _ListaAsistencias({required this.fecha});

  @override
  Widget build(BuildContext context) {
    if (!firebaseReady) {
      return const Center(child: Text('Firebase no está configurado'));
    }
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('asistencias')
          .where('fecha', isEqualTo: fecha)
          .snapshots(),
      builder: (context, snap) {
        if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        // se ordena en el cliente para no necesitar un índice compuesto
        final docs = snap.data!.docs.toList()
          ..sort((a, b) =>
              (a.data()['hora'] as String).compareTo(b.data()['hora'] as String));
        if (docs.isEmpty) {
          return const Center(child: Text('Sin asistencias para esta fecha'));
        }
        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (_, i) {
            final d = docs[i].data();
            return ListTile(
              leading: const Icon(Icons.check_circle, color: Colors.green),
              title: Text(d['nombre'] as String),
              subtitle: Text('${d['fecha']}  ${d['hora']}'),
            );
          },
        );
      },
    );
  }
}

class AsistenciaScreen extends StatelessWidget {
  const AsistenciaScreen({super.key});

  Future<void> _limpiar(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Limpiar registro del día'),
        content: const Text('Se van a eliminar todas las asistencias de hoy.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Eliminar')),
        ],
      ),
    );
    if (ok != true || !firebaseReady) return;

    final snap = await FirebaseFirestore.instance
        .collection('asistencias')
        .where('fecha', isEqualTo: _hoy())
        .get();
    final batch = FirebaseFirestore.instance.batch();
    for (final d in snap.docs) {
      batch.delete(d.reference);
    }
    await batch.commit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const MenuButton(),
        title: const Text('Asistencias de hoy'),
        actions: [
          IconButton(
            tooltip: 'Limpiar registro del día',
            icon: const Icon(Icons.delete_sweep),
            onPressed: () => _limpiar(context),
          ),
        ],
      ),
      body: _ListaAsistencias(fecha: _hoy()),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/escanear'),
        icon: const Icon(Icons.qr_code_scanner),
        label: const Text('Escanear'),
      ),
    );
  }
}

// EXTRA: historial por fecha
class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  DateTime _fecha = DateTime.now();

  Future<void> _elegir() async {
    final f = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    );
    if (f != null) setState(() => _fecha = f);
  }

  @override
  Widget build(BuildContext context) {
    final texto = DateFormat('yyyy-MM-dd').format(_fecha);
    return Scaffold(
      appBar: AppBar(
        leading: const MenuButton(),
        title: Text('Historial: $texto'),
        actions: [
          IconButton(icon: const Icon(Icons.calendar_month), onPressed: _elegir),
        ],
      ),
      body: _ListaAsistencias(fecha: texto),
    );
  }
}
