# MovyPuebla 🚌

App de movilidad urbana para Puebla. Fomenta el uso de transporte público y micromovilidad.

## Estructura del proyecto

```
movypuebla_backend/    → API Node.js + Express + Firestore
movypuebla_flutter/    → App Flutter (Android, iOS, Web)
```

## Requisitos previos

- [Node.js](https://nodejs.org/) v18+
- [Flutter SDK](https://flutter.dev/docs/get-started/install) 3.3+
- Cuenta en [Firebase Console](https://console.firebase.google.com)

## Configuración inicial

### 1. Clonar el repositorio

```bash
git clone https://github.com/TU_USUARIO/movypuebla.git
cd movypuebla
```

### 2. Configurar Firebase

Pide al líder del proyecto estos archivos (NO están en el repo por seguridad):

| Archivo | Dónde colocarlo |
|---|---|
| `google-services.json` | `movypuebla_flutter/movipuebla/android/app/` |
| `GoogleService-Info.plist` | `movypuebla_flutter/movipuebla/ios/Runner/` |
| `serviceAccountKey.json` | `movypuebla_backend/` |

Para obtenerlos:
1. Ve a [Firebase Console](https://console.firebase.google.com) → proyecto `movypuebla`
2. `google-services.json`: Configuración del proyecto → Apps Android → Descargar
3. `GoogleService-Info.plist`: Configuración del proyecto → Apps iOS → Descargar
4. `serviceAccountKey.json`: Configuración → Cuentas de servicio → Generar nueva clave privada

### 3. Backend

```bash
cd movypuebla_backend
npm install
npm run seed    # Solo la primera vez, para poblar Firestore
npm run dev     # Levanta el servidor en localhost:4000
```

### 4. Flutter

```bash
cd movypuebla_flutter/movipuebla
flutter pub get
flutter run     # Elige dispositivo: Chrome, Android, iOS
```

## Endpoints del API

| Método | Ruta | Descripción |
|---|---|---|
| GET | `/routes/search` | Lista todas las rutas |
| GET | `/routes/:id` | Detalle de ruta con paradas |

## Tecnologías

- **Frontend:** Flutter + flutter_map (OpenStreetMap) + Firebase Auth
- **Backend:** Node.js + Express + TypeScript
- **Base de datos:** Firestore (Firebase)
- **Geocoding:** Nominatim (OpenStreetMap, gratuito)
