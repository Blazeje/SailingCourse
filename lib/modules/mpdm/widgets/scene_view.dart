import 'package:flutter/material.dart';
import '../models/quiz_card.dart';
import '../painters/scene_painter.dart';

/// Widget that draws the quiz card scene.
class SceneView extends StatelessWidget {
  final QuizCard card;

  const SceneView({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 240, maxHeight: 240),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: 1,
            child: CustomPaint(
              painter: ScenePainter(card),
              size: Size.infinite,
            ),
          ),
        ),
      ),
    );
  }
}
