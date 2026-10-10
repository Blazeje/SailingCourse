import 'package:flutter_test/flutter_test.dart';

import 'package:sailing_course/shared/quiz/data/card_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
      'GIVEN Polish locale WHEN loading navigation cards THEN 12 cards are returned',
      () async {
    // GIVEN: a navigation repository set to Polish.
    final repo = CardRepository(languageCode: 'pl', assetModule: 'navigation');

    // WHEN: cards are loaded.
    final cards = await repo.loadCards();

    // THEN: the full navigation deck loads.
    expect(cards.length, 12);
  });

  test(
      'GIVEN English locale WHEN loading navigation cards THEN 12 cards are returned',
      () async {
    // GIVEN: a navigation repository set to English.
    final repo = CardRepository(languageCode: 'en', assetModule: 'navigation');

    // WHEN: cards are loaded.
    final cards = await repo.loadCards();

    // THEN: the full navigation deck loads.
    expect(cards.length, 12);
  });

  test(
      'GIVEN navigation cards WHEN inspected THEN they are text-only with a valid correct answer',
      () async {
    // GIVEN: the English navigation deck.
    final repo = CardRepository(languageCode: 'en', assetModule: 'navigation');

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
      'GIVEN both locales WHEN compared THEN navigation cards share ids and correct answers',
      () async {
    // GIVEN: the Polish and English navigation decks.
    final pl =
        await CardRepository(languageCode: 'pl', assetModule: 'navigation')
            .loadCards();
    final en =
        await CardRepository(languageCode: 'en', assetModule: 'navigation')
            .loadCards();

    // THEN: both decks stay in sync by id and correct index.
    expect(pl.map((c) => c.id), en.map((c) => c.id));
    for (var i = 0; i < pl.length; i++) {
      expect(pl[i].correctIndex, en[i].correctIndex);
    }
  });
}
