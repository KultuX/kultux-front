import 'package:flutter/material.dart';

import 'package:kultux/core/utils/web_container.dart';

import 'package:kultux/config/app_colors.dart';

class AlertModal {
  static void show(
    BuildContext context, {
    required String message,
    AlertType type = AlertType.info,
    Duration duration = const Duration(seconds: 3),
    bool showClose = true,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    Color color;
    IconData icon;

    switch (type) {
      case AlertType.success:
        color = AppColors.success;
        icon = Icons.check_circle_outline;
        break;
      case AlertType.error:
        color = AppColors.error;
        icon = Icons.error_outline;
        break;
      case AlertType.warning:
        color = AppColors.warning;
        icon = Icons.warning_amber_outlined;
        break;
      default:
        color = AppColors.info;
        icon = Icons.info_outline;
    }

    entry = OverlayEntry(
      builder: (_) => _AlertModalWidget(
        message: message,
        color: color,
        icon: icon,
        showClose: showClose,
        onClose: () => entry.remove(),
      ),
    );

    overlay.insert(entry);

    Future.delayed(duration, () {
      entry.remove();
    });
  }
}

enum AlertType { success, error, warning, info }

class _AlertModalWidget extends StatefulWidget {
  final String message;
  final Color color;
  final IconData icon;
  final bool showClose;
  final VoidCallback onClose;

  const _AlertModalWidget({
    required this.message,
    required this.color,
    required this.icon,
    required this.showClose,
    required this.onClose,
  });

  @override
  State<_AlertModalWidget> createState() => _AlertModalWidgetState();
}

class _AlertModalWidgetState extends State<_AlertModalWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slide;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fade = Tween<double>(begin: 0, end: 1).animate(_controller);

    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    final anchoPantalla = MediaQuery.of(context).size.width;
    final esWeb = anchoPantalla > 600;

    return WebContainer(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: 50,
            left: 16,
            right: esWeb ? 40 : 16,
          ),
          child: SlideTransition(
            position: _slide,
            child: FadeTransition(
              opacity: _fade,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: esWeb ? 360 : double.infinity,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: 16,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: widget.color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          widget.icon,
                          size: 18,
                          color: widget.color,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          widget.message,
                          style:  TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                            color: AppColors.text,
                          ),
                        ),
                      ),
                      if (widget.showClose) ...[
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: widget.onClose,
                          child: Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: AppColors.border,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 14,
                              color: AppColors.textSoft,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
