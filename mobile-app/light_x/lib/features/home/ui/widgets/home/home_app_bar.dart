import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:light_x/core/constants/constants.dart';
import 'package:light_x/routes/app_router.dart';
import 'package:light_x/shared/components/buttons/build_icon_button.dart';
import 'package:light_x/shared/components/layout/app_padding.dart';
import 'package:light_x/shared/components/layout/app_text.dart';
import 'package:light_x/shared/helpers/extensions/extensions.dart';
import 'package:light_x/shared/helpers/formatter.dart';
import 'package:light_x/shared/theme/src/app_colors.dart';
import 'package:remixicon/remixicon.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: ColoredBox(
          color: context.scaffoldBackgroundColor.withValues(alpha: 0.92),
          child: TopPadding(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Routes.pricing.push(context);
                    },
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.primary,
                      child: Icon(Icons.person_rounded, color: Colors.white),
                    ),
                  ),
                  12.inRow,
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        final f = Formatter.getGreetingAndDate();
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(f.greeting, fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                            AppText(f.date, fontSize: 12, color: AppColors.neutralBlack200),
                          ],
                        );
                      },
                    ),
                  ),
                  SizedBox.square(
                    dimension: 36,
                    child: BuildIconButton(
                      onPressed: () {},
                      icon: const Icon(RemixIcons.notification_2_line, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
