import 'package:flutter/material.dart';
import 'package:light_x/shared/theme/src/app_colors.dart';

class AppTextStyles {
  static const senderLabel = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 12,
    height: 16 / 12,
    color: AppColors.textSecondary,
  );

  static const messageBody = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 14,
    height: 23 / 14,
    color: AppColors.textPrimary,
  );

  static const messageBodyWhite = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 14,
    height: 23 / 14,
    color: AppColors.white,
  );

  static const cardTitle = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 12,
    height: 16 / 12,
    color: AppColors.textPrimary,
  );

  static const cardSubtitle = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 11,
    height: 16 / 11,
    color: AppColors.textSecondary,
  );

  static const chipLabel = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 12,
    height: 16 / 12,
    color: AppColors.primary,
  );

  static const inputHint = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 14,
    height: 19 / 14,
    color: AppColors.textSecondary,
  );
}
