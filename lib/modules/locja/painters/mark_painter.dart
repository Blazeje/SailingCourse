import 'package:flutter/material.dart';

import '../../../shared/quiz/models/quiz_card.dart';

/// Supported IALA (Region A) mark scenes, keyed by [QuizCard.scene].
enum MarkType {
  lateralPort,
  lateralStarboard,
  cardinalNorth,
  cardinalEast,
  cardinalSouth,
  cardinalWest,
  isolatedDanger,
  safeWater,
  specialMark;

  static MarkType? fromId(String? id) {
    switch (id) {
      case 'lateral_port':
        return MarkType.lateralPort;
      case 'lateral_starboard':
        return MarkType.lateralStarboard;
      case 'cardinal_north':
        return MarkType.cardinalNorth;
      case 'cardinal_east':
        return MarkType.cardinalEast;
      case 'cardinal_south':
        return MarkType.cardinalSouth;
      case 'cardinal_west':
        return MarkType.cardinalWest;
      case 'isolated_danger':
        return MarkType.isolatedDanger;
      case 'safe_water':
        return MarkType.safeWater;
      case 'special_mark':
        return MarkType.specialMark;
      default:
        return null;
    }
  }
}

/// Draws a canonical IALA (Region A) buoy/beacon from [QuizCard.scene].
///
/// Each mark is rendered as a floating body (its colour scheme) with the
/// matching topmark above it.
class MarkPainter extends CustomPainter {
  static const _red = Color(0xFFD5342A);
  static const _green = Color(0xFF1F9E4B);
  static const _yellow = Color(0xFFF3C400);
  static const _black = Color(0xFF1B1C20);
  static const _white = Color(0xFFF7F7F7);

  final QuizCard card;

  MarkPainter(this.card);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    _drawBackground(canvas, w, h);

    final type = MarkType.fromId(card.scene);
    if (type == null) return;

    final waterY = h * 0.80;
    final bodyBottom = waterY;
    final bodyHeight = h * 0.36;
    final bodyTop = bodyBottom - bodyHeight;
    final cx = w * 0.5;

    _drawMark(canvas, type, cx, bodyTop, bodyBottom, w, h);
    _drawWaterline(canvas, w, h, waterY);
  }

  void _drawBackground(Canvas canvas, double w, double h) {
    final rect = Rect.fromLTWH(0, 0, w, h);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFBDE3F5), Color(0xFFE8F4FB)],
        ).createShader(rect),
    );
  }

  void _drawWaterline(Canvas canvas, double w, double h, double waterY) {
    canvas.drawRect(
      Rect.fromLTRB(0, waterY, w, h),
      Paint()..color = const Color(0x552E6F9E),
    );
    canvas.drawLine(
      Offset(0, waterY),
      Offset(w, waterY),
      Paint()
        ..color = const Color(0xFF2E6F9E)
        ..strokeWidth = h * 0.006,
    );
  }

  void _drawMark(
    Canvas canvas,
    MarkType type,
    double cx,
    double bodyTop,
    double bodyBottom,
    double w,
    double h,
  ) {
    final bodyWidth = w * 0.26;
    switch (type) {
      case MarkType.lateralPort:
        _drawCanBody(canvas, cx, bodyTop, bodyBottom, bodyWidth, [_red]);
        _drawCanTopmark(canvas, cx, bodyTop, w, h, _red);
        break;
      case MarkType.lateralStarboard:
        _drawConeBody(canvas, cx, bodyTop, bodyBottom, bodyWidth, _green);
        _drawConeTopmark(canvas, cx, bodyTop, w, h, _green, up: true);
        break;
      case MarkType.cardinalNorth:
        _drawPillarBody(
            canvas, cx, bodyTop, bodyBottom, bodyWidth, [_black, _yellow]);
        _drawDoubleCone(canvas, cx, bodyTop, w, h, _black,
            topUp: true, bottomUp: true);
        break;
      case MarkType.cardinalSouth:
        _drawPillarBody(
            canvas, cx, bodyTop, bodyBottom, bodyWidth, [_yellow, _black]);
        _drawDoubleCone(canvas, cx, bodyTop, w, h, _black,
            topUp: false, bottomUp: false);
        break;
      case MarkType.cardinalEast:
        _drawPillarBody(canvas, cx, bodyTop, bodyBottom, bodyWidth,
            [_black, _yellow, _black]);
        _drawDoubleCone(canvas, cx, bodyTop, w, h, _black,
            topUp: true, bottomUp: false);
        break;
      case MarkType.cardinalWest:
        _drawPillarBody(canvas, cx, bodyTop, bodyBottom, bodyWidth,
            [_yellow, _black, _yellow]);
        _drawDoubleCone(canvas, cx, bodyTop, w, h, _black,
            topUp: false, bottomUp: true);
        break;
      case MarkType.isolatedDanger:
        _drawPillarBody(canvas, cx, bodyTop, bodyBottom, bodyWidth,
            [_black, _red, _black]);
        _drawDoubleBall(canvas, cx, bodyTop, w, h, _black);
        break;
      case MarkType.safeWater:
        _drawPillarBodyVertical(
            canvas, cx, bodyTop, bodyBottom, bodyWidth, _red, _white);
        _drawBall(canvas, cx, bodyTop - h * 0.10, w, h, _red);
        break;
      case MarkType.specialMark:
        _drawPillarBody(canvas, cx, bodyTop, bodyBottom, bodyWidth, [_yellow]);
        _drawCross(canvas, cx, bodyTop, w, h, _yellow);
        break;
    }
  }

  // ----------------------------- Bodies ------------------------------------

  void _drawCanBody(Canvas canvas, double cx, double top, double bottom,
      double bw, List<Color> bands) {
    final rect = Rect.fromLTRB(cx - bw / 2, top, cx + bw / 2, bottom);
    final path = Path()
      ..addRRect(RRect.fromRectAndCorners(rect,
          topLeft: const Radius.circular(4), topRight: const Radius.circular(4)));
    _fillHorizontalBands(canvas, path, rect, bands);
    _outline(canvas, path);
  }

  void _drawConeBody(Canvas canvas, double cx, double top, double bottom,
      double bw, Color color) {
    final path = Path()
      ..moveTo(cx, top)
      ..lineTo(cx + bw / 2, bottom)
      ..lineTo(cx - bw / 2, bottom)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
    _outline(canvas, path);
  }

  void _drawPillarBody(Canvas canvas, double cx, double top, double bottom,
      double bw, List<Color> bands) {
    final rect = Rect.fromLTRB(cx - bw / 2, top, cx + bw / 2, bottom);
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(6)));
    _fillHorizontalBands(canvas, path, rect, bands);
    _outline(canvas, path);
  }

  void _drawPillarBodyVertical(Canvas canvas, double cx, double top,
      double bottom, double bw, Color a, Color b) {
    final rect = Rect.fromLTRB(cx - bw / 2, top, cx + bw / 2, bottom);
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(6)));
    canvas.save();
    canvas.clipPath(path);
    const stripes = 4;
    final sw = rect.width / stripes;
    for (var i = 0; i < stripes; i++) {
      canvas.drawRect(
        Rect.fromLTRB(
            rect.left + i * sw, rect.top, rect.left + (i + 1) * sw, rect.bottom),
        Paint()..color = i.isEven ? a : b,
      );
    }
    canvas.restore();
    _outline(canvas, path);
  }

  void _fillHorizontalBands(
      Canvas canvas, Path clip, Rect rect, List<Color> bands) {
    canvas.save();
    canvas.clipPath(clip);
    final bh = rect.height / bands.length;
    for (var i = 0; i < bands.length; i++) {
      canvas.drawRect(
        Rect.fromLTRB(
            rect.left, rect.top + i * bh, rect.right, rect.top + (i + 1) * bh),
        Paint()..color = bands[i],
      );
    }
    canvas.restore();
  }

  void _outline(Canvas canvas, Path path) {
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = const Color(0x33000000),
    );
  }

  // ----------------------------- Topmarks ----------------------------------

  void _spindle(Canvas canvas, double cx, double bodyTop, double h) {
    canvas.drawRect(
      Rect.fromLTRB(cx - h * 0.008, bodyTop - h * 0.06, cx + h * 0.008, bodyTop),
      Paint()..color = _black,
    );
  }

  void _cone(Canvas canvas, double cx, double cy, double s, Color color,
      {required bool up}) {
    final path = Path();
    if (up) {
      path
        ..moveTo(cx, cy - s)
        ..lineTo(cx + s, cy + s)
        ..lineTo(cx - s, cy + s)
        ..close();
    } else {
      path
        ..moveTo(cx, cy + s)
        ..lineTo(cx + s, cy - s)
        ..lineTo(cx - s, cy - s)
        ..close();
    }
    canvas.drawPath(path, Paint()..color = color);
  }

  void _drawConeTopmark(Canvas canvas, double cx, double bodyTop, double w,
      double h, Color color,
      {required bool up}) {
    _spindle(canvas, cx, bodyTop, h);
    final s = w * 0.07;
    _cone(canvas, cx, bodyTop - h * 0.06 - s, s, color, up: up);
  }

  void _drawDoubleCone(Canvas canvas, double cx, double bodyTop, double w,
      double h, Color color,
      {required bool topUp, required bool bottomUp}) {
    _spindle(canvas, cx, bodyTop, h);
    final s = w * 0.06;
    final gap = s * 0.15;
    final bottomCy = bodyTop - h * 0.06 - s;
    final topCy = bottomCy - 2 * s - gap;
    _cone(canvas, cx, topCy, s, color, up: topUp);
    _cone(canvas, cx, bottomCy, s, color, up: bottomUp);
  }

  void _drawCanTopmark(
      Canvas canvas, double cx, double bodyTop, double w, double h, Color color) {
    _spindle(canvas, cx, bodyTop, h);
    final cw = w * 0.11;
    final ch = h * 0.10;
    final cy = bodyTop - h * 0.06 - ch;
    canvas.drawRect(
      Rect.fromLTRB(cx - cw / 2, cy, cx + cw / 2, cy + ch),
      Paint()..color = color,
    );
  }

  void _ballAt(Canvas canvas, double cx, double cy, double r, Color color) {
    canvas.drawCircle(Offset(cx, cy), r, Paint()..color = color);
  }

  void _drawBall(
      Canvas canvas, double cx, double cy, double w, double h, Color color) {
    _spindle(canvas, cx, cy + h * 0.10, h);
    _ballAt(canvas, cx, cy, w * 0.06, color);
  }

  void _drawDoubleBall(
      Canvas canvas, double cx, double bodyTop, double w, double h, Color color) {
    _spindle(canvas, cx, bodyTop, h);
    final r = w * 0.055;
    final bottomCy = bodyTop - h * 0.06 - r;
    final topCy = bottomCy - 2 * r - r * 0.5;
    _ballAt(canvas, cx, bottomCy, r, color);
    _ballAt(canvas, cx, topCy, r, color);
  }

  void _drawCross(
      Canvas canvas, double cx, double bodyTop, double w, double h, Color color) {
    _spindle(canvas, cx, bodyTop, h);
    final s = w * 0.07;
    final cy = bodyTop - h * 0.06 - s;
    final paint = Paint()
      ..color = color
      ..strokeWidth = w * 0.03
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
        Offset(cx - s, cy - s), Offset(cx + s, cy + s), paint);
    canvas.drawLine(
        Offset(cx + s, cy - s), Offset(cx - s, cy + s), paint);
  }

  @override
  bool shouldRepaint(covariant MarkPainter oldDelegate) =>
      oldDelegate.card.scene != card.scene;
}
