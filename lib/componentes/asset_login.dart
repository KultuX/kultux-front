import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kultux/componentes/botones.dart';
import 'package:kultux/componentes/text_fields.dart';
import 'package:kultux/registro.dart';

class AssetLogin extends StatefulWidget{
  final VoidCallback? cerrar;
  final VoidCallback? logeado;
  const AssetLogin({super.key, this.cerrar, this.logeado});
  @override
  State<AssetLogin> createState() => _AssetLoginState();
}

class _AssetLoginState extends State<AssetLogin>{
  @override
  Widget build(BuildContext context){

    return Stack(

      children:[
        GestureDetector(
          onTap: widget.cerrar,
          child: Container(color: Colors.black54)
        ),
        Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 358.16,
              height: 475.2,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black26)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min, // ⚡ se ajusta al contenido
                children:[
                  Image.asset('assets/images/logo_login.png', width:90,height: 90,),
                  const SizedBox(height: 15),
                  CamposPersonalizados.normal(
                      titulo: 'Correo electrónico',
                      ancho:321
                  ),
                  const SizedBox(height: 15),
                  CamposPersonalizados.password(titulo: 'Contraseña',ancho:321),
                  const SizedBox(height: 8),
                  Row(
                    children:[
                      Checkbox(
                        value: false,
                        onChanged: (valor){},
                        checkColor: Color.fromARGB(255, 166, 226, 70) ,
                        activeColor: Colors.grey[200],
                        semanticLabel: 'Mantener sesión iniciada',
                      ),
                      Text('Mantener la sesión iniciada',style: TextStyle(fontFamily: 'RobotoCondensed',)),
                      const SizedBox(height: 20),
                      //Text("He olvidado mi contraseña",style: TextStyle(fontFamily: 'RobotoCondensed'),)
                    ],
                  ),
                  const SizedBox(height: 10),
                  BotonesGenerico(titulo:"Iniciar sesión", ancho:194, pulsar: widget.logeado),
                  const SizedBox(height: 10),
                  BotonesGenerico(
                      titulo:"Registrarse",
                      ancho:194,
                      pulsar:(){
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder:(context) => RegistroPage()
                            )
                        );}
                      ),
                  const SizedBox(height: 10),
                  BotonesGenerico(titulo:"Entrar como invitado",imagen:"assets/iconos/invitado.svg", ancho:194, pulsar: widget.logeado),

                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}