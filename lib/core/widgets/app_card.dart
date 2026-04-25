import 'package:flutter/material.dart';
import 'package:figma_squircle/figma_squircle.dart';
import '../design_system/app_colors.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double cornerRadius;
  final double cornerSmoothing;
  final List<BoxShadow>? boxShadow;
  final Color? color;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.cornerRadius = 24.0,
    this.cornerSmoothing = 0.6,
    this.boxShadow,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final shape = SmoothRectangleBorder(
      borderRadius: SmoothBorderRadius(
        cornerRadius: cornerRadius,
        cornerSmoothing: cornerSmoothing,
      ),
    );

    return Container(
      margin: margin,
      decoration: ShapeDecoration(
        color: color ?? AppColors.surface,
        shadows: boxShadow ?? [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        shape: shape,
      ),
      child: Material(
        color: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        shape: shape,
        child: Padding(
          padding: padding ?? const EdgeInsets.all(20),
          child: child,
        ),
      ),
    );
  }
}
