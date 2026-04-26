import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

import '../config.dart';
import '../models/route_model.dart';
import '../services/nominatim_service.dart';
import '../widgets/place_search_field.dart';
import 'route_detail_screen.dart';

class HomeMapScreen extends StatefulWidget {
  static const routeName = '/home';
  const HomeMapScreen({super.key});

  @override
  State<HomeMapScreen> createState() => _HomeMapScreenState();
}

class _HomeMapScreenState extends State<HomeMapScreen> {
  final MapController _mapController = MapController();
  final LatLng _pueblaCenter = const LatLng(19.0413, -98.2062);

  NominatimPlace? _origin;
  NominatimPlace? _destination;
  bool _loadingRoutes = false;
  List<RouteModel> _routes = [];

  final String _baseUrl = getBaseUrl();

  List<Marker> get _markers {
    final markers = <Marker>[];
    if (_origin != null) {
      markers.add(Marker(
        point: _origin!.location,
        width: 40,
        height: 40,
        child: const Icon(Icons.trip_origin, color: Colors.green, size: 32),
      ));
    }
    if (_destination != null) {
      markers.add(Marker(
        point: _destination!.location,
        width: 40,
        height: 40,
        child: const Icon(Icons.flag, color: Colors.red, size: 32),
      ));
    }
    return markers;
  }

  void _onOriginSelected(NominatimPlace place) {
    setState(() => _origin = place);
    _mapController.move(place.location, 14);
  }

  void _onDestinationSelected(NominatimPlace place) {
    setState(() => _destination = place);
    if (_origin != null) {
      final bounds =
          LatLngBounds.fromPoints([_origin!.location, place.location]);
      _mapController.fitCamera(
        CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(50)),
      );
    } else {
      _mapController.move(place.location, 14);
    }
  }

  Future<void> _searchRoutes() async {
    setState(() => _loadingRoutes = true);
    try {
      final uri = Uri.parse('$_baseUrl/routes/search');
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        setState(() {
          _routes = data
              .map((e) => RouteModel.fromJson(e as Map<String, dynamic>))
              .toList();
        });
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de red: $e')),
      );
    } finally {
      if (mounted) setState(() => _loadingRoutes = false);
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(title: const Text('MovyPuebla - Urbano')),
      body: Column(
        children: [
          SizedBox(
            height: height * 0.35,
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _pueblaCenter,
                initialZoom: 12,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.movypuebla.app',
                ),
                MarkerLayer(markers: _markers),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Column(
              children: [
                PlaceSearchField(
                  label: 'Origen',
                  icon: Icons.trip_origin,
                  onPlaceSelected: _onOriginSelected,
                ),
                const SizedBox(height: 4),
                PlaceSearchField(
                  label: 'Destino',
                  icon: Icons.flag,
                  onPlaceSelected: _onDestinationSelected,
                ),
                const SizedBox(height: 8),
                _loadingRoutes
                    ? const CircularProgressIndicator()
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _searchRoutes,
                          icon: const Icon(Icons.search),
                          label: const Text('Buscar ruta'),
                        ),
                      ),
              ],
            ),
          ),
          Expanded(
            child: _routes.isEmpty
                ? const Center(
                    child: Text('Ingresa origen y destino, luego busca rutas.'))
                : ListView.builder(
                    itemCount: _routes.length,
                    itemBuilder: (context, index) {
                      final r = _routes[index];
                      final tarifa =
                          '${r.baseFareMin.toStringAsFixed(2)} - ${r.baseFareMax.toStringAsFixed(2)}';
                      final nocturno = r.nightFare?.toStringAsFixed(2);
                      return ListTile(
                        leading: const Icon(Icons.directions_bus),
                        title: Text(r.name),
                        subtitle: Text('Tarifa: $tarifa MXN'),
                        trailing: r.supportsNightService && nocturno != null
                            ? Text('$nocturno MXN')
                            : null,
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            RouteDetailScreen.routeName,
                            arguments: r,
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
