import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

/// URL base del backend. Detecta plataforma automáticamente:
/// - Web: localhost:4000
/// - Android emulator: 10.0.2.2:4000
/// - iOS simulator / desktop: localhost:4000
String getBaseUrl() {
  if (kIsWeb) return 'http://localhost:4000';
  if (Platform.isAndroid) return 'http://10.0.2.2:4000';
  return 'http://localhost:4000';
}
