import 'scene_element.dart';

/// Card category: lights (night) or day shapes.
enum CardCategory {
  lights,
  shapes;

  static CardCategory fromJson(String value) {
    switch (value.toLowerCase()) {
      case 'lights':
        return CardCategory.lights;
      case 'shapes':
        return CardCategory.shapes;
      default:
        throw ArgumentError('Nieznana kategoria: $value');
    }
  }

  String get label => this == CardCategory.lights ? 'Światła' : 'Znaki dzienne';
}

/// Quiz card: scene + question + three A/B/C answers.
class QuizCard {
  final String id;
  final CardCategory category;
  final bool isDay;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final List<SceneElement> elements;

  const QuizCard({
    required this.id,
    required this.category,
    required this.isDay,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    required this.elements,
  });

  String get correctText => options[correctIndex];

  factory QuizCard.fromJson(Map<String, dynamic> json) {
    return QuizCard(
      id: json['id'] as String,
      category: CardCategory.fromJson(json['category'] as String),
      isDay: json['isDay'] as bool,
      question: json['question'] as String,
      options: (json['options'] as List).map((e) => e as String).toList(),
      correctIndex: json['correctIndex'] as int,
      explanation: json['explanation'] as String? ?? '',
      elements: (json['elements'] as List)
          .map((e) => SceneElement.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Returns a copy with shuffled answers (updates correctIndex).
  QuizCard shuffledOptions() {
    final correct = options[correctIndex];
    final shuffled = List<String>.from(options)..shuffle();
    return QuizCard(
      id: id,
      category: category,
      isDay: isDay,
      question: question,
      options: shuffled,
      correctIndex: shuffled.indexOf(correct),
      explanation: explanation,
      elements: elements,
    );
  }
}
