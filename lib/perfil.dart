import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kultux/componentes/botones.dart';
import 'package:kultux/main.dart';
import 'package:kultux/models/usuario.dart';
class PerfilPage extends StatefulWidget{
  final VoidCallback cerrarSesion;
  final Usuario? usuario;
  const PerfilPage({super.key, required this.cerrarSesion, this.usuario});
  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage>{
  final _opciones = {
    'Editar perfil': 'assets/iconos/editar_perfil.svg',
    'Guardados' : 'assets/iconos/guardados.svg',
    'Notificaciones activadas' : 'assets/iconos/sin_notificaciones.svg',
    //'Idioma Español' : 'assets/iconos/idiomas.svg',
    'Contacta con nosotros' : 'assets/iconos/contactar_nosotros.svg',
    'Términos y condiciones':'assets/iconos/terminos_condiciones.svg',
    'Política de privacidad': 'assets/iconos/politica_privacidad.svg'
  };
  
  @override
  Widget build(BuildContext context){
    return SingleChildScrollView(
        child: Column(
            crossAxisAlignment: .stretch,
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
                          Text(widget.usuario?.nombre ?? 'Nombre usuario' , style: TextStyle(fontFamily: 'RobotoCondensed',fontSize: 20)),
                          const SizedBox(height: 8,),
                          Text(widget.usuario?.email ?? 'correo@correo.com', style: TextStyle(fontFamily: 'RobotoCondensed',))
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
                      trailing: SvgPicture.asset("assets/iconos/flecha_siguiente.svg"),
                          onTap: (){
                            if(texto == 'Contacta con nosotros'){
                              _mostrarContacto();
                            }else{
                              _mostrarProximamente();
                            }
                          },
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
                  _confirmarCerrarSesion();
                },),
              const SizedBox(width: 20,),
              BotonesGenerico(titulo: "Eliminar cuenta"),
              ],
            ), const SizedBox(height: 20),
          ]
        )
    );
  }

 Future<void> _mostrarContacto() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Contacta con nosotros'),
          content: Column(
            mainAxisSize: MainAxisSize.min, // Corregido
            crossAxisAlignment: CrossAxisAlignment.start, // Corregido
            children: [
              SvgPicture.asset("assets/iconos/contactar_nosotros.svg"), // ¡falta la coma!
              const SizedBox(height: 8), // opcional, para separar imagen y texto
              const Text(
                  'Si tienes cualquier duda o sugerencia, pueden contactarnos en los siguientes correos electrónicos:'
              ),
              _textoConLink(normal: '1: ', link: 'smmoninog01@iesalbarregas.es'),
              _textoConLink(normal: '2: ', link: 'cmaciasi01@iesalbarregas.es'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmarCerrarSesion()async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cerrar sesión', textAlign: .center,),
            content: Column(
              mainAxisAlignment: .center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('⚠️', style: TextStyle(fontSize: 50)),
                const SizedBox(height: 16),
                const Text('¿Estás segur@ de que quieres cerrar sesión?', textAlign: .center,),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                        width:120,
                        child:ElevatedButton(
                          onPressed: (){
                            Navigator.of(context).pop();
                            },
                          child: Text('Cancelar'
                          ),
                        )
                    ),
                    const SizedBox(width: 10),
                    BotonesGenerico(
                      titulo: 'Cerrar sesión',
                      ancho: 120,
                      pulsar: () {
                        Navigator.of(context).pop();
                        widget.cerrarSesion();
                      },
                    ),
                  ],
                )
              ],
            ),
        );
      },
    );
  }


  Widget _textoConLink({required String normal, required String link}){
    return RichText(
        text: TextSpan(
            style: TextStyle(
                fontFamily: 'RobotoCondensed',
                color: Colors.black,
                fontSize: 14
            ),
            children: [
              TextSpan(text:normal),
              TextSpan(
                text: link,
                style: TextStyle(

                    color:Colors.blue,
                    decoration: .underline
                ),
              )
            ]
        )
    );
  }

  Future<void> _mostrarProximamente() async{
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Color.fromARGB(255, 166, 226, 70),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.construction,
                size: 60,
                color: Colors.black,
              ),
              const SizedBox(height: 20),
              const Text(
                'Próximamente',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const CircularProgressIndicator(
                color: Colors.white,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Cerrar',
                  style: TextStyle(color: Colors.black),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}