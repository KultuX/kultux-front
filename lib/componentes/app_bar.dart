import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppBarPersonalizado extends StatefulWidget
    implements PreferredSizeWidget {
  final bool logeado;
  final bool invitado;

  final VoidCallback? onMostrarLogin;
  final VoidCallback? onIrInicio;
  final VoidCallback? onIrPerfil;

  final bool perfilActivado;

  const AppBarPersonalizado({
    super.key,
    this.logeado = false,
    this.invitado = false,
    this.onMostrarLogin,
    this.onIrInicio,
    this.onIrPerfil,
    this.perfilActivado = false,
  });

  @override
  State<AppBarPersonalizado> createState() => _AppBarPersonalizadoState();

  @override
  Size get preferredSize => const Size.fromHeight(70);
}

class _AppBarPersonalizadoState extends State<AppBarPersonalizado> {
  @override
  Widget build(BuildContext context) {
    final bool activo = widget.perfilActivado;

    return AppBar(
      backgroundColor: Colors.black,
      elevation: 0,
      leadingWidth: 70,

      leading: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: GestureDetector(
          onTap: widget.onIrInicio,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Image.asset(
              'assets/images/logo_kultux.png',
              width: 40,
              height: 40,
            ),
          ),
        ),
      ),

      actions: [
        if (widget.logeado)
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: GestureDetector(
              onTap: widget.onIrPerfil,
              child: SvgPicture.asset(
                'assets/iconos/perfil.svg',
                width: activo ? 40 : 32,
                height: activo ? 40 : 32,
                colorFilter: ColorFilter.mode(
                  activo ? const Color(0xFFA6E246) : Colors.white,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),

        if (widget.invitado)
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Center(
              child: GestureDetector(
                onTap: widget.onMostrarLogin,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFA6E246).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFA6E246),
                      width: 1,
                    ),
                  ),
                  child: const Text(
                    'Entrar',
                    style: TextStyle(
                      color: Color(0xFFA6E246),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
