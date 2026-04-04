import 'package:flutter/material.dart';

class AppPageTransitionTheme {}

class CustomPageTransitionBuilder extends PageTransitionsBuilder {
  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Define your custom transition here. For example, a fade transition:
    return FadeTransition(opacity: animation, child: child);
  }
}
