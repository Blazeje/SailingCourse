import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/quiz_card.dart';
import '../models/scene_element.dart';

/// Draws the card scene: lights at night or day shapes (port of SceneView.kt).
class ScenePainter extends CustomPainter {
  final QuizCard card;

  ScenePainter(this.card);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final unit = math.min(w, h);

    _drawBackground(canvas, w, h);

    final waterY = h * 0.72;
    _drawSeaAndHull(canvas, w, h, waterY, unit);

    final mastElems =
        card.elements.where((e) => (e.x - 0.5).abs() < 0.05).toList();
    if (mastElems.isNotEmpty) {
      final topY =
          mastElems.map((e) => e.y).reduce(math.min) * h - unit * 0.05;
      final mastPaint = Paint()
        ..color = card.isDay
            ? const Color(0xFF4A4A55)
            : const Color(0xFF33363F)
        ..strokeWidth = unit * 0.012
        ..style = PaintingStyle.stroke;
      canvas.drawLine(
        Offset(w * 0.5, waterY),
        Offset(w * 0.5, topY),
        mastPaint,
      );
    }

    for (final e in card.elements) {
      if (e.kind == ElementKind.light) {
        _drawLight(canvas, e, w, h, unit);
      } else {
        _drawShape(canvas, e, w, h, unit);
      }
    }
  }

  void _drawBackground(Canvas canvas, double w, double h) {
    final Color top;
    final Color bottom;
    if (card.isDay) {
      top = const Color(0xFF8FC7EA);
      bottom = const Color(0xFFDDEEF7);
    } else {
      top = const Color(0xFF05070F);
      bottom = const Color(0xFF111A2E);
    }
    final rect = Rect.fromLTWH(0, 0, w, h);
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [top, bottom],
      ).createShader(rect);
    canvas.drawRect(rect, paint);
  }

  void _drawSeaAndHull(
      Canvas canvas, double w, double h, double waterY, double unit) {
    final waterPaint = Paint()
      ..color =
          card.isDay ? const Color(0xFF2E6F9E) : const Color(0xFF0A1122)
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTRB(0, waterY, w, h), waterPaint);

    final hullTop = waterY - unit * 0.02;
    final hullBottom = waterY + unit * 0.06;
    final path = Path()
      ..moveTo(w * 0.28, hullTop)
      ..lineTo(w * 0.72, hullTop)
      ..lineTo(w * 0.66, hullBottom)
      ..lineTo(w * 0.34, hullBottom)
      ..close();
    final hullPaint = Paint()
      ..color =
          card.isDay ? const Color(0xFF2B2F3A) : const Color(0xFF1B2030)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, hullPaint);
  }

  void _drawLight(
      Canvas canvas, SceneElement e, double w, double h, double unit) {
    final cx = e.x * w;
    final cy = e.y * h;
    final r = unit * 0.030 * e.sizeScale;
    final center = Offset(cx, cy);

    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          e.color.withAlpha(150),
          e.color.withAlpha(0),
        ],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: r * 3.2))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, r * 3.2, glowPaint);

    canvas.drawCircle(center, r, Paint()..color = e.color);
    canvas.drawCircle(
      center,
      r * 0.45,
      Paint()..color = Colors.white.withAlpha(200),
    );
  }

  void _drawShape(
      Canvas canvas, SceneElement e, double w, double h, double unit) {
    final cx = e.x * w;
    final cy = e.y * h;
    final s = unit * 0.075 * e.sizeScale;
    final paint = Paint()
      ..color = e.color
      ..style = PaintingStyle.fill;

    switch (e.kind) {
      case ElementKind.ball:
        canvas.drawCircle(Offset(cx, cy), s, paint);
        break;
      case ElementKind.coneUp:
        final path = Path()
          ..moveTo(cx, cy - s)
          ..lineTo(cx + s, cy + s)
          ..lineTo(cx - s, cy + s)
          ..close();
        canvas.drawPath(path, paint);
        break;
      case ElementKind.coneDown:
        final path = Path()
          ..moveTo(cx, cy + s)
          ..lineTo(cx + s, cy - s)
          ..lineTo(cx - s, cy - s)
          ..close();
        canvas.drawPath(path, paint);
        break;
      case ElementKind.diamond:
        final path = Path()
          ..moveTo(cx, cy - s * 1.2)
          ..lineTo(cx + s * 0.85, cy)
          ..lineTo(cx, cy + s * 1.2)
          ..lineTo(cx - s * 0.85, cy)
          ..close();
        canvas.drawPath(path, paint);
        break;
      case ElementKind.cylinder:
        canvas.drawRect(
          Rect.fromLTRB(cx - s * 0.7, cy - s, cx + s * 0.7, cy + s),
          paint,
        );
        canvas.drawOval(
          Rect.fromLTRB(
              cx - s * 0.7, cy - s - s * 0.18, cx + s * 0.7, cy - s + s * 0.18),
          paint,
        );
        canvas.drawOval(
          Rect.fromLTRB(
              cx - s * 0.7, cy + s - s * 0.18, cx + s * 0.7, cy + s + s * 0.18),
          paint,
        );
        break;
      case ElementKind.light:
        break;
    }
  }

  @override
  bool shouldRepaint(covariant ScenePainter oldDelegate) =>
      oldDelegate.card.id != card.id;
}
