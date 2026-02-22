import 'package:flutter/material.dart';
import 'package:light_x/shared/components/layout/app_scaffold.dart';
import 'package:light_x/shared/theme/src/app_colors.dart';
import 'package:light_x/shared/theme/src/app_text_styles.dart';

// ─────────────────────────────────────────────
// Hero Header
// ─────────────────────────────────────────────

/// Centred hero with an icon, headline, and subtitle.
class PricingHero extends StatelessWidget {
  final Widget icon;
  final String title;
  final String subtitle;

  const PricingHero({super.key, required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 32),
        icon,
        const SizedBox(height: 28),
        Text(title, textAlign: TextAlign.center, style: AppTextStyles.heroTitle),
        const SizedBox(height: 16),
        Text(subtitle, textAlign: TextAlign.center, style: AppTextStyles.heroSubtitle),
        const SizedBox(height: 32),
      ],
    );
  }
}

/// Data model for a single feature line item.
class PlanFeature {
  final String text;
  final bool included; // false → struck-through + dimmed
  final bool isPremium; // true → primary-blue check icon

  const PlanFeature(this.text, {this.included = true, this.isPremium = false});
}

class _FeatureRow extends StatelessWidget {
  final PlanFeature feature;

  const _FeatureRow({required this.feature});

  @override
  Widget build(BuildContext context) {
    final dimmed = !feature.included;
    final iconColor = feature.isPremium ? AppColors.primary : AppColors.textMuted;

    return Opacity(
      opacity: dimmed ? 0.4 : 1.0,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(
              feature.included ? Icons.check_circle_rounded : Icons.cancel_rounded,
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              feature.text,
              style: (feature.isPremium ? AppTextStyles.featurePremium : AppTextStyles.featureBasic).copyWith(
                decoration: dimmed ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Plan Cards
// ─────────────────────────────────────────────

/// Basic (free/lower-tier) plan card.
class BasicPlanCard extends StatelessWidget {
  final String name;
  final String price;
  final String period;
  final List<PlanFeature> features;
  final String ctaLabel;
  final VoidCallback? onTap;

  const BasicPlanCard({
    super.key,
    required this.name,
    required this.price,
    required this.period,
    required this.features,
    required this.ctaLabel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name + price
          Text(name, style: AppTextStyles.planName),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(price, style: AppTextStyles.planPrice),
              const SizedBox(width: 4),
              Text(period, style: AppTextStyles.planPeriod),
            ],
          ),
          const SizedBox(height: 32),

          // Features
          Column(
            children: features
                .map(
                  (f) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _FeatureRow(feature: f),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),

          // CTA (disabled style)
          GestureDetector(
            onTap: onTap,
            child: Container(
              height: 52,
              decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(16)),
              alignment: Alignment.center,
              child: Text(ctaLabel, style: AppTextStyles.ctaDisabled),
            ),
          ),
        ],
      ),
    );
  }
}

/// Featured (premium) plan card with highlight badge, savings note, and CTA.
class PremiumPlanCard extends StatelessWidget {
  final String name;
  final String price;
  final String period;
  final List<PlanFeature> features;
  final String badgeLabel; // e.g. "Most Popular"
  final String savingsLabel; // e.g. "Save 40% vs monthly"
  final String ctaLabel;
  final String ctaNote; // e.g. "Cancel anytime"
  final VoidCallback? onTap;

  const PremiumPlanCard({
    super.key,
    required this.name,
    required this.price,
    required this.period,
    required this.features,
    required this.badgeLabel,
    required this.savingsLabel,
    required this.ctaLabel,
    required this.ctaNote,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Card body
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.white,
            border: Border.all(color: AppColors.primary, width: 2),
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [BoxShadow(color: AppColors.featuredShadow, blurRadius: 20, spreadRadius: 0)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name row
              Row(
                children: [
                  Text(name, style: AppTextStyles.planName),
                  const SizedBox(width: 8),
                  const Icon(Icons.bolt_rounded, color: AppColors.primary, size: 14),
                ],
              ),
              const SizedBox(height: 8),

              // Price row
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(price, style: AppTextStyles.planPrice.copyWith(color: Colors.black)),
                  const SizedBox(width: 4),
                  Text(period, style: AppTextStyles.planPeriod),
                ],
              ),
              const SizedBox(height: 30),

              // Features
              Column(
                children: features
                    .map(
                      (f) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _FeatureRow(feature: f),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 12),

              // Savings label
              Center(child: Text(savingsLabel, style: AppTextStyles.savingsBadge)),
              const SizedBox(height: 12),

              // CTA button
              GestureDetector(
                onTap: onTap,
                child: Container(
                  height: 58,
                  decoration: BoxDecoration(
                    color: AppColors.navy,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(color: AppColors.primaryShadow, blurRadius: 15, offset: Offset(0, 10)),
                      BoxShadow(color: AppColors.primaryShadow, blurRadius: 6, offset: Offset(0, 4)),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(ctaLabel, style: AppTextStyles.ctaPrimary),
                ),
              ),
              const SizedBox(height: 12),

              // Cancel note
              Center(child: Text(ctaNote, style: AppTextStyles.ctaNote)),
            ],
          ),
        ),

        // Highlight badge (top-right, overlapping corner)
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: const BoxDecoration(
              color: AppColors.navy,
              borderRadius: BorderRadius.only(topRight: Radius.circular(22), bottomLeft: Radius.circular(16)),
            ),
            child: Text(badgeLabel.toUpperCase(), style: AppTextStyles.highlightBadge),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Trust Signal
// ─────────────────────────────────────────────

/// Data model for a single trust signal item.
class TrustSignal {
  final IconData icon;
  final String title;
  final String body;

  const TrustSignal({required this.icon, required this.title, required this.body});
}

/// Centred icon + title + body text trust signal item.
class AppTextStylesrustSignalItem extends StatelessWidget {
  final TrustSignal data;
  const AppTextStylesrustSignalItem({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
          child: Icon(data.icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(height: 16),
        Text(data.title, textAlign: TextAlign.center, style: AppTextStyles.trustTitle),
        const SizedBox(height: 8),
        Text(data.body, textAlign: TextAlign.center, style: AppTextStyles.trustBody),
      ],
    );
  }
}

/// Section with a category label and a vertical list of trust signals.
class TrustSignalsSection extends StatelessWidget {
  final String sectionLabel;
  final List<TrustSignal> signals;

  const TrustSignalsSection({super.key, required this.sectionLabel, required this.signals});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Divider
        const Divider(color: AppColors.border),
        const SizedBox(height: 32),

        // Section label
        Text(sectionLabel.toUpperCase(), style: AppTextStyles.trustHeading),
        const SizedBox(height: 40),

        // Trust items
        Column(
          children: signals
              .map(
                (s) => Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: AppTextStylesrustSignalItem(data: s),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// FAQ Teaser Row
// ─────────────────────────────────────────────

/// A simple "Still have questions?" CTA row that links to the FAQ.
class FaqTeaserRow extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const FaqTeaserRow({super.key, this.label = 'View all FAQs', this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 32),
      child: Center(
        child: GestureDetector(
          onTap: onTap,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: AppTextStyles.faqLabel),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_forward_rounded, color: AppColors.primary, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────

class PricingScreen extends StatelessWidget {
  const PricingScreen({super.key});

  static const _basicFeatures = [
    PlanFeature('1 Daily Scan'),
    PlanFeature('Basic health metrics'),
    PlanFeature('AI Health Insights', included: false),
    PlanFeature('Wearable integration', included: false),
  ];

  static const _premiumFeatures = [
    PlanFeature('Unlimited Daily Scans', isPremium: true),
    PlanFeature('Daily Summaries and Reminders', isPremium: true),
    PlanFeature('Send data to Medical professionals and Ward.', isPremium: true),
    PlanFeature('Advanced AI cardiovascular analysis', isPremium: true),
    PlanFeature('Find Verified Pharmacies Around You', isPremium: true),
  ];

  static const appTextStylesrustSignals = [
    TrustSignal(
      icon: Icons.lock_rounded,
      title: 'HIPAA Compliant',
      body:
          'Your health data is encrypted end-to-end and stored in compliance '
          'with HIPAA regulations.',
    ),
    TrustSignal(
      icon: Icons.verified_rounded,
      title: 'Clinically Validated',
      body:
          'Our algorithms are validated against clinical studies with '
          'over 50,000 data points.',
    ),
    TrustSignal(
      icon: Icons.wifi_off_rounded,
      title: 'Works Offline',
      body:
          'Core scanning features work without an internet connection and '
          'sync when you\'re back online.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      extendBodyBehindAppBar: true,
      appBarPadding: (apply) => apply.copyWith(bottom: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 128),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero
            PricingHero(
              icon: Container(
                width: 78,
                height: 78,
                decoration: BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
                child: const Icon(Icons.favorite_rounded, color: AppColors.primary, size: 36),
              ),
              title: 'Your Health,\nUpgraded',
              subtitle:
                  'Get unlimited access to AI-powered cardiovascular '
                  'health monitoring and personalised insights.',
            ),

            // Basic plan
            BasicPlanCard(
              name: 'Basic',
              price: 'Free',
              period: 'forever',
              features: _basicFeatures,
              ctaLabel: 'Current Plan',
              onTap: null,
            ),
            const SizedBox(height: 12),

            // Premium plan
            PremiumPlanCard(
              name: 'Premium',
              price: '₦7,999',
              period: '/ month',
              features: _premiumFeatures,
              badgeLabel: 'Most Popular',
              savingsLabel: 'Save 40% with annual billing',
              ctaLabel: 'Start 7-Day Free Trial',
              ctaNote: 'Cancel anytime · No commitment',
              onTap: () {},
            ),

            const SizedBox(height: 32),

            // Trust signals
            TrustSignalsSection(sectionLabel: 'Why thousands trust us', signals: appTextStylesrustSignals),

            // FAQ teaser
            FaqTeaserRow(label: 'View all FAQs', onTap: () {}),
          ],
        ),
      ),
    );
  }
}
