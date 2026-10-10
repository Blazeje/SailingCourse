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
        throw ArgumentError('Unknown category: $value');
    }
  }

  String get label =>
      this == CardCategory.lights ? 'Lights' : 'Day shapes';
}

/// Quiz card: an optional scene + question + three A/B/C answers.
///
/// Scene-based modules (e.g. MPDM lights & shapes) populate [elements];
/// text-only modules (e.g. rescue knowledge) leave them empty.
class QuizCard {
  final String id;
  final CardCategory? category;
  final bool isDay;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final List<SceneElement> elements;

  /// Optional named scene for modules that draw a canonical figure instead of
  /// free-form [elements] (e.g. an IALA mark id like `cardinal_north`).
  final String? scene;

  const QuizCard({
    required this.id,
    this.category,
    this.isDay = false,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    this.elements = const <SceneElement>[],
    this.scene,
  });

  String get correctText => options[correctIndex];

  /// Whether this card carries a drawable scene.
  bool get hasScene => elements.isNotEmpty || scene != null;

  factory QuizCard.fromJson(Map<String, dynamic> json) {
    final rawCategory = json['category'] as String?;
    return QuizCard(
      id: json['id'] as String,
      category: rawCategory != null ? CardCategory.fromJson(rawCategory) : null,
      isDay: json['isDay'] as bool? ?? false,
      question: json['question'] as String,
      options: (json['options'] as List).map((e) => e as String).toList(),
      correctIndex: json['correctIndex'] as int,
      explanation: json['explanation'] as String? ?? '',
      elements: (json['elements'] as List?)
              ?.map((e) => SceneElement.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <SceneElement>[],
      scene: json['scene'] as String?,
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
      scene: scene,
    );
  }
}
