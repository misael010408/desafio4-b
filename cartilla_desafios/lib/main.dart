import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/firebase_status.dart';
import 'core/notification_service.dart';
import 'presentation/providers/settings_provider.dart';
import 'presentation/router/router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Desafío 6: Hive para preferencias
  await Hive.initFlutter();
  await Hive.openBox('prefs');

  // Desafío 7: Firebase. Si todavía no lo configuraste, la app sigue
  // funcionando en "modo local" (desafíos 4, 4C, 5 y 6).
  try {
    await Firebase.initializeApp();
    firebaseReady = true;
  } catch (e) {
    firebaseReady = false;
    debugPrint('Firebase no configurado: $e');
  }

  // Desafío 8: notificaciones locales
  await NotificationService.init();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return MaterialApp.router(
      title: 'Cartilla Flutter',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      themeMode: settings.oscuro ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
      ),
    );
  }
}
