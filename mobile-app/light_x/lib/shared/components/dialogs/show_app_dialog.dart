import 'package:flutter/material.dart';

Future<void> showAppDialog(BuildContext context, {required Widget Function(BuildContext context) builder}) async =>
    await showDialog(
      context: context,
      fullscreenDialog: true,
      barrierColor: const Color(0x66252525),
      useSafeArea: false,
      builder: builder,
    );
