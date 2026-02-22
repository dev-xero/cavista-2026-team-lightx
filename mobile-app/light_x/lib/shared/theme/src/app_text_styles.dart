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

  // Health Dashboard

  static const timestamp = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 12,
    height: 16 / 12,
    letterSpacing: 1.2,
    color: AppColors.textSecondary,
  );

  static const gaugeScore = TextStyle(
    fontWeight: FontWeight.w800,
    fontSize: 48,
    height: 1,
    letterSpacing: -2.4,
    color: AppColors.textPrimary,
  );

  static const gaugeLabel = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 14,
    height: 20 / 14,
    color: AppColors.textSecondary,
  );

  static const gaugeBadge = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 12,
    height: 16 / 12,
    letterSpacing: 0.6,
    color: AppColors.amber,
  );

  static const gaugeDescription = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 14,
    height: 20 / 14,
    color: AppColors.textBodySecondary,
  );

  static const metricCardLabel = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 12,
    height: 16 / 12,
    letterSpacing: -0.3,
    color: AppColors.textSecondary,
  );

  static const metricCardValue = TextStyle(
    fontWeight: FontWeight.w800,
    fontSize: 24,
    height: 32 / 24,
    color: AppColors.textPrimary,
  );

  static const metricCardUnit = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 14,
    height: 20 / 14,
    color: AppColors.textMuted,
  );

  static const metricCardStatus = TextStyle(fontWeight: FontWeight.w700, fontSize: 10, height: 15 / 10);

  static const tipTitle = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 14,
    height: 20 / 14,
    color: AppColors.textPrimary,
  );

  static const tipBody = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 12,
    height: 20 / 12,
    color: AppColors.textSecondary,
  );

  static const premiumTitle = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 18,
    height: 28 / 18,
    color: AppColors.white,
  );

  static const premiumBody = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 14,
    height: 20 / 14,
    color: AppColors.premiumBodyText,
  );

  // Scanner screen
  static const scannerHeading = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 24,
    height: 32 / 24,
    color: AppColors.textPrimary,
  );

  static const scannerSubtitle = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 16,
    height: 24 / 16,
    color: AppColors.textSecondary,
  );

  static const statusIndicatorLabel = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 12,
    height: 16 / 12,
    letterSpacing: 0.6,
    color: AppColors.textMuted,
  );

  static const statusIndicatorValue = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 14,
    height: 20 / 14,
    color: AppColors.textPrimary,
  );

  static const progressStepLabel = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 14,
    height: 20 / 14,
    letterSpacing: 1.4,
    color: AppColors.primary,
  );

  static const progressPercent = TextStyle(
    fontWeight: FontWeight.w900,
    fontSize: 24,
    height: 32 / 24,
    color: AppColors.primary,
  );

  static const progressCaption = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 14,
    height: 20 / 14,
    color: AppColors.textSecondary,
  );
}
