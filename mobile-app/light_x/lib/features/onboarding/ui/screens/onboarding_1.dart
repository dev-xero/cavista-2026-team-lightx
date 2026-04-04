import 'package:flutter/material.dart';
import 'package:light_x/core/base/src/absorber.dart';
import 'package:light_x/core/constants/constants.dart';
import 'package:light_x/core/utils/app_logger.dart';
import 'package:light_x/features/onboarding/providers/onboarding_providers.dart';
import 'package:light_x/routes/app_router.dart';
import 'package:light_x/shared/components/buttons/app_button.dart';
import 'package:light_x/shared/components/indicators/app_linear_progress_indicator.dart';
import 'package:light_x/shared/components/layout/app_text.dart';
import 'package:light_x/shared/theme/src/app_colors.dart';
import 'package:light_x/shared/components/layout/app_padding.dart';
import 'package:light_x/shared/components/layout/app_scaffold.dart';
import 'package:light_x/shared/components/layout/texts.dart';
import 'package:light_x/shared/helpers/extensions/extensions.dart';

part '../widgets/onboarding_1/__option_card.dart';
part '../widgets/onboarding_1/__header_progress_bar.dart';

class Onboarding1 extends StatelessWidget {
  const Onboarding1({super.key});

  @override
  Widget build(BuildContext context) {
    return AbsorberRead(
      listenable: OnboardingProviders.asPro,
      builder: (_, p, _, _) {
        return AppScaffold(
          leading: const SizedBox.shrink(),
          // title: Center(child: AppTexts.pageAppBarTitleText("WELCOME", fontWeight: FontWeight.bold)),
          // trailing: const SizedBox(width: 48),
          appBarPadding: (p) => p.copyWith(left: 16, right: 16),
          extendBodyBehindAppBar: true,

          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 72,
                  child: Center(child: AppTexts.pageAppBarTitleText("WELCOME", fontWeight: FontWeight.bold)),
                ),
              ),
              PinnedHeaderSliver(child: _HeaderProgressBar(progress: 0.2)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: AppTexts.pageAppBarTitleText(
                    "How many hours do you sleep per day?",
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: AbsorberWatch(
                  listenable: p.onboarding1,
                  builder: (context, state, ref, _) {
                    final options = ref.read(p.onboarding1.notifier).options;
                    final selected = state.sleepOptionIndex;

                    return Column(
                      children: List.generate(options.length, (index) {
                        final option = options[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _OptionCard(
                            title: option.title,
                            subtitle: option.subtitle,
                            isSelected: selected == index,
                            onTap: () {
                              p.onboarding1.self(ref).setSleepOptionIndex(index);
                              AppLogger.d("Selected sleep option index: $index, title: ${option.title}");
                            },
                          ),
                        );
                      }),
                    );
                  },
                ),
              ),

              40.inSliverColumn,
              SliverToBoxAdapter(child: BottomPadding()),
            ],
          ),
          footer: Column(
            children: [
              AppButton(
                label: "Continue",
                onPressed: () {
                  Routes.onboarding2.push(context);
                },
              ),
              8.inColumn,
              SizedBox(
                height: 36,
                child: Center(child: AppText("Skip for now", color: AppColors.blackGray)),
              ),
            ],
          ),
        );
      },
    );
  }
}
