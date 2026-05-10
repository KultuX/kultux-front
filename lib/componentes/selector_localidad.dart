import 'package:flutter/material.dart';
import 'package:kultux/models/localidad.dart';
import 'package:kultux/api/localidadesApi.dart';

class SelectorLocalidad extends StatefulWidget {
  final Localidad? valorInicial;
  final ValueChanged<Localidad?> onSelected;
  final String label;

  const SelectorLocalidad({
    super.key,
    required this.onSelected,
    this.valorInicial,
    this.label = 'Ubicación',
  });

  @override
  State<SelectorLocalidad> createState() => _SelectorLocalidadState();
}

class _SelectorLocalidadState extends State<SelectorLocalidad> {
  late final TextEditingController _controller;
  List<Localidad> _localidades = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _cargarLocalidades();
  }

  Future<void> _cargarLocalidades() async {
    try {
      final lista = await LocalidadApiService.obtenerLocalidadNombres();
      if (!mounted) return;

      _localidades = lista;

      // ✅ aplicar valor inicial REAL
      if (widget.valorInicial != null) {
        final match = lista.firstWhere(
              (l) => l.ine == widget.valorInicial!.ine,
          orElse: () => widget.valorInicial!,
        );
        _controller.text = match.nombre;
        widget.onSelected(match);
      }

      setState(() => _cargando = false);
    } catch (_) {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) return _loader();

    return Autocomplete<Localidad>(
      optionsBuilder: (TextEditingValue value) {
        if (value.text.isEmpty) return const Iterable<Localidad>.empty();
        return _localidades.where(
              (l) => l.nombre.toLowerCase().contains(value.text.toLowerCase()),
        );
      },
      displayStringForOption: (l) => l.nombre,
      onSelected: (loc) {
        _controller.text = loc.nombre;
        widget.onSelected(loc);
      },
      fieldViewBuilder: (context, _, focusNode, __) {
        return TextField(
          controller: _controller,
          focusNode: focusNode,
          decoration: _inputDeco(
            label: widget.label,
            icon: Icons.location_on,
          ),
        );
      },
    );
  }

  Widget _loader() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  InputDecoration _inputDeco({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey.shade100,
      isDense: true,
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide:
        const BorderSide(color: Color.fromARGB(255, 166, 226, 70)),
      ),
      suffixIcon: Icon(icon, size: 16),
    );
  }
}
