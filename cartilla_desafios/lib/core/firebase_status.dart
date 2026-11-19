import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Se pone en true en main() si Firebase.initializeApp() funcionó.
bool firebaseReady = false;

/// Estado de sesión que escucha GoRouter (refreshListenable).
class AuthState extends ChangeNotifier {
  bool localMode = false; // entrar sin Firebase (solo para probar 4, 4C, 5, 6)

  AuthState() {
    if (firebaseReady) {
      FirebaseAuth.instance.authStateChanges().listen((_) => notifyListeners());
    }
  }

  User? get user => firebaseReady ? FirebaseAuth.instance.currentUser : null;

  bool get loggedIn => localMode || user != null;

  void entrarLocal() {
    localMode = true;
    notifyListeners();
  }

  Future<void> cerrarSesion() async {
    localMode = false;
    if (firebaseReady) await FirebaseAuth.instance.signOut();
    notifyListeners();
  }
}

final authState = AuthState();
