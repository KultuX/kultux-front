import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kultux/models/franja.dart';

class TarjetaBusqueda extends StatelessWidget {
  final String titulo;
  final String? localidad;
  final String? fecha;
  final String imagenUrl;
  final VoidCallback onTap;
  final String? textoEtiqueta;
  final String? iconoEtiqueta;
  final Map<String, List<Franja>>? horario;
  final bool? abierto;

  const TarjetaBusqueda._({
    super.key,
    required this.titulo,
    this.localidad,
    this.fecha,
    required this.imagenUrl,
    required this.onTap,
    this.textoEtiqueta,
    this.iconoEtiqueta,
    this.horario,
    this.abierto,
  });

  const TarjetaBusqueda.actividad({
    Key? key,
    required String titulo,
    required String localidad,
    required String fecha,
    required String imagenUrl,
    required VoidCallback onTap,
    required String textoEtiqueta,
    required String iconoEtiqueta,
  }) : this._(
          key: key,
          titulo: titulo,
          localidad: localidad,
          fecha: fecha,
          imagenUrl: imagenUrl,
          onTap: onTap,
          textoEtiqueta: textoEtiqueta,
          iconoEtiqueta: iconoEtiqueta
        );

  const TarjetaBusqueda.restaurante({
    Key? key,
    required String titulo,
    required String imagenUrl,
    required String textoEtiqueta,
    required String iconoEtiqueta,
    required VoidCallback onTap,
    required Map<String, List<Franja>> horario,
    required bool abierto,
    String? localidad,
  }) : this._(
          key: key,
          titulo: titulo,
          imagenUrl: imagenUrl,
          textoEtiqueta: textoEtiqueta,
          iconoEtiqueta: iconoEtiqueta,
          onTap: onTap,
          horario: horario,
          abierto: abierto,
          localidad: localidad,
        );

  const TarjetaBusqueda.alojamiento({
    Key? key,
    required String titulo,
    required String imagenUrl,
    required String textoEtiqueta,
    required String iconoEtiqueta,
    required VoidCallback onTap,
    String? localidad,
  }) : this._(
          key: key,
          titulo: titulo,
          imagenUrl: imagenUrl,
          textoEtiqueta: textoEtiqueta,
          iconoEtiqueta: iconoEtiqueta,
          onTap: onTap,
          localidad: localidad,
        );


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE8E8E8), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ImagenSuperior(imagenUrl: imagenUrl),

            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          titulo,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: "RobotoCondensed",
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _BotonFlecha(onTap: onTap),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      if (localidad != null)
                        _ChipMeta(
                          icono: Icons.location_on_outlined,
                          texto: localidad!,
                          fondoColor: const Color(0xFFF5F5F5),
                          textoColor: const Color(0xFF444444),
                        ),

                      if (fecha != null)
                        _ChipMeta(
                          icono: Icons.calendar_today_outlined,
                          texto: fecha!,
                          fondoColor: const Color(0xFFF0F8E6),
                          textoColor: const Color(0xFF4A7A10),
                        ),

                      if (textoEtiqueta != null && iconoEtiqueta != null)
                        _ChipMetaSvg(
                          iconoPath: iconoEtiqueta!,
                          texto: textoEtiqueta!,
                          fondoColor: const Color(0xFF1A1A1A),
                          textoColor: Colors.white,
                          iconoColor: const Color(0xFFA6E246),
                        ),
                    ],
                  ),

                  if (horario != null && abierto != null) ...[
                    const SizedBox(height: 8),
                    _HorarioInline(horario: horario!, abierto: abierto!),
                    const Text(
                      "El horario puede sufrir cambios",
                      style: TextStyle(
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                          fontSize: 10
                      ),
                    )
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImagenSuperior extends StatelessWidget {
  final String imagenUrl;
  const _ImagenSuperior({required this.imagenUrl});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: SizedBox(
        width: double.infinity,
        height: 140,
        child: Image.network(
          imagenUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: Colors.grey.shade200,
            child: Icon(Icons.image_outlined, color: Colors.grey.shade400, size: 36),
          ),
        ),
      ),
    );
  }
}

class _BotonFlecha extends StatelessWidget {
  final VoidCallback onTap;
  const _BotonFlecha({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFFA6E246),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: SvgPicture.asset(
            "assets/iconos/flecha_siguiente.svg",
            width: 18,
            height: 18,
            colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
          ),
        ),
      ),
    );
  }
}

class _ChipMeta extends StatelessWidget {
  final IconData icono;
  final String texto;
  final Color fondoColor;
  final Color textoColor;

  const _ChipMeta({
    required this.icono,
    required this.texto,
    required this.fondoColor,
    required this.textoColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: fondoColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 13, color: textoColor),
          const SizedBox(width: 4),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 130),
            child: Text(
              texto,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: "RobotoCondensed",
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: textoColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipMetaSvg extends StatelessWidget {
  final String iconoPath;
  final String texto;
  final Color fondoColor;
  final Color textoColor;
  final Color iconoColor;

  const _ChipMetaSvg({
    required this.iconoPath,
    required this.texto,
    required this.fondoColor,
    required this.textoColor,
    required this.iconoColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: fondoColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            iconoPath,
            width: 13,
            height: 13,
            colorFilter: ColorFilter.mode(iconoColor, BlendMode.srcIn),
          ),
          const SizedBox(width: 4),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 130),
            child: Text(
              texto,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: "RobotoCondensed",
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: textoColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HorarioInline extends StatelessWidget {
  final Map<String, List<Franja>> horario;
  final bool abierto;

  const _HorarioInline({required this.horario, required this.abierto});

  String _formatearHora(String hora) => hora.length >= 5 ? hora.substring(0, 5) : hora;

  @override
  Widget build(BuildContext context) {
    final hoy = DateTime.now().weekday;
    final franjasHoy = horario['$hoy'] ?? [];
    final color = abierto ? const Color(0xFFA6E246) : Colors.red.shade400;
    final colorFondo = abierto ? const Color(0xFFF0F8E6) : Colors.red.shade50;
    final colorTexto = abierto ? const Color(0xFF4A7A10) : Colors.red.shade700;

    const diasNombre = {1:'L',2:'M',3:'X',4:'J',5:'V',6:'S',7:'D'};
    final diasQueAbre = [1,2,3,4,5,6,7]
        .where((d) => (horario['$d'] ?? []).isNotEmpty)
        .toSet();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: colorFondo,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            children: [
              Container(
                width: 8, height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text(
                abierto ? 'Abierto' : 'Cerrado',
                style: TextStyle(
                  fontFamily: 'RobotoCondensed',
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  color: colorTexto,
                ),
              ),
              if (franjasHoy.isNotEmpty) ...[
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 1, height: 12,
                  color: colorTexto.withOpacity(0.3),
                ),
                Expanded(
                  child: Text(
                    franjasHoy
                        .map((f) => '${_formatearHora(f.inicio)}–${_formatearHora(f.fin)}')
                        .join('  |  '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'RobotoCondensed',
                      fontSize: 12,
                      color: colorTexto,
                    ),
                  ),
                ),
              ],
            ],
          ),

          // Fila 2: días que abre
          if (diasQueAbre.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [1,2,3,4,5,6,7].map((d) {
                final activo = diasQueAbre.contains(d);
                final esHoy = d == hoy;
                return Container(
                  margin: const EdgeInsets.only(right: 4),
                  width: 22, height: 22,
                  decoration: BoxDecoration(
                    color: esHoy
                        ? color
                        : activo
                        ? color.withOpacity(0.2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: activo ? color : colorTexto.withOpacity(0.2),
                      width: 0.8,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      diasNombre[d]!,
                      style: TextStyle(
                        fontFamily: 'RobotoCondensed',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: esHoy
                            ? Colors.black
                            : activo
                            ? colorTexto
                            : colorTexto.withOpacity(0.3),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
