import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
class BotonesGenerico extends StatelessWidget{
  final String? imagen;
  final String titulo;
  final double? ancho;
  final VoidCallback? pulsar;
  const BotonesGenerico({super.key,required this.titulo, this.imagen, this.ancho, this.pulsar});
  @override
  Widget build(BuildContext context){
    return SizedBox(
        width: ancho,
        height: 40,
        child:Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.black,
                width:1
              )
            ),
            /*boxShadow: [
              BoxShadow(
                color: Colors.black26,
                offset: Offset(0, 0.05),
                blurRadius: 2.5,
                spreadRadius: 0,
              )
            ],*/
            borderRadius: BorderRadius.circular(30)
          ),
          child:ElevatedButton(
              style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                  alignment: .center,
                  backgroundColor: Color.fromARGB(255, 166, 226, 70),
                  elevation: 0,
                shadowColor: Colors.transparent,
                  minimumSize: Size(150, 40)
              ),
              onPressed: pulsar,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: .center,
                children: [
                  Text(
                      titulo,
                      style: TextStyle(
                          fontFamily: 'RobotoCondensed',
                          fontWeight: .bold
                      )
                  ),
                  if (imagen != null) const SizedBox(width: 8),
                  if(imagen != null) SvgPicture.asset(imagen!,)
                ],
              )
          )
        ),
    );
  }

}