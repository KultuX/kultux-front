import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
class BotonesGenerico extends StatelessWidget{
  final String? imagen;
  final String titulo;
  final double? ancho;
  final VoidCallback? pulsar;
  const BotonesGenerico({super.key,required this.titulo, this.imagen, this.ancho, this.pulsar});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: ancho,
      height: 40,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: imagen != null ? 8 : 12),
          backgroundColor: Color.fromARGB(255, 166, 226, 70),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: 0,
        ),
        onPressed: pulsar,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  titulo,
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: 'RobotoCondensed',
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis, // por si acaso
                ),
              ),
            ),
            if (imagen != null) ...[
              SizedBox(width: 4),
              SvgPicture.asset(
                imagen!,
                width: 16,
                height: 16,
              ),
            ],
          ],
        ),
      ),
    );
  }
}