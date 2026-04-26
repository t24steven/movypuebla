import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'register_screen.dart';
import 'home_map_screen.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;

  bool get _firebaseAvailable => Firebase.apps.isNotEmpty;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      if (_firebaseAvailable) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
        );
      }
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(HomeMapScreen.routeName);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String mensaje;
      switch (e.code) {
        case 'user-not-found':
          mensaje = 'No existe una cuenta con ese correo.';
          break;
        case 'wrong-password':
          mensaje = 'Contraseña incorrecta.';
          break;
        case 'invalid-email':
          mensaje = 'Correo no válido.';
          break;
        default:
          mensaje = e.message ?? 'Error al iniciar sesión.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensaje)),
      );
    } catch (e) {
      if (!mounted) return;
      // Si Firebase no está configurado, dejar pasar al home de todos modos
      if (!_firebaseAvailable) {
        Navigator.of(context).pushReplacementNamed(HomeMapScreen.routeName);
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al iniciar sesión: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar sesión')),
      body: Padding(
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
                    'Modo desarrollo: Firebase no configurado. '
                    'El login se omitirá temporalmente.',
                    style: TextStyle(fontSize: 12, color: Colors.orange),
                  ),
                ),
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: 'Correo'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Campo obligatorio' : null,
              ),
              TextFormField(
                controller: _passwordCtrl,
                decoration: const InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
                validator: (value) => value == null || value.length < 6
                    ? 'Mínimo 6 caracteres'
                    : null,
              ),
              const SizedBox(height: 16),
              _loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _submit,
                      child: const Text('Entrar'),
                    ),
              TextButton(
                onPressed: () {
                  Navigator.of(context)
                      .pushReplacementNamed(RegisterScreen.routeName);
                },
                child: const Text('Crear cuenta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
