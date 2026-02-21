import 'package:flutter/material.dart';

class AppBackButton extends StatelessWidget {
  final void Function()? onPressed;
  const AppBackButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Icon(Icons.arrow_back_ios, color: Colors.black),
    );
  }
}
