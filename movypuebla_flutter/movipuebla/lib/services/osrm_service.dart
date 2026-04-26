import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

/// Servicio de ruteo usando OSRM (Open Source Routing Machine).
/// Usa el servidor público de demo para desarrollo.
/// Para producción, considera hostear tu propia instancia de OSRM.
class OsrmService {
  static const _baseUrl = 'https://router.project-osrm.org';

  /// Obtiene la ruta real (polyline) entre una lista de puntos.
  /// Retorna la lista de coordenadas que forman la ruta por calles reales.
  static Future<List<LatLng>> getRoute(List<LatLng> waypoints) async {
    if (waypoints.length < 2) return [];

    // OSRM espera coordenadas como lng,lat (invertido vs LatLng)
    final coords =
        waypoints.map((p) => '${p.longitude},${p.latitude}').join(';');

    final uri = Uri.parse(
      '$_baseUrl/route/v1/driving/$coords'
      '?overview=full&geometries=geojson',
    );

    final response = await http.get(uri, headers: {
      'User-Agent': 'MovyPuebla/0.1',
    });

    if (response.statusCode != 200) return [];

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final routes = data['routes'] as List?;
    if (routes == null || routes.isEmpty) return [];

    final geometry = routes[0]['geometry'] as Map<String, dynamic>;
    final coordinates = geometry['coordinates'] as List;

    // GeoJSON usa [lng, lat], convertimos a LatLng
    return coordinates
        .map((c) => LatLng((c as List)[1].toDouble(), c[0].toDouble()))
        .toList();
  }

  /// Obtiene la ruta entre dos puntos con info de distancia y duración.
  static Future<RouteInfo?> getRouteInfo(
      LatLng origin, LatLng destination) async {
    final coords =
        '${origin.longitude},${origin.latitude};${destination.longitude},${destination.latitude}';

    final uri = Uri.parse(
      '$_baseUrl/route/v1/driving/$coords'
      '?overview=full&geometries=geojson',
    );

    final response = await http.get(uri, headers: {
      'User-Agent': 'MovyPuebla/0.1',
    });

    if (response.statusCode != 200) return null;

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final routes = data['routes'] as List?;
    if (routes == null || routes.isEmpty) return null;

    final route = routes[0] as Map<String, dynamic>;
    final geometry = route['geometry'] as Map<String, dynamic>;
    final coordinates = geometry['coordinates'] as List;

    final points = coordinates
        .map((c) => LatLng((c as List)[1].toDouble(), c[0].toDouble()))
        .toList();

    return RouteInfo(
      points: points,
      distanceMeters: (route['distance'] as num).toDouble(),
      durationSeconds: (route['duration'] as num).toDouble(),
    );
  }
}

class RouteInfo {
  final List<LatLng> points;
  final double distanceMeters;
  final double durationSeconds;

  RouteInfo({
    required this.points,
    required this.distanceMeters,
    required this.durationSeconds,
  });

  String get distanceText {
    if (distanceMeters >= 1000) {
      return '${(distanceMeters / 1000).toStringAsFixed(1)} km';
    }
    return '${distanceMeters.toInt()} m';
  }

  String get durationText {
    final minutes = (durationSeconds / 60).ceil();
    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      return '${hours}h ${mins}min';
    }
    return '$minutes min';
  }
}
