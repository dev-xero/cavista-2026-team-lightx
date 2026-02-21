import 'package:flutter/material.dart';

class AppText extends StatelessWidget {
  final String data;
  final TextStyle? style;
  final double? fontSize;
  final FontWeight fontWeight;
  final Color? color;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final bool? softWrap;
  final double? height;
  final double? letterSpacing;
  const AppText(
    this.data, {
    super.key,
    this.style,
    this.fontSize,
    this.fontWeight = FontWeight.normal,
    this.color,
    this.textAlign,
    this.overflow,
    this.softWrap,
    this.height,
    this.letterSpacing,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      textAlign: textAlign,
      overflow: overflow,
      softWrap: softWrap,
      style:
          style ??
          Theme.of(context).textTheme.labelMedium?.copyWith(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: color,
            fontFamily: 'Manrope',
            height: height,
            letterSpacing: letterSpacing,
          ),
    );
  }
}
