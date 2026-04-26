import 'dart:async';
import 'package:flutter/material.dart';
import '../services/nominatim_service.dart';

/// Campo de texto con autocompletado de lugares vía Nominatim.
/// Llama [onPlaceSelected] cuando el usuario elige un resultado.
class PlaceSearchField extends StatefulWidget {
  final String label;
  final IconData icon;
  final void Function(NominatimPlace place) onPlaceSelected;

  const PlaceSearchField({
    super.key,
    required this.label,
    required this.icon,
    required this.onPlaceSelected,
  });

  @override
  State<PlaceSearchField> createState() => _PlaceSearchFieldState();
}

class _PlaceSearchFieldState extends State<PlaceSearchField> {
  final TextEditingController _controller = TextEditingController();
  List<NominatimPlace> _suggestions = [];
  bool _loading = false;
  Timer? _debounce;

  void _onChanged(String value) {
    // Debounce de 500ms para no saturar Nominatim
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _search(value);
    });
  }

  Future<void> _search(String query) async {
    if (query.length < 3) {
      setState(() => _suggestions = []);
      return;
    }
    setState(() => _loading = true);
    try {
      final results = await NominatimService.search(query);
      if (mounted) setState(() => _suggestions = results);
    } catch (_) {
      // Silenciar errores de red en autocompletado
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _selectPlace(NominatimPlace place) {
    // Mostrar solo la parte corta del nombre
    final shortName = place.displayName.split(',').first;
    _controller.text = shortName;
    setState(() => _suggestions = []);
    widget.onPlaceSelected(place);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            labelText: widget.label,
            prefixIcon: Icon(widget.icon),
            suffixIcon: _loading
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : null,
          ),
          onChanged: _onChanged,
        ),
        if (_suggestions.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxHeight: 150),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(4),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                final place = _suggestions[index];
                return ListTile(
                  dense: true,
                  leading: const Icon(Icons.location_on, size: 18),
                  title: Text(
                    place.displayName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13),
                  ),
                  onTap: () => _selectPlace(place),
                );
              },
            ),
          ),
      ],
    );
  }
}
