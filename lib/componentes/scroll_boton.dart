import 'package:flutter/material.dart';

class ScrollBoton extends StatefulWidget {
  final ScrollController controller;
  final double mostrarDesde;

  const ScrollBoton({
    super.key,
    required this.controller,
    this.mostrarDesde = 300,
  });

  @override
  State<ScrollBoton> createState() => _ScrollBotonState();
}

class _ScrollBotonState extends State<ScrollBoton> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_listenerScroll);
  }

  void _listenerScroll() {
    final mostrar = widget.controller.offset > widget.mostrarDesde;
    if (mostrar != _visible) {
      setState(() => _visible = mostrar);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_listenerScroll);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: _visible ? Offset.zero : const Offset(0, 0.3),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: _visible ? 1 : 0,
        child: GestureDetector(
          onTap: () {
            widget.controller.animateTo(
              0,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.75),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.keyboard_arrow_up,
              size: 22,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}