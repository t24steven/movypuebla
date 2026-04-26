import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../config.dart';
import '../models/route_model.dart';

class DriverDashboardScreen extends StatefulWidget {
  static const routeName = '/driver-dashboard';
  const DriverDashboardScreen({super.key});

  @override
  State<DriverDashboardScreen> createState() => _DriverDashboardScreenState();
}

class _DriverDashboardScreenState extends State<DriverDashboardScreen> {
  final String _baseUrl = getBaseUrl();
  String _status = 'inactive'; // inactive, active, break
  RouteModel? _assignedRoute;
  bool _loading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final routeId = args?['assignedRouteId'] as String?;
    if (routeId != null && _assignedRoute == null) {
      _loadAssignedRoute(routeId);
    } else {
      _loading = false;
    }
  }

  Future<void> _loadAssignedRoute(String routeId) async {
    try {
      final uri = Uri.parse('$_baseUrl/routes/$routeId');
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        setState(() {
          _assignedRoute = RouteModel.fromJson(data);
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('Error cargando ruta asignada: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  void _toggleStatus() {
    setState(() {
      switch (_status) {
        case 'inactive':
          _status = 'active';
          break;
        case 'active':
          _status = 'break';
          break;
        case 'break':
          _status = 'inactive';
          break;
      }
    });
  }

  Color get _statusColor {
    switch (_status) {
      case 'active':
        return Colors.green;
      case 'break':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String get _statusText {
    switch (_status) {
      case 'active':
        return 'En servicio';
      case 'break':
        return 'En descanso';
      default:
        return 'Fuera de servicio';
    }
  }

  IconData get _statusIcon {
    switch (_status) {
      case 'active':
        return Icons.directions_bus;
      case 'break':
        return Icons.pause_circle;
      default:
        return Icons.power_settings_new;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel Transportista'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () =>
                Navigator.of(context).pushReplacementNamed('/login'),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Estado actual
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Icon(_statusIcon, size: 64, color: _statusColor),
                          const SizedBox(height: 8),
                          Text(
                            _statusText,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: _statusColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _statusColor,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                              ),
                              onPressed: _toggleStatus,
                              icon: const Icon(Icons.swap_horiz),
                              label: Text(_status == 'inactive'
                                  ? 'Iniciar servicio'
                                  : _status == 'active'
                                      ? 'Tomar descanso'
                                      : 'Finalizar turno'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Ruta asignada
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Ruta asignada',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 8),
                          if (_assignedRoute != null) ...[
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                backgroundColor: Colors.green,
                                child: Text(_assignedRoute!.code,
                                    style:
                                        const TextStyle(color: Colors.white)),
                              ),
                              title: Text(_assignedRoute!.name),
                              subtitle: Text(
                                  'Tarifa: ${_assignedRoute!.baseFareMin.toStringAsFixed(2)} - ${_assignedRoute!.baseFareMax.toStringAsFixed(2)} MXN'),
                            ),
                          ] else
                            const Text(
                              'Sin ruta asignada. Contacta al administrador.',
                              style: TextStyle(color: Colors.grey),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Estadísticas del día
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Hoy',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _statItem(Icons.route, '0', 'Viajes'),
                              _statItem(Icons.schedule, '0h', 'Tiempo'),
                              _statItem(Icons.people, '0', 'Pasajeros'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _statItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.green, size: 28),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      ],
    );
  }
}
