import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    debugPrint('Firebase inicializado correctamente');
  } catch (e) {
    // Si no hay google-services.json / GoogleService-Info.plist,
    // la app sigue funcionando sin Auth por ahora.
    debugPrint('Firebase no disponible: $e');
  }
  runApp(const MovyPueblaApp());
}
