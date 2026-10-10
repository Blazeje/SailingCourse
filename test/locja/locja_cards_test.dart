import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sailing_course/modules/locja/painters/mark_painter.dart';
import 'package:sailing_course/shared/quiz/data/card_repository.dart';
import 'package:sailing_course/shared/quiz/models/quiz_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
      'GIVEN Polish locale WHEN loading pilotage cards THEN 14 cards are returned',
      () async {
    // GIVEN: a pilotage repository set to Polish.
    final repo = CardRepository(languageCode: 'pl', assetModule: 'locja');

    // WHEN: cards are loaded.
    final cards = await repo.loadCards();

    // THEN: the full pilotage deck loads.
    expect(cards.length, 14);
  });

  test(
      'GIVEN English locale WHEN loading pilotage cards THEN 14 cards are returned',
      () async {
    // GIVEN: a pilotage repository set to English.
    final repo = CardRepository(languageCode: 'en', assetModule: 'locja');

    // WHEN: cards are loaded.
    final cards = await repo.loadCards();

    // THEN: the full pilotage deck loads.
    expect(cards.length, 14);
  });

  test(
      'GIVEN pilotage cards WHEN inspected THEN each is well formed',
      () async {
    // GIVEN: the English pilotage deck.
    final repo = CardRepository(languageCode: 'en', assetModule: 'locja');

    // WHEN: cards are loaded.
    final cards = await repo.loadCards();

    // THEN: every card has three options and a valid correct answer.
    for (final card in cards) {
      expect(card.options.length, 3);
      expect(card.correctIndex, inInclusiveRange(0, 2));
      expect(card.explanation, isNotEmpty);
    }
  });

  test(
      'GIVEN cards carrying a scene WHEN mapped THEN each scene id is a known mark type',
      () async {
    // GIVEN: the English pilotage deck.
    final repo = CardRepository(languageCode: 'en', assetModule: 'locja');

    // WHEN: cards are loaded.
    final cards = await repo.loadCards();

    // THEN: every scene string resolves to a valid mark type.
    final sceneCards = cards.where((c) => c.scene != null).toList();
    expect(sceneCards, isNotEmpty);
    for (final card in sceneCards) {
      expect(card.hasScene, true);
      expect(MarkType.fromId(card.scene), isNotNull);
    }
  });

  test(
      'GIVEN both locales WHEN compared THEN pilotage cards share ids, answers and scenes',
      () async {
    // GIVEN: the Polish and English pilotage decks.
    final pl = await CardRepository(languageCode: 'pl', assetModule: 'locja')
        .loadCards();
    final en = await CardRepository(languageCode: 'en', assetModule: 'locja')
        .loadCards();

    // THEN: both decks stay in sync by id, correct index and scene.
    expect(pl.map((c) => c.id), en.map((c) => c.id));
    for (var i = 0; i < pl.length; i++) {
      expect(pl[i].correctIndex, en[i].correctIndex);
      expect(pl[i].scene, en[i].scene);
    }
  });

  test(
      'GIVEN every mark type WHEN painted THEN the painter renders without throwing',
      () {
    // GIVEN: an id for every known mark type.
    const ids = [
      'lateral_port',
      'lateral_starboard',
      'cardinal_north',
      'cardinal_east',
      'cardinal_south',
      'cardinal_west',
      'isolated_danger',
      'safe_water',
      'special_mark',
    ];

    for (final id in ids) {
      // WHEN: a card with that scene is painted onto a canvas.
      final card = QuizCard(
        id: 't',
        question: 'q',
        options: const ['a', 'b', 'c'],
        correctIndex: 0,
        explanation: 'e',
        scene: id,
      );
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      // THEN: painting completes without error.
      expect(
        () => MarkPainter(card).paint(canvas, const Size(200, 300)),
        returnsNormally,
      );
    }
  });
}
