import 'package:flutter_test/flutter_test.dart';

import 'package:sailing_course/shared/quiz/data/card_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
      'GIVEN Polish locale WHEN loading meteo cards THEN 12 cards are returned',
      () async {
    // GIVEN: a meteo repository set to Polish.
    final repo = CardRepository(languageCode: 'pl', assetModule: 'meteo');

    // WHEN: cards are loaded.
    final cards = await repo.loadCards();

    // THEN: the full meteo deck loads.
    expect(cards.length, 12);
  });

  test(
      'GIVEN English locale WHEN loading meteo cards THEN 12 cards are returned',
      () async {
    // GIVEN: a meteo repository set to English.
    final repo = CardRepository(languageCode: 'en', assetModule: 'meteo');

    // WHEN: cards are loaded.
    final cards = await repo.loadCards();

    // THEN: the full meteo deck loads.
    expect(cards.length, 12);
  });

  test(
      'GIVEN meteo cards WHEN inspected THEN they are text-only with a valid correct answer',
      () async {
    // GIVEN: the English meteo deck.
    final repo = CardRepository(languageCode: 'en', assetModule: 'meteo');

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
      'GIVEN both locales WHEN compared THEN meteo cards share ids and correct answers',
      () async {
    // GIVEN: the Polish and English meteo decks.
    final pl = await CardRepository(languageCode: 'pl', assetModule: 'meteo')
        .loadCards();
    final en = await CardRepository(languageCode: 'en', assetModule: 'meteo')
        .loadCards();

    // THEN: both decks stay in sync by id and correct index.
    expect(pl.map((c) => c.id), en.map((c) => c.id));
    for (var i = 0; i < pl.length; i++) {
      expect(pl[i].correctIndex, en[i].correctIndex);
    }
  });
}
