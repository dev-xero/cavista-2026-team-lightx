import 'package:flutter/material.dart';
import 'package:light_x/shared/theme/src/app_colors.dart';

class StreamingCursor extends StatefulWidget {
  const StreamingCursor({super.key});

  @override
  State<StreamingCursor> createState() => _StreamingCursorState();
}

class _StreamingCursorState extends State<StreamingCursor> with SingleTickerProviderStateMixin {
  late final _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500))
    ..repeat(reverse: true);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _ctrl,
    child: Container(
      width: 2,
      height: 16,
      decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2)),
    ),
  );
}
