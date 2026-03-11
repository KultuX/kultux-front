import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppBarPersonalizado extends StatefulWidget implements PreferredSizeWidget{
  const AppBarPersonalizado({super.key});
  @override
  State<AppBarPersonalizado> createState() => _AppBarPersonalizadoState();
  @override
  Size get preferredSize => const Size.fromHeight(70);
}
class _AppBarPersonalizadoState extends State<AppBarPersonalizado>{
  //List<String> _modos = ['sin', 'con', 'abierto'];
  bool _iconoActivo = false;
  @override
  Widget build(BuildContext context) {
    return AppBar(
      //toolbarHeight: 70,
      leading: Padding(
          padding: const EdgeInsets.only(left:10),
          child: Image.asset(
            'assets/images/logo_kultux.png',
            width: 30,
            height: 30,

          )
      ),
      backgroundColor: Colors.black,
        actions: [
          Padding(
              padding: const EdgeInsets.only(right:20),
              child:IconButton(
                icon: SvgPicture.asset(
                  _iconoActivo
                      ? 'assets/iconos/mostrar_notificacion.svg'
                      :'assets/iconos/sin_notificaciones.svg',

                ),
                onPressed: (){
                  setState(() {
                    _iconoActivo = !_iconoActivo;
                  });
                },
              ))
        ]
    );
  }
}