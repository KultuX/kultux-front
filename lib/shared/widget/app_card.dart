import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kultux/core/utils/formatter.dart';
import 'package:kultux/core/models/time_slot.dart';

import '../../config/app_colors.dart';

class AppCard extends StatelessWidget {
  final String title;
  final String? location;
  final String? startDate;
  final String imageUrl;
  final VoidCallback onTap;
  final String? textBadge;
  final String? iconBadge;
  final Map<String, List<TimeSlot>>? schedule;
  final bool? isOpen;
  final String? endDate;
  final String? status;

  const AppCard._({
    super.key,
    required this.title,
    this.location,
    this.startDate,
    required this.imageUrl,
    required this.onTap,
    this.textBadge,
    this.iconBadge,
    this.schedule,
    this.isOpen,
    this.endDate,
    this.status,
  });

  const AppCard.activity({
    Key? key,
    required String title,
    required String location,
    required String startDate,
    required String imageUrl,
    required VoidCallback onTap,
    required String textBadge,
    required String iconBadge,
    String? endDate,
    String? status,
  }) : this._(
    key: key,
    title: title,
    location: location,
    startDate: startDate,
    imageUrl: imageUrl,
    onTap: onTap,
    textBadge: textBadge,
    iconBadge: iconBadge,
    endDate: endDate,
    status: status,
  );

  const AppCard.restaurant({
    Key? key,
    required String name,
    required String imageUrl,
    required String textBadge,
    required String iconBadge,
    required VoidCallback onTap,
    required Map<String, List<TimeSlot>> schedule,
    required bool isOpen,
    String? location,
  }) : this._(
    key: key,
    title: name,
    imageUrl: imageUrl,
    textBadge: textBadge,
    iconBadge: iconBadge,
    onTap: onTap,
    schedule: schedule,
    isOpen: isOpen,
    location: location,
  );

  const AppCard.accommodation({
    Key? key,
    required String name,
    required String imageUrl,
    required String textBadge,
    required String iconBadge,
    required VoidCallback onTap,
    String? location,
  }) : this._(
    key: key,
    title: name,
    imageUrl: imageUrl,
    textBadge: textBadge,
    iconBadge: iconBadge,
    onTap: onTap,
    location: location,
  );

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width -
        32;
    final height = width * 3 / 3;

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: SizedBox(
          width: double.infinity,
          height: height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                memCacheWidth: 800,
                placeholder: (_, __) => const ColoredBox(
                  color: Color(0xFFD4D0C8),
                ),
                errorWidget: (_, __, ___) => Container(
                  color: AppColors.imagePlaceholder,
                  child: const Icon(Icons.image_outlined,
                      color: AppColors.imageErrorIcon, size: 48),
                ),
              ),


              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.45, 1.0],
                    colors: [
                      Colors.transparent,
                      AppColors.imageGradientTop.withOpacity(0.15),
                      AppColors.imageGradientBottom.withOpacity(0.78),
                    ],
                  ),
                ),
              ),

              Positioned(
                top: 14,
                left: 14,
                right: 14,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (status != null && status!.isNotEmpty)
                      _Estado(estado: status!),
                    const Spacer(),
                    if (textBadge != null && iconBadge != null)
                      _Categoria(
                        iconoPath: iconBadge!,
                        texto: categoryFormatter(textBadge!),
                      ),
                  ],
                ),
              ),

              Positioned(
                left: 16,
                right: 16,
                bottom: 18,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'RobotoCondensed',
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        if (location != null)
                          _Fechas(
                            icono: Icons.location_on_outlined,
                            texto: location!,
                          ),
                        if (startDate != null)
                          _Fechas(
                            icono: Icons.calendar_today_outlined,
                            texto:
                            '${dateFormatter(startDate!)}${endDate != null && endDate!.isNotEmpty ? ' – ${dateFormatter(endDate!)}' : ''}',
                            verde: true,
                          ),
                      ],
                    ),
                    if (schedule != null && isOpen != null) ...[
                      const SizedBox(height: 8),
                      _HorarioLinea(horario: schedule!, abierto: isOpen!),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Estado extends StatelessWidget {
  final String estado;
  const _Estado({required this.estado});

  @override
  Widget build(BuildContext context) {
    final esProximo = estado == 'PROXIMAMENTE';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: esProximo
            ? const Color.fromARGB(136, 166, 226, 70)
            : const Color.fromARGB(92, 255, 82, 100),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        estado,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Color.fromARGB(255, 255, 255, 255),
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _Categoria extends StatelessWidget {
  final String iconoPath;
  final String texto;
  const _Categoria({required this.iconoPath, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFA6E246).withOpacity(0.25),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            iconoPath,
            width: 13,
            height: 13,
            colorFilter: const ColorFilter.mode(
              Color(0xFFA6E246),
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            texto,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFFA6E246),
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _Fechas extends StatelessWidget {
  final IconData icono;
  final String texto;
  final bool verde;
  const _Fechas({required this.icono, required this.texto, this.verde = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: verde
            ? const Color(0x4D639922)
            : Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icono,
            size: 12,
            color: verde
                ? const Color(0xFFC0DD97)
                : Colors.white.withOpacity(0.9),
          ),
          const SizedBox(width: 4),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 140),
            child: Text(
              texto,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: verde
                    ? const Color(0xFFC0DD97)
                    : Colors.white.withOpacity(0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _HorarioLinea extends StatelessWidget {
  final Map<String, List<TimeSlot>> horario;
  final bool abierto;
  const _HorarioLinea({required this.horario, required this.abierto});

  String _fmt(String h) => h.length >= 5 ? h.substring(0, 5) : h;

  @override
  Widget build(BuildContext context) {
    final hoy = DateTime.now().weekday;
    final franjas = horario['$hoy'] ?? [];
    final color =
    abierto ? const Color(0xFFA6E246) : const Color(0xFFE24B4A);

    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            abierto && franjas.isNotEmpty
                ? 'Abierto · ${franjas.map((f) => '${_fmt(f.inicio)}–${_fmt(f.fin)}').join(' | ')}'
                : abierto
                ? 'Abierto'
                : 'Cerrado',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.85),
            ),
          ),
        ),
      ],
    );
  }
}