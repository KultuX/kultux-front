import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kultux/core/utils/formatter.dart';
import 'package:kultux/core/models/time_slot.dart';

import 'package:kultux/config/app_colors.dart';

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
                  color: AppColors.imagePlaceholder,
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
                      _Status(status: status!),
                    const Spacer(),
                    if (textBadge != null && iconBadge != null)
                      _Category(
                        iconPath: iconBadge!,
                        text: categoryFormatter(textBadge!),
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
                        color: AppColors.white,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        if (location != null)
                          _Dates(
                            icon: Icons.location_on_outlined,
                            text: location!,
                          ),
                        if (startDate != null)
                          _Dates(
                            icon: Icons.calendar_today_outlined,
                            text:
                            '${dateFormatter(startDate!)}${endDate != null && endDate!.isNotEmpty ? ' – ${dateFormatter(endDate!)}' : ''}',
                            green: true,
                          ),
                      ],
                    ),
                    if (schedule != null && isOpen != null) ...[
                      const SizedBox(height: 8),
                      _ScheduleLine(schedule: schedule!, isOpen: isOpen!),
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

class _Status extends StatelessWidget {
  final String status;
  const _Status({required this.status});

  @override
  Widget build(BuildContext context) {
    final isNext = status == 'PROXIMAMENTE';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: isNext
            ? AppColors.statusNext
            : AppColors.statusCancel,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.white,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _Category extends StatelessWidget {
  final String iconPath;
  final String text;
  const _Category({required this.iconPath, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.navBg.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.categoryBadgeBorder,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            iconPath,
            width: 13,
            height: 13,
            colorFilter: const ColorFilter.mode(
              AppColors.green,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.green,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _Dates extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool green;
  const _Dates({required this.icon, required this.text, this.green = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: green
            ? AppColors.dateGreenBg
            : AppColors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: green
                ? AppColors.dateGreenText
                : Colors.white.withOpacity(0.14),
          ),
          const SizedBox(width: 4),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 140),
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: green
                    ? AppColors.dateGreenText
                    : Colors.white.withOpacity(0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _ScheduleLine extends StatelessWidget {
  final Map<String, List<TimeSlot>> schedule;
  final bool isOpen;
  const _ScheduleLine({required this.schedule, required this.isOpen});

  String _fmt(String h) => h.length >= 5 ? h.substring(0, 5) : h;

  @override
  Widget build(BuildContext context) {
    final hoy = DateTime.now().weekday;
    final franjas = schedule['$hoy'] ?? [];
    final color =
    isOpen ? AppColors.success : AppColors.scheduleClosed;

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
            isOpen && franjas.isNotEmpty
                ? 'Abierto · ${franjas.map((f) => '${_fmt(f.start)}–${_fmt(f.end)}').join(' | ')}'
                : isOpen
                ? 'Abierto'
                : 'Cerrado',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.white.withOpacity(0.85),
            ),
          ),
        ),
      ],
    );
  }
}