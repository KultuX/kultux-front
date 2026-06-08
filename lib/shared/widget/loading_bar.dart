import 'package:flutter/material.dart';

class LoadingBar extends StatelessWidget {
  final Widget child;
  final bool cargando;

  const LoadingBar({super.key, required this.child, required this.cargando});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (cargando)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(
              minHeight: 3,
              backgroundColor: const Color(0xFFE0DDD6),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFFA6E246),
              ),
            ),
          ),
      ],
    );
  }
}
