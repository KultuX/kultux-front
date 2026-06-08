import 'package:flutter/cupertino.dart';

class WebContainer extends StatelessWidget {
  final Widget child;
  final double maxAncho;

  const WebContainer({super.key, required this.child, this.maxAncho = 700});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxAncho),
        child: child,
      ),
    );
  }
}
