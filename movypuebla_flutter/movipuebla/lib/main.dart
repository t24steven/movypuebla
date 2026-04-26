import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'l10n/language_provider.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    debugPrint('Firebase inicializado correctamente');
  } catch (e) {
    debugPrint('Firebase no disponible: $e');
  }

  final languageProvider = LanguageProvider();

  runApp(
    LanguageScope(
      provider: languageProvider,
      child: ListenableBuilder(
        listenable: languageProvider,
        builder: (context, _) => const MovyPueblaApp(),
      ),
    ),
  );
}
