import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:light_x/core/assets/assets.gen.dart';
import 'package:light_x/core/base/src/absorber.dart';
import 'package:light_x/core/constants/constants.dart';
import 'package:light_x/features/onboarding/providers/onboarding_providers.dart';
import 'package:light_x/routes/app_router.dart';
import 'package:light_x/shared/components/buttons/app_back_button.dart';
import 'package:light_x/shared/components/buttons/app_button.dart';
import 'package:light_x/shared/components/indicators/app_linear_progress_indicator.dart';
import 'package:light_x/shared/components/inputs/app_text_form_field.dart';
import 'package:light_x/shared/components/layout/app_scaffold.dart';
import 'package:light_x/shared/components/layout/app_text.dart';
import 'package:light_x/shared/components/layout/texts.dart';
import 'package:light_x/shared/helpers/extensions/extensions.dart';
import 'package:light_x/shared/theme/src/app_colors.dart';

part '../widgets/onboarding_2/__metric_input.dart';
part '../widgets/onboarding_2/__gender_card.dart';
part '../widgets/onboarding_2/__onboarding_2.dart';

class Onboarding2 extends StatefulWidget {
  const Onboarding2({super.key});

  @override
  State<Onboarding2> createState() => _Onboarding2State();
}

class _Onboarding2State extends State<Onboarding2> {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AbsorberRead(
      listenable: OnboardingProviders.asPro,
      builder: (_, p, _, _) {
        return AppScaffold(
          leading: AppBackButton(),
          title: Center(child: AppTexts.pageAppBarTitleText("WELCOME", fontWeight: FontWeight.bold)),
          trailing: const SizedBox(width: 48),
          appBarPadding: (p) => p.copyWith(left: 16, right: 16, top: p.top - 8, bottom: 16),

          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(textTheme)),
              36.inSliverColumn,
              SliverToBoxAdapter(child: _buildGenderSelection(p)),
              36.inSliverColumn,
              SliverToBoxAdapter(child: _buildBodyMetrics()),
              36.inSliverColumn,
              SliverToBoxAdapter(child: _buildLifestyleSection(p)),
              16.inSliverColumn,
              SliverToBoxAdapter(child: _DiabeticToggleRow(value: false, onChanged: (value) {})),

              40.inSliverColumn,
            ],
          ),

          footer: Consumer(
            builder: (context, ref, _) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                    child: AppButton(
                      label: "Continue",
                      trailing: Icon(Icons.arrow_right_alt, color: Colors.white, size: 20),
                      onPressed: () {
                        Routes.home.push(context);
                        OnboardingProviders.asPro.read(ref).completeOnboarding();
                      },
                      size: const Size(double.infinity, 56),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
