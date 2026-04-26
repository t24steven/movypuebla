import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;

/// URL del backend en Railway (producción).
const _productionUrl = 'https://movypuebla-production.up.railway.app';

/// URL base del backend.
/// - En debug web: localhost para desarrollo rápido
/// - En todo lo demás: Railway (funciona desde cualquier dispositivo)
String getBaseUrl() {
  if (kDebugMode && kIsWeb) return 'http://localhost:4000';
  return _productionUrl;
}
