import 'package:flutter/material.dart';
import 'package:mlimi/constants/trending_theme.dart';

class GlassPill extends StatelessWidget {
  final String label;
  final Color? textColor;
  final Color? backgroundColor;
  final bool uppercase;

  const GlassPill({
    super.key,
    required this.label,
    this.textColor,
    this.backgroundColor,
    this.uppercase = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: backgroundColor != null
          ? BoxDecoration(
              color: backgroundColor!.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(999),
            )
          : TrendingTheme.glass(),
      child: Text(
        uppercase ? label.toUpperCase() : label,
        style: TrendingTheme.labelSm(color: textColor ?? Colors.white).copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: uppercase ? 1.2 : 0.3,
          fontSize: uppercase ? 10 : 11,
        ),
      ),
    );
  }
}
