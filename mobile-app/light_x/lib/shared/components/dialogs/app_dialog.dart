import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:light_x/routes/app_router.dart';
import 'package:light_x/shared/helpers/extensions/extensions.dart';

class AppDialog extends StatelessWidget {
  final Widget child;
  final Alignment? alignment;
  final Size? size;

  final Color backgroundColor;
  final void Function()? onTapOutside;
  final bool canPop;
  final bool isScrollable;
  const AppDialog({
    super.key,
    this.alignment,
    required this.child,
    this.backgroundColor = Colors.white,
    this.size,
    this.onTapOutside,
    this.canPop = true,
    this.isScrollable = false,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: canPop,
      child: Stack(
        alignment: alignment ?? Alignment.center,
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                if (onTapOutside != null) {
                  onTapOutside!();
                } else {
                  context.pop();
                }
              },
              // child: SizedBox.expand(),
            ),
          ),
          Positioned(
            left: 34,
            right: 34,
            bottom: alignment == Alignment.bottomCenter
                ? context.padding.bottom + 16.0
                : isScrollable
                ? 0
                : null,
            top: alignment == Alignment.topCenter
                ? context.padding.top + 16.0
                : isScrollable
                ? 0
                : null,
            child: isScrollable
                ? (alignment != null
                      ? Align(
                          alignment: alignment!,
                          child: SingleChildScrollView(child: _buildDialogContainer()),
                        )
                      : SingleChildScrollView(child: _buildDialogContainer()))
                : _buildDialogContainer(),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogContainer() {
    return AnimatedContainer(
          curve: CustomCurves.defaultIosSpring,
          duration: 500.inMs,
          clipBehavior: Clip.hardEdge,
          height: size?.height,
          width: size?.width,
          constraints: BoxConstraints(maxHeight: size?.height ?? 626, maxWidth: size?.width ?? 328, minHeight: 200),
          decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(12.0)),
          padding: EdgeInsets.symmetric(vertical: 36, horizontal: 30),
          child: child,
        )
        .animate()
        .scaleXY(
          begin: 0.9,
          alignment: Alignment.bottomCenter,
          duration: 500.inMs,
          curve: CustomCurves.defaultIosSpring,
        )
        .slideY(begin: 0.1, end: 0, duration: 500.inMs, curve: CustomCurves.defaultIosSpring);
  }
}
