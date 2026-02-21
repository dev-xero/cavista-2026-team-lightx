import 'package:flutter/material.dart';
import 'package:light_x/shared/theme/src/app_colors.dart';

class AppLinearProgressIndicator extends StatelessWidget {
  final double progressFrom;
  final double progress;
  final Color? color;
  final double? minHeight;
  final bool isTiny;
  const AppLinearProgressIndicator._({
    super.key,
    this.progressFrom = 0.0,
    required this.progress,
    this.color,
    this.minHeight,
    required this.isTiny,
  });

  factory AppLinearProgressIndicator.tiny({
    Key? key,
    double progressFrom = 0.0,
    required double progress,
    Color? color,
  }) {
    return AppLinearProgressIndicator._(
      key: key,
      progressFrom: progressFrom,
      progress: progress,
      color: color,
      isTiny: true,
      minHeight: 6,
    );
  }

  factory AppLinearProgressIndicator.regular({
    Key? key,
    double progressFrom = 0.0,
    required double progress,
    Color? color,
    double? minHeight,
  }) {
    return AppLinearProgressIndicator._(
      key: key,
      progressFrom: progressFrom,
      progress: progress,
      color: color,
      minHeight: minHeight,
      isTiny: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return isTiny ? _buildTinyProgressIndicator() : _buildRegularProgressIndicator();
  }

  Widget _buildTinyProgressIndicator() {
    return TweenAnimationBuilder<double>(
      duration: Durations.medium1,
      curve: Curves.decelerate,
      tween: Tween(begin: progressFrom, end: progress),
      builder: (context, value, child) {
        return Stack(
          alignment: Alignment.centerLeft,
          children: [
            // Background
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const SizedBox(height: 4, width: double.infinity),
            ),
            // Progress
            FractionallySizedBox(
              widthFactor: value,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color ?? AppColors.primary, borderRadius: BorderRadius.circular(24)),
                child: const SizedBox(height: 6),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRegularProgressIndicator() {
    return SizedBox(
      height: 10,
      child: TweenAnimationBuilder<double>(
        duration: Durations.medium1,
        curve: Curves.decelerate,
        tween: Tween(begin: progressFrom, end: progress),
        builder: (context, value, child) {
          return LinearProgressIndicator(
            value: value,
            backgroundColor: AppColors.primary.withValues(alpha: 0.2),
            color: color ?? AppColors.primary,
            borderRadius: BorderRadius.circular(24),
            minHeight: minHeight ?? 10,
          );
        },
      ),
    );
  }
}
