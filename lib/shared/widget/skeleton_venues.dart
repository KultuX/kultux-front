import 'package:flutter/material.dart';
import 'package:kultux/shared/widget/slide_gradient.dart';
class SkeletonMiniVenues extends StatefulWidget {
  const SkeletonMiniVenues({super.key});

  @override
  State<SkeletonMiniVenues> createState() => _SkeletonMiniVenuesState();
}

class _SkeletonMiniVenuesState extends State<SkeletonMiniVenues>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _animation = Tween<double>(
      begin: -1,
      end: 2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _shimmer({double? width, double? height, BorderRadius? radius}) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: radius ?? BorderRadius.circular(4),
          gradient: LinearGradient(
            stops: const [0.0, 0.5, 1.0],
            colors: const [
              Color(0xFFE8E8E8),
              Color(0xFFF5F5F5),
              Color(0xFFE8E8E8),
            ],
            transform: SlideGradient(_animation.value),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: _shimmer(radius: BorderRadius.circular(12)),
        ),
        const SizedBox(height: 5),
        _shimmer(
          width: double.infinity,
          height: 20,
          radius: BorderRadius.circular(6),
        ),
      ],
    );
  }
}
