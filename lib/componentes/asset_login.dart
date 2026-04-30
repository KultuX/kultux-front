import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kultux/componentes/botones.dart';
import 'package:kultux/componentes/text_fields.dart';
import 'package:kultux/registro.dart';
import 'package:kultux/models/usuario.dart';
import 'package:kultux/api/usuariosAPI.dart';
import 'package:kultux/repository/usuario_repository.dart';

class AssetLogin extends StatefulWidget{
  final VoidCallback? cerrar;
  final void Function(Usuario usuario)? logeado;
  final VoidCallback? invitado;

  const AssetLogin({super.key, this.cerrar, this.logeado, this.invitado});
  @override
  State<AssetLogin> createState() => _AssetLoginState();
}

class _AssetLoginState extends State<AssetLogin>{

  TextEditingController email = TextEditingController();
  TextEditingController pass = TextEditingController();

  bool _errorEmail = false;
  bool _errorPass = false;
  bool _checked = false;
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
                      ancho:321,
                    controller: email,
                    mostrarError: _errorEmail,
                  ),
                  const SizedBox(height: 15),
                  CamposPersonalizados.password(
                    titulo: 'Contraseña',
                    ancho:321,
                    controller: pass,
                    mostrarError: _errorPass,
                  ),
                  const SizedBox(height: 40),
                 /* Row(
                    children:[
                      Checkbox(
                          value: _checked,
                          onChanged: (valor) => setState(()=> _checked = valor ?? false),
                          checkColor: Colors.black,
                          fillColor: MaterialStateProperty.resolveWith<Color?>((states) {
                            if (states.contains(MaterialState.selected)) {
                              return Color.fromARGB(255, 166, 226, 70); // verde solo al marcar
                            }
                            return null; // fondo transparente al desmarcar → borde intacto
                          }),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5), // hace las esquinas redondeadas
                            side: BorderSide(color: Colors.black26, width: 1), // borde del checkbox
                          )
                      ),
                      /*Text('Mantener la sesión iniciada',style: TextStyle(fontFamily: 'RobotoCondensed',)),*/
                      const SizedBox(height: 20),
                      //Text("He olvidado mi contraseña",style: TextStyle(fontFamily: 'RobotoCondensed'),)
                    ],
                  ),
                  const SizedBox(height: 10),*/

                  BotonesGenerico(
                    titulo:"Iniciar sesión",
                    ancho:194,
                    pulsar: () async{
                      setState(() {
                        _errorEmail = false;
                        _errorPass = false;
                      });

                      if (email.text.trim().isEmpty && pass.text.trim().isEmpty) {
                        _errorEmail = true;
                        _errorPass = true;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              showCloseIcon: true,
                              content: Text(textAlign: .center, "⚠️ Debes introducir correo y contraseña.")),
                        );
                        return;
                      }

                      if(email.text.trim().isEmpty) {
                        setState(() {
                          _errorEmail = true;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              showCloseIcon: true,
                              content: Text(textAlign: .center, "⚠️ Introduce un correo.")),
                        );
                        return;
                      }

                     if(pass.text.trim().isEmpty) {
                        setState(() {
                          _errorPass = true;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(

                          const SnackBar(
                              showCloseIcon: true,
                              content: Text(textAlign: .center, "⚠️ Introduce una contraseña.")),
                        );
                        return;
                      }



                      final usuarioLogin = Usuario.login(email.text, pass.text);
                      try {
                      // Llamada a la API
                      Usuario usuario = await UsuarioApiService.loginUsuario(usuarioLogin);
                      await UsuarioRepository.guardar(usuario);

                      // Mostrar mensaje de bienvenida
                      ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          showCloseIcon: true,
                          content: Text(textAlign: .center,"👋🏻 ¡¡Bienvenid@, ${usuario.nombre!.toUpperCase() ?? usuario.email}!!👋🏻")),
                      );

                      // Ejecutar callback y pasar el usuario
                      if (widget.logeado != null) widget.logeado!(usuario);

                      } catch (e) {
                        _errorEmail = true;
                        _errorPass = true;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            showCloseIcon: true,
                            content: Text(textAlign: .center,"⚠️ Usuario o contraseña incorrectos.")),
                        );
                      }
                    },

                    //widget.logeado,
                  ),
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
                  BotonesGenerico(titulo:"Entrar como invitado",imagen:"assets/iconos/invitado.svg", ancho:194, pulsar: widget.invitado),

                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}