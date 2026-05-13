import 'package:flutter/material.dart';

// Tarjeta reutilizable para Actividad, Restaurante y Alojamiento en Guardados
class TarjetaGuardado extends StatelessWidget {
  final String titulo;
  final String? localidad;
  final String? categoria;
  final String? imagenUrl;
  final VoidCallback onTap;

  // Solo actividad
  final String? fecha;

  // Solo restaurante
  final bool? abierto;

  const TarjetaGuardado._({
    super.key,
    required this.titulo,
    required this.onTap,
    this.localidad,
    this.categoria,
    this.imagenUrl,
    this.fecha,
    this.abierto,
  });

  const TarjetaGuardado.actividad({
    Key? key,
    required String titulo,
    required VoidCallback onTap,
    String? localidad,
    String? categoria,
    String? imagenUrl,
    String? fecha,
  }) : this._(
    key: key,
    titulo: titulo,
    onTap: onTap,
    localidad: localidad,
    categoria: categoria,
    imagenUrl: imagenUrl,
    fecha: fecha,
  );

  const TarjetaGuardado.restaurante({
    Key? key,
    required String titulo,
    required VoidCallback onTap,
    String? localidad,
    String? categoria,
    String? imagenUrl,
    bool? abierto,
  }) : this._(
    key: key,
    titulo: titulo,
    onTap: onTap,
    localidad: localidad,
    categoria: categoria,
    imagenUrl: imagenUrl,
    abierto: abierto,
  );

  const TarjetaGuardado.alojamiento({
    Key? key,
    required String titulo,
    required VoidCallback onTap,
    String? localidad,
    String? categoria,
    String? imagenUrl,
  }) : this._(
    key: key,
    titulo: titulo,
    onTap: onTap,
    localidad: localidad,
    categoria: categoria,
    imagenUrl: imagenUrl,
  );

  static const _verde = Color(0xFFA6E246);
  static const _texto = Color(0xFF1A1A1A);
  static const _textoSuave = Color(0xFF6B6B6B);
  static const _borde = Color(0xFFE0DDD6);
  static const _fondoCard = Color(0xFFF8F7F4);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: _fondoCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _borde),
        ),
        child: Row(
          children: [
            // Imagen pequeña
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 64,
                height: 64,
                child: imagenUrl != null && imagenUrl!.isNotEmpty
                    ? Image.network(
                  imagenUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _imagenFallback(),
                )
                    : _imagenFallback(),
              ),
            ),
            const SizedBox(width: 12),
            // Info
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
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _texto,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 5,
                    runSpacing: 4,
                    children: [
                      if (localidad != null && localidad!.isNotEmpty)
                        _Chip(
                          icono: Icons.location_on_outlined,
                          texto: localidad!,
                          fondo: const Color(0xFFF0F0F0),
                          color: _textoSuave,
                        ),
                      if (fecha != null && fecha!.isNotEmpty)
                        _Chip(
                          icono: Icons.calendar_today_outlined,
                          texto: fecha!,
                          fondo: const Color(0xFFEAF3DE),
                          color: const Color(0xFF3B6D11),
                        ),
                      if (abierto != null)
                        _Chip(
                          icono: Icons.circle,
                          texto: abierto! ? 'Abierto' : 'Cerrado',
                          fondo: abierto!
                              ? const Color(0xFFEAF3DE)
                              : const Color(0xFFFFEBEE),
                          color: abierto!
                              ? const Color(0xFF3B6D11)
                              : const Color(0xFFC62828),
                          iconSize: 8,
                        ),
                      if (categoria != null && categoria!.isNotEmpty)
                        _Chip(
                          texto: categoria!,
                          fondo: _texto,
                          color: _verde,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Botón flecha
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _verde,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.chevron_right, size: 18, color: _texto),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagenFallback() {
    return Container(
      color: const Color(0xFFE8E5DF),
      child: const Icon(Icons.image_outlined, color: Color(0xFFB0B0B0), size: 28),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData? icono;
  final String texto;
  final Color fondo;
  final Color color;
  final double iconSize;

  const _Chip({
    this.icono,
    required this.texto,
    required this.fondo,
    required this.color,
    this.iconSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icono != null) ...[
            Icon(icono, size: iconSize, color: color),
            const SizedBox(width: 3),
          ],
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 110),
            child: Text(
              texto,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'RobotoCondensed',
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}