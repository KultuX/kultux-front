import 'package:flutter/material.dart';

class PageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool showDate;
  final bool showTodayLabel;
  final VoidCallback? onBack;
  final EdgeInsets padding;
  final bool showRightImage;
  final double minHeight;
  final String? logoAsset;

  const PageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.showDate = false,
    this.showTodayLabel = false,
    this.onBack,
    this.padding = const EdgeInsets.fromLTRB(16, 10, 16, 12),
    this.showRightImage = false,
    this.minHeight = 0,
    this.logoAsset = '',
  });

  @override
  Widget build(BuildContext context) {
    final bool tieneFlecha = onBack != null;

    final fechaActual = DateTime.now();

    const dias = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
    final dia = dias[fechaActual.weekday - 1];

    return Container(
      height: minHeight > 0 ? minHeight : null,
      width: double.infinity,
      padding: padding,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1a1a1a), Color(0xFF2d2d2d)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          if (showRightImage)
            Positioned(
              top: logoAsset!.isNotEmpty ? null : 0,
              right: 0,
              bottom: logoAsset!.isNotEmpty ? 0 : null,
              child: Opacity(
                opacity: logoAsset!.isNotEmpty ? 1 : 0.15,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                    logoAsset!.isNotEmpty ? 0 : 8,
                  ),
                  child: SizedBox(
                    width: logoAsset!.isNotEmpty ? 45 : 80,
                    height: logoAsset!.isNotEmpty ? 45 : 80,
                    child: Image.asset(
                      logoAsset!.isNotEmpty
                          ? logoAsset!
                          : "assets/images/extrem.png",
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey.shade700,
                        child: const Icon(Icons.image, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (tieneFlecha)
            Positioned(
              top: -20,
              left: -14,
              child: GestureDetector(
                onTap: onBack,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 36, 36),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),

          Padding(
            padding: EdgeInsets.only(top: tieneFlecha ? 18 : 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: .end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (subtitle != null) ...[
                        Text(
                          subtitle!,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFFb0b0b0),
                          ),
                        ),

                        const SizedBox(height: 2),
                      ],

                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Container(
                        width: 32,
                        height: 2,
                        decoration: BoxDecoration(
                          color: const Color(0xFFA6E246),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ],
                  ),
                ),

                if (showDate)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (showTodayLabel)
                        const Text(
                          'Hoy',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFFb0b0b0),
                          ),
                        ),

                      if (showTodayLabel) const SizedBox(height: 2),

                      Text(
                        "$dia. ${fechaActual.day}/${fechaActual.month}/${fechaActual.year}",
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
