import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CamposPersonalizados extends StatefulWidget{
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
    this.pass = false,
    this.tipo = TextInputType.text,
    this.mostrarError = false,
    required this.controller
  });

  const CamposPersonalizados.password({
    super.key,
    required this.titulo,
    this.ancho = 364,
    this.mostrarError = false,
    required this.controller
  }): pass = true, tipo = TextInputType.text;

  @override
  State<CamposPersonalizados> createState() => _CamposPersonalizadosState();

}

class _CamposPersonalizadosState extends State<CamposPersonalizados>{
  bool _mostrarPass = false;

  Widget? _pref(){
    if(widget.pass){
      return SizedBox(
        width: 15,
        height: 15,
        child: Center(
          child:SvgPicture.asset(
          "assets/iconos/candado_contrasenia.svg",
        ),)
      );
    }
    return null;
  }
  Widget _error(){
    return Padding(
      padding: const EdgeInsets.all(12),
      child: SvgPicture.asset(
          "assets/iconos/error_x.svg"
      ),
    );
  }
  Widget? _suf(){
    if(!widget.pass && widget.mostrarError){
      return _error();
    }
    if(widget.pass){
      return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
        children:[
          IconButton(
            padding: EdgeInsets.zero,
            icon: SvgPicture.asset(
              _mostrarPass
                  ? "assets/iconos/mostrar_contrasenia.svg"
                  :"assets/iconos/ocultar_contrasenia.svg",
              width: 20,
              height: 20,
            ),
            onPressed: (){
              setState(() {
                _mostrarPass = !_mostrarPass;
              });
            },
          ),
          if(widget.mostrarError)_error()
        ]
      );
    }
    return null;
  }
  @override
  Widget build(BuildContext context){
    return SizedBox(
      width: widget.ancho,
      child: TextField(
        controller: widget.controller,
        keyboardType: widget.tipo,
        obscureText: widget.pass ? !_mostrarPass : false,
        decoration: InputDecoration(
          labelText: widget.titulo,
          labelStyle: TextStyle(fontFamily: 'RobotoCondensed'),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10)
          ),
          prefixIcon: _pref(),
          suffixIcon: _suf(),

        )
      )
    );
  }
}