// Reusable glassmorphic surface used throughout Smart Heritage:
// frosted-glass cards, overlays, and panels.
//
// No extra dependencies required beyond Flutter's dart:ui (for
// BackdropFilter / ImageFilter.blur).

import 'dart:ui';
import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.blurSigma = 20,
    this.tintColor = Colors.white,
    this.tintOpacity = 0.7,
    this.borderColor,
    this.padding,
    this.margin,
    this.width,
    this.height,
  });

  final Widget child;
  final BorderRadius borderRadius;
  final double blurSigma;
  final Color tintColor;
  final double tintOpacity;
  final Color? borderColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: tintColor.withOpacity(tintOpacity),
              borderRadius: borderRadius,
              border: Border.all(
                color: borderColor ?? Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}