import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

import '../config.dart';
import '../models/route_model.dart';
import '../models/stop_model.dart';
import '../services/osrm_service.dart';

class RouteDetailScreen extends StatefulWidget {
  static const routeName = '/route-detail';
  const RouteDetailScreen({super.key});

  @override
  State<RouteDetailScreen> createState() => _RouteDetailScreenState();
}

class _RouteDetailScreenState extends State<RouteDetailScreen> {
  RouteModel? _route;
  List<StopModel> _stops = [];
  bool _loading = true;
  bool _initialized = false;
  final MapController _mapController = MapController();
  final String _baseUrl = getBaseUrl();

  // Ruta real por calles (OSRM)
  List<LatLng> _realRoutePoints = [];
  RouteInfo? _routeInfo;

  List<StopModel> get _geoStops =>
      _stops.where((s) => s.lat != null && s.lng != null).toList();

  List<Marker> get _markers => _geoStops.map((s) {
        final isFirst = s.order == _geoStops.first.order;
        final isLast = s.order == _geoStops.last.order;
        return Marker(
          point: LatLng(s.lat!, s.lng!),
          width: 120,
          height: 50,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isFirst
                    ? Icons.play_circle_fill
                    : isLast
                        ? Icons.flag_circle
                        : Icons.circle,
                color: isFirst
                    ? Colors.green
                    : isLast
                        ? Colors.red
                        : Colors.blue,
                size: isFirst || isLast ? 24 : 14,
              ),
              Text(
                s.name,
                style:
                    const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      }).toList();

  /// Puntos para la polyline: usa ruta OSRM si está disponible,
  /// si no, líneas rectas entre paradas como fallback.
  List<LatLng> get _polylinePoints {
    if (_realRoutePoints.isNotEmpty) return _realRoutePoints;
    return _geoStops.map((s) => LatLng(s.lat!, s.lng!)).toList();
  }

  void _fitMapToStops() {
    final points = _polylinePoints;
    if (points.length < 2) return;
    final bounds = LatLngBounds.fromPoints(points);
    _mapController.fitCamera(
      CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(40)),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _route = ModalRoute.of(context)!.settings.arguments as RouteModel;
      _loadRouteDetail();
    }
  }

  Future<void> _loadRouteDetail() async {
    setState(() => _loading = true);
    try {
      final uri = Uri.parse('$_baseUrl/routes/${_route!.id}');
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final stopsJson = data['stops'] as List;
        _stops = stopsJson
            .map((e) => StopModel.fromJson(e as Map<String, dynamic>))
            .toList();
        setState(() {});

        // Obtener ruta real por calles con OSRM
        await _loadOsrmRoute();

        WidgetsBinding.instance.addPostFrameCallback((_) => _fitMapToStops());
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
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadOsrmRoute() async {
    if (_geoStops.length < 2) return;
    try {
      final waypoints = _geoStops.map((s) => LatLng(s.lat!, s.lng!)).toList();

      // Obtener ruta con info de distancia/duración
      final info = await OsrmService.getRouteInfo(
        waypoints.first,
        waypoints.last,
      );

      // Obtener ruta completa pasando por todas las paradas
      final points = await OsrmService.getRoute(waypoints);

      if (mounted && points.isNotEmpty) {
        setState(() {
          _realRoutePoints = points;
          _routeInfo = info;
        });
      }
    } catch (e) {
      // Si OSRM falla, se usa el fallback de líneas rectas
      debugPrint('OSRM no disponible: $e');
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  String _formatFare(double min, double max) {
    return '${min.toStringAsFixed(2)} - ${max.toStringAsFixed(2)} MXN';
  }

  @override
  Widget build(BuildContext context) {
    if (_route == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final route = _route!;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(title: Text(route.name)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_geoStops.isNotEmpty)
                  SizedBox(
                    height: height * 0.3,
                    child: FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: LatLng(
                          _geoStops.first.lat!,
                          _geoStops.first.lng!,
                        ),
                        initialZoom: 13,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.movypuebla.app',
                        ),
                        PolylineLayer(
                          polylines: [
                            Polyline(
                              points: _polylinePoints,
                              color: Colors.green.shade700,
                              strokeWidth: 4,
                            ),
                          ],
                        ),
                        MarkerLayer(markers: _markers),
                      ],
                    ),
                  ),

                // Info de distancia y tiempo (OSRM)
                if (_routeInfo != null)
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: Colors.green.shade50,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.straighten,
                                size: 18, color: Colors.green),
                            const SizedBox(width: 4),
                            Text(_routeInfo!.distanceText,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.schedule,
                                size: 18, color: Colors.green),
                            const SizedBox(width: 4),
                            Text(_routeInfo!.durationText,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.pin_drop,
                                size: 18, color: Colors.green),
                            const SizedBox(width: 4),
                            Text('${_geoStops.length} paradas',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ],
                    ),
                  ),

                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Text('Código: ${route.code}',
                          style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 12),
                      const Text('Tarifas',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      _tarifaRow('Normal',
                          _formatFare(route.baseFareMin, route.baseFareMax)),
                      _tarifaRow('Personas con discapacidad', 'Gratis'),
                      _tarifaRow(
                          'Estudiantes',
                          _formatFare(route.discountStudentMin,
                              route.discountStudentMax)),
                      _tarifaRow(
                          'Adultos mayores',
                          _formatFare(route.discountSeniorMin,
                              route.discountSeniorMax)),
                      if (route.supportsNightService && route.nightFare != null)
                        _tarifaRow('Feria (nocturno)',
                            '${route.nightFare!.toStringAsFixed(2)} MXN'),
                      const SizedBox(height: 16),
                      const Text('Paradas principales',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      ..._stops.map((s) => _stopTile(s)),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _tarifaRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _stopTile(StopModel s) {
    final hasCoords = s.lat != null && s.lng != null;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 14,
        backgroundColor: Colors.green,
        child: Text('${s.order}',
            style: const TextStyle(color: Colors.white, fontSize: 12)),
      ),
      title: Text(s.name),
      subtitle: hasCoords
          ? Text(
              '${s.lat!.toStringAsFixed(5)}, ${s.lng!.toStringAsFixed(5)}',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            )
          : Text('Sin coordenadas',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
      trailing: hasCoords
          ? IconButton(
              icon: const Icon(Icons.my_location, size: 18),
              onPressed: () {
                _mapController.move(LatLng(s.lat!, s.lng!), 16);
              },
            )
          : null,
    );
  }
}
