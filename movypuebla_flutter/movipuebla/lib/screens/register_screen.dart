import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;
import '../config.dart';
import 'login_screen.dart';
import 'home_map_screen.dart';
import 'driver_dashboard_screen.dart';

class RegisterScreen extends StatefulWidget {
  static const routeName = '/register';
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;
  String _role = 'citizen'; // citizen o driver

  bool get _firebaseAvailable => Firebase.apps.isNotEmpty;
  final String _baseUrl = getBaseUrl();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      String uid = 'dev-${DateTime.now().millisecondsSinceEpoch}';

      if (_firebaseAvailable) {
        final credential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
        );
        await credential.user?.updateDisplayName(_nameCtrl.text.trim());
        uid = credential.user?.uid ?? uid;
      }

      // Guardar perfil con rol en el backend
      await http.post(
        Uri.parse('$_baseUrl/users'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'uid': uid,
          'name': _nameCtrl.text.trim(),
          'email': _emailCtrl.text.trim(),
          'role': _role,
        }),
      );

      if (!mounted) return;

      if (_role == 'driver') {
        Navigator.of(context).pushReplacementNamed(
          DriverDashboardScreen.routeName,
        );
      } else {
        Navigator.of(context).pushReplacementNamed(HomeMapScreen.routeName);
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String mensaje;
      switch (e.code) {
        case 'email-already-in-use':
          mensaje = 'Ya existe una cuenta con ese correo.';
          break;
        case 'weak-password':
          mensaje = 'La contraseña es muy débil.';
          break;
        default:
          mensaje = e.message ?? 'Error al registrarse.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensaje)),
      );
    } catch (e) {
      if (!mounted) return;
      if (!_firebaseAvailable) {
        // Modo dev: navegar de todos modos
        if (_role == 'driver') {
          Navigator.of(context)
              .pushReplacementNamed(DriverDashboardScreen.routeName);
        } else {
          Navigator.of(context).pushReplacementNamed(HomeMapScreen.routeName);
        }
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (!_firebaseAvailable)
                Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Modo desarrollo: Firebase no configurado.',
                    style: TextStyle(fontSize: 12, color: Colors.orange),
                  ),
                ),

              // Selección de rol
              const Text('¿Cómo usarás MovyPuebla?',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _RoleCard(
                      icon: Icons.person,
                      label: 'Ciudadano',
                      subtitle: 'Buscar rutas',
                      selected: _role == 'citizen',
                      onTap: () => setState(() => _role = 'citizen'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _RoleCard(
                      icon: Icons.directions_bus,
                      label: 'Transportista',
                      subtitle: 'Operar ruta',
                      selected: _role == 'driver',
                      onTap: () => setState(() => _role = 'driver'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Nombre completo'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Campo obligatorio' : null,
              ),
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: 'Correo'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Campo obligatorio' : null,
              ),
              TextFormField(
                controller: _passwordCtrl,
                decoration: const InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
                validator: (v) =>
                    v == null || v.length < 6 ? 'Mínimo 6 caracteres' : null,
              ),
              const SizedBox(height: 16),
              _loading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submit,
                        child: const Text('Registrarme'),
                      ),
                    ),
              TextButton(
                onPressed: () => Navigator.of(context)
                    .pushReplacementNamed(LoginScreen.routeName),
                child: const Text('Ya tengo cuenta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: selected ? Colors.green : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: selected ? Colors.green.shade50 : null,
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: selected ? Colors.green : Colors.grey),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.green : Colors.grey.shade700)),
            Text(subtitle,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }
}
