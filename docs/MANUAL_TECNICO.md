# Manual Técnico — MovyPuebla 🚌

## Resumen de Tecnologías

MovyPuebla es una aplicación multiplataforma (Android, iOS, Web) con un backend en la nube. Este documento explica cada tecnología usada, para qué sirve y qué debe saber el desarrollador que trabaje con ella.

---

## 1. Flutter (Frontend)

**¿Qué es?** Framework de Google para crear apps nativas desde un solo código base.

**¿Para qué se usa?** Toda la interfaz de usuario: pantallas, mapas, formularios, navegación.

**¿Qué debe saber el desarrollador?**
- Lenguaje: Dart
- Estructura: widgets (todo es un widget)
- Estado: `StatefulWidget` con `setState()`
- Navegación: rutas nombradas (`Navigator.pushNamed`)
- Versión mínima: Flutter 3.3+, Dart SDK >=3.3.0

**Archivos clave:**
- `lib/main.dart` — Punto de entrada, inicializa Firebase y el provider de idioma
- `lib/app.dart` — Configuración de MaterialApp y rutas
- `lib/screens/` — Todas las pantallas
- `lib/models/` — Modelos de datos (RouteModel, StopModel, UserModel)
- `lib/services/` — Servicios externos (Nominatim, OSRM)
- `lib/widgets/` — Widgets reutilizables (PlaceSearchField, PanicButton, LanguageSelector)
- `lib/l10n/` — Traducciones e internacionalización
- `lib/config.dart` — URL del backend (Railway en producción, localhost en desarrollo web)

---

## 2. Node.js + Express (Backend)

**¿Qué es?** Node.js es un runtime de JavaScript del lado del servidor. Express es un framework web minimalista.

**¿Para qué se usa?** API REST que conecta la app Flutter con la base de datos Firestore.

**¿Qué debe saber el desarrollador?**
- Lenguaje: TypeScript (compilado a JavaScript)
- Puerto por defecto: 4000
- Hot reload en desarrollo con `ts-node-dev`
- Compilación: `tsc` genera archivos en `dist/`

**Endpoints:**

| Método | Ruta | Descripción |
|--------|------|-------------|
| GET | `/routes/search` | Lista rutas. Acepta `originLat`, `originLng`, `destLat`, `destLng` para ordenar por cercanía |
| GET | `/routes/:id` | Detalle de ruta con paradas ordenadas |
| POST | `/users` | Crear/actualizar perfil de usuario con rol |
| GET | `/users/:uid` | Obtener perfil de usuario |
| PUT | `/users/:uid/location` | Actualizar ubicación del transportista |

**Archivos clave:**
- `src/index.ts` — Servidor Express, CORS, registro de routers
- `src/routes/routesRouter.ts` — Endpoints de rutas y paradas
- `src/routes/usersRouter.ts` — Endpoints de usuarios
- `src/services/firestore.ts` — Conexión a Firestore (soporta archivo local y variable de entorno)
- `src/seed/seedRoutes.ts` — Script para poblar Firestore con datos de ejemplo

---

## 3. Firebase

### 3.1 Firebase Authentication

**¿Qué es?** Servicio de autenticación de Google.

**¿Para qué se usa?** Registro e inicio de sesión con correo y contraseña.

**¿Qué debe saber el desarrollador?**
- Método habilitado: Email/Password
- La app funciona sin Firebase configurado (modo desarrollo)
- Errores comunes: `user-not-found`, `wrong-password`, `email-already-in-use`
- Si hay muchos intentos fallidos, Firebase bloquea temporalmente el dispositivo (15-30 min)

**Configuración necesaria:**
- `google-services.json` en `android/app/` (Android)
- `GoogleService-Info.plist` en `ios/Runner/` (iOS)
- SHA-1 del certificado de debug registrado en Firebase Console

### 3.2 Cloud Firestore

**¿Qué es?** Base de datos NoSQL en tiempo real de Google.

**¿Para qué se usa?** Almacenar rutas, paradas y perfiles de usuario.

**Colecciones:**

**`routes`** — Rutas de transporte
```
{
  name: "Línea 3 Valsequillo – CAPU",
  code: "L3",
  zoneType: "urbana",
  baseFareMin: 6.0,
  baseFareMax: 7.5,
  discountDisabled: 0.0,
  discountStudentMin: 4.0,
  discountStudentMax: 6.0,
  discountSeniorMin: 4.0,
  discountSeniorMax: 6.0,
  nightFare: 30.0,
  supportsNightService: true
}
```

**`stops`** — Paradas de cada ruta
```
{
  routeId: "abc123",
  name: "CAPU",
  order: 5,
  lat: 19.0700,
  lng: -98.2280
}
```

**`users`** — Perfiles de usuario
```
{
  uid: "firebase-uid",
  name: "Juan Pérez",
  email: "juan@email.com",
  role: "citizen" | "driver",
  assignedRouteId: "abc123" (solo drivers)
}
```

### 3.3 Firebase Admin SDK (Backend)

**¿Qué es?** SDK de Firebase para servidores.

**¿Para qué se usa?** El backend Node.js lo usa para leer/escribir en Firestore.

**Configuración:**
- En desarrollo local: archivo `serviceAccountKey.json` en la raíz del backend
- En producción (Railway): variable de entorno `FIREBASE_SERVICE_ACCOUNT` con el JSON completo

---

## 4. OpenStreetMap + flutter_map

**¿Qué es?** OpenStreetMap (OSM) es un mapa libre y gratuito. `flutter_map` es el widget de Flutter para mostrarlo.

**¿Para qué se usa?** Mostrar el mapa de Puebla, marcadores de paradas, polylines de rutas.

**¿Qué debe saber el desarrollador?**
- No requiere API key
- Tiles: `https://tile.openstreetmap.org/{z}/{x}/{y}.png`
- Coordenadas: usa `LatLng` del paquete `latlong2`
- Política de uso: incluir User-Agent identificable, no hacer más de 1 request/segundo en tiles

**Paquetes:** `flutter_map: ^8.1.0`, `latlong2: ^0.9.1`

---

## 5. Nominatim (Geocoding)

**¿Qué es?** API gratuita de OpenStreetMap para convertir texto en coordenadas.

**¿Para qué se usa?** Autocompletado de los campos Origen y Destino. El usuario escribe "CAPU" y Nominatim devuelve las coordenadas.

**¿Qué debe saber el desarrollador?**
- URL: `https://nominatim.openstreetmap.org/search`
- Límite: máximo 1 request/segundo
- Requiere User-Agent identificable
- Viewbox configurado para priorizar resultados en Puebla
- Debounce de 500ms implementado en el widget

**Archivo:** `lib/services/nominatim_service.dart`

---

## 6. OSRM (Ruteo)

**¿Qué es?** Open Source Routing Machine — servicio gratuito de cálculo de rutas.

**¿Para qué se usa?** Dibujar la ruta real por calles entre las paradas (no líneas rectas). También calcula distancia y tiempo estimado.

**¿Qué debe saber el desarrollador?**
- URL: `https://router.project-osrm.org/route/v1/driving/`
- Formato de coordenadas: `lng,lat` (invertido respecto a LatLng)
- Respuesta en GeoJSON
- Servidor público de demo — para producción con alto tráfico, hostear instancia propia
- Si OSRM falla, la app usa líneas rectas como fallback

**Archivo:** `lib/services/osrm_service.dart`

---

## 7. url_launcher

**¿Qué es?** Plugin de Flutter para abrir URLs, hacer llamadas y enviar SMS.

**¿Para qué se usa?** Botón de pánico — llamar al 911, policía municipal, enviar SMS de emergencia.

**¿Qué debe saber el desarrollador?**
- Solo funciona en dispositivos móviles (Android/iOS)
- En web, `tel:` y `sms:` no funcionan
- Paquete: `url_launcher: ^6.3.0`

---

## 8. Railway (Hosting del Backend)

**¿Qué es?** Plataforma de hosting en la nube.

**¿Para qué se usa?** El backend Node.js está desplegado ahí para que la app funcione desde cualquier dispositivo sin necesidad de red local.

**¿Qué debe saber el desarrollador?**
- URL de producción: `https://movypuebla-production.up.railway.app`
- Deploy automático desde GitHub (rama `main`)
- Variable de entorno `FIREBASE_SERVICE_ACCOUNT` configurada con el JSON de la service account
- Root directory: `movypuebla_backend`
- Build: `npm run build` → Start: `npm run start`

---

## 9. Internacionalización (i18n)

**¿Qué es?** Sistema propio de traducciones para soportar múltiples idiomas.

**¿Para qué se usa?** La app soporta 8 idiomas: español, náhuatl, totonaco, mazateco, popoloca, mixteco, otomí y tepehua.

**¿Qué debe saber el desarrollador?**
- No usa el sistema oficial de Flutter (`gen_l10n`) porque las lenguas indígenas no tienen locale codes estándar
- Implementado con `ChangeNotifier` + `InheritedNotifier`
- Para agregar un texto traducible: agregar la key en `_es` y en cada idioma en `app_strings.dart`
- Para usar una traducción: `LanguageScope.of(context).t('key')`
- Las traducciones a lenguas indígenas son aproximaciones y deben ser revisadas por hablantes nativos

**Archivos:**
- `lib/l10n/app_strings.dart` — Todas las traducciones
- `lib/l10n/language_provider.dart` — Provider de idioma
- `lib/widgets/language_selector.dart` — Widget selector

---

## Arquitectura General

```
┌─────────────────────────────────────────────┐
│              Flutter App                     │
│  (Android / iOS / Web)                       │
│                                              │
│  ┌──────────┐ ┌──────────┐ ┌──────────────┐ │
│  │ Screens  │ │ Widgets  │ │   Services   │ │
│  │          │ │          │ │              │ │
│  │ Splash   │ │ Search   │ │ Nominatim    │ │
│  │ Login    │ │ Panic    │ │ OSRM         │ │
│  │ Register │ │ Language │ │              │ │
│  │ HomeMap  │ │          │ │              │ │
│  │ Detail   │ │          │ │              │ │
│  │ Driver   │ │          │ │              │ │
│  └──────────┘ └──────────┘ └──────┬───────┘ │
│                                    │         │
└────────────────────────────────────┼─────────┘
                                     │ HTTP
                    ┌────────────────▼─────────────┐
                    │     Backend (Railway)          │
                    │     Node.js + Express + TS     │
                    │                                │
                    │  /routes/search                 │
                    │  /routes/:id                    │
                    │  /users                         │
                    └────────────────┬───────────────┘
                                     │
                    ┌────────────────▼───────────────┐
                    │     Firebase                    │
                    │                                 │
                    │  Auth (email/password)           │
                    │  Firestore (routes, stops, users)│
                    └─────────────────────────────────┘
```

---

## Comandos Útiles

```bash
# Backend - desarrollo
cd movypuebla_backend
npm install
npm run dev          # Levanta en localhost:4000
npm run seed         # Poblar Firestore con datos de ejemplo
npm run build        # Compilar TypeScript

# Flutter - desarrollo
cd movypuebla_flutter/movipuebla
flutter pub get      # Instalar dependencias
flutter run          # Correr app (elige dispositivo)
flutter run -d chrome  # Correr en web
flutter build apk    # Generar APK para Android

# Git
git pull             # Actualizar código
git add -A           # Preparar cambios
git commit -m "msg"  # Guardar cambios
git push             # Subir a GitHub
```
