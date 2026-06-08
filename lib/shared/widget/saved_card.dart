import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:kultux/core/utils/formatter.dart';

import '../../config/app_colors.dart';

class SavedCard extends StatelessWidget {
  final String title;
  final String? location;
  final String? category;
  final String? imageUrl;
  final VoidCallback onTap;
  final String? startDate;
  final bool? isOpen;
  final String? endDate;

  const SavedCard._({
    super.key,
    required this.title,
    required this.onTap,
    this.location,
    this.category,
    this.imageUrl,
    this.startDate,
    this.isOpen,
    this.endDate,
  });

  const SavedCard.activity({
    Key? key,
    required String title,
    required VoidCallback onTap,
    String? location,
    String? category,
    String? imageUrl,
    String? startDate,
    String? endDate,
  }) : this._(
         key: key,
         title: title,
         onTap: onTap,
         location: location,
         category: category,
         imageUrl: imageUrl,
         startDate: startDate,
         endDate: endDate,
       );

  const SavedCard.restaurant({
    Key? key,
    required String name,
    required VoidCallback onTap,
    String? location,
    String? category,
    String? imageUrl,
    bool? isOpen,
  }) : this._(
         key: key,
         title: name,
         onTap: onTap,
         location: location,
         category: category,
         imageUrl: imageUrl,
         isOpen: isOpen,
       );

  const SavedCard.accommodation({
    Key? key,
    required String name,
    required VoidCallback onTap,
    String? location,
    String? category,
    String? imageUrl,
  }) : this._(
         key: key,
         title: name,
         onTap: onTap,
         location: location,
         category: category,
         imageUrl: imageUrl,
       );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 64,
                height: 64,
                child: imageUrl != null && imageUrl!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: imageUrl!,
                        fit: BoxFit.cover,
                        memCacheWidth: 100,
                        memCacheHeight: 100,
                        placeholder: (_, __) => Container(
                          color: const Color(0xFFE8E5DF),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFFA6E246),
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                        errorWidget: (_, __, ___) => _imageFallback(),
                      )
                    : _imageFallback(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'RobotoCondensed',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 5,
                    runSpacing: 4,
                    children: [
                      if (location != null && location!.isNotEmpty)
                        _Badge(
                          icon: Icons.location_on_outlined,
                          text: location!,
                          background: const Color(0xFFF0F0F0),
                          color: AppColors.textSoft,
                        ),
                      if (startDate != null)
                        _Badge(
                          icon: Icons.calendar_today_outlined,
                          text:
                              '${dateFormatter(startDate!)}${endDate != null && endDate!.isNotEmpty ? ' - ${dateFormatter(endDate!)}' : ''}',
                          background: const Color(0xFFEAF3DE),
                          color: const Color(0xFF3B6D11),
                        ),
                      if (isOpen != null)
                        _Badge(
                          icon: Icons.circle,
                          text: isOpen! ? 'Abierto' : 'Cerrado',
                          background: isOpen!
                              ? const Color(0xFFEAF3DE)
                              : const Color(0xFFFFEBEE),
                          color: isOpen!
                              ? const Color(0xFF3B6D11)
                              : const Color(0xFFC62828),
                          iconSize: 8,
                        ),
                      if (category != null && category!.isNotEmpty)
                        _Badge(text: category!, background: AppColors.text, color: AppColors.green),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.green,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.chevron_right, size: 18, color: AppColors.text),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageFallback() {
    return Container(
      color: const Color(0xFFE8E5DF),
      child: const Icon(
        Icons.image_outlined,
        color: Color(0xFFB0B0B0),
        size: 28,
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData? icon;
  final String text;
  final Color background;
  final Color color;
  final double iconSize;

  const _Badge({
    this.icon,
    required this.text,
    required this.background,
    required this.color,
    this.iconSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: iconSize, color: color),
            const SizedBox(width: 3),
          ],
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 110),
            child: Text(
              categoryFormatter(text),
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
