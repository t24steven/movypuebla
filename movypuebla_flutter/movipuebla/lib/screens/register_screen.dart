import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'login_screen.dart';
import 'home_map_screen.dart';

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

  bool get _firebaseAvailable => Firebase.apps.isNotEmpty;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      if (_firebaseAvailable) {
        final credential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
        );
        await credential.user?.updateDisplayName(_nameCtrl.text.trim());
      }
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(HomeMapScreen.routeName);
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
        case 'invalid-email':
          mensaje = 'Correo no válido.';
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
        Navigator.of(context).pushReplacementNamed(HomeMapScreen.routeName);
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al registrarse: $e')),
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
                    'El registro se omitirá temporalmente.',
                    style: TextStyle(fontSize: 12, color: Colors.orange),
                  ),
                ),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Nombre completo'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Campo obligatorio' : null,
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
                      child: const Text('Registrarme'),
                    ),
              TextButton(
                onPressed: () {
                  Navigator.of(context)
                      .pushReplacementNamed(LoginScreen.routeName);
                },
                child: const Text('Ya tengo cuenta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
