import 'package:flutter/material.dart';
import 'app_strings.dart';

/// Provider global de idioma. Usa InheritedWidget para propagarse.
class LanguageProvider extends ChangeNotifier {
  AppLanguage _language = AppLanguage.es;

  AppLanguage get language => _language;

  void setLanguage(AppLanguage lang) {
    _language = lang;
    notifyListeners();
  }

  String t(String key) => AppStrings.get(_language, key);
}

/// Widget para acceder al idioma desde cualquier parte del árbol.
class LanguageScope extends InheritedNotifier<LanguageProvider> {
  const LanguageScope({
    super.key,
    required LanguageProvider provider,
    required super.child,
  }) : super(notifier: provider);

  static LanguageProvider of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<LanguageScope>()!
        .notifier!;
  }
}
