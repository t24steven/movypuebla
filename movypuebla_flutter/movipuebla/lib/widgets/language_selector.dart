import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import '../l10n/language_provider.dart';

/// Botón que abre un selector de idioma.
class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = LanguageScope.of(context);
    return IconButton(
      icon: const Icon(Icons.translate),
      tooltip: provider.t('language'),
      onPressed: () => _showLanguagePicker(context, provider),
    );
  }

  void _showLanguagePicker(BuildContext context, LanguageProvider provider) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                provider.t('language'),
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ...AppLanguage.values.map((lang) => ListTile(
                  leading: Icon(
                    lang == provider.language
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: lang == provider.language ? Colors.green : null,
                  ),
                  title: Text(lang.label),
                  onTap: () {
                    provider.setLanguage(lang);
                    Navigator.pop(ctx);
                  },
                )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
