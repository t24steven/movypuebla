import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Botón flotante de pánico. Al presionarlo muestra opciones de emergencia.
class PanicButton extends StatelessWidget {
  const PanicButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'panic',
      backgroundColor: Colors.red,
      onPressed: () => _showPanicDialog(context),
      child: const Icon(Icons.sos, color: Colors.white, size: 28),
    );
  }

  void _showPanicDialog(BuildContext context) {
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
            const Icon(Icons.warning_amber_rounded,
                color: Colors.red, size: 48),
            const SizedBox(height: 8),
            const Text(
              'Emergencia',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Selecciona una opción de ayuda',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),

            // Llamar al 911
            _EmergencyOption(
              icon: Icons.phone,
              color: Colors.red,
              title: 'Llamar al 911',
              subtitle: 'Emergencias generales',
              onTap: () {
                Navigator.pop(ctx);
                _call('911');
              },
            ),
            const SizedBox(height: 8),

            // Llamar a policía municipal
            _EmergencyOption(
              icon: Icons.local_police,
              color: Colors.blue,
              title: 'Policía Municipal Puebla',
              subtitle: '222 309 4400',
              onTap: () {
                Navigator.pop(ctx);
                _call('2223094400');
              },
            ),
            const SizedBox(height: 8),

            // Enviar SMS de emergencia
            _EmergencyOption(
              icon: Icons.message,
              color: Colors.orange,
              title: 'SMS de emergencia',
              subtitle: 'Enviar ubicación por mensaje',
              onTap: () {
                Navigator.pop(ctx);
                _sendEmergencySms(context);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _call(String number) async {
    final uri = Uri.parse('tel:$number');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _sendEmergencySms(BuildContext context) async {
    // Mensaje predeterminado con solicitud de ayuda
    const message = 'EMERGENCIA MovyPuebla: Necesito ayuda. '
        'Estoy usando transporte público en Puebla.';

    final uri = Uri.parse('sms:911?body=$message');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

class _EmergencyOption extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _EmergencyOption({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(color: color.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.1),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(subtitle,
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}
