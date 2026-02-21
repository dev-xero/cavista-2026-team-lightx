import 'package:flutter/material.dart';

class BuildIconButton extends StatelessWidget {
  final bool useNormalPadding;
  final void Function() onPressed;
  final Widget icon;
  final String? tooltip;
  final Color? color;
  const BuildIconButton({
    super.key,
    this.useNormalPadding = false,
    required this.onPressed,
    required this.icon,
    this.tooltip,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final button = IconButton(
      onPressed: onPressed,
      icon: icon,
      tooltip: tooltip,
      style: ButtonStyle(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        // fixedSize: buttonSizeState,
        maximumSize: const WidgetStatePropertyAll(Size.square(72)),
        minimumSize: const WidgetStatePropertyAll(Size.square(8)),
        padding: WidgetStatePropertyAll(EdgeInsets.all(useNormalPadding ? 12 : 4)),
        backgroundColor: color != null ? WidgetStatePropertyAll(color) : null,
      ),
    );
    return button;
  }
}
