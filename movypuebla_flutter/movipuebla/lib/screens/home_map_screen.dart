import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

import '../config.dart';
import '../models/route_model.dart';
import '../services/nominatim_service.dart';
import '../widgets/place_search_field.dart';
import '../widgets/panic_button.dart';
import '../widgets/language_selector.dart';
import '../l10n/language_provider.dart';
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
      // Construir URL con coordenadas si están disponibles
      final params = <String, String>{};
      if (_origin != null && _destination != null) {
        params['originLat'] = _origin!.location.latitude.toString();
        params['originLng'] = _origin!.location.longitude.toString();
        params['destLat'] = _destination!.location.latitude.toString();
        params['destLng'] = _destination!.location.longitude.toString();
      }

      final uri = Uri.parse('$_baseUrl/routes/search')
          .replace(queryParameters: params.isNotEmpty ? params : null);
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

  void _showDriverInfoSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const CircleAvatar(
              radius: 36,
              backgroundColor: Colors.green,
              child: Icon(Icons.directions_bus, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 12),
            const Text('Conductor en turno',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _driverInfoRow(Icons.person, 'Nombre', 'Juan Pérez López'),
            _driverInfoRow(Icons.badge, 'No. Operador', 'OP-2024-0153'),
            _driverInfoRow(
                Icons.route, 'Ruta asignada', 'L3 Valsequillo – CAPU'),
            _driverInfoRow(Icons.directions_bus, 'Unidad', 'Unidad #42'),
            _driverInfoRow(Icons.circle, 'Estado', 'En servicio',
                valueColor: Colors.green),
            const SizedBox(height: 16),
            Text(
              'Esta información se actualiza cuando el conductor inicia su turno.',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _driverInfoRow(IconData icon, String label, String value,
      {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.green.shade700),
          const SizedBox(width: 12),
          Text('$label: ', style: TextStyle(color: Colors.grey.shade600)),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text('MovyPuebla - ${LanguageScope.of(context).t('urban')}'),
        actions: [
          const LanguageSelector(),
          IconButton(
            icon: const Icon(Icons.person_pin),
            tooltip: 'Info del conductor',
            onPressed: () => _showDriverInfoSheet(context),
          ),
        ],
      ),
      floatingActionButton: const PanicButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Column(
        children: [
          SizedBox(
            height: height * 0.3,
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
                  label: LanguageScope.of(context).t('origin'),
                  icon: Icons.trip_origin,
                  onPlaceSelected: _onOriginSelected,
                ),
                const SizedBox(height: 4),
                PlaceSearchField(
                  label: LanguageScope.of(context).t('destination'),
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
                          label:
                              Text(LanguageScope.of(context).t('searchRoute')),
                        ),
                      ),
              ],
            ),
          ),
          Expanded(
            child: _routes.isEmpty
                ? Center(child: Text(LanguageScope.of(context).t('noRoutes')))
                : ListView.builder(
                    itemCount: _routes.length,
                    itemBuilder: (context, index) {
                      final r = _routes[index];
                      final tarifa =
                          '${r.baseFareMin.toStringAsFixed(2)} - ${r.baseFareMax.toStringAsFixed(2)}';

                      // Info de cercanía (solo si se buscó con coordenadas)
                      final hasProximity = r.nearestOriginStop != null;
                      String? proximityText;
                      if (hasProximity) {
                        proximityText =
                            'Sube en ${r.nearestOriginStop} (${r.nearestOriginDistKm} km) '
                            '→ Baja en ${r.nearestDestStop} (${r.nearestDestDistKm} km)';
                      }

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        child: ListTile(
                          leading: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.directions_bus,
                                  color: Colors.green),
                              Text(r.code,
                                  style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          title: Text(r.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Tarifa: $tarifa MXN'),
                              if (proximityText != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    proximityText,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.green.shade700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          isThreeLine: hasProximity,
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              RouteDetailScreen.routeName,
                              arguments: r,
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
