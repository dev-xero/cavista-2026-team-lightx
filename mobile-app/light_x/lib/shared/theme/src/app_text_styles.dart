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

  // White variant of messageBody
  static TextStyle get messageBodyWhite => messageBody.copyWith(color: AppColors.white);

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

  static const navLabel = TextStyle(fontWeight: FontWeight.w700, fontSize: 10, height: 15 / 10);

  // navLabel variant with custom color
  static TextStyle get sleepBadge => navLabel.copyWith(color: AppColors.sleepBadgeTxt);

  // navLabel variant with custom color
  static TextStyle get highlightBadge => navLabel.copyWith(letterSpacing: 1, color: AppColors.white);

  static const connBadge = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 12,
    height: 16 / 12,
    letterSpacing: 0.6,
    color: AppColors.connectedText,
  );

  static const syncValue = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 30,
    height: 36 / 30,
    color: AppColors.textPrimary,
  );

  static const syncTitle = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 18,
    height: 28 / 18,
    color: AppColors.textPrimary,
  );

  // syncTitle variant in white
  static TextStyle get premiumTitleWhite => syncTitle.copyWith(color: AppColors.white);

  static const syncSubtitle = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 14,
    height: 20 / 14,
    color: AppColors.textSecondary,
  );

  // Aliases — same shape, same colour
  static TextStyle get progressCaption_ => syncSubtitle; // identical to progressCaption
  static TextStyle get planPeriod => syncSubtitle; // identical shape & colour
  static TextStyle get ctaNote_ => syncSubtitle; // close enough if desired

  static const statLabel = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 14,
    height: 20 / 14,
    color: AppColors.textSecondary,
  );

  static const statValue = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 24,
    height: 32 / 24,
    color: AppColors.textPrimary,
  );

  static const statUnit = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 12,
    height: 16 / 12,
    color: AppColors.textMuted,
  );

  static const statProgress = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 12,
    height: 16 / 12,
    color: AppColors.primary,
  );

  static TextStyle get savingsBadge => statProgress; // same style
  static TextStyle get faqLabel => statProgress.copyWith(color: AppColors.primary); // already primary — direct alias ok

  static const syncBtnLabel = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 16,
    height: 24 / 16,
    color: AppColors.white,
  );

  static TextStyle get ctaPrimary => syncBtnLabel;

  static const heroTitle = TextStyle(
    fontWeight: FontWeight.w800,
    fontSize: 30,
    height: 36 / 30,
    letterSpacing: -0.75,
    color: AppColors.textPrimary,
    textBaseline: TextBaseline.alphabetic,
  );

  static final heroSubtitle = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 18,
    height: 29 / 18,
    color: AppColors.bodyText,
  );

  static const planName = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 20,
    height: 28 / 20,
    color: AppColors.textPrimary,
  );

  static const planPrice = TextStyle(
    fontWeight: FontWeight.w900,
    fontSize: 36,
    height: 40 / 36,
    color: AppColors.textPrimary,
  );

  static final featureBasic = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 16,
    height: 24 / 16,
    color: AppColors.bodyText,
  );

  static const featurePremium = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 16,
    height: 24 / 16,
    color: AppColors.textPrimary,
  );

  static const ctaDisabled = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 14,
    height: 20 / 14,
    color: AppColors.textMuted,
  );

  static const ctaNote = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 10,
    height: 15 / 10,
    color: AppColors.textSecondary,
  );

  static const trustHeading = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 14,
    height: 20 / 14,
    letterSpacing: 1.4,
    color: AppColors.textMuted,
  );

  static const trustTitle = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 16,
    height: 24 / 16,
    color: AppColors.textPrimary,
  );

  static const trustBody = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 14,
    height: 23 / 14,
    color: AppColors.textSecondary,
  );
}
