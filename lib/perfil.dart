import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kultux/componentes/botones.dart';
import 'package:kultux/main.dart';
class PerfilPage extends StatefulWidget{
  final VoidCallback cerrarSesion;
  const PerfilPage({super.key, required this.cerrarSesion});
  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage>{
  final _opciones = {
    'Editar perfil': 'assets/iconos/editar_perfil.svg',
    'Guardados' : 'assets/iconos/guardados.svg',
    'Notificaciones activadas' : 'assets/iconos/sin_notificaciones.svg',
    //'Idioma Español' : 'assets/iconos/idiomas.svg',
    'Contacta con nostros' : 'assets/iconos/contactar_nosotros.svg',
    'Términos y condiciones':'assets/iconos/terminos_condiciones.svg',
    'Política de privacidad': 'assets/iconos/politica_privacidad.svg'
  };
  
  @override
  Widget build(BuildContext context){
    return SingleChildScrollView(
        child: Column(
            crossAxisAlignment: .center,
            children: [
              Card(
                  elevation: 4,
                  margin: const EdgeInsets.all(16),
                  child:Padding(
                    padding: const EdgeInsets.all(16),
                    child:Column(
                        children:[
                          CircleAvatar(
                              radius: 90,
                              backgroundImage: AssetImage("assets/images/logo_registro.png")
                          ),
                          const SizedBox(height: 8,),
                          Text('Nombre usuario', style: TextStyle(fontFamily: 'RobotoCondensed',fontSize: 20)),
                          const SizedBox(height: 8,),
                          Text('correo@correo.com')
                        ]
                    ),
                  )
              ),
              ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: _opciones.length,
                        itemBuilder: (context, index){
                    final texto = _opciones.keys.elementAt(index);
                    final icono = _opciones.values.elementAt(index);
                    return Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child:ListTile(
                      leading: SvgPicture.asset(icono, colorFilter: ColorFilter.mode(Colors.black, BlendMode.srcIn),),
                      title: Text(texto),
                      trailing: SvgPicture.asset("assets/iconos/flecha_siguiente.svg")
                    ));
                  }
                ),
              const SizedBox(height: 16),
            Row(mainAxisAlignment: .center,
              children: [
              BotonesGenerico(
                titulo: "Cerrar sesión",
               // imagen: "assets/iconos/",
                pulsar: (){
                widget.cerrarSesion();
                },),
              const SizedBox(width: 20,),
              BotonesGenerico(titulo: "Eliminar cuenta"),
              ],
            ), const SizedBox(height: 20),
          ]
        )
    );
  }

  Widget _opcionesElemento({required String titulo, required String pathIcono}){
    return Container(
      child: Row(
        children:[
          SvgPicture.asset(pathIcono),
          Text(titulo),
          SvgPicture.asset("assets/iconos/flecha_siguiente.svg")
        ]

      ),
    );
  }
}