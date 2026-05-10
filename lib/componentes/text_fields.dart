import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CamposPersonalizados extends StatefulWidget {
  final String titulo;
  final double ancho;
  final TextInputType tipo;
  final bool mostrarError;
  final bool pass;
  final TextEditingController controller;

  const CamposPersonalizados.normal({
    super.key,
    required this.titulo,
    this.ancho = 364,
    this.tipo = TextInputType.text,
    this.mostrarError = false,
    this.pass = false,
    required this.controller,
  });

  const CamposPersonalizados.password({
    super.key,
    required this.titulo,
    this.ancho = 364,
    this.mostrarError = false,
    required this.controller,
  })  : pass = true,
        tipo = TextInputType.text;

  @override
  State<CamposPersonalizados> createState() => _CamposPersonalizadosState();
}

class _CamposPersonalizadosState extends State<CamposPersonalizados> {
  bool _mostrarPass = false;

  /*──────────── ICONOS ────────────*/

  Widget? _prefix() {
    if (widget.pass) {
      return Padding(
        padding: const EdgeInsets.all(10),
        child: SvgPicture.asset(
          "assets/iconos/candado_contrasenia.svg",
          width: 16,
          height: 16,
          colorFilter:
          const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
        ),
      );
    }
    return null;
  }

  Widget _iconoError() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: SvgPicture.asset(
        "assets/iconos/error_x.svg",
        width: 16,
        height: 16,
      ),
    );
  }

  Widget? _suffix() {
    if (widget.pass) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            icon: SvgPicture.asset(
              _mostrarPass
                  ? "assets/iconos/mostrar_contrasenia.svg"
                  : "assets/iconos/ocultar_contrasenia.svg",
              width: 18,
              height: 18,
            ),
            onPressed: () {
              setState(() => _mostrarPass = !_mostrarPass);
            },
          ),
          if (widget.mostrarError) _iconoError(),
        ],
      );
    }

    if (widget.mostrarError) {
      return _iconoError();
    }

    return null;
  }

  /*──────────── UI ────────────*/

  @override
  Widget build(BuildContext context) {
    final bool hayError = widget.mostrarError;

    return SizedBox(
      width: widget.ancho,
      child: TextField(
        controller: widget.controller,
        keyboardType: widget.tipo,
        obscureText: widget.pass ? !_mostrarPass : false,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          labelText: widget.titulo,
          labelStyle: TextStyle(
            fontSize: 12,
            color: hayError ? Colors.red : Colors.grey.shade600,
            fontFamily: 'RobotoCondensed',
          ),

          filled: true,
          fillColor: Colors.grey.shade100,
          isDense: true,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),

          prefixIcon: _prefix(),
          suffixIcon: _suffix(),

          border: _border(Colors.grey.shade300),
          enabledBorder: _border(Colors.grey.shade300),
          focusedBorder: _border(
            hayError
                ? Colors.red
                : const Color.fromARGB(255, 166, 226, 70),
            width: 1.5,
          ),
          errorBorder: _border(Colors.red),
          focusedErrorBorder: _border(Colors.red, width: 1.5),
        ),
      ),
    );
  }

  OutlineInputBorder _border(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}