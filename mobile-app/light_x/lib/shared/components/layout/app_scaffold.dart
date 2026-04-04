import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:light_x/core/constants/constants.dart';
import 'package:light_x/shared/components/buttons/app_back_button.dart';
import 'package:light_x/shared/components/indicators/app_circular_loading_indicator.dart';
import 'package:light_x/shared/helpers/extensions/extensions.dart';
import 'package:light_x/shared/theme/src/app_colors.dart';

class AppScaffold extends StatelessWidget {
  final bool extendBodyBehindAppBar;
  final bool extendBody;
  final Color? backgroundColor;
  final Color? appBarBackgroundColor;
  final bool? resizeToAvoidBottomInset;
  final Widget? appBar;
  final EdgeInsets Function(EdgeInsets apply)? appBarPadding;

  final Widget? title;
  final Widget? trailing;
  final Widget? leading;

  /// Won't work if [appBar] is provided
  final bool applyDefaultAppBar;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final SystemUiOverlayStyle? systemUiOverlayStyle;
  final bool canPop;
  final void Function(bool, dynamic)? onPopInvokedWithResult;
  final EdgeInsets? viewPadding;
  final void Function()? onBackButtonPressed;
  final Widget body;
  final Widget? footer;
  final bool isLoading;

  const AppScaffold({
    super.key,
    this.extendBodyBehindAppBar = false,
    this.appBarPadding,
    this.extendBody = false,
    this.backgroundColor,
    this.resizeToAvoidBottomInset,
    this.appBar,
    this.applyDefaultAppBar = true,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.systemUiOverlayStyle,
    this.canPop = true,
    this.onPopInvokedWithResult,
    this.viewPadding,
    this.title,
    this.trailing,
    this.leading,
    required this.body,
    this.onBackButtonPressed,
    this.appBarBackgroundColor,
    this.footer,
    this.isLoading = false,
  });

  Widget get _defaultAppBar => ColoredBox(
    color: appBarBackgroundColor ?? Colors.transparent,
    child: Row(
      mainAxisSize: MainAxisSize.max,
      spacing: 16,
      children: [
        leading ?? AppBackButton(onPressed: onBackButtonPressed),
        Expanded(child: title ?? const SizedBox()),
        if (trailing != null) trailing!,
      ],
    ),
  );

  Widget resolvedBody(BuildContext context) {
    final defaultPadding = context.padding.copyWith(left: Spacing.lg, right: Spacing.lg);
    return applyDefaultAppBar || appBar != null
        ? (extendBodyBehindAppBar
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    Padding(
                      padding: viewPadding ?? defaultPadding.copyWith(bottom: 24),
                      child: footer != null
                          ? Column(
                              children: [
                                Expanded(child: body),
                                if (!extendBody) ?footer,
                              ],
                            )
                          : body,
                    ),
                    Positioned(
                      top: 24,
                      left: 0,
                      right: 0,
                      child: Padding(
                        padding: appBarPadding != null
                            ? appBarPadding!(defaultPadding.copyWith(top: 24))
                            : defaultPadding.copyWith(top: 24),
                        child: appBar ?? _defaultAppBar,
                      ),
                    ),

                    if (extendBody && footer != null)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Padding(padding: defaultPadding.copyWith(bottom: 24, top: 0), child: footer!),
                      ),

                    if (isLoading) positionedLoadingIndicator(),
                  ],
                )
              : extendBody
              ? Stack(
                  children: [
                    buildNotExtendBodyBehindAppBar(defaultPadding),
                    if (footer != null) Positioned(bottom: 0, left: 0, right: 0, child: footer!),
                    if (isLoading) positionedLoadingIndicator(),
                  ],
                )
              : buildNotExtendBodyBehindAppBar(defaultPadding))
        : body;
  }

  @override
  Widget build(BuildContext context) {
    final resolvedBodyWidget = resolvedBody(context);
    return PopScope(
      canPop: canPop,
      onPopInvokedWithResult: onPopInvokedWithResult,
      child: AnnotatedRegion(
        // value: systemUiOverlayStyle ?? UiUtils.systemUiOverlayStyle(theme),
        value:
            systemUiOverlayStyle ??
            const SystemUiOverlayStyle(
              systemNavigationBarColor: AppColors.neutralWhite100,
              statusBarColor: AppColors.neutralWhite100,
            ),
        child: Scaffold(
          extendBodyBehindAppBar: extendBodyBehindAppBar,
          extendBody: extendBody,
          backgroundColor: backgroundColor,
          resizeToAvoidBottomInset: resizeToAvoidBottomInset,
          floatingActionButton: floatingActionButton,
          bottomNavigationBar: bottomNavigationBar,
          body: (isLoading && !((applyDefaultAppBar || appBar != null) && extendBodyBehindAppBar))
              ? Stack(fit: StackFit.expand, children: [resolvedBodyWidget, positionedLoadingIndicator()])
              : resolvedBodyWidget,
        ),
      ),
    );
  }

  Widget positionedLoadingIndicator() {
    return Positioned.fill(
      child: ColoredBox(
        color: Colors.black.withValues(alpha: 0.1),
        child: const AppCircularLoadingIndicator(),
      ).animate().fade(),
    );
  }

  Widget buildNotExtendBodyBehindAppBar(EdgeInsets defaultPadding) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
          padding: appBarPadding != null
              ? appBarPadding!(defaultPadding.copyWith(top: defaultPadding.top + 24, bottom: 24))
              : defaultPadding.copyWith(top: defaultPadding.top + 24, bottom: 24),
          child: appBar ?? _defaultAppBar,
        ),
        Flexible(
          child: Padding(padding: viewPadding ?? defaultPadding.copyWith(top: 0), child: body),
        ),

        if (!extendBody) ?footer,
      ],
    );
  }
}
