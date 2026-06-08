import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const _family = 'RobotoCondensed';

  // ── Headings == //
  static const pageTitle = TextStyle(
    fontFamily: _family,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
  );

  static const sectionTitle = TextStyle(
    fontFamily: _family,
    fontSize: 16,
    fontWeight: FontWeight.w800,
    color: AppColors.text,
    letterSpacing: -0.2,
  );

  static const cardTitle = TextStyle(
    fontFamily: _family,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.text,
  );

  // == Body == //
  static const body = TextStyle(
    fontFamily: _family,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.text,
    height: 1.65,
  );

  static const bodySmall = TextStyle(
    fontFamily: _family,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.text,
  );

  // == Labels == //
  static const label = TextStyle(
    fontFamily: _family,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textSoft,
  );

  static const labelSection = TextStyle(
    fontFamily: _family,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.textSoft,
    letterSpacing: 0.8,
  );

  static const caption = TextStyle(
    fontFamily: _family,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textHint,
  );

  // == Buttons == //
  static const button = TextStyle(
    fontFamily: _family,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.text,
  );

  static const buttonSmall = TextStyle(
    fontFamily: _family,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.text,
  );

  // == Navigation == //
  static const navSelected = TextStyle(
    color: AppColors.green,
    fontWeight: FontWeight.w600,
    fontSize: 14,
  );

  static const navUnselected = TextStyle(
    color: AppColors.white,
    fontSize: 13,
  );

  static const legalDialogTitle = TextStyle(
    color: Colors.black,
    fontFamily: _family,
    fontSize: 20
  );

  static const legalDialogText = TextStyle(
    color: Colors.black87,
    fontFamily: _family,
    fontSize: 13,
    height: 1.5
  );

  static const legalDialogFooter = TextStyle(
    color: Colors.grey,
    fontFamily: _family,
    fontSize: 12,
    fontStyle: FontStyle.italic

  );
}