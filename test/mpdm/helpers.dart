import 'package:sailing_course/shared/quiz/models/quiz_card.dart';
import 'package:sailing_course/shared/quiz/models/scene_element.dart';

/// Test card factory (no scene elements - irrelevant to the logic under test).
QuizCard buildCard({
  String id = 'c1',
  CardCategory category = CardCategory.lights,
  bool isDay = false,
  List<String> options = const ['Correct', 'Wrong 1', 'Wrong 2'],
  int correctIndex = 0,
  String explanation = 'Explanation',
}) {
  return QuizCard(
    id: id,
    category: category,
    isDay: isDay,
    question: 'Question $id',
    options: options,
    correctIndex: correctIndex,
    explanation: explanation,
    elements: const <SceneElement>[],
  );
}
