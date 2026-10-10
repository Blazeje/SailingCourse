import 'package:flutter/material.dart';
import '../models/quiz_card.dart';
import '../painters/scene_painter.dart';

/// Builds the [CustomPainter] used to render a card's scene. Modules can supply
/// their own (e.g. an IALA mark painter) instead of the default [ScenePainter].
typedef ScenePainterBuilder = CustomPainter Function(QuizCard card);

/// Widget that draws the quiz card scene.
class SceneView extends StatelessWidget {
  final QuizCard card;
  final ScenePainterBuilder? painterBuilder;

  const SceneView({super.key, required this.card, this.painterBuilder});

  @override
  Widget build(BuildContext context) {
    final builder = painterBuilder ?? (c) => ScenePainter(c);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 240, maxHeight: 240),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: 1,
            child: CustomPaint(
              painter: builder(card),
              size: Size.infinite,
            ),
          ),
        ),
      ),
    );
  }
}
