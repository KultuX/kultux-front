import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TextFieldApp extends StatefulWidget {
  final String title;
  final double width;
  final TextInputType type;
  final bool showError;
  final bool pass;
  final bool? email;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  const TextFieldApp.normal({
    super.key,
    required this.title,
    this.width = 364,
    this.type = TextInputType.text,
    this.showError = false,
    this.pass = false,
    required this.controller,
    this.onChanged,
    this.email = false
  });

  const TextFieldApp.password({
    super.key,
    required this.title,
    this.width = 364,
    this.showError = false,
    required this.controller,
    this.onChanged,
    this.email = false
  }) : pass = true,
       type = TextInputType.text;

  @override
  State<TextFieldApp> createState() => _TextFieldAppState();
}

class _TextFieldAppState extends State<TextFieldApp> {
  bool _showPass = false;

  Widget? _prefix() {
    if (widget.pass) {
      return Padding(
        padding: const EdgeInsets.all(10),
        child: SvgPicture.asset(
          "assets/iconos/candado_contrasenia.svg",
          width: 16,
          height: 16,
          colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
        ),
      );
    }
    if(widget.email != null && widget.email!){
      return Padding(
        padding: const EdgeInsets.all(10),
        child: Icon(
          Icons.email_outlined,
          size: 18,
          color:  Colors.grey.shade500
        )
      );
    }
    return null;
  }

  Widget _iconError() {
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
            color:  Colors.grey.shade300,
            padding: EdgeInsets.zero,
            icon: SvgPicture.asset(
              _showPass
                  ? "assets/iconos/mostrar_contrasenia.svg"
                  : "assets/iconos/ocultar_contrasenia.svg",
              width: 16,
              height: 16,
            ),
            onPressed: () {
              setState(() => _showPass = !_showPass);
            },
          ),
          if (widget.showError) _iconError(),
        ],
      );
    }

    if (widget.showError) {
      return _iconError();
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final bool hayError = widget.showError;

    return SizedBox(
      width: widget.width,
      child: TextField(
        controller: widget.controller,
        keyboardType: widget.type,
        obscureText: widget.pass ? !_showPass : false,
        style: const TextStyle(fontSize: 13),
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          labelText: widget.title,
          labelStyle: TextStyle(
            fontSize: 12,
            color: hayError ? Colors.red : Colors.grey.shade600,
            fontFamily: 'RobotoCondensed',
          ),

          filled: true,
          fillColor: Colors.grey.shade100,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),

          prefixIcon: _prefix(),
          suffixIcon: _suffix(),

          border: _border(Colors.grey.shade300),
          enabledBorder: _border(Colors.grey.shade300),
          focusedBorder: _border(
            hayError ? Colors.red : const Color.fromARGB(255, 166, 226, 70),
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
