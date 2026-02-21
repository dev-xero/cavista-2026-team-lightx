import 'package:flutter/material.dart';
import 'package:light_x/core/constants/constants.dart';
import 'package:light_x/shared/components/layout/app_text.dart';
import 'package:light_x/shared/theme/src/app_colors.dart';

enum ButtonType { filled, outlined }

class AppButton extends StatelessWidget {
  /// Type can be [ButtonType.filled] or [ButtonType.outlined]
  final ButtonType type;

  /// Used for Semantics if [child] is provided
  final String label;

  /// These can be of type [Flexible], [Expanded] or [Widget] since they are placed in a Row internally
  final Widget? leading;
  final Widget? trailing;

  final double? labelSize;
  final Color? labelColor;

  /// Default Color -> [AppColors.primaryColorB600]
  final Color color;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;

  final double borderRadius;
  final Size? size;
  final EdgeInsets? padding;

  /// For Implicit Styling(Other properties like color will be ignored if provided)
  final ButtonStyle? style;
  final bool isLoading;

  final double? outlinedBorderWidth;
  final Color? overlayColor;

  /// [label], [leading] and [trailing] will be ignored if child is provided.
  final Widget? child;
  const AppButton({
    super.key,
    required this.label,
    this.leading,
    this.trailing,
    this.type = ButtonType.filled,
    this.color = AppColors.primary,
    this.borderRadius = 30,
    this.size,
    this.style,
    this.padding,
    required this.onPressed,
    this.onLongPress,
    this.child,
    this.labelSize,
    this.labelColor = AppColors.neutralWhite300,
    this.isLoading = false,
    this.outlinedBorderWidth,
    this.overlayColor,
  });

  Widget _defaultChild([Color? labelColor]) => FittedBox(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: Spacing.xs,
      children: [
        leading ?? const SizedBox.shrink(),
        AppText(
          label,
          fontSize: labelSize ?? 14,
          color: onPressed == null ? AppColors.neutralBlack300 : labelColor,
          fontWeight: FontWeight.w600,
        ),
        trailing ?? const SizedBox.shrink(),
      ],
    ),
  );
  Widget get _buildLoadingIndicator => SizedBox.square(
    dimension: 20,
    child: CircularProgressIndicator(strokeCap: StrokeCap.round, color: labelColor),
  );

  @override
  Widget build(BuildContext context) {
    return switch (type) {
      ButtonType.filled => ElevatedButton(
        onPressed: onPressed,
        onLongPress: onLongPress,
        style:
            style ??
            ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith((state) {
                if (state.contains(WidgetState.disabled)) return AppColors.neutralBlack200;
                return color;
              }),
              splashFactory: InkSparkle.splashFactory,
              overlayColor: WidgetStatePropertyAll(overlayColor ?? AppColors.primary.withValues(alpha: 0.1)),
              shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius))),
              // fixedSize: size ?? Size.fromHeight(50),
              maximumSize: WidgetStatePropertyAll(size ?? const Size.fromHeight(50)),
              minimumSize: WidgetStatePropertyAll(size ?? const Size.fromHeight(50)),
              padding: WidgetStatePropertyAll(padding),
              elevation: const WidgetStatePropertyAll(0.0),
            ),
        child: isLoading ? _buildLoadingIndicator : (child ?? _defaultChild(labelColor)),
      ),
      ButtonType.outlined => OutlinedButton(
        onPressed: onPressed,
        style:
            style ??
            OutlinedButton.styleFrom(
              overlayColor: overlayColor ?? AppColors.neutralBlack300,
              side: BorderSide(color: color, width: outlinedBorderWidth ?? 1.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                side: BorderSide(color: color),
              ),
              fixedSize: size ?? const Size.fromHeight(50),
              padding: padding,
              elevation: 0.0,
            ),
        child: isLoading ? _buildLoadingIndicator : (child ?? _defaultChild((labelColor ?? color))),
      ),
    };
  }
}
