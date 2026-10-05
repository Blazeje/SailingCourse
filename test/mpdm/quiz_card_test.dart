import 'package:flutter_test/flutter_test.dart';

import 'package:sailing_course/modules/mpdm/models/quiz_card.dart';
import 'package:sailing_course/modules/mpdm/models/scene_element.dart';

void main() {
  group('QuizCard.fromJson', () {
    test('GIVEN valid JSON WHEN parsing THEN fields and elements are read',
        () {
      // GIVEN: a raw card JSON.
      final json = {
        'id': 'n01',
        'category': 'lights',
        'isDay': false,
        'question': 'What vessel is this?',
        'options': ['A', 'B', 'C'],
        'correctIndex': 0,
        'explanation': 'because',
        'elements': [
          {'x': 0.3, 'y': 0.66, 'kind': 'LIGHT', 'color': 'RED'},
          {'x': 0.5, 'y': 0.3, 'kind': 'BALL', 'color': 'BLACK', 'sizeScale': 0.8},
        ],
      };

      // WHEN: parsing.
      final card = QuizCard.fromJson(json);

      // THEN: fields match the JSON.
      expect(card.id, 'n01');
      expect(card.category, CardCategory.lights);
      expect(card.isDay, false);
      expect(card.correctIndex, 0);
      expect(card.correctText, 'A');
      expect(card.elements.length, 2);
      expect(card.elements.first.kind, ElementKind.light);
      expect(card.elements.first.color, Palette.red);
      expect(card.elements[1].sizeScale, 0.8);
    });
  });

  group('QuizCard.shuffledOptions', () {
    test(
        'GIVEN a card WHEN shuffled THEN correct index still points to the same text',
        () {
      // GIVEN: a card whose correct answer is at index 0.
      final card = QuizCard(
        id: 'c1',
        category: CardCategory.lights,
        isDay: false,
        question: 'q',
        options: const ['Correct', 'Wrong 1', 'Wrong 2'],
        correctIndex: 0,
        explanation: '',
        elements: const <SceneElement>[],
      );

      // WHEN: shuffling many times.
      for (var i = 0; i < 20; i++) {
        final shuffled = card.shuffledOptions();

        // THEN: correctIndex always points to the 'Correct' text.
        expect(shuffled.options[shuffled.correctIndex], 'Correct');
        expect(shuffled.options.toSet(), card.options.toSet());
      }
    });
  });
}
