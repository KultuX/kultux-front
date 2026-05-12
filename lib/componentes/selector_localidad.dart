import 'package:flutter/material.dart';
import 'package:kultux/models/localidad.dart';

class SelectorLocalidad extends StatefulWidget {
  final List<Localidad> localidades;
  final int? ineInicial;
  final ValueChanged<Localidad?> onSelected;
  final String label;

  const SelectorLocalidad({
    super.key,
    required this.localidades,
    required this.onSelected,
    this.ineInicial,
    this.label = 'Ubicación',
  });

  @override
  State<SelectorLocalidad> createState() => _SelectorLocalidadState();
}

class _SelectorLocalidadState extends State<SelectorLocalidad> {
  late final TextEditingController _controller;
  Localidad? _seleccionada;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    if (widget.ineInicial != null) {
      final match = widget.localidades.where((l) => l.ine == widget.ineInicial).firstOrNull;
      if (match != null) {
        _seleccionada = match;
        _controller.text = match.nombre;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Autocomplete<Localidad>(
      optionsBuilder: (v) {
        if (v.text.isEmpty) return const Iterable<Localidad>.empty();
        return widget.localidades.where(
              (l) => l.nombre.toLowerCase().contains(v.text.toLowerCase()),
        );
      },
      displayStringForOption: (l) => l.nombre,
      onSelected: (loc) {
        setState(() => _seleccionada = loc);
        _controller.text = loc.nombre;
        widget.onSelected(loc);
      },
      fieldViewBuilder: (context, ctrl, focusNode, _) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (ctrl.text != _controller.text) ctrl.text = _controller.text;
        });
        return TextField(
          controller: ctrl,
          focusNode: focusNode,
          style: const TextStyle(fontSize: 13),
          decoration: _inputDeco(ctrl),
        );
      },
      optionsViewBuilder: (context, onSelected, options) => Align(
        alignment: Alignment.topLeft,
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 280,
            child: ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: options.length,
              itemBuilder: (_, i) {
                final o = options.elementAt(i);
                return ListTile(
                  dense: true,
                  title: Text(o.nombre, style: const TextStyle(fontSize: 13)),
                  onTap: () => onSelected(o),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDeco(TextEditingController ctrl) {
    final hasValue = _seleccionada != null;
    return InputDecoration(
      labelText: widget.label,
      labelStyle: TextStyle(fontSize: 12, color: Colors.grey.shade600),
      isDense: true,
      filled: true,
      fillColor: Colors.grey.shade100,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color.fromARGB(255, 166, 226, 70), width: 1),
      ),
      suffixIcon: hasValue
          ? GestureDetector(
        onTap: () {
          setState(() => _seleccionada = null);
          ctrl.clear();
          widget.onSelected(null);
        },
        child: Icon(Icons.clear, size: 16, color: Colors.grey.shade600),
      )
          : Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
    );
  }
}