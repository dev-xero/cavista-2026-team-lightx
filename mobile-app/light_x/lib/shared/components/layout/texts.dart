import 'package:flutter/material.dart';
import 'package:light_x/shared/components/layout/app_text.dart';
import 'package:light_x/shared/theme/src/app_colors.dart';

class AppTexts {
  static Widget pageAppBarTitleText(String title, {double? fontSize, FontWeight? fontWeight}) {
    return AppText(
      title,
      fontSize: fontSize ?? 18,
      fontWeight: fontWeight ?? FontWeight.w600,
      color: AppColors.neutralBlack500,
    );
  }

  static Widget headerTitleText(String title) {
    return AppText(title, fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.neutralBlack500);
  }

  static Widget compulsoryTitleText(String title) {
    const defaultTextStyle = TextStyle(
      fontSize: 14, // 0.875rem
      height: 1.429, // 1.25rem / 0.875rem
      fontWeight: FontWeight.w500,
      color: AppColors.neutralBlack900,
    );
    return Align(
      alignment: Alignment.centerLeft,
      child: RichText(
        text: TextSpan(
          text: title,
          style: defaultTextStyle,
          children: [
            TextSpan(
              text: "*",
              style: defaultTextStyle.copyWith(color: AppColors.red500),
            ),
          ],
        ),
      ),
    );
  }
}
