import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final EdgeInsetsGeometry padding;

  const AppLogo({
    super.key,
    this.size = 48,
    this.padding = const EdgeInsets.all(4),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Padding(
        padding: padding,
        child: Image.asset(
          'assets/images/network_doctor_logo.png',
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}