import 'package:flutter_test/flutter_test.dart';

import 'package:sailing_course/shared/quiz/data/card_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('GIVEN Polish locale WHEN loading rescue cards THEN 12 cards are returned',
      () async {
    // GIVEN: a rescue repository set to Polish.
    final repo = CardRepository(languageCode: 'pl', assetModule: 'rescue');

    // WHEN: cards are loaded.
    final cards = await repo.loadCards();

    // THEN: the full rescue deck loads.
    expect(cards.length, 12);
  });

  test('GIVEN English locale WHEN loading rescue cards THEN 12 cards are returned',
      () async {
    // GIVEN: a rescue repository set to English.
    final repo = CardRepository(languageCode: 'en', assetModule: 'rescue');

    // WHEN: cards are loaded.
    final cards = await repo.loadCards();

    // THEN: the full rescue deck loads.
    expect(cards.length, 12);
  });

  test(
      'GIVEN rescue cards WHEN inspected THEN they are text-only with a valid correct answer',
      () async {
    // GIVEN: the English rescue deck.
    final repo = CardRepository(languageCode: 'en', assetModule: 'rescue');

    // WHEN: cards are loaded.
    final cards = await repo.loadCards();

    // THEN: every card is text-only and well formed.
    for (final card in cards) {
      expect(card.hasScene, false);
      expect(card.options.length, 3);
      expect(card.correctIndex, inInclusiveRange(0, 2));
      expect(card.explanation, isNotEmpty);
    }
  });

  test(
      'GIVEN both locales WHEN compared THEN rescue cards share ids and correct answers',
      () async {
    // GIVEN: the Polish and English rescue decks.
    final pl =
        await CardRepository(languageCode: 'pl', assetModule: 'rescue')
            .loadCards();
    final en =
        await CardRepository(languageCode: 'en', assetModule: 'rescue')
            .loadCards();

    // THEN: both decks stay in sync by id and correct index.
    expect(pl.map((c) => c.id), en.map((c) => c.id));
    for (var i = 0; i < pl.length; i++) {
      expect(pl[i].correctIndex, en[i].correctIndex);
    }
  });
}
