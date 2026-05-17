import 'package:flutter/material.dart';

class AppBarPersonalizado extends StatefulWidget
    implements PreferredSizeWidget {

  final bool logeado;
  final bool invitado;
  final VoidCallback? onMostrarLogin;
  final VoidCallback? onIrInicio;

  const AppBarPersonalizado({
    super.key,
    this.logeado = false,
    this.invitado = false,
    this.onMostrarLogin,
    this.onIrInicio,
  });

  @override
  State<AppBarPersonalizado> createState() =>
      _AppBarPersonalizadoState();

  @override
  Size get preferredSize => const Size.fromHeight(70);
}

class _AppBarPersonalizadoState
    extends State<AppBarPersonalizado> {

  @override
  Widget build(BuildContext context) {
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
              width: 32,
              height: 32,
            ),
          ),
        ),
      ),
      actions: [
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