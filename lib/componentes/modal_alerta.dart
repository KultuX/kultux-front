import 'package:flutter/material.dart';

class Alerta {
  static void show(
      BuildContext context, {
        required String mensaje,
        TipoAviso tipo = TipoAviso.info,
        Duration duracion = const Duration(seconds: 3),
      }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    Color color;
    IconData icono;

    switch (tipo) {
      case TipoAviso.success:
        color = const Color(0xFFA8D63F);
        icono = Icons.check_circle_outline;
        break;
      case TipoAviso.error:
        color = const Color(0xFFC62828);
        icono = Icons.error_outline;
        break;
      case TipoAviso.warning:
        color = const Color(0xFFF9A825);
        icono = Icons.warning_amber_outlined;
        break;
      default:
        color = const Color(0xFF6B6B6B);
        icono = Icons.info_outline;
    }

    entry = OverlayEntry(
      builder: (_) => _AlertaWidget(
        mensaje: mensaje,
        color: color,
        icono: icono,
      ),
    );

    overlay.insert(entry);

    Future.delayed(duracion, () {
      entry.remove();
    });
  }
}

enum TipoAviso { success, error, warning, info }

class _AlertaWidget extends StatefulWidget {
  final String mensaje;
  final Color color;
  final IconData icono;

  const _AlertaWidget({
    required this.mensaje,
    required this.color,
    required this.icono,
  });

  @override
  State<_AlertaWidget> createState() => _AlertaWidgetState();
}

class _AlertaWidgetState extends State<_AlertaWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slide;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fade = Tween<double>(begin: 0, end: 1).animate(_controller);

    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 50,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _fade,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F7F4),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE0DDD6)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 16,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: widget.color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(widget.icono,
                        size: 18, color: widget.color),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.mensaje,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
