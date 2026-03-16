import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kultux/models/usuario.dart';
class GuardadosPage extends StatefulWidget{
  final bool mostrar;
  const GuardadosPage({super.key, this.mostrar = false});
  @override
  State<GuardadosPage> createState() => _GuardadosPageState();
}

class _GuardadosPageState extends State<GuardadosPage> {

  @override
  Widget build(BuildContext context) {
    return
      Center(
          child: Column(
              mainAxisAlignment: .center,
              crossAxisAlignment: .center,
              mainAxisSize: .min,
              children:[
                Text('😰', style: TextStyle(fontFamily: 'RobotoCondensed', fontWeight: .bold, fontSize:100),),
                const SizedBox(height: 30),
                Text('Uppps', style: TextStyle(fontFamily: 'RobotoCondensed', fontWeight: .bold, fontSize: 50),),
                const SizedBox(height: 30),
                Text('Aún no hay actividades guardadas... ¿Por qué no pruebas en \'Inicio\' o \'Buscar\'?'),
                const SizedBox(height: 30),
                Text('¿Por qué no pruebas en \'Inicio\'🏠 o \'Buscar\? 🔍')
              ]
          )
      )
    ;
  }
}