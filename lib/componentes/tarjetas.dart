import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kultux/models/franja.dart';
import 'package:cached_network_image/cached_network_image.dart';

const _verde = Color(0xFFA6E246);
const _fondoCard = Color(0xFFF8F7F4);
const _texto = Color(0xFF1A1A1A);
const _textoSuave = Color(0xFF6B6B6B);
const _borde = Color(0xFFE0DDD6);

class Tarjeta extends StatelessWidget {
  final String titulo;
  final String? localidad;
  final String? fecha;
  final String imagenUrl;
  final VoidCallback onTap;
  final String? textoEtiqueta;
  final String? iconoEtiqueta;
  final Map<String, List<Franja>>? horario;
  final bool? abierto;

  const Tarjeta._({
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

  const Tarjeta.actividades({
    Key? key,
    required String titulo,
    required String localidad,
    required String fecha,
    required String imagenUrl,
    required VoidCallback onTap,
  }) : this._(
    key: key, titulo: titulo, localidad: localidad,
    fecha: fecha, imagenUrl: imagenUrl, onTap: onTap,
  );

  const Tarjeta.restaurante({
    Key? key,
    required String titulo,
    required String imagenUrl,
    required String textoEtiqueta,
    required String iconoEtiqueta,
    required VoidCallback onTap,
  }) : this._(
    key: key, titulo: titulo, imagenUrl: imagenUrl,
    textoEtiqueta: textoEtiqueta, iconoEtiqueta: iconoEtiqueta, onTap: onTap,
  );

  const Tarjeta.alojamiento({
    Key? key,
    required String titulo,
    required String imagenUrl,
    required String textoEtiqueta,
    required String iconoEtiqueta,
    required VoidCallback onTap,
    String? localidad,
  }) : this._(
    key: key, titulo: titulo, imagenUrl: imagenUrl,
    textoEtiqueta: textoEtiqueta, iconoEtiqueta: iconoEtiqueta,
    onTap: onTap, localidad: localidad,
  );

  const Tarjeta.restauranteBusqueda({
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
    key: key, titulo: titulo, imagenUrl: imagenUrl,
    textoEtiqueta: textoEtiqueta, iconoEtiqueta: iconoEtiqueta,
    onTap: onTap, horario: horario, abierto: abierto, localidad: localidad,
  );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: _fondoCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _borde),
          boxShadow: const [
            BoxShadow(color: Color(0x10000000), blurRadius: 12, offset: Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Imagen ──────────────────────────────────────────────────
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: SizedBox(
                width: double.infinity,
                height: 130,
                child: CachedNetworkImage(
                  imageUrl: imagenUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    color: const Color(0xFFE8E5DF),
                    child: const Center(
                      child: CircularProgressIndicator(color: _verde, strokeWidth: 2),
                    ),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    color: const Color(0xFFE8E5DF),
                    child: Icon(Icons.image_outlined,
                        color: Colors.grey.shade400, size: 36),
                  ),
                ),
              ),
            ),

            // ── Info ─────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          titulo,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'RobotoCondensed',
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: _texto,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6, runSpacing: 4,
                          children: [
                            if (localidad != null) _Chip.localidad(localidad!),
                            if (fecha != null) _Chip.fecha(fecha!),
                            if (textoEtiqueta != null && iconoEtiqueta != null)
                              _Chip.etiqueta(textoEtiqueta!, iconoEtiqueta!),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Botón flecha
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: _verde,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/iconos/flecha_siguiente.svg',
                        width: 18, height: 18,
                        colorFilter: const ColorFilter.mode(_texto, BlendMode.srcIn),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Chips internos ─────────────────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  final Widget leading;
  final String texto;
  final Color fondo;
  final Color colorTexto;

  const _Chip({
    required this.leading,
    required this.texto,
    required this.fondo,
    required this.colorTexto,
  });

  factory _Chip.localidad(String texto) => _Chip(
    leading: const Icon(Icons.location_on_outlined,
        size: 12, color: _textoSuave),
    texto: texto,
    fondo: const Color(0xFFF0EDE8),
    colorTexto: _textoSuave,
  );

  factory _Chip.fecha(String texto) => _Chip(
    leading: const Icon(Icons.calendar_today_outlined,
        size: 12, color: Color(0xFF4A7A10)),
    texto: texto,
    fondo: const Color(0xFFF0F8E6),
    colorTexto: const Color(0xFF4A7A10),
  );

  factory _Chip.etiqueta(String texto, String iconoPath) => _Chip(
    leading: SvgPicture.asset(iconoPath,
        width: 12, height: 12,
        colorFilter: const ColorFilter.mode(_verde, BlendMode.srcIn)),
    texto: texto,
    fondo: _texto,
    colorTexto: Colors.white,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          leading,
          const SizedBox(width: 4),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 120),
            child: Text(
              texto,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'RobotoCondensed',
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: colorTexto,
              ),
            ),
          ),
        ],
      ),
    );
  }
}