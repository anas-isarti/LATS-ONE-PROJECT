import 'dart:math';
import 'package:flutter/material.dart';

class TheLastOneLogo extends StatelessWidget {
  final double size;
  const TheLastOneLogo({super.key, this.size = 150});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _LogoPainter()),
    );
  }
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final center = Offset(cx, cy);
    final radius = size.width / 2 * 0.88;

    // ── Clip all interior drawing to circle ──────────────────────────────
    canvas.save();
    final circlePath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius));
    canvas.clipPath(circlePath);

    // Left half — dark industry
    canvas.drawRect(
      Rect.fromLTWH(0, 0, cx, size.height),
      Paint()..color = const Color(0xFF1A1A1A),
    );
    // Right half — dark green ecology
    canvas.drawRect(
      Rect.fromLTWH(cx, 0, size.width, size.height),
      Paint()..color = const Color(0xFF1A3A1A),
    );

    // Factory chimneys (left side)
    _drawFactories(canvas, size);

    // Wind turbine + solar panel (right side)
    _drawGreenEnergy(canvas, size);

    // Vertical dividing line
    canvas.drawLine(
      Offset(cx, cy - radius),
      Offset(cx, cy + radius),
      Paint()
        ..color = const Color(0xFFFFD700)
        ..strokeWidth = size.width * 0.012,
    );

    // Lightning bolt (center)
    _drawBolt(canvas, size, center);

    canvas.restore();

    // ── Gold border (drawn outside clip so it sits on top) ────────────────
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = const Color(0xFFFFD700)
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.04,
    );
  }

  void _drawFactories(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF4A4A4A);
    final smokePaint = Paint()..color = const Color(0xFF777777).withValues(alpha: 0.5);
    final baseline = size.height * 0.82;
    final leftCx = size.width * 0.25;

    // Three chimneys
    final chimneys = [
      (leftCx - size.width * 0.10, size.width * 0.055, size.height * 0.24),
      (leftCx - size.width * 0.03, size.width * 0.065, size.height * 0.30),
      (leftCx + size.width * 0.04, size.width * 0.05, size.height * 0.20),
    ];

    for (final (x, w, h) in chimneys) {
      canvas.drawRect(
        Rect.fromLTWH(x - w / 2, baseline - h, w, h),
        paint,
      );
      // Smoke puff
      canvas.drawCircle(
        Offset(x, baseline - h - size.width * 0.03),
        size.width * 0.028,
        smokePaint,
      );
    }

    // Factory base bar
    canvas.drawRect(
      Rect.fromLTWH(leftCx - size.width * 0.17, baseline,
          size.width * 0.3, size.height * 0.04),
      paint,
    );
  }

  void _drawGreenEnergy(Canvas canvas, Size size) {
    final rightCx = size.width * 0.75;
    final baseline = size.height * 0.82;

    // Wind turbine
    _drawWindTurbine(canvas, size, Offset(rightCx - size.width * 0.07, baseline));

    // Solar panel
    _drawSolarPanel(canvas, size, Offset(rightCx + size.width * 0.06, baseline));
  }

  void _drawWindTurbine(Canvas canvas, Size size, Offset base) {
    final color = const Color(0xFF66BB6A);
    final strokePaint = Paint()
      ..color = color
      ..strokeWidth = size.width * 0.016
      ..strokeCap = StrokeCap.round;

    final mastH = size.height * 0.27;
    final hub = Offset(base.dx, base.dy - mastH);

    // Mast
    canvas.drawLine(base, hub, strokePaint);

    // 3 blades
    final bladeLen = size.width * 0.075;
    for (int i = 0; i < 3; i++) {
      final angle = (i * 2 * pi / 3) - pi / 2;
      canvas.drawLine(
        hub,
        Offset(hub.dx + bladeLen * cos(angle), hub.dy + bladeLen * sin(angle)),
        strokePaint,
      );
    }

    // Hub dot
    canvas.drawCircle(hub, size.width * 0.02, Paint()..color = color);
  }

  void _drawSolarPanel(Canvas canvas, Size size, Offset base) {
    final paint = Paint()..color = const Color(0xFF4CAF50);
    final panelW = size.width * 0.11;
    final panelH = size.height * 0.065;
    final panelY = base.dy - size.height * 0.18;

    // Panel rectangle
    canvas.drawRect(
      Rect.fromCenter(center: Offset(base.dx, panelY), width: panelW, height: panelH),
      paint,
    );
    // Grid lines
    final gridPaint = Paint()
      ..color = const Color(0xFF1A3A1A)
      ..strokeWidth = size.width * 0.008;
    canvas.drawLine(
      Offset(base.dx, panelY - panelH / 2),
      Offset(base.dx, panelY + panelH / 2),
      gridPaint,
    );
    canvas.drawLine(
      Offset(base.dx - panelW / 2, panelY),
      Offset(base.dx + panelW / 2, panelY),
      gridPaint,
    );

    // Stand
    canvas.drawLine(
      Offset(base.dx, panelY + panelH / 2),
      base,
      Paint()
        ..color = const Color(0xFF66BB6A)
        ..strokeWidth = size.width * 0.014,
    );
  }

  void _drawBolt(Canvas canvas, Size size, Offset center) {
    final paint = Paint()..color = const Color(0xFFFFD700);
    final bh = size.height * 0.38;
    final bw = size.width * 0.10;

    final path = Path()
      ..moveTo(center.dx + bw * 0.35, center.dy - bh * 0.5)
      ..lineTo(center.dx - bw * 0.05, center.dy - bh * 0.02)
      ..lineTo(center.dx + bw * 0.20, center.dy - bh * 0.02)
      ..lineTo(center.dx - bw * 0.35, center.dy + bh * 0.5)
      ..lineTo(center.dx + bw * 0.05, center.dy + bh * 0.02)
      ..lineTo(center.dx - bw * 0.20, center.dy + bh * 0.02)
      ..close();

    // Subtle glow
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFFFD700).withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_LogoPainter oldDelegate) => false;
}
