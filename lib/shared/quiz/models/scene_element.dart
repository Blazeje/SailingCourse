import 'dart:ui';

/// Rodzaj elementu rysowanego na scenie.
enum ElementKind {
  light,
  ball,
  coneUp,
  coneDown,
  diamond,
  cylinder;

  static ElementKind fromJson(String value) {
    switch (value.toUpperCase()) {
      case 'LIGHT':
        return ElementKind.light;
      case 'BALL':
        return ElementKind.ball;
      case 'CONE_UP':
        return ElementKind.coneUp;
      case 'CONE_DOWN':
        return ElementKind.coneDown;
      case 'DIAMOND':
        return ElementKind.diamond;
      case 'CYLINDER':
        return ElementKind.cylinder;
      default:
        throw ArgumentError('Nieznany ElementKind: $value');
    }
  }
}

/// Color palette for lights and shapes (matches the original MPDM).
class Palette {
  static const Color red = Color(0xFFE8402A);
  static const Color green = Color(0xFF2ECC40);
  static const Color white = Color(0xFFFFF3C4);
  static const Color yellow = Color(0xFFFFD400);
  static const Color black = Color(0xFF15161A);

  static Color fromName(String name) {
    switch (name.toUpperCase()) {
      case 'RED':
        return red;
      case 'GREEN':
        return green;
      case 'WHITE':
        return white;
      case 'YELLOW':
        return yellow;
      case 'BLACK':
        return black;
      default:
        throw ArgumentError('Nieznany kolor: $name');
    }
  }
}

/// A single scene element. The x/y coordinates are normalized to 0..1.
class SceneElement {
  final double x;
  final double y;
  final ElementKind kind;
  final Color color;
  final double sizeScale;

  const SceneElement({
    required this.x,
    required this.y,
    required this.kind,
    required this.color,
    this.sizeScale = 1.0,
  });

  factory SceneElement.fromJson(Map<String, dynamic> json) {
    return SceneElement(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      kind: ElementKind.fromJson(json['kind'] as String),
      color: Palette.fromName(json['color'] as String),
      sizeScale: (json['sizeScale'] as num?)?.toDouble() ?? 1.0,
    );
  }
}
