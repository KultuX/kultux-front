import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:kultux/componentes/text_fields.dart';
import 'package:kultux/registro.dart';
import 'package:kultux/models/usuario.dart';
import 'package:kultux/api/usuariosAPI.dart';
import 'package:kultux/repository/usuario_repository.dart';
import 'package:kultux/componentes/modal_alerta.dart';

const _verde = Color(0xFFA6E246);
const _fondoCard = Color(0xFFF8F7F4);
const _texto = Color(0xFF1A1A1A);
const _textoSuave = Color(0xFF6B6B6B);
const _borde = Color(0xFFE0DDD6);

class AssetLogin extends StatefulWidget {
  final VoidCallback? cerrar;
  final void Function(Usuario usuario)? logeado;
  final VoidCallback? invitado;

  const AssetLogin({super.key, this.cerrar, this.logeado, this.invitado});

  @override
  State<AssetLogin> createState() => _AssetLoginState();
}

class _AssetLoginState extends State<AssetLogin> {
  final TextEditingController email = TextEditingController();
  final TextEditingController pass = TextEditingController();

  bool _errorEmail = false;
  bool _errorPass = false;
  bool _checked = false;

  Future<void> _iniciarSesion() async {
    setState(() { _errorEmail = false; _errorPass = false; });

    if (email.text.trim().isEmpty && pass.text.trim().isEmpty) {
      setState(() { _errorEmail = true; _errorPass = true; });
      Alerta.show(context,mensaje:'Debes introducir correo y contraseña.' , tipo: TipoAviso.warning);

      return;
    }
    if (email.text.trim().isEmpty) {
      setState(() => _errorEmail = true);
      Alerta.show(context,mensaje:'Introduce un correo' , tipo: TipoAviso.warning);
      return;
    }
    if (pass.text.trim().isEmpty) {
      setState(() => _errorPass = true);
      Alerta.show(context,mensaje:'Introduce una contraseña.' , tipo: TipoAviso.warning);
      return;
    }

    try {
      final usuario = await UsuarioApiService.loginUsuario(
        Usuario.login(email.text, pass.text),
      );
      if (_checked) await UsuarioRepository.guardar(usuario);

      Alerta.show(context,mensaje:'👋🏻 ¡¡Bienvenid@, ${usuario.nombre?.toUpperCase() ?? usuario.email}!!', tipo: TipoAviso.success );
      widget.logeado?.call(usuario);
    } catch (_) {
      setState(() { _errorEmail = true; _errorPass = true; });
      Alerta.show(context,mensaje:'Usuario o contraseña incorrectos.', tipo: TipoAviso.error );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Fondo semitransparente
        GestureDetector(
          onTap: widget.cerrar,
          child: Container(color: Colors.black54),
        ),

        Center(
          child: Material(
            color: Colors.transparent,
            child: SingleChildScrollView(
            child: Container(
              width: 360,
              decoration: BoxDecoration(
                color: _fondoCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _borde),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 24,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 18),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF1a1a1a), Color(0xFF2d2d2d)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: 0, right: 0,
                          child: Opacity(
                            opacity: 0.12,
                            child: Container(
                              width: 60, height: 60,
                              decoration: BoxDecoration(
                                color: _verde,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset('assets/images/logo_login.png',
                                width: 44, height: 44),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Kultux',
                                    style: TextStyle(
                                        fontSize: 11, color: Color(0xFFb0b0b0))),
                                const SizedBox(height: 2),
                                const Text('Iniciar sesión',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white)),
                                const SizedBox(height: 5),
                                Container(
                                  width: 30, height: 2,
                                  decoration: BoxDecoration(
                                    color: _verde,
                                    borderRadius: BorderRadius.circular(1),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _Campo(child: CamposPersonalizados.normal(
                          titulo: 'Correo electrónico',
                          controller: email,
                          mostrarError: _errorEmail,
                          tipo: TextInputType.emailAddress,
                        )),
                        const SizedBox(height: 10),
                        _Campo(child: CamposPersonalizados.password(
                          titulo: 'Contraseña',
                          controller: pass,
                          mostrarError: _errorPass,
                        )),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),

                          child: Row(
                            children: [
                              SizedBox(
                                width: 24, height: 24,
                                child: Checkbox(
                                  value: _checked,
                                  onChanged: (v) =>
                                      setState(() => _checked = v ?? false),
                                  checkColor: _texto,
                                  materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                                  fillColor: WidgetStateProperty.resolveWith(
                                        (s) => s.contains(WidgetState.selected)
                                        ? _verde
                                        : null,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text('Mantener la sesión iniciada',
                                  style: TextStyle(
                                      fontFamily: 'RobotoCondensed',
                                      fontSize: 13,
                                      color: _textoSuave)),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: _iniciarSesion,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: _verde,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Center(
                              child: Text('Iniciar sesión',
                                  style: TextStyle(
                                      fontFamily: 'RobotoCondensed',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: _texto)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: widget.invitado,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: _borde, width: 1.5),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.person_outline,
                                    size: 16, color: _textoSuave),
                                SizedBox(width: 6),
                                Text('Entrar como invitado',
                                    style: TextStyle(
                                        fontFamily: 'RobotoCondensed',
                                        fontSize: 13,
                                        color: _textoSuave)),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),
                        Center(
                          child: RichText(
                            text: TextSpan(
                              text: '¿No tienes cuenta? ',
                              style: const TextStyle(
                                  fontFamily: 'RobotoCondensed',
                                  fontSize: 13,
                                  color: _textoSuave),
                              children: [
                                TextSpan(
                                  text: 'Regístrate',
                                  style: const TextStyle(
                                      fontFamily: 'RobotoCondensed',
                                      fontSize: 13,
                                      color: _verde,
                                      fontWeight: FontWeight.w700,
                                      decoration: TextDecoration.underline,
                                      decorationColor: _verde),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => RegistroPage()),
                                    ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            )),
          ),
        ),
      ],
    );
  }
}

Widget _Campo({required Widget child}) => Container(
 /* decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: _borde),
  ),*/
  child: Padding(
    padding: const EdgeInsets.all(10),
    child: child,
  ),
);