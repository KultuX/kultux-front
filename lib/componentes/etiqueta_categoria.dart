import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class EtiquetaCategoria extends StatelessWidget {
  final String iconoPath;
  final String texto;
  final Color fondoColor;
  final Color textoColor;
  final Color iconoColor;

  const EtiquetaCategoria({
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
