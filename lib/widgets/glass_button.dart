import 'dart:ui';
import 'package:flutter/material.dart';

class InnerShadowPainter extends CustomPainter {
  final double borderRadius;
  final Color shadowColor;
  final double blurRadius;
  final Offset offset;

  InnerShadowPainter({
    required this.borderRadius,
    required this.shadowColor,
    required this.blurRadius,
    required this.offset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    canvas.clipRRect(rrect);

    final paint = Paint()
      ..color = shadowColor
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blurRadius)
      ..style = PaintingStyle.stroke
      ..strokeWidth = blurRadius * 2;

    canvas.translate(offset.dx, offset.dy);
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant InnerShadowPainter oldDelegate) {
    return oldDelegate.borderRadius != borderRadius ||
        oldDelegate.shadowColor != shadowColor ||
        oldDelegate.blurRadius != blurRadius ||
        oldDelegate.offset != offset;
  }
}

class GlassButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final double borderRadius;
  final double padding;

  const GlassButton({
    super.key,
    required this.child,
    required this.onTap,
    this.borderRadius = 16.0,
    this.padding = 16.0,
  });

  @override
  State<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
          child: CustomPaint(
            foregroundPainter: _isPressed
                ? InnerShadowPainter(
                    borderRadius: widget.borderRadius,
                    shadowColor: Colors.black.withOpacity(0.5),
                    blurRadius: 4.0,
                    offset: const Offset(2, 2),
                  )
                : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              padding: EdgeInsets.all(widget.padding),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                border: Border.all(
                  color: Colors.white.withOpacity(_isPressed ? 0.03 : 0.08),
                  width: 1.0,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _isPressed
                      ? [
                          Colors.black.withOpacity(0.15),
                          Colors.black.withOpacity(0.05),
                        ]
                      : [
                          Colors.white.withOpacity(0.05),
                          Colors.white.withOpacity(0.01),
                        ],
                ),
              ),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
