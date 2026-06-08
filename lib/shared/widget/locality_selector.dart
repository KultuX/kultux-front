import 'package:flutter/material.dart';
import 'package:kultux/core/models/location.dart';
import 'package:kultux/core/utils/formatter.dart';

class LocalitySelector extends StatefulWidget {
  final List<Location> locations;
  final int? startLocation;
  final ValueChanged<Location?> onSelected;
  final String label;

  const LocalitySelector({
    super.key,
    required this.locations,
    required this.onSelected,
    this.startLocation,
    this.label = 'Localidad',
  });

  @override
  State<LocalitySelector> createState() => _LocalitySelectorState();
}

class _LocalitySelectorState extends State<LocalitySelector> {
  late final TextEditingController _controller;
  Location? _selected;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();

    _focusNode = FocusNode();
    _controller = TextEditingController();
    if (widget.startLocation != null) {
      final match = widget.locations
          .where((l) => l.ine == widget.startLocation)
          .firstOrNull;
      if (match != null) {
        _selected = match;
        _controller.text = match.name;
      }
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Autocomplete<Location>(
      optionsBuilder: (v) {
        if (v.text.isEmpty) return const Iterable<Location>.empty();
        return widget.locations.where(
          (l) => accentFormatter(l.name).contains(accentFormatter(v.text)),
        );
      },
      displayStringForOption: (l) => l.name,
      onSelected: (loc) {
        setState(() => _selected = loc);
        _controller.text = loc.name;
        widget.onSelected(loc);
      },
      fieldViewBuilder: (context, ctrl, internalFocusNode, _) {
        if (_selected != null && ctrl.text.isEmpty) {
          ctrl.text = _selected!.name;
        }
        return TextField(
          controller: ctrl,
          focusNode: internalFocusNode,
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
                  title: Text(o.name, style: const TextStyle(fontSize: 13)),
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
    final hasValue = _selected != null;
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
        borderSide: const BorderSide(
          color: Color.fromARGB(255, 166, 226, 70),
          width: 1,
        ),
      ),
      suffixIcon: hasValue
          ? GestureDetector(
              onTap: () {
                setState(() => _selected = null);
                ctrl.clear();
                widget.onSelected(null);
              },
              child: Icon(Icons.clear, size: 16, color: Colors.grey.shade600),
            )
          : Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
    );
  }
}
