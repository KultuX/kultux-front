import 'package:flutter/material.dart';
import 'package:kultux/shared/widget/slide_gradient.dart';
class SkeletonSavedCard extends StatefulWidget {
  const SkeletonSavedCard({super.key});
  @override
  State<SkeletonSavedCard> createState() =>
      _SkeletonSavedCardState();
}

class _SkeletonSavedCardState extends State<SkeletonSavedCard>
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

  Widget _s(double w, double h, {BorderRadius? r}) => AnimatedBuilder(
    animation: _animation,
    builder: (_, __) => Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        borderRadius: r ?? BorderRadius.circular(4),
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

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F7F4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE0DDD6)),
      ),
      child: Row(
        children: [
          _s(64, 64, r: BorderRadius.circular(10)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _s(double.infinity, 13),
                const SizedBox(height: 6),
                _s(120, 13),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _s(70, 20, r: BorderRadius.circular(5)),
                    const SizedBox(width: 5),
                    _s(80, 20, r: BorderRadius.circular(5)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _s(32, 32, r: BorderRadius.circular(8)),
        ],
      ),
    );
  }
}
