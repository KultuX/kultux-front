import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppBarPersonalizado extends StatefulWidget implements PreferredSizeWidget{
  final bool logeado;
  final VoidCallback? notificaciones;
  final bool mostrar;
  const AppBarPersonalizado({super.key, this.logeado = false, this.notificaciones, this.mostrar = false});
  @override
  State<AppBarPersonalizado> createState() => _AppBarPersonalizadoState();
  @override
  Size get preferredSize => const Size.fromHeight(70);
}
class _AppBarPersonalizadoState extends State<AppBarPersonalizado>{



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
          if (!widget.logeado)
            Padding(
                padding: const EdgeInsets.only(right:20),
                child:IconButton(
                  icon: SvgPicture.asset(
                    widget.mostrar
                        ? 'assets/iconos/mostrar_notificacion.svg'
                        :'assets/iconos/sin_notificaciones.svg',

                  ),
                  onPressed: (){
                    if (widget.notificaciones != null) {
                      widget.notificaciones!();
                    }
                  },
                )
            )
        ]
    );
  }
}