import 'package:flutter/material.dart';
import 'package:kultux/shared/widget/slide_gradient.dart';


class AppCardSkeleton extends StatefulWidget {
  const AppCardSkeleton({super.key});

  @override
  State<AppCardSkeleton> createState() => _AppCardSkeletonState();
}

class _AppCardSkeletonState extends State<AppCardSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _anim = Tween<double>(begin: -1, end: 2).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }


  Widget _shimmer(double width, double height, {BorderRadius? radius, bool onDarkBg = false}) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: radius ?? BorderRadius.circular(4),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            stops: const [0.0, 0.5, 1.0],
            colors: onDarkBg
                ? const [
              Color(0xFF333333),
              Color(0xFF444444),
              Color(0xFF333333),
            ]
                : const [
              Color(0xFFE8E8E8),
              Color(0xFFF5F5F5),
              Color(0xFFE8E8E8),
            ],
            transform: SlideGradient(_anim.value),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final width = MediaQuery.of(context).size.width - 32;
    final height = width * 3 / 3;

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Fondo base del Skeleton (Simula la imagen cargando)
            _shimmer(double.infinity, double.infinity, radius: BorderRadius.zero),

            // 2. Capa de degradado oscuro idéntica a tu diseño original
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.45, 1.0],
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.15),
                    Colors.black.withOpacity(0.78),
                  ],
                ),
              ),
            ),

            // 3. Badges Superiores (Status y Categoría)
            Positioned(
              top: 14,
              left: 14,
              right: 14,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Simulación de _Status
                  _shimmer(90, 24, radius: BorderRadius.circular(20)),
                  // Simulación de _Category
                  _shimmer(110, 24, radius: BorderRadius.circular(20)),
                ],
              ),
            ),

            // 4. Información Inferior (Título, Fechas/Ubicación y Horario)
            Positioned(
              left: 16,
              right: 16,
              bottom: 18,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Primera línea del título
                  _shimmer(double.infinity, 18, onDarkBg: true),
                  const SizedBox(height: 6),
                  // Segunda línea del título (más corta)
                  _shimmer(width * 0.6, 18, onDarkBg: true),
                  const SizedBox(height: 14),

                  // Fila de Badges de Fechas / Ubicación
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      // Ubicación placeholder
                      _shimmer(100, 22, radius: BorderRadius.circular(20), onDarkBg: true),
                      // Fecha placeholder
                      _shimmer(130, 22, radius: BorderRadius.circular(20), onDarkBg: true),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Fila de línea de horario / apertura
                  Row(
                    children: [
                      // Círculo indicador de estado (abierto/cerrado)
                      _shimmer(6, 6, radius: BorderRadius.circular(3), onDarkBg: true),
                      const SizedBox(width: 6),
                      // Texto de la franja horaria
                      _shimmer(150, 12, onDarkBg: true),
                    ],
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


class SkeletonCard extends StatefulWidget {
  const SkeletonCard({super.key});

  @override
  State<SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<SkeletonCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _anim = Tween<double>(begin: -1, end: 2).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Widget _shimmer(double width, double height, {BorderRadius? radius}) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: radius ?? BorderRadius.circular(4),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            stops: const [0.0, 0.5, 1.0],
            colors: const [
              Color(0xFFE8E8E8),
              Color(0xFFF5F5F5),
              Color(0xFFE8E8E8),
            ],
            transform: SlideGradient(_anim.value),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE8E8E8)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: _shimmer(double.infinity, 140, radius: BorderRadius.zero),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _shimmer(double.infinity, 14),
                  const SizedBox(height: 6),
                  _shimmer(160, 14),
                  const SizedBox(height: 10),
                  Row(children: [
                    _shimmer(80, 24, radius: BorderRadius.circular(6)),
                    const SizedBox(width: 6),
                    _shimmer(100, 24, radius: BorderRadius.circular(6)),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

