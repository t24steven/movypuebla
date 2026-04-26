import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'dart:io' show Platform;

/// IP local de tu computadora en la red WiFi.
/// Cámbiala si tu IP cambia (corre ipconfig en Windows para verla).
const _localIp = '192.168.1.168';

/// URL base del backend. Detecta plataforma automáticamente:
/// - Web: localhost:4000
/// - Android emulator: 10.0.2.2:4000
/// - Android/iOS dispositivo físico: tu IP local
/// - Desktop: localhost:4000
String getBaseUrl() {
  if (kIsWeb) return 'http://localhost:4000';
  if (Platform.isAndroid || Platform.isIOS) {
    // En debug con dispositivo físico, usa la IP local
    return kDebugMode
        ? 'http://$_localIp:4000'
        : 'http://$_localIp:4000'; // En producción cambiar a URL del servidor
  }
  return 'http://localhost:4000';
}
