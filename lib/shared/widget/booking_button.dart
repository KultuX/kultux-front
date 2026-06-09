import 'package:flutter/material.dart';
import 'package:kultux/config/app_colors.dart';

class BookingButton extends StatelessWidget {
  final bool enable;
  final bool isActivity;
  final bool isRestaurant;
  final VoidCallback? onTap;

  const BookingButton({
    super.key,
    required this.enable,
    required this.isActivity,
    required this.isRestaurant,
    this.onTap});

  @override
  Widget build(BuildContext context) => Opacity(
    opacity: enable ? 1.0 : 0.4,
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.green,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActivity ? Icons.confirmation_number_outlined : isRestaurant ? Icons.restaurant_outlined : Icons.hotel_outlined,
              size: 20, color: Colors.black87,
            ),
            const SizedBox(width: 8),
            Text(
              isActivity ? 'Comprar entradas' : 'Reservar ahora',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.black87, letterSpacing: 0.2),
            ),
          ],
        ),
      ),
    ),
  );
}
