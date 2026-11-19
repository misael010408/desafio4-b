import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Desafío 6 — preferencias persistentes con Hive
class Settings {
  final bool oscuro;
  final bool notificaciones;
  const Settings({this.oscuro = false, this.notificaciones = true});
}

class SettingsNotifier extends StateNotifier<Settings> {
  SettingsNotifier()
      : super(Settings(
          oscuro: Hive.box('prefs').get('oscuro', defaultValue: false) as bool,
          notificaciones:
              Hive.box('prefs').get('notificaciones', defaultValue: true) as bool,
        ));

  Box get _box => Hive.box('prefs');

  void setOscuro(bool v) {
    _box.put('oscuro', v);
    state = Settings(oscuro: v, notificaciones: state.notificaciones);
  }

  void setNotificaciones(bool v) {
    _box.put('notificaciones', v);
    state = Settings(oscuro: state.oscuro, notificaciones: v);
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, Settings>((ref) => SettingsNotifier());
