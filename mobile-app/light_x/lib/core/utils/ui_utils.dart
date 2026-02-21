import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UiUtils {
  static SystemUiOverlayStyle systemUiOverlayStyle(ThemeData theme) {
    return SystemUiOverlayStyle(
      systemNavigationBarColor: theme.scaffoldBackgroundColor,
      systemNavigationBarIconBrightness: theme.brightness == Brightness.dark ? Brightness.light : Brightness.dark,
      statusBarColor: theme.scaffoldBackgroundColor,
      statusBarIconBrightness: theme.brightness == Brightness.dark ? Brightness.light : Brightness.dark,
    );
  }
}
