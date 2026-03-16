import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kultux/models/usuario.dart';
class NotificacionesPage extends StatefulWidget{
  final bool mostrar;
  const NotificacionesPage({super.key, this.mostrar = false});
  @override
  State<NotificacionesPage> createState() => _NotificacionesPageState();
}

class _NotificacionesPageState extends State<NotificacionesPage> {

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
              Text('Aún no hay actividades guardadas ni asistencias para notificar')
            ]
            )
        )
    ;
  }
}