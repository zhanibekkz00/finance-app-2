import 'dart:ui';
import 'package:flutter/material.dart';

class GradientBorderPainter extends CustomPainter {
  final double borderRadius;
  final double width;
  final LinearGradient gradient;

  GradientBorderPainter({
    required this.borderRadius,
    required this.width,
    required this.gradient,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final RRect rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..strokeWidth = width
      ..style = PaintingStyle.stroke;

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant GradientBorderPainter oldDelegate) {
    return oldDelegate.borderRadius != borderRadius ||
        oldDelegate.width != width ||
        oldDelegate.gradient != gradient;
  }
}

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double padding;
  final double borderRadius;
  final double blur;
  final LinearGradient? borderGradient;
  final Color? backgroundColor;

  const GlassContainer({
    super.key,
    required this.child,
    this.padding = 20.0,
    this.borderRadius = 20.0,
    this.blur = 16.0,
    this.borderGradient,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final defaultGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white.withOpacity(0.15),
        Colors.white.withOpacity(0.02),
        Colors.white.withOpacity(0.05),
        Colors.white.withOpacity(0.15),
      ],
      stops: const [0.0, 0.4, 0.6, 1.0],
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: CustomPaint(
          foregroundPainter: GradientBorderPainter(
            borderRadius: borderRadius,
            width: 1.0,
            gradient: borderGradient ?? defaultGradient,
          ),
          child: Container(
            padding: EdgeInsets.all(padding),
            decoration: BoxDecoration(
              color: backgroundColor ?? Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
