import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

/// Resultado de geocoding de Nominatim (OpenStreetMap).
class NominatimPlace {
  final String displayName;
  final LatLng location;

  NominatimPlace({required this.displayName, required this.location});

  factory NominatimPlace.fromJson(Map<String, dynamic> json) {
    return NominatimPlace(
      displayName: json['display_name'] as String,
      location: LatLng(
        double.parse(json['lat'] as String),
        double.parse(json['lon'] as String),
      ),
    );
  }
}

class NominatimService {
  static const _baseUrl = 'https://nominatim.openstreetmap.org';

  /// Busca lugares por texto, limitado a la zona de Puebla.
  /// viewbox = bounding box de Puebla metropolitana.
  static Future<List<NominatimPlace>> search(String query) async {
    if (query.trim().isEmpty) return [];

    final uri = Uri.parse('$_baseUrl/search').replace(queryParameters: {
      'q': query,
      'format': 'json',
      'limit': '5',
      'addressdetails': '1',
      // Bounding box de Puebla para priorizar resultados locales
      'viewbox': '-98.35,19.12,-98.10,18.92',
      'bounded': '0', // 0 = prioriza viewbox pero no excluye otros
    });

    final response = await http.get(uri, headers: {
      // Nominatim requiere un User-Agent identificable
      'User-Agent': 'MovyPuebla/0.1 (contacto@movypuebla.com)',
    });

    if (response.statusCode != 200) return [];

    final data = jsonDecode(response.body) as List;
    return data
        .map((e) => NominatimPlace.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
