import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../core/firebase_status.dart';
import '../../core/notification_service.dart';
import '../providers/settings_provider.dart';

class EscanearScreen extends ConsumerStatefulWidget {
  const EscanearScreen({super.key});

  @override
  ConsumerState<EscanearScreen> createState() => _EscanearScreenState();
}

class _EscanearScreenState extends ConsumerState<EscanearScreen> {
  final _controller = MobileScannerController();
  bool _procesando = false;
  bool _linterna = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _aviso(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _registrar(String nombre) async {
    final ahora = DateTime.now();
    final fecha = DateFormat('yyyy-MM-dd').format(ahora);
    final hora = DateFormat('HH:mm:ss').format(ahora);
    final col = FirebaseFirestore.instance.collection('asistencias');

    final existente = await col
        .where('fecha', isEqualTo: fecha)
        .where('nombre', isEqualTo: nombre)
        .limit(1)
        .get();

    if (existente.docs.isNotEmpty) {
      _aviso('$nombre ya está registrado hoy');
      if (ref.read(settingsProvider).notificaciones) {
        await NotificationService.mostrar(
            'Asistencia duplicada', '$nombre ya fue registrado hoy.');
      }
    } else {
      await col.add({
        'nombre': nombre,
        'fecha': fecha,
        'hora': hora,
        'timestamp': FieldValue.serverTimestamp(),
      });
      _aviso('Asistencia registrada: $nombre ($hora)');
    }
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_procesando) return;
    final valor = capture.barcodes.firstOrNull?.rawValue?.trim();
    if (valor == null || valor.isEmpty) return;

    _procesando = true;
    try {
      if (!firebaseReady) {
        _aviso('Firebase no está configurado');
      } else {
        await _registrar(valor);
      }
    } catch (e) {
      _aviso('Error: $e');
    }
    // evita registrar el mismo QR muchas veces seguidas
    await Future.delayed(const Duration(seconds: 3));
    _procesando = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear QR'),
        actions: [
          IconButton(
            icon: Icon(_linterna ? Icons.flashlight_off : Icons.flashlight_on),
            onPressed: () async {
              await _controller.toggleTorch();
              setState(() => _linterna = !_linterna);
            },
          ),
        ],
      ),
      body: MobileScanner(controller: _controller, onDetect: _onDetect),
    );
  }
}
