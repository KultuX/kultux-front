
import 'package:flutter/material.dart';
class SlideGradient extends GradientTransform {
  final double value;
  const SlideGradient(this.value);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * value, 0, 0);
  }
}